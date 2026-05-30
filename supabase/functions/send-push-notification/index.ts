// Supabase Edge Function: send-push-notification
//
// Triggered by a Database Webhook on INSERT into public.notifications.
// Looks up the recipient's fcm_token, mints an OAuth2 access token from a
// Firebase service account, and POSTs to the FCM HTTP v1 API.
//
// Required secrets (set via `supabase secrets set ...`):
//   FIREBASE_PROJECT_ID         — your Firebase project id (e.g. "domora-app")
//   FIREBASE_SERVICE_ACCOUNT    — full service account JSON as a single line
//   SUPABASE_URL                — automatically set by Supabase
//   SUPABASE_SERVICE_ROLE_KEY   — automatically set by Supabase
//
// Setup steps (one-time):
//   1. Firebase Console → Project Settings → Service Accounts → Generate new
//      private key. Save the JSON.
//   2. `supabase secrets set FIREBASE_PROJECT_ID=<project_id>`
//      `supabase secrets set FIREBASE_SERVICE_ACCOUNT="$(cat path/to/key.json)"`
//   3. `supabase functions deploy send-push-notification`
//   4. Supabase Dashboard → Database → Webhooks → "Create a new hook":
//      • Table: notifications
//      • Events: INSERT
//      • Type: Supabase Edge Functions
//      • Edge Function: send-push-notification
//      • HTTP Headers: Authorization: Bearer <SUPABASE_SERVICE_ROLE_KEY>

import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

interface NotificationRow {
  id: string;
  user_id: string;
  type: string;
  title: string;
  message: string;
  related_service_id: string | null;
  related_quote_id: string | null;
  related_booking_id: string | null;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  record: NotificationRow;
  schema: string;
  old_record: NotificationRow | null;
}

interface ServiceAccount {
  client_email: string;
  private_key: string;
  token_uri: string;
}

// ---------------------------------------------------------------------------
// OAuth2 token cache (per-isolate). FCM HTTP v1 access tokens last ~1 hour.
// ---------------------------------------------------------------------------
let cachedToken: { token: string; expiresAt: number } | null = null;

async function getAccessToken(serviceAccount: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  if (cachedToken && cachedToken.expiresAt > now + 60) {
    return cachedToken.token;
  }

  // Import the PEM private key as a CryptoKey for RS256 signing.
  const pem = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const binaryDer = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: serviceAccount.client_email,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: serviceAccount.token_uri,
      exp: getNumericDate(60 * 60),
      iat: getNumericDate(0),
    },
    cryptoKey,
  );

  const tokenRes = await fetch(serviceAccount.token_uri, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenRes.ok) {
    throw new Error(`OAuth2 token exchange failed: ${tokenRes.status} ${await tokenRes.text()}`);
  }

  const body = await tokenRes.json() as { access_token: string; expires_in: number };
  cachedToken = {
    token: body.access_token,
    expiresAt: now + body.expires_in,
  };
  return body.access_token;
}

// ---------------------------------------------------------------------------
// Handler
// ---------------------------------------------------------------------------
Deno.serve(async (req) => {
  try {
    const payload: WebhookPayload = await req.json();

    if (payload.type !== "INSERT" || payload.table !== "notifications") {
      return new Response("ignored", { status: 200 });
    }

    const notification = payload.record;

    // Look up the recipient's FCM token using the service role (bypasses RLS).
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const { data: user, error: userErr } = await supabase
      .from("users")
      .select("fcm_token")
      .eq("id", notification.user_id)
      .maybeSingle();

    if (userErr) {
      console.error("user lookup failed", userErr);
      return new Response("user lookup failed", { status: 500 });
    }
    if (!user?.fcm_token) {
      // Recipient has no registered device — skip silently, this is normal.
      return new Response("no fcm_token, skipped", { status: 200 });
    }

    const projectId = Deno.env.get("FIREBASE_PROJECT_ID");
    const serviceAccountJson = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
    if (!projectId || !serviceAccountJson) {
      console.error("Missing FIREBASE_PROJECT_ID or FIREBASE_SERVICE_ACCOUNT");
      return new Response("server misconfigured", { status: 500 });
    }
    const serviceAccount: ServiceAccount = JSON.parse(serviceAccountJson);
    const accessToken = await getAccessToken(serviceAccount);

    const fcmRes = await fetch(
      `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          message: {
            token: user.fcm_token,
            notification: {
              title: notification.title,
              body: notification.message,
            },
            data: {
              type: notification.type,
              related_service_id: notification.related_service_id ?? "",
              related_quote_id: notification.related_quote_id ?? "",
              related_booking_id: notification.related_booking_id ?? "",
            },
            android: {
              priority: "HIGH",
              notification: { sound: "default" },
            },
          },
        }),
      },
    );

    if (!fcmRes.ok) {
      const errText = await fcmRes.text();
      console.error("FCM send failed", fcmRes.status, errText);

      // If the token is stale, drop it from the user row so we stop retrying.
      if (fcmRes.status === 404 || errText.includes("UNREGISTERED") || errText.includes("INVALID_ARGUMENT")) {
        await supabase
          .from("users")
          .update({ fcm_token: null })
          .eq("id", notification.user_id);
      }

      return new Response(`fcm send failed: ${errText}`, { status: 200 });
    }

    return new Response("sent", { status: 200 });
  } catch (e) {
    console.error("send-push-notification error", e);
    return new Response(`error: ${e}`, { status: 500 });
  }
});

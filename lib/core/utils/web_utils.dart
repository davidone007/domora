// Web-only utilities (uses dart:html). This file is imported conditionally
// via `web_utils_stub.dart` on non-web platforms.
import 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handle Supabase auth redirect fragments (e.g. #access_token=...)
/// Attempts to let the client parse the session (if supported) and
/// then removes the URL fragment so the router does not choke on it.
Future<void> handleAuthRedirectFragment(SupabaseClient client) async {
  try {
    final frag = Uri.base.fragment;
    if (frag.isEmpty) return;

    // Try to let Supabase parse session from URL if method exists.
    try {
      // Some versions of the client expose `getSessionFromUrl`/`getSessionFromUri`.
      final auth = client.auth;
      // Use dynamic invocation to avoid compile-time dependency on specific API.
      final dyn = auth as dynamic;
      if (dyn.getSessionFromUrl != null) {
        await dyn.getSessionFromUrl();
      }
    } catch (_) {
      // ignore - not all clients expose getSessionFromUrl
    }

    // Remove fragment to avoid router/assertion issues.
    final cleanUri = Uri.base.replace(fragment: '');
    html.window.history.replaceState(null, '', cleanUri.toString());
  } catch (e) {
    // Non-fatal; just log.
    // ignore: avoid_print
    print('⚠️ web_utils.handleAuthRedirectFragment failed: $e');
  }
}

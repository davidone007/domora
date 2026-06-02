-- Webhook trigger: calls the Edge Function whenever a notification row is inserted.
-- Uses pg_net (net.http_post) which is already enabled on this project.
--
-- SECURITY: replace the two placeholders below before running this migration:
--   <PROJECT_REF>               -> your Supabase project ref
--   <SUPABASE_SERVICE_ROLE_KEY> -> Project Settings > API > service_role key
-- Do NOT commit the real service_role key to source control.

CREATE OR REPLACE FUNCTION public.fn_send_push_notification_webhook()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  PERFORM net.http_post(
    url     := 'https://<PROJECT_REF>.functions.supabase.co/send-push-notification',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer <SUPABASE_SERVICE_ROLE_KEY>'
    ),
    body    := jsonb_build_object(
      'type',       'INSERT',
      'table',      'notifications',
      'schema',     'public',
      'record',     row_to_json(NEW)::jsonb,
      'old_record', NULL
    )
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_notification_insert ON public.notifications;
CREATE TRIGGER on_notification_insert
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_send_push_notification_webhook();

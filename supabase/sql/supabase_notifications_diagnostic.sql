-- ============================================================================
-- DOMORA - HU18 NOTIFICATIONS DIAGNOSTIC (read-only)
-- Run this in the Supabase SQL Editor to verify that the notification
-- automation is correctly installed. Safe to run anytime.
-- ============================================================================

-- 1. TRIGGERS: expect three rows
--    tr_new_service_notification     on public.services
--    tr_new_proposal_notification    on public.quotes
--    tr_booking_accepted_notification on public.bookings
SELECT
  tgname                           AS trigger_name,
  tgrelid::regclass                AS on_table,
  tgenabled                        AS enabled
FROM pg_trigger
WHERE tgname LIKE 'tr_%notification%'
ORDER BY tgname;

-- 2. TRIGGER FUNCTIONS: expect three rows
SELECT
  proname                          AS function_name,
  prosecdef                        AS security_definer
FROM pg_proc
WHERE proname IN (
  'handle_new_service_notification',
  'handle_new_proposal_notification',
  'handle_booking_accepted_notification'
)
ORDER BY proname;

-- 3. REALTIME PUBLICATION: expect notifications listed
SELECT schemaname, tablename
FROM pg_publication_tables
WHERE pubname = 'supabase_realtime'
  AND tablename = 'notifications';

-- 4. RLS POLICIES on public.notifications
SELECT policyname, cmd, qual
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'notifications'
ORDER BY policyname;

-- 5. fcm_token COLUMN on public.users
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'users'
  AND column_name = 'fcm_token';

-- 6. RECENT NOTIFICATIONS (last 10)
-- Note: under RLS this only shows rows where auth.uid() = user_id.
-- Run as the recipient (or as service_role) to inspect.
SELECT id, user_id, type, title, related_booking_id, is_read, created_at
FROM public.notifications
ORDER BY created_at DESC
LIMIT 10;

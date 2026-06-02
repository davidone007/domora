-- ============================================================================
-- DOMORA - NOTIFICATIONS TABLE RLS FOR HU18
-- Run this in the Supabase SQL Editor.
-- ============================================================================

alter table public.notifications enable row level security;

drop policy if exists "users_select_own_notifications" on public.notifications;
create policy "users_select_own_notifications" 
  on public.notifications 
  for select 
  to authenticated
  using (auth.uid() = user_id);

drop policy if exists "users_update_own_notifications" on public.notifications;
create policy "users_update_own_notifications" 
  on public.notifications 
  for update 
  to authenticated
  using (auth.uid() = user_id);

-- Dar permisos de acceso al rol de servicio
grant all on table public.notifications to service_role;
grant all on table public.notifications to authenticated;

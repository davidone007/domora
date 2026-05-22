-- ============================================================================
-- DOMORA - RPC FUNCTION FOR HU16
-- Run this in the Supabase SQL Editor to enable service completion logic.
-- This function updates both the booking and the service to 'completed'.
-- ============================================================================

create or replace function public.complete_booking(
  p_booking_id uuid,
  p_service_id uuid
) returns void as $$
begin
  -- 1. Actualizar el booking a completed
  update public.bookings 
  set 
    status = 'completed', 
    updated_at = now(), 
    completed_at = now() 
  where id = p_booking_id;

  -- 2. Actualizar el servicio a completed
  update public.services 
  set 
    status = 'completed', 
    updated_at = now() 
  where id = p_service_id;
end;
$$ language plpgsql security definer;

-- Permisos
grant execute on function public.complete_booking to authenticated;
grant execute on function public.complete_booking to service_role;

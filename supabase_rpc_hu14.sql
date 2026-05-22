-- ============================================================================
-- DOMORA - RPC FUNCTION FOR HU14
-- Run this in the Supabase SQL Editor to enable proposal acceptance logic.
-- This function ensures that booking creation and status updates are atomic.
-- ============================================================================

-- Eliminamos la versión anterior si existe para evitar errores de cambio de tipo de retorno
drop function if exists public.accept_quote(uuid, uuid, uuid, uuid, decimal);

create or replace function public.accept_quote(
  p_quote_id uuid,
  p_service_id uuid,
  p_client_id uuid,
  p_provider_id uuid,
  p_price decimal
) returns uuid as $$
declare
  v_booking_id uuid;
begin
  -- 1. Crear el booking
  insert into public.bookings (
    quote_id, 
    service_id, 
    client_id, 
    provider_id, 
    status, 
    final_price,
    created_at,
    updated_at
  )
  values (
    p_quote_id, 
    p_service_id, 
    p_client_id, 
    p_provider_id, 
    'pending', 
    p_price,
    now(),
    now()
  )
  returning id into v_booking_id;

  -- 2. Aceptar la propuesta actual
  update public.quotes 
  set 
    status = 'accepted', 
    updated_at = now() 
  where id = p_quote_id;

  -- 3. Rechazar las demás propuestas del mismo servicio que estén pendientes
  update public.quotes 
  set 
    status = 'rejected', 
    updated_at = now() 
  where service_id = p_service_id 
    and id <> p_quote_id
    and status = 'pending';

  -- 4. Actualizar estado del servicio a 'in_progress'
  update public.services 
  set 
    status = 'in_progress', 
    updated_at = now() 
  where id = p_service_id;

  return v_booking_id;
end;
$$ language plpgsql security definer;

-- Dar permisos de ejecución a usuarios autenticados
grant execute on function public.accept_quote to authenticated;
 grant execute on function public.accept_quote to service_role;

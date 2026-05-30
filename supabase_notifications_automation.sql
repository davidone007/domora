-- ============================================================================
-- DOMORA - AUTOMATED NOTIFICATIONS TRIGGERS (HU18-bis)
-- Run this in the Supabase SQL Editor.
-- ============================================================================

-- 0. ENABLE REALTIME FOR NOTIFICATIONS TABLE
-- ----------------------------------------------------------------------------
-- Required so that supabase_flutter .stream() receives live changes.
-- Wrapped in DO/EXCEPTION so re-runs don't abort the script with
-- "relation is already member of publication".
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
EXCEPTION WHEN duplicate_object THEN
  -- Already added, nothing to do.
  NULL;
END $$;

-- 0b. ADD fcm_token COLUMN TO users (for OS-level push via FCM)
-- ----------------------------------------------------------------------------
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS fcm_token text;

-- 1. NOTIFY PROVIDERS WHEN A NEW SERVICE IS PUBLISHED
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_service_notification()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert a notification for every user with the 'provider' role
  INSERT INTO public.notifications (user_id, type, title, message, related_service_id)
  SELECT 
    ur.user_id, 
    'new_service_available', 
    'Nuevo servicio disponible', 
    'Se ha publicado una nueva solicitud de ' || NEW.category || ': ' || NEW.title,
    NEW.id
  FROM public.user_roles ur
  JOIN public.roles r ON ur.role_id = r.id
  WHERE r.name = 'provider';
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_new_service_notification ON public.services;
CREATE TRIGGER tr_new_service_notification
AFTER INSERT ON public.services
FOR EACH ROW EXECUTE FUNCTION public.handle_new_service_notification();


-- 2. NOTIFY CLIENT WHEN A NEW PROPOSAL (QUOTE) IS RECEIVED
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_proposal_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_service_title TEXT;
  v_client_id UUID;
BEGIN
  -- Get service details (Using CORRECT column name: client_id)
  SELECT title, client_id INTO v_service_title, v_client_id 
  FROM public.services WHERE id = NEW.service_id;

  -- Insert notification for the client
  INSERT INTO public.notifications (user_id, type, title, message, related_service_id, related_quote_id)
  VALUES (
    v_client_id, 
    'proposal_received', 
    'Nueva propuesta recibida', 
    'Has recibido una cotización para tu servicio: ' || v_service_title, 
    NEW.service_id, 
    NEW.id
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_new_proposal_notification ON public.quotes;
CREATE TRIGGER tr_new_proposal_notification
AFTER INSERT ON public.quotes
FOR EACH ROW EXECUTE FUNCTION public.handle_new_proposal_notification();


-- 3. NOTIFY PROVIDER WHEN THEIR PROPOSAL IS ACCEPTED (BOOKING CREATED)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_booking_accepted_notification()
RETURNS TRIGGER AS $$
DECLARE
  service_title TEXT;
BEGIN
  -- Get service title
  SELECT title INTO service_title 
  FROM public.services WHERE id = NEW.service_id;

  -- Insert notification for the provider
  INSERT INTO public.notifications (user_id, type, title, message, related_service_id, related_booking_id)
  VALUES (
    NEW.provider_id, 
    'service_accepted', 
    '¡Propuesta aceptada!', 
    'Tu propuesta para "' || service_title || '" ha sido seleccionada.', 
    NEW.service_id, 
    NEW.id
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS tr_booking_accepted_notification ON public.bookings;
CREATE TRIGGER tr_booking_accepted_notification
AFTER INSERT ON public.bookings
FOR EACH ROW EXECUTE FUNCTION public.handle_booking_accepted_notification();

-- ---------------------------------------------------------------------------
-- Trigger 1: Notify the service owner when a provider submits a proposal
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_notify_proposal_received()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_client_id UUID;
  v_title     TEXT;
BEGIN
  SELECT client_id, title INTO v_client_id, v_title
  FROM services WHERE id = NEW.service_id;

  IF v_client_id IS NOT NULL THEN
    INSERT INTO notifications(user_id, type, title, message, related_service_id, related_quote_id)
    VALUES (
      v_client_id,
      'proposal_received',
      'Nueva propuesta recibida',
      'Un proveedor envió una propuesta para: ' || COALESCE(v_title, 'tu servicio'),
      NEW.service_id,
      NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_proposal_received ON quotes;
CREATE TRIGGER trg_notify_proposal_received
  AFTER INSERT ON quotes
  FOR EACH ROW EXECUTE FUNCTION fn_notify_proposal_received();

-- ---------------------------------------------------------------------------
-- Trigger 2: Notify the provider when their proposal is accepted
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_notify_service_accepted()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_title TEXT;
BEGIN
  IF NEW.status = 'accepted' AND (OLD.status IS DISTINCT FROM 'accepted') THEN
    SELECT title INTO v_title FROM services WHERE id = NEW.service_id;

    INSERT INTO notifications(user_id, type, title, message, related_service_id, related_quote_id)
    VALUES (
      NEW.provider_id,
      'service_accepted',
      'Tu propuesta fue aceptada',
      'El cliente aceptó tu propuesta para: ' || COALESCE(v_title, 'el servicio'),
      NEW.service_id,
      NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_service_accepted ON quotes;
CREATE TRIGGER trg_notify_service_accepted
  AFTER UPDATE ON quotes
  FOR EACH ROW EXECUTE FUNCTION fn_notify_service_accepted();

-- ---------------------------------------------------------------------------
-- Trigger 3: Notify the provider when the client confirms payment
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_notify_payment_confirmed()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_provider_id UUID;
  v_service_id  UUID;
  v_title       TEXT;
BEGIN
  SELECT b.provider_id, b.service_id INTO v_provider_id, v_service_id
  FROM bookings b WHERE b.id = NEW.booking_id;

  SELECT title INTO v_title FROM services WHERE id = v_service_id;

  IF v_provider_id IS NOT NULL THEN
    INSERT INTO notifications(user_id, type, title, message, related_service_id, related_booking_id)
    VALUES (
      v_provider_id,
      'payment_confirmed',
      'Pago confirmado',
      'El cliente realizó el pago para: ' || COALESCE(v_title, 'el servicio'),
      v_service_id,
      NEW.booking_id
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_payment_confirmed ON payments;
CREATE TRIGGER trg_notify_payment_confirmed
  AFTER INSERT ON payments
  FOR EACH ROW EXECUTE FUNCTION fn_notify_payment_confirmed();

-- ---------------------------------------------------------------------------
-- Trigger 4: Notify the client when the booking is marked completed
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION fn_notify_booking_completed()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_title TEXT;
BEGIN
  IF NEW.status = 'completed' AND (OLD.status IS DISTINCT FROM 'completed') THEN
    SELECT title INTO v_title FROM services WHERE id = NEW.service_id;

    INSERT INTO notifications(user_id, type, title, message, related_service_id, related_booking_id)
    VALUES (
      NEW.client_id,
      'service_completed',
      'Servicio completado',
      COALESCE(v_title, 'Tu servicio') || ' fue marcado como completado.',
      NEW.service_id,
      NEW.id
    );
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_notify_booking_completed ON bookings;
CREATE TRIGGER trg_notify_booking_completed
  AFTER UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION fn_notify_booking_completed();

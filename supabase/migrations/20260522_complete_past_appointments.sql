-- Marca como realizadas las citas confirmadas cuyo slot ya terminó.
-- Duración del slot: 30 min (misma convención que slot_generator.dart en Flutter).
CREATE OR REPLACE FUNCTION public.complete_past_appointments()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE appointments
  SET status = 'done'
  WHERE status = 'confirmed'
    AND scheduled_at + interval '30 minutes' <= now();

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_past_appointments() TO authenticated;

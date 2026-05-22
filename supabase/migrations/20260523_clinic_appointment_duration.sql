-- Duración de cita configurable por clínica (minutos por franja reservable).

ALTER TABLE clinics
  ADD COLUMN IF NOT EXISTS appointment_duration_minutes integer NOT NULL DEFAULT 30
  CHECK (appointment_duration_minutes IN (30, 45, 60, 90, 120));

ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS duration_minutes integer
  CHECK (duration_minutes IS NULL OR duration_minutes IN (30, 45, 60, 90, 120));

UPDATE appointments a
SET duration_minutes = c.appointment_duration_minutes
FROM clinics c
WHERE c.id = a.clinic_id
  AND a.duration_minutes IS NULL;

-- Slots ocupados: devuelve inicio + duración para detectar solapamientos.
DROP FUNCTION IF EXISTS public.get_booked_slots(uuid, timestamptz, timestamptz);

CREATE OR REPLACE FUNCTION public.get_booked_slots(
  p_clinic_id uuid,
  p_from      timestamptz,
  p_to        timestamptz
)
RETURNS TABLE (scheduled_at timestamptz, duration_minutes integer)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
    SELECT
      a.scheduled_at,
      COALESCE(a.duration_minutes, c.appointment_duration_minutes, 30)::integer
    FROM appointments a
    INNER JOIN clinics c ON c.id = a.clinic_id
    WHERE a.clinic_id = p_clinic_id
      AND a.scheduled_at >= p_from
      AND a.scheduled_at < p_to
      AND a.status IN ('pending', 'confirmed');
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_booked_slots(uuid, timestamptz, timestamptz) TO authenticated;

-- Marcar realizadas según la duración de cada cita (o la de la clínica si es antigua).
CREATE OR REPLACE FUNCTION public.complete_past_appointments()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  updated_count integer;
BEGIN
  UPDATE appointments a
  SET status = 'done'
  FROM clinics c
  WHERE a.clinic_id = c.id
    AND a.status = 'confirmed'
    AND a.scheduled_at
        + make_interval(mins => COALESCE(a.duration_minutes, c.appointment_duration_minutes))
        <= now();

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_past_appointments() TO authenticated;

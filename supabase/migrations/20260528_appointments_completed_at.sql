-- Fecha en que la clínica marcó la cita como realizada (o el sistema la completó).
ALTER TABLE appointments
  ADD COLUMN IF NOT EXISTS completed_at timestamptz;

UPDATE appointments
SET completed_at = scheduled_at
WHERE status = 'done'
  AND completed_at IS NULL;

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
  SET status = 'done',
      completed_at = now()
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

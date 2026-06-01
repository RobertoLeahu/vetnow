-- Sincroniza citas vencidas: confirmed → done, pending → cancelled.
-- También programa ejecución periódica vía pg_cron (cada 5 min).

CREATE OR REPLACE FUNCTION public.complete_past_appointments()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  done_count integer;
  cancelled_count integer;
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

  GET DIAGNOSTICS done_count = ROW_COUNT;

  UPDATE appointments a
  SET status = 'cancelled'
  FROM clinics c
  WHERE a.clinic_id = c.id
    AND a.status = 'pending'
    AND a.scheduled_at
        + make_interval(mins => COALESCE(a.duration_minutes, c.appointment_duration_minutes))
        <= now();

  GET DIAGNOSTICS cancelled_count = ROW_COUNT;

  RETURN done_count + cancelled_count;
END;
$$;

GRANT EXECUTE ON FUNCTION public.complete_past_appointments() TO authenticated;

-- Job periódico (requiere extensión pg_cron habilitada en Supabase).
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'sync-past-appointments') THEN
    PERFORM cron.unschedule('sync-past-appointments');
  END IF;
END $$;

SELECT cron.schedule(
  'sync-past-appointments',
  '*/5 * * * *',
  $$SELECT public.complete_past_appointments()$$
);

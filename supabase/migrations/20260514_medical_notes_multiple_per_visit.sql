-- Permite varias notas clínicas por cita (elimina UNIQUE en appointment_id).
-- El nombre del constraint en Postgres suele ser medical_notes_appointment_id_key.
DO $$
BEGIN
  IF to_regclass('public.medical_notes') IS NOT NULL THEN
    ALTER TABLE public.medical_notes
      DROP CONSTRAINT IF EXISTS medical_notes_appointment_id_key;
  END IF;
END $$;

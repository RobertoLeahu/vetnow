-- Quitar duraciones de 15 y 20 minutos (solo aplica si ya ejecutaste 20260523).

UPDATE clinics
SET appointment_duration_minutes = 30
WHERE appointment_duration_minutes IN (15, 20);

UPDATE appointments
SET duration_minutes = 30
WHERE duration_minutes IN (15, 20);

ALTER TABLE clinics
  DROP CONSTRAINT IF EXISTS clinics_appointment_duration_minutes_check;

ALTER TABLE clinics
  ADD CONSTRAINT clinics_appointment_duration_minutes_check
  CHECK (appointment_duration_minutes IN (30, 45, 60, 90, 120));

ALTER TABLE appointments
  DROP CONSTRAINT IF EXISTS appointments_duration_minutes_check;

ALTER TABLE appointments
  ADD CONSTRAINT appointments_duration_minutes_check
  CHECK (duration_minutes IS NULL OR duration_minutes IN (30, 45, 60, 90, 120));

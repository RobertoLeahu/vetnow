-- La clínica puede actualizar citas de su agenda (confirmar / marcar realizada).
DROP POLICY IF EXISTS "appointments_clinic_update" ON appointments;
DROP POLICY IF EXISTS "clinic_update_own_appointments" ON appointments;
CREATE POLICY "clinic_update_own_appointments"
  ON appointments
  FOR UPDATE
  TO authenticated
  USING (
    clinic_id IN (SELECT id FROM clinics WHERE profile_id = auth.uid())
  )
  WITH CHECK (
    clinic_id IN (SELECT id FROM clinics WHERE profile_id = auth.uid())
  );

-- La clínica puede leer el perfil del propietario si tiene una cita con él.
DROP POLICY IF EXISTS "clinic_read_owner_profile_for_appointments" ON profiles;
CREATE POLICY "clinic_read_owner_profile_for_appointments"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM appointments a
      INNER JOIN clinics c ON c.id = a.clinic_id
      WHERE a.owner_id = profiles.id
        AND c.profile_id = auth.uid()
    )
  );

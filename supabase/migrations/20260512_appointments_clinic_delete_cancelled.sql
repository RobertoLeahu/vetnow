-- La clínica puede eliminar del historial las citas canceladas de su agenda.
DROP POLICY IF EXISTS "clinic_delete_own_cancelled_appointments" ON appointments;
CREATE POLICY "clinic_delete_own_cancelled_appointments"
  ON appointments
  FOR DELETE
  TO authenticated
  USING (
    status = 'cancelled'
    AND clinic_id IN (SELECT id FROM clinics WHERE profile_id = auth.uid())
  );

-- El propietario puede borrar definitivamente sus citas canceladas (p. ej. desde el listado).
DROP POLICY IF EXISTS "owners delete own cancelled appointments" ON appointments;
CREATE POLICY "owners delete own cancelled appointments"
  ON appointments
  FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid() AND status = 'cancelled');

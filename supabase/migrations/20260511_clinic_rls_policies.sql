-- RLS policies para que la clínica dueña pueda gestionar sus propias filas.
-- Contexto: clinic_specialties y schedules tienen SELECT público pero les
-- faltaban políticas de escritura/borrado para el rol clinic.

-- ── clinic_specialties ──────────────────────────────────────────────────────

-- La clínica solo puede insertar/borrar sus propias especialidades
-- (la FK clinic_id debe coincidir con la id de la clínica cuyo profile_id = auth.uid())
CREATE POLICY "clinic owner can insert clinic_specialties"
  ON clinic_specialties
  FOR INSERT
  TO authenticated
  WITH CHECK (
    clinic_id IN (
      SELECT id FROM clinics WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "clinic owner can delete clinic_specialties"
  ON clinic_specialties
  FOR DELETE
  TO authenticated
  USING (
    clinic_id IN (
      SELECT id FROM clinics WHERE profile_id = auth.uid()
    )
  );

-- ── schedules ────────────────────────────────────────────────────────────────

-- Lectura pública (necesaria para mostrar horarios a los propietarios)
CREATE POLICY "schedules are publicly readable"
  ON schedules
  FOR SELECT
  USING (true);

-- La clínica solo puede insertar/borrar/actualizar sus propios horarios
CREATE POLICY "clinic owner can insert schedules"
  ON schedules
  FOR INSERT
  TO authenticated
  WITH CHECK (
    clinic_id IN (
      SELECT id FROM clinics WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "clinic owner can delete schedules"
  ON schedules
  FOR DELETE
  TO authenticated
  USING (
    clinic_id IN (
      SELECT id FROM clinics WHERE profile_id = auth.uid()
    )
  );

CREATE POLICY "clinic owner can update schedules"
  ON schedules
  FOR UPDATE
  TO authenticated
  USING (
    clinic_id IN (
      SELECT id FROM clinics WHERE profile_id = auth.uid()
    )
  );

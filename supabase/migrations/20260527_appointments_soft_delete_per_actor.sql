-- ROLLBACK: eliminar todo lo añadido por el intento de soft delete.
-- Ejecutar en Supabase SQL Editor para volver al estado original.

DROP POLICY IF EXISTS "appointments_owner_visible_not_deleted" ON appointments;
DROP POLICY IF EXISTS "appointments_clinic_visible_not_deleted" ON appointments;
DROP POLICY IF EXISTS "appointments_owner_soft_delete_cancelled" ON appointments;
DROP POLICY IF EXISTS "appointments_clinic_soft_delete_cancelled" ON appointments;

ALTER TABLE appointments DROP COLUMN IF EXISTS deleted_by_owner_at;
ALTER TABLE appointments DROP COLUMN IF EXISTS deleted_by_clinic_at;

-- Restaurar políticas de borrado físico originales.
DROP POLICY IF EXISTS "owners delete own cancelled appointments" ON appointments;
CREATE POLICY "owners delete own cancelled appointments"
  ON appointments
  FOR DELETE
  TO authenticated
  USING (owner_id = auth.uid() AND status = 'cancelled');

DROP POLICY IF EXISTS "clinic_delete_own_cancelled_appointments" ON appointments;
CREATE POLICY "clinic_delete_own_cancelled_appointments"
  ON appointments
  FOR DELETE
  TO authenticated
  USING (
    status = 'cancelled'
    AND clinic_id IN (SELECT id FROM clinics WHERE profile_id = auth.uid())
  );

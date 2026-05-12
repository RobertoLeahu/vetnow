-- La clínica puede leer datos básicos de mascotas citadas en sus citas
-- (el join PostgREST devolvía pets: null y rompía Appointment.fromMap).
DROP POLICY IF EXISTS "clinic_read_pets_linked_to_appointments" ON pets;
CREATE POLICY "clinic_read_pets_linked_to_appointments"
  ON pets
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM appointments a
      INNER JOIN clinics c ON c.id = a.clinic_id
      WHERE a.pet_id = pets.id
        AND c.profile_id = auth.uid()
    )
  );

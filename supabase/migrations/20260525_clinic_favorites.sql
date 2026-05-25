CREATE TABLE clinic_favorites (
  owner_id   uuid REFERENCES auth.users NOT NULL,
  clinic_id  uuid REFERENCES clinics(id) ON DELETE CASCADE NOT NULL,
  created_at timestamptz DEFAULT now(),
  PRIMARY KEY (owner_id, clinic_id)
);

ALTER TABLE clinic_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "owner_favorites_all" ON clinic_favorites
  FOR ALL TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

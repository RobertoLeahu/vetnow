-- Bucket público para fotos de mascotas (ruta: {owner_id}/{pet_id}.ext)
-- El cliente usa supabase.storage.from('pet-photos') en PetRepository.

INSERT INTO storage.buckets (id, name, public)
VALUES ('pet-photos', 'pet-photos', true)
ON CONFLICT (id) DO NOTHING;

-- Lectura pública (URLs públicas en la app)
DROP POLICY IF EXISTS "pet photos public read" ON storage.objects;
CREATE POLICY "pet photos public read"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'pet-photos');

-- Solo el propietario autenticado puede subir en su carpeta (primer segmento = auth.uid())
DROP POLICY IF EXISTS "pet photos owner insert" ON storage.objects;
CREATE POLICY "pet photos owner insert"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'pet-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "pet photos owner update" ON storage.objects;
CREATE POLICY "pet photos owner update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (
    bucket_id = 'pet-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

DROP POLICY IF EXISTS "pet photos owner delete" ON storage.objects;
CREATE POLICY "pet photos owner delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'pet-photos'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

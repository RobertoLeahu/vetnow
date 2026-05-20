-- Índice compuesto para acelerar el filtrado por bounding box (lat, lng)
-- usado por la búsqueda geográfica de clínicas en `searchClinicsNearby`.
--
-- Se complementa con un filtro Haversine exacto en cliente. Por eso un
-- índice B-tree estándar es suficiente y no se requiere PostGIS.
CREATE INDEX IF NOT EXISTS clinics_lat_lng_idx
  ON public.clinics (lat, lng)
  WHERE lat IS NOT NULL AND lng IS NOT NULL;

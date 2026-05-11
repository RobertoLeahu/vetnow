-- Función pública para consultar slots ocupados de una clínica en un rango de tiempo.
-- SECURITY DEFINER bypasea RLS para que cualquier usuario autenticado pueda ver
-- qué horas están ocupadas sin acceder a datos personales de otras citas.
CREATE OR REPLACE FUNCTION public.get_booked_slots(
  p_clinic_id uuid,
  p_from      timestamptz,
  p_to        timestamptz
)
RETURNS TABLE (scheduled_at timestamptz)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
    SELECT a.scheduled_at
    FROM appointments a
    WHERE a.clinic_id = p_clinic_id
      AND a.scheduled_at >= p_from
      AND a.scheduled_at < p_to
      AND a.status IN ('pending', 'confirmed');
END;
$$;

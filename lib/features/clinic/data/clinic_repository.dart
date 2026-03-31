import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/clinic.dart';

class ClinicRepository {
  /// Búsqueda con filtros opcionales de ciudad y especialidad
  Future<List<Clinic>> searchClinics({
    String? city,
    String? specialtyId,
  }) async {
    var query = supabase
        .from('clinics')
        .select('''
          *,
          clinic_specialties(
            specialties(id, name)
          )
        ''');

    if (city != null && city.isNotEmpty) {
      query = query.ilike('city', '%$city%');
    }

    final data = await query;
    final clinics = (data as List).map((e) => Clinic.fromMap(e)).toList();

    // Filtro por especialidad en cliente (más simple que join complejo)
    if (specialtyId != null && specialtyId.isNotEmpty) {
      return clinics
          .where((c) => c.specialties.any((s) => s.id == specialtyId))
          .toList();
    }

    return clinics;
  }

  /// Obtener una clínica por ID
  Future<Clinic?> getClinicById(String id) async {
    final data = await supabase
        .from('clinics')
        .select('''
          *,
          clinic_specialties(
            specialties(id, name)
          )
        ''')
        .eq('id', id)
        .maybeSingle();

    if (data == null) return null;
    return Clinic.fromMap(data);
  }

  /// Obtener la clínica del usuario logueado
  Future<Clinic?> getMyClinic(String profileId) async {
    final data = await supabase
        .from('clinics')
        .select('''
          *,
          clinic_specialties(
            specialties(id, name)
          )
        ''')
        .eq('profile_id', profileId)
        .maybeSingle();

    if (data == null) return null;
    return Clinic.fromMap(data);
  }

  /// Crear o actualizar clínica
  Future<void> upsertClinic(Map<String, dynamic> data) async {
    await supabase.from('clinics').upsert(data);
  }

  /// Reemplazar especialidades de una clínica
  Future<void> updateSpecialties(
    String clinicId,
    List<String> specialtyIds,
  ) async {
    await supabase
        .from('clinic_specialties')
        .delete()
        .eq('clinic_id', clinicId);

    if (specialtyIds.isEmpty) return;

    await supabase.from('clinic_specialties').insert(
          specialtyIds
              .map((sid) => {'clinic_id': clinicId, 'specialty_id': sid})
              .toList(),
        );
  }
}
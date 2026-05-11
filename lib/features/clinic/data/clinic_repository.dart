import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/schedule.dart';

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

  // ── Schedules ───────────────────────────────────────────────────

  Future<List<Schedule>> fetchSchedules(String clinicId) async {
    final data = await supabase
        .from('schedules')
        .select()
        .eq('clinic_id', clinicId)
        .order('day_of_week');
    return (data as List).map((e) => Schedule.fromMap(e)).toList();
  }

  Future<void> upsertSchedules(
    String clinicId,
    List<Schedule> schedules,
  ) async {
    await supabase.from('schedules').delete().eq('clinic_id', clinicId);

    if (schedules.isEmpty) return;

    await supabase
        .from('schedules')
        .insert(schedules.map((s) => s.toMap()).toList());
  }

  // ── Logo ────────────────────────────────────────────────────────

  String _contentTypeForPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  Future<String> uploadClinicLogo({
    required String clinicId,
    required File file,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final objectName = '$clinicId/logo.$ext';
    final contentType = _contentTypeForPath(file.path);

    await supabase.storage.from('clinic-logos').upload(
          objectName,
          file,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return supabase.storage.from('clinic-logos').getPublicUrl(objectName);
  }

  // ── Crear clínica mínima al registrarse ─────────────────────────

  Future<void> createClinicForProfile({
    required String profileId,
    required String name,
  }) async {
    await supabase.from('clinics').insert({
      'profile_id': profileId,
      'name': name,
      'address': '',
      'city': '',
    });
  }
}
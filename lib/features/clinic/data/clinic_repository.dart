import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/strings/search_text.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/schedule.dart';

class ClinicRepository {
  /// Búsqueda por texto (nombre, ciudad o dirección) y especialidad opcional.
  Future<List<Clinic>> searchClinics({
    String? query,
    String? specialtyId,
  }) async {
    final data = await supabase.from('clinics').select('''
          *,
          clinic_specialties(
            specialties(id, name)
          )
        ''');

    var clinics = (data as List).map((e) => Clinic.fromMap(e)).toList();

    final term = query?.trim();
    if (term != null && term.isNotEmpty) {
      clinics = clinics
          .where(
            (c) =>
                searchTextContains(c.name, term) ||
                searchTextContains(c.city, term) ||
                searchTextContains(c.address, term),
          )
          .toList();
    }

    if (specialtyId != null && specialtyId.isNotEmpty) {
      clinics = clinics
          .where((c) => c.specialties.any((s) => s.id == specialtyId))
          .toList();
    }

    return clinics;
  }

  /// Busca clínicas dentro de un radio en km desde la posición del usuario.
  ///
  /// Para reducir la carga de red se aplica un pre-filtro en servidor con un
  /// bounding box (lat ± delta, lng ± delta). El filtro exacto por distancia
  /// (Haversine) se hace en cliente para evitar PostGIS.
  Future<List<Clinic>> searchClinicsNearby({
    required double userLat,
    required double userLng,
    required double radiusKm,
    String? specialtyId,
  }) async {
    // 1 grado de latitud ≈ 111 km. Se multiplica el delta por 1.5 como margen
    // para asegurar que el bounding box no descarte clínicas válidas cerca
    // del borde antes de filtrar con Haversine.
    final latDelta = (radiusKm / 111.0) * 1.5;
    // 1 grado de longitud varía con la latitud: 111 km * cos(lat).
    final cosLat = math.cos(userLat * math.pi / 180.0);
    final lngDelta = (radiusKm / (111.0 * (cosLat.abs() < 0.01 ? 0.01 : cosLat))).abs() * 1.5;

    final data = await supabase
        .from('clinics')
        .select('''
          *,
          clinic_specialties(
            specialties(id, name)
          )
        ''')
        .not('lat', 'is', null)
        .not('lng', 'is', null)
        .gte('lat', userLat - latDelta)
        .lte('lat', userLat + latDelta)
        .gte('lng', userLng - lngDelta)
        .lte('lng', userLng + lngDelta);

    var clinics = (data as List).map((e) => Clinic.fromMap(e)).toList();

    if (specialtyId != null && specialtyId.isNotEmpty) {
      clinics = clinics
          .where((c) => c.specialties.any((s) => s.id == specialtyId))
          .toList();
    }

    final withDistance = <Clinic>[];
    for (final c in clinics) {
      if (c.lat == null || c.lng == null) continue;
      final d = haversineKm(
        lat1: userLat,
        lng1: userLng,
        lat2: c.lat!,
        lng2: c.lng!,
      );
      if (d <= radiusKm) {
        withDistance.add(c.copyWith(distanceKm: d));
      }
    }

    withDistance.sort((a, b) => (a.distanceKm!).compareTo(b.distanceKm!));
    return withDistance;
  }

  /// Geocodifica una dirección usando OpenStreetMap Nominatim.
  ///
  /// Devuelve `(lat, lng)` o `null` si Nominatim no encuentra resultados.
  /// Nominatim requiere un User-Agent identificable y un límite de 1 req/s,
  /// por lo que solo debe llamarse al guardar el perfil de clínica.
  Future<({double lat, double lng})?> geocodeAddress({
    required String address,
    required String city,
  }) async {
    final addr = address.trim();
    final cty = city.trim();
    if (addr.isEmpty && cty.isEmpty) return null;

    // Intento 1: dirección completa + ciudad + país
    if (addr.isNotEmpty && cty.isNotEmpty) {
      final coords = await _nominatimSearch('$addr, $cty, España');
      if (coords != null) return coords;
      await Future<void>.delayed(const Duration(seconds: 1));
    }

    // Intento 2: solo ciudad + país (útil si la calle no está en OSM)
    if (cty.isNotEmpty) {
      final coords = await _nominatimSearch('$cty, España');
      if (coords != null) return coords;
      if (addr.isNotEmpty) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    // Intento 3: solo dirección si no hay ciudad
    if (addr.isNotEmpty) {
      return _nominatimSearch('$addr, España');
    }

    return null;
  }

  Future<({double lat, double lng})?> _nominatimSearch(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '1',
      'countrycodes': 'es',
      'addressdetails': '0',
    });

    try {
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'VetNow/1.0 (contacto@vetnow.app)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) return null;

      final first = decoded.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat']?.toString() ?? '');
      final lng = double.tryParse(first['lon']?.toString() ?? '');
      if (lat == null || lng == null) return null;
      return (lat: lat, lng: lng);
    } catch (_) {
      return null;
    }
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

  /// Actualiza solo el teléfono de la clínica del perfil indicado.
  Future<void> updateClinicPhoneByProfile({
    required String profileId,
    String? phone,
  }) async {
    await supabase
        .from('clinics')
        .update({'phone': phone})
        .eq('profile_id', profileId);
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
    String? email,
  }) async {
    await supabase.from('clinics').insert({
      'profile_id': profileId,
      'name': name,
      'address': '',
      'city': '',
      if (email != null) 'email': email,
    });
  }

  // ── Favoritos ──────────────────────────────────────────────────

  Future<Set<String>> fetchFavoriteClinicIds(String ownerId) async {
    final data = await supabase
        .from('clinic_favorites')
        .select('clinic_id')
        .eq('owner_id', ownerId);
    return (data as List).map((e) => e['clinic_id'] as String).toSet();
  }

  Future<List<Clinic>> fetchFavoriteClinics(String ownerId) async {
    final favRows = await supabase
        .from('clinic_favorites')
        .select('clinic_id')
        .eq('owner_id', ownerId);
    final ids =
        (favRows as List).map((e) => e['clinic_id'] as String).toList();
    if (ids.isEmpty) return [];

    final data = await supabase
        .from('clinics')
        .select('''
          *,
          clinic_specialties(
            specialties(id, name)
          )
        ''')
        .inFilter('id', ids);
    return (data as List).map((e) => Clinic.fromMap(e)).toList();
  }

  Future<void> addFavorite(String ownerId, String clinicId) async {
    await supabase.from('clinic_favorites').upsert({
      'owner_id': ownerId,
      'clinic_id': clinicId,
    });
  }

  Future<void> removeFavorite(String ownerId, String clinicId) async {
    await supabase
        .from('clinic_favorites')
        .delete()
        .eq('owner_id', ownerId)
        .eq('clinic_id', clinicId);
  }
}
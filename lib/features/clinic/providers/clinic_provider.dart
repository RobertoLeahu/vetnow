import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/clinic_repository.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/schedule.dart';
import '../../../shared/models/specialty.dart';
import '../../../core/supabase/supabase_client.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (_) => ClinicRepository(),
);

// Filtros de búsqueda como estado
class SearchFilters {
  /// Texto libre: busca por nombre de clínica, ciudad o dirección.
  final String query;
  final String? specialtyId;

  /// Modo proximidad GPS. Si es true se usa [userLat] / [userLng] y se ignora
  /// el filtro de [query].
  final bool isNearbyMode;
  final double? userLat;
  final double? userLng;
  final double nearbyRadiusKm;

  const SearchFilters({
    this.query = '',
    this.specialtyId,
    this.isNearbyMode = false,
    this.userLat,
    this.userLng,
    this.nearbyRadiusKm = 10.0,
  });

  SearchFilters copyWith({
    String? query,
    String? specialtyId,
    bool clearSpecialty = false,
    bool? isNearbyMode,
    double? userLat,
    double? userLng,
    double? nearbyRadiusKm,
    bool clearLocation = false,
  }) =>
      SearchFilters(
        query: query ?? this.query,
        specialtyId: clearSpecialty ? null : (specialtyId ?? this.specialtyId),
        isNearbyMode: isNearbyMode ?? this.isNearbyMode,
        userLat: clearLocation ? null : (userLat ?? this.userLat),
        userLng: clearLocation ? null : (userLng ?? this.userLng),
        nearbyRadiusKm: nearbyRadiusKm ?? this.nearbyRadiusKm,
      );
}

final searchFiltersProvider = StateProvider<SearchFilters>(
  (_) => const SearchFilters(),
);

// Resultados de búsqueda reactivos a los filtros
final clinicSearchProvider = FutureProvider<List<Clinic>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final repo = ref.watch(clinicRepositoryProvider);

  if (filters.isNearbyMode &&
      filters.userLat != null &&
      filters.userLng != null) {
    return repo.searchClinicsNearby(
      userLat: filters.userLat!,
      userLng: filters.userLng!,
      radiusKm: filters.nearbyRadiusKm,
      specialtyId: filters.specialtyId,
    );
  }

  return repo.searchClinics(
    query: filters.query,
    specialtyId: filters.specialtyId,
  );
});

// Catálogo de especialidades
final specialtiesProvider = FutureProvider<List<Specialty>>((ref) async {
  final data = await supabase.from('specialties').select();
  return (data as List).map((e) => Specialty.fromMap(e)).toList();
});

// Clínica por ID (para pantalla de detalle)
final clinicDetailProvider = FutureProvider.family<Clinic?, String>((
  ref,
  id,
) async {
  return ref.watch(clinicRepositoryProvider).getClinicById(id);
});

// Horarios semanales de una clínica concreta (para el flujo de reserva)
final clinicSchedulesProvider =
    FutureProvider.family<List<Schedule>, String>((ref, clinicId) async {
  return ref.watch(clinicRepositoryProvider).fetchSchedules(clinicId);
});

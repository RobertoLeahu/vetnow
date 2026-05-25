import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/clinic_repository.dart';
import '../../auth/providers/auth_provider.dart';
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
  /// Especialidad seleccionada; solo aplica a la búsqueda de clínicas cercanas.
  final String? specialtyId;

  /// Modo proximidad GPS. Si es true se usa [userLat] / [userLng] en
  /// [clinicSearchProvider] (cercanas). [query] no filtra favoritos.
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

/// Búsqueda por texto (nombre, ciudad, dirección) para la pantalla de búsqueda.
final clinicTextSearchProvider =
    FutureProvider.autoDispose.family<List<Clinic>, String>((ref, query) async {
  final term = query.trim();
  if (term.isEmpty) return [];
  final specialtyId = ref.watch(searchFiltersProvider).specialtyId;
  return ref.read(clinicRepositoryProvider).searchClinics(
        query: term,
        specialtyId: specialtyId,
      );
});

// Clínicas cercanas (solo activo en NearbyScreen; usa especialidad y GPS).
final clinicSearchProvider = FutureProvider.autoDispose<List<Clinic>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  if (!filters.isNearbyMode ||
      filters.userLat == null ||
      filters.userLng == null) {
    return [];
  }

  return ref.watch(clinicRepositoryProvider).searchClinicsNearby(
    userLat: filters.userLat!,
    userLng: filters.userLng!,
    radiusKm: filters.nearbyRadiusKm,
    specialtyId: filters.specialtyId,
  );
});

// Catálogo de especialidades
final specialtiesProvider = FutureProvider<List<Specialty>>((ref) async {
  final data = await supabase.from('specialties').select();
  return (data as List).map((e) => Specialty.fromMap(e)).toList();
});

// Clínica por ID (para pantalla de detalle y reserva).
final clinicDetailProvider = FutureProvider.autoDispose.family<Clinic?, String>((
  ref,
  id,
) async {
  return ref.watch(clinicRepositoryProvider).getClinicById(id);
});

// Horarios semanales de una clínica (flujo de reserva; se refresca al entrar).
final clinicSchedulesProvider =
    FutureProvider.autoDispose.family<List<Schedule>, String>((ref, clinicId) async {
  return ref.watch(clinicRepositoryProvider).fetchSchedules(clinicId);
});

/// Fuerza recarga de datos de clínica usados en reserva (horarios, duración, etc.).
void invalidateClinicBookingData(WidgetRef ref, String clinicId) {
  ref.invalidate(clinicSchedulesProvider(clinicId));
  ref.invalidate(clinicDetailProvider(clinicId));
}

// ── Favoritos ────────────────────────────────────────────────────

/// IDs de clínicas favoritas del propietario logueado.
final favoriteClinicIdsProvider =
    FutureProvider.autoDispose<Set<String>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull?.session?.user;
  if (user == null) return {};
  return ref.watch(clinicRepositoryProvider).fetchFavoriteClinicIds(user.id);
});

/// Clínicas favoritas completas (para la lista en SearchScreen).
final favoriteClinicsProvider =
    FutureProvider.autoDispose<List<Clinic>>((ref) async {
  final user = ref.watch(authStateProvider).valueOrNull?.session?.user;
  if (user == null) return [];
  return ref.watch(clinicRepositoryProvider).fetchFavoriteClinics(user.id);
});

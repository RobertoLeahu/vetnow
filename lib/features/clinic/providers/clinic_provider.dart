import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/clinic_repository.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/specialty.dart';
import '../../../core/supabase/supabase_client.dart';

final clinicRepositoryProvider = Provider<ClinicRepository>(
  (_) => ClinicRepository(),
);

// Filtros de búsqueda como estado
class SearchFilters {
  final String city;
  final String? specialtyId;

  const SearchFilters({this.city = '', this.specialtyId});

  SearchFilters copyWith({String? city, String? specialtyId}) => SearchFilters(
        city: city ?? this.city,
        specialtyId: specialtyId,
      );
}

final searchFiltersProvider =
    StateProvider<SearchFilters>((_) => const SearchFilters());

// Resultados de búsqueda reactivos a los filtros
final clinicSearchProvider = FutureProvider<List<Clinic>>((ref) async {
  final filters = ref.watch(searchFiltersProvider);
  final repo = ref.watch(clinicRepositoryProvider);
  return repo.searchClinics(
    city: filters.city,
    specialtyId: filters.specialtyId,
  );
});

// Catálogo de especialidades
final specialtiesProvider = FutureProvider<List<Specialty>>((ref) async {
  final data = await supabase.from('specialties').select();
  return (data as List).map((e) => Specialty.fromMap(e)).toList();
});

// Clínica por ID (para pantalla de detalle)
final clinicDetailProvider =
    FutureProvider.family<Clinic?, String>((ref, id) async {
  return ref.watch(clinicRepositoryProvider).getClinicById(id);
});
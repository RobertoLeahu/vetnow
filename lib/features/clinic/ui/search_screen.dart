import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../providers/clinic_provider.dart';
import '../../../app/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/clinic.dart';

IconData _specialtyIcon(String name) {
  final n = name
      .toLowerCase()
      .replaceAll(RegExp(r'[áàä]'), 'a')
      .replaceAll(RegExp(r'[éèë]'), 'e')
      .replaceAll(RegExp(r'[íìï]'), 'i')
      .replaceAll(RegExp(r'[óòö]'), 'o')
      .replaceAll(RegExp(r'[úùü]'), 'u');

  if (n.contains('medicina')) return Icons.medical_services_rounded;
  if (n.contains('dermat')) return Icons.healing_rounded;
  if (n.contains('cardio')) return Icons.favorite_rounded;
  if (n.contains('traumat')) return Icons.set_meal_rounded;
  if (n.contains('oftalm')) return Icons.visibility_rounded;
  if (n.contains('exotic') || n.contains('exot')) return Icons.pets_rounded;
  if (n.contains('urgenc') || n.contains('24')) {
    return Icons.local_hospital_rounded;
  }
  return Icons.medical_information_outlined;
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  bool _locating = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(clinicSearchProvider);
    ref.invalidate(specialtiesProvider);
    ref.invalidate(profileProvider);
    await Future.wait([
      ref.read(clinicSearchProvider.future),
      ref.read(specialtiesProvider.future),
    ]);
  }

  Future<void> _toggleNearby() async {
    final filters = ref.read(searchFiltersProvider);

    if (filters.isNearbyMode) {
      ref
          .read(searchFiltersProvider.notifier)
          .update((s) => s.copyWith(isNearbyMode: false, clearLocation: true));
      return;
    }

    setState(() => _locating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        await _showLocationDeniedDialog(
          title: 'Ubicación desactivada',
          message:
              'Activa el servicio de ubicación de tu dispositivo para ver las clínicas cercanas.',
          openSettings: () => Geolocator.openLocationSettings(),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        await _showLocationDeniedDialog(
          title: 'Permiso de ubicación necesario',
          message:
              'Para mostrarte las clínicas más cercanas necesitamos acceder a tu ubicación. Actívala en los ajustes de la app.',
          openSettings: () => Geolocator.openAppSettings(),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 15),
      );

      _searchCtrl.clear();
      ref.read(searchFiltersProvider.notifier).update(
            (s) => s.copyWith(
              isNearbyMode: true,
              userLat: position.latitude,
              userLng: position.longitude,
              query: '',
            ),
          );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener tu ubicación: $e')),
      );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _showLocationDeniedDialog({
    required String title,
    required String message,
    required Future<bool> Function() openSettings,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openSettings();
            },
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final firstName = profile?.fullName.split(' ').first ?? '';
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final clinicsAsync = ref.watch(clinicSearchProvider);
    final filters = ref.watch(searchFiltersProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        size: 36,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 24,
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            const TextSpan(text: 'Bienvenido a VetNow, '),
                            TextSpan(
                              text: '$firstName!',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Buscador
                      TextField(
                        controller: _searchCtrl,
                        enabled: !filters.isNearbyMode,
                        decoration: InputDecoration(
                          hintText: filters.isNearbyMode
                              ? 'Mostrando clínicas cerca de ti'
                              : 'Buscar por nombre, ciudad o dirección',
                          prefixIcon: const Icon(Icons.search_rounded),
                        ),
                        onChanged: (v) => ref
                            .read(searchFiltersProvider.notifier)
                            .update((s) => s.copyWith(query: v)),
                      ),
                      const SizedBox(height: 12),

                      // Botón "Cerca de mí"
                      _NearbyToggle(
                        active: filters.isNearbyMode,
                        loading: _locating,
                        radiusKm: filters.nearbyRadiusKm,
                        onTap: _locating ? null : _toggleNearby,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Chips de especialidades
              SliverToBoxAdapter(
                child: specialtiesAsync.when(
                  data: (specialties) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        _SpecialtyChip(
                          label: 'Todas',
                          icon: Icons.apps_rounded,
                          selected: filters.specialtyId == null,
                          onTap: () => ref
                              .read(searchFiltersProvider.notifier)
                              .update((s) => s.copyWith(clearSpecialty: true)),
                        ),
                        ...specialties.map(
                          (s) => _SpecialtyChip(
                            label: s.name,
                            icon: _specialtyIcon(s.name),
                            selected: filters.specialtyId == s.id,
                            onTap: () => ref
                                .read(searchFiltersProvider.notifier)
                                .update((f) => f.copyWith(specialtyId: s.id)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Título sección
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    filters.isNearbyMode
                        ? 'Clínicas cerca de ti'
                        : 'Clínicas disponibles',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Lista de clínicas
              clinicsAsync.when(
                data: (clinics) => clinics.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyState(
                          icon: filters.isNearbyMode
                              ? Icons.location_off_rounded
                              : Icons.search_off_rounded,
                          title: filters.isNearbyMode
                              ? 'No hay clínicas en ${filters.nearbyRadiusKm.toStringAsFixed(0)} km'
                              : 'No hay clínicas con estos filtros',
                          subtitle: filters.isNearbyMode
                              ? 'Las clínicas deben tener ubicación GPS registrada '
                                  '(guardar perfil en Mi clínica). Si usas emulador, '
                                  'configura la ubicación del dispositivo en Valdemoro.'
                              : 'Prueba con otro nombre, ciudad o especialidad',
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                            child: _ClinicCard(clinic: clinics[i]),
                          ),
                          childCount: clinics.length,
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                    child: Center(child: Text('Error: $e'))),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyToggle extends StatelessWidget {
  final bool active;
  final bool loading;
  final double radiusKm;
  final VoidCallback? onTap;

  const _NearbyToggle({
    required this.active,
    required this.loading,
    required this.radiusKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = active ? AppTheme.primary : AppTheme.surface;
    final fgColor = active ? Colors.white : AppTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppTheme.primary : AppTheme.divider,
          ),
        ),
        child: Row(
          children: [
            if (loading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fgColor,
                ),
              )
            else
              Icon(
                active
                    ? Icons.my_location_rounded
                    : Icons.location_searching_rounded,
                size: 20,
                color: fgColor,
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                active
                    ? 'Mostrando clínicas en ${radiusKm.toStringAsFixed(0)} km'
                    : 'Buscar clínicas cerca de mí',
                style: TextStyle(
                  color: fgColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (active)
              Icon(Icons.close_rounded, size: 18, color: fgColor),
          ],
        ),
      ),
    );
  }
}

class _SpecialtyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _SpecialtyChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  final Clinic clinic;
  const _ClinicCard({required this.clinic});

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/search/clinic/${clinic.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.surface,
              backgroundImage: clinic.logoUrl != null
                  ? NetworkImage(clinic.logoUrl!)
                  : null,
              child: clinic.logoUrl == null
                  ? const Icon(
                      Icons.local_hospital_rounded,
                      color: AppTheme.primary,
                      size: 28,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          clinic.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (clinic.distanceKm != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 12,
                                color: AppTheme.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                _formatDistance(clinic.distanceKm!),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          clinic.city,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (clinic.specialties.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: clinic.specialties
                          .take(2)
                          .map(
                            (s) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                s.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

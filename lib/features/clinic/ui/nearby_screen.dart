import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/theme.dart';
import '../../../shared/models/clinic.dart';
import '../providers/clinic_provider.dart';

IconData _nearbySpecialtyIcon(String name) {
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

class NearbyScreen extends ConsumerStatefulWidget {
  final double userLat;
  final double userLng;

  const NearbyScreen({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  bool _mapExpanded = false;
  String? _selectedClinicId;
  final _mapCtrl = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchFiltersProvider.notifier).update(
            (s) => s.copyWith(
              isNearbyMode: true,
              userLat: widget.userLat,
              userLng: widget.userLng,
            ),
          );
    });
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  void _deselectClinic() {
    if (_selectedClinicId == null) return;
    setState(() => _selectedClinicId = null);
  }

  void _onMapHeaderTap() {
    if (_selectedClinicId != null) {
      _deselectClinic();
      return;
    }
    setState(() {
      _mapExpanded = !_mapExpanded;
      if (!_mapExpanded) _selectedClinicId = null;
    });
  }

  void _onClinicTap(Clinic clinic) {
    if (!_mapExpanded) {
      context.push('/search/clinic/${clinic.id}');
      return;
    }

    if (_selectedClinicId == clinic.id) {
      context.push('/search/clinic/${clinic.id}');
      return;
    }

    setState(() => _selectedClinicId = clinic.id);
    if (clinic.lat != null && clinic.lng != null) {
      _mapCtrl.move(LatLng(clinic.lat!, clinic.lng!), 15.0);
    }
  }

  void _setSpecialtyFilter(String? specialtyId) {
    ref.read(searchFiltersProvider.notifier).update(
          (s) => specialtyId == null
              ? s.copyWith(clearSpecialty: true)
              : s.copyWith(specialtyId: specialtyId),
        );
    ref.invalidate(clinicSearchProvider);
  }

  @override
  Widget build(BuildContext context) {
    final clinicsAsync = ref.watch(clinicSearchProvider);
    final filters = ref.watch(searchFiltersProvider);
    final specialtiesAsync = ref.watch(specialtiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínicas cercanas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref
                .read(searchFiltersProvider.notifier)
                .update((s) => s.copyWith(isNearbyMode: false, clearLocation: true));
            context.pop();
          },
        ),
      ),
      body: Column(
        children: [
          specialtiesAsync.when(
            data: (specialties) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _NearbySpecialtyChip(
                    label: 'Todas',
                    icon: Icons.apps_rounded,
                    selected: filters.specialtyId == null,
                    onTap: () => _setSpecialtyFilter(null),
                  ),
                  ...specialties.map(
                    (s) => _NearbySpecialtyChip(
                      label: s.name,
                      icon: _nearbySpecialtyIcon(s.name),
                      selected: filters.specialtyId == s.id,
                      onTap: () => _setSpecialtyFilter(s.id),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Map section
          _MapSection(
            expanded: _mapExpanded,
            userLat: widget.userLat,
            userLng: widget.userLng,
            mapCtrl: _mapCtrl,
            clinics: clinicsAsync.valueOrNull ?? [],
            selectedClinicId: _selectedClinicId,
            radiusKm: filters.nearbyRadiusKm,
            onHeaderTap: _onMapHeaderTap,
            onMapBackgroundTap: _deselectClinic,
            onClinicTap: _onClinicTap,
          ),

          // Divider
          GestureDetector(
            onTap: _deselectClinic,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 1,
              color: AppTheme.divider,
            ),
          ),

          // Clinic list
          Expanded(
            child: GestureDetector(
              onTap: _deselectClinic,
              behavior: HitTestBehavior.deferToChild,
              child: clinicsAsync.when(
              data: (clinics) => clinics.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_off_rounded,
                                size: 64, color: AppTheme.textSecondary),
                            const SizedBox(height: 16),
                            Text(
                              'No hay clínicas en ${filters.nearbyRadiusKm.toStringAsFixed(0)} km',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              filters.specialtyId != null
                                  ? 'Prueba con otra especialidad o amplía el radio de búsqueda.'
                                  : 'Las clínicas necesitan tener su ubicación GPS registrada para aparecer aquí.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      itemCount: clinics.length + 1,
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '${clinics.length} clínica${clinics.length == 1 ? '' : 's'} cerca de ti',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          );
                        }
                        final clinic = clinics[i - 1];
                        final isSelected = _selectedClinicId == clinic.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _NearbyClinicCard(
                            clinic: clinic,
                            highlighted: isSelected && _mapExpanded,
                            onTap: () => _onClinicTap(clinic),
                          ),
                        );
                      },
                    ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('Error: $e')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Specialty chip (cercanas) ────────────────────────────────────

class _NearbySpecialtyChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NearbySpecialtyChip({
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

// ── Map Section ──────────────────────────────────────────────────

class _MapSection extends StatelessWidget {
  final bool expanded;
  final double userLat;
  final double userLng;
  final MapController mapCtrl;
  final List<Clinic> clinics;
  final String? selectedClinicId;
  final double radiusKm;
  final VoidCallback onHeaderTap;
  final VoidCallback onMapBackgroundTap;
  final void Function(Clinic) onClinicTap;

  const _MapSection({
    required this.expanded,
    required this.userLat,
    required this.userLng,
    required this.mapCtrl,
    required this.clinics,
    required this.selectedClinicId,
    required this.radiusKm,
    required this.onHeaderTap,
    required this.onMapBackgroundTap,
    required this.onClinicTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: expanded ? 340 : 56,
      child: Column(
        children: [
          // Toggle button
          InkWell(
            onTap: onHeaderTap,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    expanded
                        ? Icons.map_rounded
                        : Icons.map_outlined,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ver en el mapa',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  if (clinics.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        '${clinics.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map
          if (expanded)
            Expanded(
              child: ClipRect(
                child: FlutterMap(
                  mapController: mapCtrl,
                  options: MapOptions(
                    initialCenter: LatLng(userLat, userLng),
                    initialZoom: 13.0,
                    onTap: (_, __) => onMapBackgroundTap(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.robertoleahu.vetnow',
                    ),
                    // User location marker
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(userLat, userLng),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.my_location_rounded,
                                size: 18,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        ...clinics
                            .where((c) => c.lat != null && c.lng != null)
                            .map(
                              (c) => Marker(
                                point: LatLng(c.lat!, c.lng!),
                                width: selectedClinicId == c.id ? 48 : 40,
                                height: selectedClinicId == c.id ? 48 : 40,
                                child: GestureDetector(
                                  onTap: () => onClinicTap(c),
                                  child: _ClinicMapPin(
                                    selected: selectedClinicId == c.id,
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClinicMapPin extends StatelessWidget {
  final bool selected;

  const _ClinicMapPin({this.selected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: selected ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? Colors.orange.shade700 : AppTheme.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: selected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: selected ? 0.35 : 0.2),
              blurRadius: selected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.local_hospital_rounded,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ── Clinic Card ──────────────────────────────────────────────────

class _NearbyClinicCard extends StatelessWidget {
  final Clinic clinic;
  final bool highlighted;
  final VoidCallback onTap;

  const _NearbyClinicCard({
    required this.clinic,
    this.highlighted = false,
    required this.onTap,
  });

  String _formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toStringAsFixed(0)} m';
    return '${km.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: highlighted ? AppTheme.primary.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: highlighted ? AppTheme.primary : AppTheme.divider,
            width: highlighted ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.surface,
              backgroundImage:
                  clinic.logoUrl != null ? NetworkImage(clinic.logoUrl!) : null,
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../appointment/providers/appointment_provider.dart';
import '../providers/clinic_provider.dart';
import '../../../app/theme.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/pet.dart';

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
    ref.invalidate(favoriteClinicsProvider);
    ref.invalidate(specialtiesProvider);
    ref.invalidate(profileProvider);
    ref.invalidate(myAppointmentsProvider);
    await Future.wait([
      ref.read(favoriteClinicsProvider.future),
      ref.read(specialtiesProvider.future),
      ref.read(myAppointmentsProvider.future),
    ]);
  }

  Future<void> _openNearby() async {
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

      if (!mounted) return;
      ref.read(searchFiltersProvider.notifier).update(
            (s) => s.copyWith(
              isNearbyMode: true,
              userLat: position.latitude,
              userLng: position.longitude,
            ),
          );
      ref.invalidate(clinicSearchProvider);
      context.push(
        '/search/nearby',
        extra: (lat: position.latitude, lng: position.longitude),
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
    final favoritesAsync = ref.watch(favoriteClinicsProvider);
    final appointmentsAsync = ref.watch(myAppointmentsProvider);
    final filters = ref.watch(searchFiltersProvider);
    final specialties = specialtiesAsync.valueOrNull ?? [];

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

                      // Search field
                      TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Buscar por nombre, ciudad o dirección',
                          prefixIcon: Icon(Icons.search_rounded),
                        ),
                        onChanged: (v) => ref
                            .read(searchFiltersProvider.notifier)
                            .update((s) => s.copyWith(query: v)),
                      ),
                      const SizedBox(height: 12),

                      // "Cerca de mí" button
                      _NearbyButton(
                        loading: _locating,
                        onTap: _locating ? null : _openNearby,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Specialty chips (solo filtran clínicas cercanas)
              SliverToBoxAdapter(
                child: specialtiesAsync.when(
                  data: (_) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SpecialtyChip(
                          label: 'Todas',
                          icon: Icons.apps_rounded,
                          selected: filters.specialtyId == null,
                          onTap: () {
                            ref.read(searchFiltersProvider.notifier).update(
                                  (s) => s.copyWith(clearSpecialty: true),
                                );
                            ref.invalidate(clinicSearchProvider);
                          },
                        ),
                        ...specialties.map(
                          (s) => _SpecialtyChip(
                            label: s.name,
                            icon: _specialtyIcon(s.name),
                            selected: filters.specialtyId == s.id,
                            onTap: () {
                              ref.read(searchFiltersProvider.notifier).update(
                                    (f) => f.copyWith(specialtyId: s.id),
                                  );
                              ref.invalidate(clinicSearchProvider);
                            },
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

              // Section title
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Clínicas favoritas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Favorite clinics (lista fija; no depende de chips ni búsqueda)
              favoritesAsync.when(
                data: (allFavs) {
                  Widget content;
                  if (allFavs.isEmpty) {
                    content = const _EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'Todavía no tienes clínicas favoritas',
                      subtitle:
                          'Explora y pulsa el corazón en cualquier clínica para añadirla aquí.',
                    );
                  } else {
                    content = Column(
                      children: [
                        for (var i = 0; i < allFavs.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _ClinicCard(clinic: allFavs[i]),
                        ],
                      ],
                    );
                  }

                  return SliverToBoxAdapter(
                    child: _FavoritesSectionBox(child: content),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: _FavoritesSectionBox(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: _FavoritesSectionBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Section title — Próximas citas
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Próximas citas',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Próximas citas (contenido dentro del recuadro)
              appointmentsAsync.when(
                data: (all) {
                  final now = DateTime.now();
                  final upcoming = all
                      .where((a) => a.isUpcoming && a.scheduledAt.isAfter(now))
                      .take(3)
                      .toList();

                  Widget content;
                  if (upcoming.isEmpty) {
                    content = const _EmptyState(
                      icon: Icons.calendar_today_rounded,
                      title: 'No tienes citas programadas',
                      subtitle: 'Reserva una cita y aparecerá aquí.',
                    );
                  } else {
                    content = Column(
                      children: [
                        for (var i = 0; i < upcoming.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _UpcomingAppointmentCard(
                            appointment: upcoming[i],
                          ),
                        ],
                      ],
                    );
                  }

                  return SliverToBoxAdapter(
                    child: _FavoritesSectionBox(child: content),
                  );
                },
                loading: () => const SliverToBoxAdapter(
                  child: _FavoritesSectionBox(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: _FavoritesSectionBox(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: Text('Error: $e')),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Próxima cita card ─────────────────────────────────────────────

class _UpcomingAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final slot = appointment.scheduledAt;
    final dayName = DateFormat('EEEE', 'es').format(slot);
    final dayCapitalized =
        dayName[0].toUpperCase() + dayName.substring(1);
    final dateStr = DateFormat("d 'de' MMMM", 'es').format(slot);
    final timeStr = DateFormat('HH:mm').format(slot);

    final emoji = switch (appointment.petSpecies) {
      PetSpecies.dog => '🐶',
      PetSpecies.cat => '🐱',
      PetSpecies.rabbit => '🐰',
      PetSpecies.hamster => '🐹',
      PetSpecies.bird => '🦜',
      PetSpecies.reptile => '🦎',
      PetSpecies.ferret => '🦦',
      PetSpecies.other => '🐾',
    };

    final (badgeLabel, badgeColor) = appointment.isPending
        ? ('Pendiente', Colors.orange.shade700)
        : ('Confirmada', AppTheme.primary);

    return GestureDetector(
      onTap: () => context.push('/appointments'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date column
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dayCapitalized.substring(0, 3),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('d').format(slot),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM', 'es').format(slot),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Info column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$dayCapitalized, $dateStr · $timeStr',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        appointment.petName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_hospital_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          appointment.clinicName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Status badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                badgeLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Recuadro de sección (título fuera; contenido dentro) ─────────

class _FavoritesSectionBox extends StatelessWidget {
  final Widget child;

  const _FavoritesSectionBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider),
        ),
        child: child,
      ),
    );
  }
}

// ── Nearby Button ────────────────────────────────────────────────

class _NearbyButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onTap;

  const _NearbyButton({
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            if (loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.primary,
                ),
              )
            else
              const Icon(
                Icons.location_searching_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Buscar clínicas cerca de mí',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Specialty Chip ───────────────────────────────────────────────

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

// ── Clinic Card ──────────────────────────────────────────────────

class _ClinicCard extends StatelessWidget {
  final Clinic clinic;
  const _ClinicCard({required this.clinic});

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
                  Text(
                    clinic.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
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

// ── Empty State ──────────────────────────────────────────────────

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

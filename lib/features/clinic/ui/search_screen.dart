import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../../core/location/user_location_service.dart';
import '../../../core/onboarding/onboarding_keys.dart';
import '../../../core/onboarding/onboarding_provider.dart';
import '../../../core/onboarding/onboarding_showcase.dart';
import '../../appointment/providers/appointment_provider.dart';
import '../providers/clinic_provider.dart';
import '../../../app/theme.dart';
import '../../../core/datetime/app_date_format.dart';
import '../../../core/errors/app_error_presenter.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../l10n/l10n_ext.dart';
import '../../../shared/models/appointment.dart';
import '../../../shared/models/clinic.dart';
import '../../../shared/models/pet.dart';
import '../../../shared/models/profile.dart';
import 'clinic_list_card.dart';

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
  if (n.contains('traumat')) return Icons.emergency_rounded;
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
  bool _locating = false;
  bool _tourStarted = false;
  final ScrollController _scrollController = ScrollController();
  late final OnboardingShowcaseStart _onShowcaseStart;
  late final OnboardingShowcaseComplete _onShowcaseComplete;

  @override
  void initState() {
    super.initState();
    _onShowcaseStart = _handleShowcaseStart;
    _onShowcaseComplete = _handleShowcaseComplete;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addOnboardingStartListener(_onShowcaseStart);
      addOnboardingCompleteListener(_onShowcaseComplete);
      _maybeStartTour();
    });
  }

  @override
  void dispose() {
    removeOnboardingStartListener(_onShowcaseStart);
    removeOnboardingCompleteListener(_onShowcaseComplete);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleShowcaseComplete(int? index, GlobalKey key) {
    if (index == null) return;

    final keys = ref.read(ownerOnboardingKeysProvider);
    final GlobalKey? nextKey = switch (index) {
      1 => keys.favoriteClinics,
      2 => keys.upcomingAppointments,
      3 => keys.bottomNav,
      _ => null,
    };
    if (nextKey != null) {
      unawaited(_animateToShowcaseTarget(nextKey));
    }
  }

  void _handleShowcaseStart(int? index, GlobalKey key) {
    if (index == null || index <= 1) return;
    if (key == ref.read(ownerOnboardingKeysProvider).bottomNav) return;

    _jumpToShowcaseTarget(key);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpToShowcaseTarget(key);
      setState(() {});
    });
  }

  double _scrollAlignmentFor(GlobalKey key) {
    final keys = ref.read(ownerOnboardingKeysProvider);
    if (key == keys.upcomingAppointments) {
      return 0.05;
    }
    if (key == keys.favoriteClinics) {
      return 0.12;
    }
    return 0.25;
  }

  void _jumpToShowcaseTarget(GlobalKey key) {
    if (!mounted || !_scrollController.hasClients) return;

    final clamped = _targetScrollOffset(key);
    if (clamped == null) return;

    if ((_scrollController.offset - clamped).abs() > 1) {
      _scrollController.jumpTo(clamped);
    }
  }

  Future<void> _animateToShowcaseTarget(GlobalKey key) async {
    if (!mounted || !_scrollController.hasClients) return;

    final clamped = _targetScrollOffset(key);
    if (clamped == null) return;

    if ((_scrollController.offset - clamped).abs() <= 1) return;

    await _scrollController.animateTo(
      clamped,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  double? _targetScrollOffset(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null || !ctx.mounted) return null;

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return null;

    final viewport = RenderAbstractViewport.of(renderObject);
    final alignment = _scrollAlignmentFor(key);
    final targetOffset =
        viewport.getOffsetToReveal(renderObject, alignment).offset;
    return targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent);
  }

  Future<void> _maybeStartTour() async {
    if (_tourStarted || !mounted) return;

    if (GoRouterState.of(context).matchedLocation != '/search') return;

    final role = ref.read(profileProvider).valueOrNull?.role;
    if (role != UserRole.owner) return;

    final show = await shouldShowOnboarding(ref, UserRole.owner);
    if (!show || !mounted) return;

    if (ref.read(favoriteClinicsProvider).isLoading) {
      await ref
          .read(favoriteClinicsProvider.future)
          .catchError((_) => <Clinic>[]);
    }
    if (ref.read(myAppointmentsProvider).isLoading) {
      await ref
          .read(myAppointmentsProvider.future)
          .catchError((_) => <Appointment>[]);
    }

    if (!mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    _tourStarted = true;
    final keys = ref.read(ownerOnboardingKeysProvider);
    startOwnerOnboarding([
      keys.searchBar,
      keys.nearby,
      keys.favoriteClinics,
      keys.upcomingAppointments,
      keys.bottomNav,
    ]);
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
      final result = await resolveUserLocation();

      if (!mounted) return;

      if (!result.isSuccess) {
        final l10n = context.l10n;
        switch (result.failure) {
          case UserLocationFailure.serviceDisabled:
            await _showLocationDeniedDialog(
              title: l10n.locationDisabledTitle,
              message: l10n.locationDisabledMessage,
              openSettings: Geolocator.openLocationSettings,
            );
          case UserLocationFailure.permissionDenied:
            await _showLocationDeniedDialog(
              title: l10n.locationPermissionTitle,
              message: l10n.locationPermissionMessage,
              openSettings: Geolocator.openAppSettings,
            );
          case UserLocationFailure.unavailable:
          case null:
            showAppError(context, l10n.errorLocationUnavailable);
        }
        return;
      }

      ref.read(searchFiltersProvider.notifier).update(
            (s) => s.copyWith(
              isNearbyMode: true,
              userLat: result.lat,
              userLng: result.lng,
            ),
          );
      ref.invalidate(clinicSearchProvider);
      context.push(
        '/search/nearby',
        extra: (lat: result.lat!, lng: result.lng!),
      );
    } catch (e) {
      if (!mounted) return;
      showAppError(context, e);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _showLocationDeniedDialog({
    required String title,
    required String message,
    required Future<bool> Function() openSettings,
  }) async {
    final l10n = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await openSettings();
            },
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.valueOrNull;
    final fullName = profile?.fullName.trim() ?? '';
    final firstName =
        fullName.isEmpty ? '' : fullName.split(RegExp(r'\s+')).first;
    final specialtiesAsync = ref.watch(specialtiesProvider);
    final favoritesAsync = ref.watch(favoriteClinicsProvider);
    final appointmentsAsync = ref.watch(myAppointmentsProvider);
    final filters = ref.watch(searchFiltersProvider);
    final specialties = specialtiesAsync.valueOrNull ?? [];
    final onboardingKeys = ref.read(ownerOnboardingKeysProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
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
                      firstName.isEmpty
                          ? Text(
                              l10n.welcomeToVetNow,
                              style: const TextStyle(
                                fontSize: 24,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                            )
                          : RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                                children: [
                                  TextSpan(text: '${l10n.welcomeToVetNow}, '),
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

                      // Abre pantalla de búsqueda en vivo
                      buildOnboardingShowcase(
                        showcaseKey: onboardingKeys.searchBar,
                        title: l10n.onboardingOwnerSearchTitle,
                        description: l10n.onboardingOwnerSearchDesc,
                        l10n: l10n,
                        context: context,
                        enableAutoScroll: false,
                        child: GestureDetector(
                          onTap: () => context.push('/search/query'),
                          child: AbsorbPointer(
                            child: TextField(
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: l10n.searchHintNameCityAddress,
                                prefixIcon: const Icon(Icons.search_rounded),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // "Cerca de mí" button
                      buildOnboardingShowcase(
                        showcaseKey: onboardingKeys.nearby,
                        title: l10n.onboardingOwnerNearbyTitle,
                        description: l10n.onboardingOwnerNearbyDesc,
                        l10n: l10n,
                        context: context,
                        enableAutoScroll: false,
                        child: _NearbyButton(
                          loading: _locating,
                          onTap: _locating ? null : _openNearby,
                        ),
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
                          label: l10n.allSpecialties,
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
                            label: s.localizedLabel(l10n),
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

              // Clínicas favoritas
              favoritesAsync.when(
                data: (allFavs) {
                  Widget content;
                  if (allFavs.isEmpty) {
                    content = _EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: l10n.noFavoriteClinicsTitle,
                      subtitle: l10n.noFavoriteClinicsSubtitle,
                    );
                  } else {
                    final displayed = allFavs.take(3).toList();
                    content = Column(
                      children: [
                        for (var i = 0; i < displayed.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          ClinicListCard(clinic: displayed[i]),
                        ],
                        if (allFavs.length > 3) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () =>
                                  context.push('/search/favorites'),
                              child: Text(
                                l10n.showMore,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return SliverToBoxAdapter(
                    child: buildOnboardingShowcase(
                      showcaseKey: onboardingKeys.favoriteClinics,
                      title: l10n.onboardingOwnerFavoritesTitle,
                      description: l10n.onboardingOwnerFavoritesDesc,
                      l10n: l10n,
                      context: context,
                      enableAutoScroll: true,
                      scrollAlignment: 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              l10n.favoriteClinics,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FavoritesSectionBox(child: content),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: buildOnboardingShowcase(
                    showcaseKey: onboardingKeys.favoriteClinics,
                    title: l10n.onboardingOwnerFavoritesTitle,
                    description: l10n.onboardingOwnerFavoritesDesc,
                    l10n: l10n,
                    context: context,
                    enableAutoScroll: true,
                    scrollAlignment: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            l10n.favoriteClinics,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _FavoritesSectionBox(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: buildOnboardingShowcase(
                    showcaseKey: onboardingKeys.favoriteClinics,
                    title: l10n.onboardingOwnerFavoritesTitle,
                    description: l10n.onboardingOwnerFavoritesDesc,
                    l10n: l10n,
                    context: context,
                    enableAutoScroll: true,
                    scrollAlignment: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            l10n.favoriteClinics,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FavoritesSectionBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text(appErrorMessage(context, e))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Próximas citas
              appointmentsAsync.when(
                data: (all) {
                  final now = DateTime.now();
                  final upcoming = all
                      .where((a) => a.isUpcoming && a.scheduledAt.isAfter(now))
                      .toList()
                    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
                  final displayed = upcoming.take(3).toList();

                  Widget content;
                  if (displayed.isEmpty) {
                    content = _EmptyState(
                      icon: Icons.calendar_today_rounded,
                      title: l10n.noScheduledAppointmentsTitle,
                      subtitle: l10n.noScheduledAppointmentsSubtitle,
                    );
                  } else {
                    content = Column(
                      children: [
                        for (var i = 0; i < displayed.length; i++) ...[
                          if (i > 0) const SizedBox(height: 10),
                          _UpcomingAppointmentCard(
                            appointment: displayed[i],
                          ),
                        ],
                        if (upcoming.length > 3) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => context.go('/appointments'),
                              child: Text(
                                l10n.showMore,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  }

                  return SliverToBoxAdapter(
                    child: buildOnboardingShowcase(
                      showcaseKey: onboardingKeys.upcomingAppointments,
                      title: l10n.onboardingOwnerUpcomingTitle,
                      description: l10n.onboardingOwnerUpcomingDesc,
                      l10n: l10n,
                      context: context,
                      enableAutoScroll: true,
                      scrollAlignment: 0.05,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              l10n.upcomingAppointments,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _FavoritesSectionBox(child: content),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: buildOnboardingShowcase(
                    showcaseKey: onboardingKeys.upcomingAppointments,
                    title: l10n.onboardingOwnerUpcomingTitle,
                    description: l10n.onboardingOwnerUpcomingDesc,
                    l10n: l10n,
                    context: context,
                    enableAutoScroll: true,
                    scrollAlignment: 0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            l10n.upcomingAppointments,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _FavoritesSectionBox(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: buildOnboardingShowcase(
                    showcaseKey: onboardingKeys.upcomingAppointments,
                    title: l10n.onboardingOwnerUpcomingTitle,
                    description: l10n.onboardingOwnerUpcomingDesc,
                    l10n: l10n,
                    context: context,
                    enableAutoScroll: true,
                    scrollAlignment: 0.05,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            l10n.upcomingAppointments,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _FavoritesSectionBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: Text(appErrorMessage(context, e))),
                          ),
                        ),
                      ],
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

class _UpcomingAppointmentCard extends ConsumerWidget {
  final Appointment appointment;
  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final slot = appointment.scheduledAt;
    final dayName = dateFormat('EEEE', locale).format(slot);
    final dayCapitalized =
        dayName[0].toUpperCase() + dayName.substring(1);
    final dateStr =
        dateFormat(searchSlotDatePattern(locale), locale).format(slot);
    final timeStr = dateFormat('HH:mm', locale).format(slot);

    final emoji = switch (appointment.petSpecies) {
      PetSpecies.dog => '🐶',
      PetSpecies.cat => '🐱',
      PetSpecies.rabbit => '🐰',
      PetSpecies.hamster => '🐹',
      PetSpecies.bird => '🦜',
      PetSpecies.reptile => '🦎',
      PetSpecies.fish => '🐟',
      PetSpecies.other => '🐾',
    };

    final (badgeLabel, badgeColor) = appointment.isPending
        ? (l10n.statusPending, Colors.orange.shade700)
        : (l10n.statusConfirmed, AppTheme.primary);

    return GestureDetector(
      onTap: () => context.go('/appointments'),
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
                    dateFormat('d', locale).format(slot),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateFormat('MMM', locale).format(slot),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '$dayCapitalized, $dateStr · $timeStr',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.petName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
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
            Expanded(
              child: Text(
                context.l10n.searchClinicsNearMe,
                style: const TextStyle(
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

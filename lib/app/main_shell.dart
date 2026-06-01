import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import '../l10n/l10n_ext.dart';
import '../app/theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/appointment/providers/appointment_provider.dart';
import '../features/clinic_panel/providers/clinic_panel_provider.dart';
import '../shared/models/profile.dart';
import '../core/onboarding/onboarding_keys.dart';
import '../core/onboarding/onboarding_provider.dart';
import '../core/onboarding/onboarding_showcase.dart';
import '../core/appointments/appointment_sync_scheduler.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  bool _showcaseRegistered = false;
  AppointmentSyncScheduler? _appointmentSync;

  @override
  void initState() {
    super.initState();
    _appointmentSync = AppointmentSyncScheduler(
      onSync: () {
        ref.invalidate(clinicAppointmentsProvider);
        ref.invalidate(myAppointmentsProvider);
      },
    )..start();
  }

  @override
  void dispose() {
    _appointmentSync?.stop();
    unregisterOnboardingShowcaseView();
    super.dispose();
  }

  void _ensureShowcaseRegistered(UserRole role) {
    if (_showcaseRegistered) return;
    _showcaseRegistered = true;

    final l10n = context.l10n;
    final lastKey = role == UserRole.clinic
        ? ref.read(clinicOnboardingKeysProvider).bottomNav
        : ref.read(ownerOnboardingKeysProvider).bottomNav;

    registerOnboardingShowcaseView(
      onComplete: () => completeOnboarding(ref, role),
      skipLabel: l10n.onboardingSkip,
      lastStepKey: lastKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    if (profileAsync.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final profile = profileAsync.valueOrNull;
    final isClinic = profile?.role == UserRole.clinic;
    final role = isClinic ? UserRole.clinic : UserRole.owner;

    _ensureShowcaseRegistered(role);

    final bottomNavKey = isClinic
        ? ref.read(clinicOnboardingKeysProvider).bottomNav
        : ref.read(ownerOnboardingKeysProvider).bottomNav;
    final l10n = context.l10n;

    final navBar = isClinic
        ? _clinicNavBar(context, ref)
        : _ownerNavBar(context);

    final navTitle = isClinic
        ? l10n.onboardingClinicNavTitle
        : l10n.onboardingOwnerNavTitle;
    final navDesc = isClinic
        ? l10n.onboardingClinicNavDesc
        : l10n.onboardingOwnerNavDesc;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: buildOnboardingShowcase(
        showcaseKey: bottomNavKey,
        title: navTitle,
        description: navDesc,
        l10n: l10n,
        context: context,
        isLastStep: true,
        tooltipPosition: TooltipPosition.top,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: navBar,
        ),
      ),
    );
  }

  Widget _ownerNavBar(BuildContext context) {
    final l10n = context.l10n;
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/search')) index = 0;
    if (location.startsWith('/appointments')) index = 1;
    if (location.startsWith('/pets')) index = 2;
    if (location.startsWith('/profile')) index = 3;

    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        switch (i) {
          case 0:
            context.go('/search');
            break;
          case 1:
            context.go('/appointments');
            break;
          case 2:
            context.go('/pets');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.search_rounded),
          label: l10n.navSearch,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month_rounded),
          label: l10n.navAppointments,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.pets_rounded),
          label: l10n.navPets,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_rounded),
          label: l10n.navProfile,
        ),
      ],
    );
  }

  Widget _clinicNavBar(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/clinic-home')) index = 0;
    if (location.startsWith('/clinic-agenda')) index = 1;
    if (location.startsWith('/clinic-patients')) index = 2;
    if (location.startsWith('/clinic-profile')) index = 3;

    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) => _onClinicNavTap(context, ref, i, index, location),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard_rounded),
          label: l10n.navClinicHome,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.calendar_month_rounded),
          label: l10n.navClinicAgenda,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.people_rounded),
          label: l10n.navClinicPatients,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.store_rounded),
          label: l10n.navMyClinic,
        ),
      ],
    );
  }

  Future<void> _onClinicNavTap(
    BuildContext context,
    WidgetRef ref,
    int targetIndex,
    int currentIndex,
    String location,
  ) async {
    if (currentIndex == targetIndex) return;

    if (location.startsWith('/clinic-profile')) {
      final exitHandler = ref.read(clinicProfileExitHandlerProvider);
      if (exitHandler != null) {
        final canLeave = await exitHandler();
        if (!canLeave) return;
      }
    }

    if (!context.mounted) return;

    switch (targetIndex) {
      case 0:
        context.go('/clinic-home');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(myClinicProvider);
          ref.invalidate(clinicAppointmentsProvider);
        });
        break;
      case 1:
        context.go('/clinic-agenda');
        break;
      case 2:
        context.go('/clinic-patients');
        break;
      case 3:
        context.go('/clinic-profile');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.invalidate(myClinicProvider);
        });
        break;
    }
  }
}

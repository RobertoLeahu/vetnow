import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/l10n_ext.dart';
import '../app/theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/clinic_panel/providers/clinic_panel_provider.dart';
import '../shared/models/profile.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    if (profileAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profile = profileAsync.valueOrNull;
    final isClinic = profile?.role == UserRole.clinic;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: isClinic ? _clinicNavBar(context, ref) : _ownerNavBar(context),
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
        ref.invalidate(clinicAppointmentsProvider);
        context.go('/clinic-home');
        break;
      case 1:
        context.go('/clinic-agenda');
        break;
      case 2:
        context.go('/clinic-patients');
        break;
      case 3:
        context.go('/clinic-profile');
        break;
    }
  }
}

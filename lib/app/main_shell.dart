import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/theme.dart';
import '../features/auth/providers/auth_provider.dart';
import '../shared/models/profile.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).valueOrNull;
    final isClinic = profile?.role == UserRole.clinic;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: isClinic ? _ClinicNavBar(context) : _OwnerNavBar(context),
      ),
    );
  }

  Widget _OwnerNavBar(BuildContext context) {
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
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded),
          label: 'Buscar',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Citas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets_rounded),
          label: 'Mascotas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Perfil',
        ),
      ],
    );
  }

  Widget _ClinicNavBar(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    int index = 0;
    if (location.startsWith('/clinic-home')) index = 0;
    if (location.startsWith('/clinic-agenda')) index = 1;
    if (location.startsWith('/clinic-patients')) index = 2;
    if (location.startsWith('/clinic-profile')) index = 3;

    return BottomNavigationBar(
      currentIndex: index,
      onTap: (i) {
        switch (i) {
          case 0:
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
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_rounded),
          label: 'Agenda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_rounded),
          label: 'Pacientes',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.store_rounded),
          label: 'Mi clínica',
        ),
      ],
    );
  }
}

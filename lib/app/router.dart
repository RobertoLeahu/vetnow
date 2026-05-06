import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/register_screen.dart';
import '../features/auth/ui/role_selector_screen.dart';
import '../features/clinic/ui/search_screen.dart';
import '../features/clinic/ui/clinic_detail_screen.dart';
import '../features/appointment/ui/appointments_screen.dart';
import '../features/appointment/ui/booking_screen.dart';
import '../features/pet/ui/pets_screen.dart';
import '../features/profile/ui/profile_screen.dart';
import '../features/profile/ui/settings_screen.dart';
import '../features/clinic_panel/ui/clinic_home_screen.dart';
import '../features/clinic_panel/ui/clinic_agenda_screen.dart';
import '../features/clinic_panel/ui/clinic_patients_screen.dart';
import '../features/clinic_panel/ui/clinic_profile_screen.dart';
import '../shared/models/profile.dart';
import '../shared/models/specialty.dart';
import 'main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/search',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/role-selector';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        // Redirige según rol al hacer login
        final role = profileAsync.valueOrNull?.role;
        if (role == UserRole.clinic) return '/clinic-home';
        return '/search';
      }
      return null;
    },
    routes: [
      // ── Auth (sin shell) ──────────────────────────────────────────
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/role-selector',
        builder: (_, __) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, state) =>
            RegisterScreen(role: state.extra as UserRole? ?? UserRole.owner),
      ),

      // ── Shell compartido ──────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          //── Rutas propietario ─────────────────────────────────────
          GoRoute(
            path: '/search',
            builder: (_, __) => const SearchScreen(),
            routes: [
              GoRoute(
                path: 'clinic/:id',
                builder: (_, state) =>
                    ClinicDetailScreen(clinicId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'book',
                    builder: (_, state) => BookingScreen(
                      clinicId: state.pathParameters['id']!,
                      specialty: state.extra as Specialty,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/appointments',
            builder: (_, __) => const AppointmentsScreen(),
          ),
          GoRoute(path: '/pets', builder: (_, __) => const PetsScreen()),
          GoRoute(
            path: '/profile',
            builder: (_, __) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (_, __) => const SettingsScreen(),
              ),
            ],
          ),

          // ── Rutas clínica ─────────────────────────────────────────
          GoRoute(
            path: '/clinic-home',
            builder: (_, __) => const ClinicHomeScreen(),
          ),
          GoRoute(
            path: '/clinic-agenda',
            builder: (_, __) => const ClinicAgendaScreen(),
          ),
          GoRoute(
            path: '/clinic-patients',
            builder: (_, __) => const ClinicPatientsScreen(),
          ),
          GoRoute(
            path: '/clinic-profile',
            builder: (_, __) => const ClinicProfileScreen(),
          ),
        ],
      ),
    ],
  );
});

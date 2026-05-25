import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/register_screen.dart';
import '../features/auth/ui/role_selector_screen.dart';
import '../features/clinic/ui/search_screen.dart';
import '../features/clinic/ui/clinic_text_search_screen.dart';
import '../features/clinic/ui/nearby_screen.dart';
import '../features/clinic/ui/clinic_detail_screen.dart';
import '../features/appointment/ui/appointments_screen.dart';
import '../features/appointment/ui/booking_screen.dart';
import '../features/pet/ui/pets_screen.dart';
import '../features/profile/ui/profile_screen.dart';
import '../features/profile/ui/settings_screen.dart';
import '../features/profile/ui/account_screen.dart';
import '../features/profile/ui/personalization_screen.dart';
import '../features/profile/ui/legal_text_screen.dart';
import '../shared/legal/legal_texts.dart';
import '../features/clinic_panel/ui/clinic_home_screen.dart';
import '../features/clinic_panel/ui/clinic_agenda_screen.dart';
import '../features/clinic_panel/ui/clinic_patients_screen.dart';
import '../features/clinic_panel/ui/clinic_profile_screen.dart';
import '../core/supabase/supabase_client.dart';
import '../shared/models/profile.dart';
import '../shared/models/specialty.dart';
import 'main_shell.dart';

bool _isOwnerShellPath(String loc) {
  return loc.startsWith('/search') ||
      loc.startsWith('/appointments') ||
      loc.startsWith('/pets') ||
      loc.startsWith('/profile');
}

bool _isClinicShellPath(String loc) {
  return loc.startsWith('/clinic-home') ||
      loc.startsWith('/clinic-agenda') ||
      loc.startsWith('/clinic-patients') ||
      loc.startsWith('/clinic-profile');
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileAsync = ref.watch(profileProvider);

  return GoRouter(
    initialLocation: '/search',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final session =
          authState.asData?.value.session ?? supabase.auth.currentSession;
      final isLoggedIn = session != null;

      final isAuthRoute =
          loc == '/login' ||
          loc == '/register' ||
          loc == '/role-selector';
      final isLegalRoute =
          loc == '/legal/privacy' || loc == '/legal/terms';
      final isPublicRoute = isAuthRoute || isLegalRoute;

      if (!isLoggedIn) {
        if (loc == '/auth-resolve') return '/login';
        if (!isPublicRoute) return '/login';
        return null;
      }

      // Sesión activa: esperar perfil antes de mostrar rutas del shell por rol
      if (profileAsync.isLoading) {
        if (loc != '/auth-resolve' && !isPublicRoute) return '/auth-resolve';
        return null;
      }

      final role = profileAsync.valueOrNull?.role ?? UserRole.owner;

      if (loc == '/auth-resolve') {
        if (profileAsync.isLoading || profileAsync.valueOrNull == null) {
          return null;
        }
        return role == UserRole.clinic ? '/clinic-home' : '/search';
      }

      if (isAuthRoute) {
        return role == UserRole.clinic ? '/clinic-home' : '/search';
      }

      if (role == UserRole.clinic && _isOwnerShellPath(loc)) {
        return '/clinic-home';
      }
      if (role == UserRole.owner && _isClinicShellPath(loc)) {
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
      GoRoute(
        path: '/legal/privacy',
        builder: (_, __) => const LegalTextScreen(
          title: 'Política de privacidad',
          content: kPrivacyPolicy,
        ),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (_, __) => const LegalTextScreen(
          title: 'Términos y condiciones',
          content: kTermsOfService,
        ),
      ),
      GoRoute(
        path: '/auth-resolve',
        builder: (_, __) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
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
                path: 'query',
                builder: (_, __) => const ClinicTextSearchScreen(),
              ),
              GoRoute(
                path: 'nearby',
                builder: (_, state) {
                  final coords = state.extra as ({double lat, double lng});
                  return NearbyScreen(
                    userLat: coords.lat,
                    userLng: coords.lng,
                  );
                },
              ),
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
                routes: [
                  GoRoute(
                    path: 'account',
                    builder: (_, __) => const AccountScreen(),
                  ),
                  GoRoute(
                    path: 'personalization',
                    builder: (_, __) => const PersonalizationScreen(),
                  ),
                ],
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
            builder: (_, state) => ClinicAgendaScreen(
              initialTabIndex: state.extra as int? ?? 0,
            ),
          ),
          GoRoute(
            path: '/clinic-patients',
            builder: (_, __) => const ClinicPatientsScreen(),
            routes: [
              GoRoute(
                path: ':ownerId',
                builder: (_, state) => OwnerPetsScreen(
                  ownerId: state.pathParameters['ownerId']!,
                  ownerName: state.extra as String? ?? '',
                ),
                routes: [
                  GoRoute(
                    path: ':petId',
                    builder: (_, state) => PetVisitsScreen(
                      ownerId: state.pathParameters['ownerId']!,
                      petId: state.pathParameters['petId']!,
                      petName: state.extra as String? ?? '',
                    ),
                  ),
                ],
              ),
            ],
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

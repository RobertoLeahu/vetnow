// Router con redirección por auth y rol
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/ui/login_screen.dart';
import '../features/auth/ui/register_screen.dart';
import '../features/auth/ui/role_selector_screen.dart';
import '../shared/models/profile.dart';
import '../features/clinic/ui/search_screen.dart';
import '../features/clinic/ui/clinic_detail_screen.dart';

// Pantallas placeholder
import '../features/profile/ui/owner_home_screen.dart';
import '../features/profile/ui/clinic_home_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull?.session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/role-selector';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final role = state.extra as UserRole? ?? UserRole.owner;
          return RegisterScreen(role: role);
        },
      ),
      GoRoute(
        path: '/role-selector',
        builder: (_, __) => const RoleSelectorScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          // Redirige según rol al cargar /home
          return Consumer(
            builder: (context, ref, _) {
              final profile = ref.watch(profileProvider);
              return profile.when(
                data: (p) => p?.role == UserRole.clinic
                    ? const ClinicHomeScreen()
                    : const OwnerHomeScreen(),
                loading: () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => const LoginScreen(),
              );
            },
          );
        },
      ),
      GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
      GoRoute(
        path: '/clinic/:id',
        builder: (context, state) =>
            ClinicDetailScreen(clinicId: state.pathParameters['id']!),
      ),
    ],
  );
});

//Auth Provider con Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/profile.dart';

// Repositorio como provider
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

// Estado del perfil del usuario logueado.
// Espera al primer evento de auth para no resolver `null` mientras el stream arranca.
final profileProvider = FutureProvider<Profile?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final authState = await ref.watch(authStateProvider.future);
  final user = authState.session?.user;
  if (user == null) return null;
  return repo.fetchProfile(user.id);
});

// Stream de sesión — úsalo en el router para redirigir
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
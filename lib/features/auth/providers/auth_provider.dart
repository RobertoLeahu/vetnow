//Auth Provider con Riverpod
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';
import '../../../shared/models/profile.dart';

// Repositorio como provider
final authRepositoryProvider = Provider<AuthRepository>(
  (_) => AuthRepository(),
);

// Estado del perfil del usuario logueado. Se recarga cuando cambia la sesión.
final profileProvider = FutureProvider<Profile?>((ref) async {
  final repo = ref.read(authRepositoryProvider);
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value.session?.user ?? repo.currentUser;
  if (user == null) return null;
  return repo.fetchProfile(user.id);
});

// Stream de sesión — úsalo en el router para redirigir
final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
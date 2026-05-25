//Auth Repository
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/profile.dart';

class AuthRepository {
  // Sesión actual
  Session? get currentSession => supabase.auth.currentSession;
  User? get currentUser => supabase.auth.currentUser;

  // Stream de cambios de sesión
  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  /// Registro: crea usuario en Auth y luego el perfil en la tabla profiles
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    DateTime? privacyAcceptedAt,
    DateTime? termsAcceptedAt,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Error al crear el usuario');

    await supabase.from('profiles').insert({
      'id': user.id,
      'role': role.name,
      'full_name': fullName,
      if (privacyAcceptedAt != null)
        'privacy_accepted_at': privacyAcceptedAt.toIso8601String(),
      if (termsAcceptedAt != null)
        'terms_accepted_at': termsAcceptedAt.toIso8601String(),
    });

    // Para clínicas, crear fila mínima en la tabla clinics
    if (role == UserRole.clinic) {
      await supabase.from('clinics').insert({
        'profile_id': user.id,
        'name': fullName,
        'address': '',
        'city': '',
      });
    }
  }

  /// Login estándar
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Logout
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Obtener perfil del usuario actual
  Future<Profile?> fetchProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return Profile.fromMap(data);
  }

  /// Actualiza el teléfono en `profiles` (un solo campo; incluye prefijo y número).
  Future<void> updatePhone({
    required String userId,
    String? phone,
  }) async {
    await supabase.from('profiles').update({'phone': phone}).eq('id', userId);
  }

  /// Cambia la contraseña del usuario autenticado.
  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Elimina todos los datos del usuario (RGPD: derecho de supresión) y cierra sesión.
  Future<void> deleteCurrentAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('No hay usuario autenticado');

    await supabase.from('pets').delete().eq('owner_id', user.id);
    await supabase.from('appointments').delete().eq('owner_id', user.id);
    await supabase.from('clinic_favorites').delete().eq('owner_id', user.id);
    await supabase.from('profiles').delete().eq('id', user.id);
    await signOut();
  }
}
import 'package:supabase_flutter/supabase_flutter.dart';

/// Acceso a Supabase Auth. No valida datos de negocio ni permisos: esos se
/// aplican en la base de datos mediante RLS.
class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: data,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}

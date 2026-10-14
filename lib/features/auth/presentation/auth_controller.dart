import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';

enum AuthStatus { idle, loading, success, error }

class AuthFormState {
  const AuthFormState({this.status = AuthStatus.idle, this.message});

  final AuthStatus status;
  final String? message;

  bool get isLoading => status == AuthStatus.loading;

  AuthFormState copyWith({AuthStatus? status, String? message}) {
    return AuthFormState(
      status: status ?? this.status,
      message: message,
    );
  }
}

/// Controla las acciones de autenticación y expone su estado a la UI.
/// No gestiona la sesión persistente: eso lo hace Supabase.
class AuthController extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<bool> signIn({required String email, required String password}) async {
    state = const AuthFormState(status: AuthStatus.loading);
    try {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
      state = const AuthFormState(status: AuthStatus.success);
      return true;
    } on AuthException catch (error) {
      state = AuthFormState(
        status: AuthStatus.error,
        message: _traducir(error.message),
      );
      return false;
    } catch (_) {
      state = const AuthFormState(
        status: AuthStatus.error,
        message: 'No se pudo iniciar sesión. Intenta de nuevo.',
      );
      return false;
    }
  }

  /// Crea la cuenta y envía alias, tipo de perfil, programa y sede en los
  /// metadatos del usuario. El trigger `crear_perfil_auth_user` de la base de
  /// datos usa esos datos para crear el perfil.
  ///
  /// Devuelve `true` si la sesión quedó activa; `false` si falta confirmar el
  /// correo (según la configuración de Auth del proyecto).
  Future<bool> signUp({
    required String email,
    required String password,
    required String alias,
    required int tipoPerfilId,
    int? programaId,
    int? sedeId,
  }) async {
    state = const AuthFormState(status: AuthStatus.loading);
    try {
      final response = await ref.read(authRepositoryProvider).signUp(
            email: email,
            password: password,
            data: {
              'alias': alias.trim(),
              'tipo_perfil_id': tipoPerfilId,
              'programa_id': programaId,
              'sede_id': sedeId,
            },
          );
      if (response.session == null) {
        state = const AuthFormState(
          status: AuthStatus.success,
          message: 'Revisa tu correo para confirmar la cuenta.',
        );
        return false;
      }
      final userId = response.user?.id;
      if (userId != null) {
        try {
          await ref.read(perfilRepositoryProvider).updatePerfil(
                id: userId,
                alias: alias,
                tipoPerfilId: tipoPerfilId,
                programaId: programaId,
                sedeId: sedeId,
              );
        } catch (_) {
          // El trigger ya crea el perfil con estos datos; este guardado es un
          // respaldo por si la migración aún no está aplicada.
        }
      }
      state = const AuthFormState(status: AuthStatus.success);
      return true;
    } on AuthException catch (error) {
      state = AuthFormState(
        status: AuthStatus.error,
        message: _traducir(error.message),
      );
      return false;
    } catch (_) {
      state = const AuthFormState(
        status: AuthStatus.error,
        message: 'No se pudo crear la cuenta. Intenta de nuevo.',
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } finally {
      state = const AuthFormState();
    }
  }

  void clearMessage() {
    state = AuthFormState(status: state.status);
  }

  String _traducir(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }
    if (normalized.contains('user already registered')) {
      return 'Ya existe una cuenta con ese correo.';
    }
    if (normalized.contains('password should be at least')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    if (normalized.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }
    return message;
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthFormState>(AuthController.new);

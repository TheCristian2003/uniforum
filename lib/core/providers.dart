import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/catalogo_item.dart';
import '../data/models/perfil.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/catalogo_repository.dart';
import '../data/repositories/perfil_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

final perfilRepositoryProvider = Provider<PerfilRepository>(
  (ref) => PerfilRepository(ref.watch(supabaseClientProvider)),
);

final catalogoRepositoryProvider = Provider<CatalogoRepository>(
  (ref) => CatalogoRepository(ref.watch(supabaseClientProvider)),
);

/// Emite en cada cambio de sesión (login, logout, refresco de token).
final authStateChangesProvider = StreamProvider<AuthState>(
  (ref) => ref.watch(authRepositoryProvider).onAuthStateChange,
);

final currentUserProvider = Provider<User?>((ref) {
  ref.watch(authStateChangesProvider);
  return ref.watch(authRepositoryProvider).currentUser;
});

/// Perfil del usuario autenticado. Es `null` si no hay sesión.
final perfilActualProvider = FutureProvider<Perfil?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(perfilRepositoryProvider).fetchById(user.id);
});

/// Catálogo de `maestra` para un `grupo` concreto.
final catalogoProvider =
    FutureProvider.family<List<CatalogoItem>, String>((ref, grupo) {
  return ref.watch(catalogoRepositoryProvider).fetchGrupo(grupo);
});

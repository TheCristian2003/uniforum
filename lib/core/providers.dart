import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/models/canal.dart';
import '../data/models/catalogo_item.dart';
import '../data/models/comentario.dart';
import '../data/models/insignia.dart';
import '../data/models/mis_votos.dart';
import '../data/models/perfil.dart';
import '../data/models/publicacion.dart';
import '../data/models/reporte.dart';
import '../data/models/restriccion.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/canales_repository.dart';
import '../data/repositories/catalogo_repository.dart';
import '../data/repositories/comentarios_repository.dart';
import '../data/repositories/gamificacion_repository.dart';
import '../data/repositories/imagenes_repository.dart';
import '../data/repositories/moderacion_repository.dart';
import '../data/repositories/perfil_repository.dart';
import '../data/repositories/publicaciones_repository.dart';
import '../data/repositories/reportes_repository.dart';
import '../data/repositories/votos_repository.dart';

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

final canalesRepositoryProvider = Provider<CanalesRepository>(
  (ref) => CanalesRepository(ref.watch(supabaseClientProvider)),
);

final publicacionesRepositoryProvider = Provider<PublicacionesRepository>(
  (ref) => PublicacionesRepository(ref.watch(supabaseClientProvider)),
);

final comentariosRepositoryProvider = Provider<ComentariosRepository>(
  (ref) => ComentariosRepository(ref.watch(supabaseClientProvider)),
);

final imagenesRepositoryProvider = Provider<ImagenesRepository>(
  (ref) => ImagenesRepository(ref.watch(supabaseClientProvider)),
);

final votosRepositoryProvider = Provider<VotosRepository>(
  (ref) => VotosRepository(ref.watch(supabaseClientProvider)),
);

final reportesRepositoryProvider = Provider<ReportesRepository>(
  (ref) => ReportesRepository(ref.watch(supabaseClientProvider)),
);

final moderacionRepositoryProvider = Provider<ModeracionRepository>(
  (ref) => ModeracionRepository(ref.watch(supabaseClientProvider)),
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

/// Canales activos para la pestaña de Canales.
final canalesProvider = FutureProvider<List<Canal>>((ref) {
  return ref.watch(canalesRepositoryProvider).fetchCanales();
});

/// Publicaciones recientes para el feed de Inicio.
final feedRecientesProvider = FutureProvider<List<Publicacion>>((ref) {
  return ref.watch(publicacionesRepositoryProvider).fetchRecientes();
});

/// Publicaciones de un canal concreto.
final publicacionesDeCanalProvider =
    FutureProvider.family<List<Publicacion>, String>((ref, canalId) {
  return ref.watch(publicacionesRepositoryProvider).fetchPorCanal(canalId);
});

/// Detalle de una publicación concreta (datos frescos, incluido su puntaje).
final publicacionDetalleProvider =
    FutureProvider.family<Publicacion?, String>((ref, publicacionId) {
  return ref.watch(publicacionesRepositoryProvider).fetchPorId(publicacionId);
});

/// Comentarios de una publicación, en orden cronológico.
final comentariosDePublicacionProvider =
    FutureProvider.family<List<Comentario>, String>((ref, publicacionId) {
  return ref
      .watch(comentariosRepositoryProvider)
      .fetchPorPublicacion(publicacionId);
});

/// Votos del usuario autenticado (publicaciones y comentarios).
final misVotosProvider = FutureProvider<MisVotos>((ref) {
  return ref.watch(votosRepositoryProvider).fetchMisVotos();
});

/// Reportes pendientes. RLS los devuelve solo a moderación; para el resto de
/// usuarios la lista llega vacía.
final reportesPendientesProvider = FutureProvider<List<Reporte>>((ref) {
  return ref.watch(reportesRepositoryProvider).fetchPendientes();
});

final miRestriccionActivaProvider = FutureProvider<Restriccion?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return ref.watch(moderacionRepositoryProvider).fetchRestriccionActiva();
});

final gamificacionRepositoryProvider = Provider<GamificacionRepository>(
  (ref) => GamificacionRepository(ref.watch(supabaseClientProvider)),
);

/// Distintivos de un usuario (con marca de cuáles ya obtuvo).
final insigniasUsuarioProvider =
    FutureProvider.family<List<Insignia>, String>((ref, usuarioId) {
  return ref.watch(gamificacionRepositoryProvider).fetchInsignias(usuarioId);
});

/// Estadísticas de participación de un usuario para el perfil.
final estadisticasUsuarioProvider =
    FutureProvider.family<EstadisticasUsuario, String>((ref, usuarioId) {
  return ref
      .watch(gamificacionRepositoryProvider)
      .fetchEstadisticas(usuarioId);
});

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/restriccion.dart';

/// Acciones de moderación sobre contenido y cuentas.
///
/// Ocultar una publicación y restringir usuarios se hace por RPC `SECURITY
/// DEFINER`: el backend verifica `es_rol_privilegiado()` y ninguna columna
/// sensible se expone al cliente. El borrado duro reutiliza el `delete` REST,
/// que RLS ya restringe a roles privilegiados.
class ModeracionRepository {
  ModeracionRepository(this._client);

  final SupabaseClient _client;

  static const duraciones = <({String label, int? value})>[
    (label: '1 día', value: 1),
    (label: '7 días', value: 7),
    (label: '30 días', value: 30),
    (label: 'Permanente', value: null),
  ];

  /// Oculta una publicación (`estado_id = 'oculto'`).
  Future<void> ocultarPublicacion(String publicacionId) async {
    await _client.rpc(
      'moderar_ocultar_publicacion',
      params: {'p_publicacion_id': publicacionId},
    );
  }

  /// Borrado duro de una publicación (RLS lo permite a roles privilegiados).
  Future<void> eliminarPublicacion(String publicacionId) async {
    await _client.from('publicaciones').delete().eq('id', publicacionId);
  }

  /// Borrado duro de un comentario (RLS lo permite a roles privilegiados).
  Future<void> eliminarComentario(String comentarioId) async {
    await _client.from('comentarios').delete().eq('id', comentarioId);
  }

  /// Restringe a un usuario. `dias` nulo significa permanente.
  Future<void> restringirUsuario({
    required String usuarioId,
    required String motivo,
    required int? dias,
    String? reporteId,
  }) async {
    await _client.rpc(
      'moderar_restringir_usuario',
      params: {
        'p_usuario_id': usuarioId,
        'p_motivo': motivo.trim(),
        'p_dias': ?dias,
        'p_reporte_id': ?reporteId,
      },
    );
  }

  /// Levanta una restricción vigente antes de su fecha de fin.
  Future<void> levantarRestriccion(String restriccionId) async {
    await _client.rpc(
      'moderar_levantar_restriccion',
      params: {'p_restriccion_id': restriccionId},
    );
  }

  /// Restricción vigente del usuario autenticado, o `null` si no tiene.
  Future<Restriccion?> fetchRestriccionActiva() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final row = await _client
        .from('restricciones_usuario')
        .select('id, usuario_id, motivo, inicia_en, expira_en, activa, creado_en, '
            'tipo:maestra!tipo_id(codigo)')
        .eq('usuario_id', user.id)
        .eq('activa', true)
        .order('creado_en', ascending: false)
        .limit(1)
        .maybeSingle();
    if (row == null) return null;
    final restriccion =
        Restriccion.fromJson(Map<String, dynamic>.from(row as Map));
    return restriccion.vigente ? restriccion : null;
  }
}

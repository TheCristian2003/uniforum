import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/comentario.dart';

/// Lectura y creación de comentarios, y marcado de solución.
class ComentariosRepository {
  ComentariosRepository(this._client);

  final SupabaseClient _client;

  static const _columnas = 'id, publicacion_id, autor_id, cuerpo, '
      'es_solucion, puntaje, imagenes, creado_en, '
      'autor:perfiles(alias, avatar_url, es_verificada)';

  Future<List<Comentario>> fetchPorPublicacion(String publicacionId) async {
    final rows = await _client
        .from('comentarios')
        .select(_columnas)
        .eq('publicacion_id', publicacionId)
        .order('creado_en');
    return rows
        .map((row) => Comentario.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  /// Solo se envía `publicacion_id`, `cuerpo` e `imagenes`; `autor_id` lo fija
  /// el backend.
  Future<void> crear({
    required String publicacionId,
    required String cuerpo,
    List<String> imagenes = const [],
  }) async {
    await _client.from('comentarios').insert({
      'publicacion_id': publicacionId,
      'cuerpo': cuerpo,
      if (imagenes.isNotEmpty) 'imagenes': imagenes,
    });
  }

  /// Marca una solución. El backend valida que solo el autor de la publicación
  /// pueda hacerlo.
  Future<void> marcarSolucion(String comentarioId) async {
    await _client.rpc(
      'marcar_comentario_solucion',
      params: {'p_comentario_id': comentarioId},
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/accion_voto.dart';
import '../models/mis_votos.dart';

/// Votos del usuario autenticado sobre publicaciones y comentarios.
///
/// El `usuario_id` lo fija el backend y RLS garantiza que solo se operen los
/// votos propios; el repositorio solo decide insertar, actualizar o eliminar.
class VotosRepository {
  VotosRepository(this._client);

  final SupabaseClient _client;

  Future<MisVotos> fetchMisVotos() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const MisVotos.vacia();

    final rows = await _client
        .from('votos')
        .select('publicacion_id, comentario_id, valor')
        .eq('usuario_id', uid);

    final publicaciones = <String, int>{};
    final comentarios = <String, int>{};
    for (final row in rows) {
      final valor = row['valor'] as int;
      final publicacionId = row['publicacion_id'] as String?;
      final comentarioId = row['comentario_id'] as String?;
      if (publicacionId != null) {
        publicaciones[publicacionId] = valor;
      } else if (comentarioId != null) {
        comentarios[comentarioId] = valor;
      }
    }
    return MisVotos(publicaciones: publicaciones, comentarios: comentarios);
  }

  Future<void> votarPublicacion({
    required String publicacionId,
    required int valor,
    int? votoActual,
  }) {
    return _aplicar(
      valor: valor,
      votoActual: votoActual,
      publicacionId: publicacionId,
    );
  }

  Future<void> votarComentario({
    required String comentarioId,
    required int valor,
    int? votoActual,
  }) {
    return _aplicar(
      valor: valor,
      votoActual: votoActual,
      comentarioId: comentarioId,
    );
  }

  Future<void> _aplicar({
    required int valor,
    required int? votoActual,
    String? publicacionId,
    String? comentarioId,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('No hay sesión activa para votar.');
    }
    final columna = publicacionId != null ? 'publicacion_id' : 'comentario_id';
    final objetivo = publicacionId ?? comentarioId!;

    switch (accionVoto(votoActual, valor)) {
      case AccionVoto.insertar:
        await _client.from('votos').insert({
          columna: objetivo,
          'valor': valor,
        });
      case AccionVoto.actualizar:
        await _client
            .from('votos')
            .update({'valor': valor})
            .eq('usuario_id', uid)
            .eq(columna, objetivo);
      case AccionVoto.eliminar:
        await _client
            .from('votos')
            .delete()
            .eq('usuario_id', uid)
            .eq(columna, objetivo);
    }
  }
}

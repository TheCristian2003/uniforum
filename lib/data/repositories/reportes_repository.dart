import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/reporte.dart';

/// Creación de reportes y su gestión por parte de moderación.
///
/// El cliente nunca envía `reportante_id` ni `estado_id`: el backend fija
/// `reportante_id` con `auth.uid()` y el estado inicial `pendiente`. La lectura
/// y la actualización de estado están limitadas por RLS a moderación.
class ReportesRepository {
  ReportesRepository(this._client);

  final SupabaseClient _client;

  static const _columnas = 'id, publicacion_id, comentario_id, descripcion, '
      'creado_en, '
      'motivo:maestra!motivo_id(nombre), '
      'estado:maestra!estado_id(codigo), '
      'reportante:perfiles(alias), '
      'publicacion:publicaciones(id, titulo, cuerpo, autor_id), '
      'comentario:comentarios(id, cuerpo, autor_id)';

  static const motivo = 'motivo_reporte';
  static const estado = 'estado_reporte';

  /// Crea un reporte para exactamente un objetivo. El backend evita reportes
  /// pendientes duplicados del mismo usuario sobre el mismo contenido.
  Future<void> crear({
    String? publicacionId,
    String? comentarioId,
    required int motivoId,
    String? descripcion,
  }) async {
    assert(
      (publicacionId != null) ^ (comentarioId != null),
      'El reporte debe apuntar a una publicación o a un comentario, no a ambos.',
    );
    await _client.from('reportes').insert({
      'publicacion_id': ?publicacionId,
      'comentario_id': ?comentarioId,
      'motivo_id': motivoId,
      if (descripcion != null && descripcion.trim().isNotEmpty)
        'descripcion': descripcion.trim(),
    });
  }

  /// Reportes pendientes, visibles solo para moderación por RLS.
  Future<List<Reporte>> fetchPendientes() async {
    final estadoId = await idEstado('pendiente');
    final rows = await _client
        .from('reportes')
        .select(_columnas)
        .eq('estado_id', estadoId)
        .order('creado_en');
    return rows
        .map((row) => Reporte.fromJson(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  /// Cambia el estado de un reporte (por ejemplo a `revisado` o `cerrado`).
  Future<void> marcarEstado({
    required String reporteId,
    required int estadoId,
  }) async {
    await _client
        .from('reportes')
        .update({'estado_id': estadoId}).eq('id', reporteId);
  }

  /// Resuelve el `id_maestra` de un estado de reporte por su código.
  Future<int> idEstado(String codigo) async {
    final row = await _client
        .from('maestra')
        .select('id_maestra')
        .eq('grupo', estado)
        .eq('codigo', codigo)
        .maybeSingle();
    if (row == null) {
      throw StateError('No existe el estado de reporte "$codigo".');
    }
    return row['id_maestra'] as int;
  }
}

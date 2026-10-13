import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/insignia.dart';

/// Estadísticas de actividad del usuario para la pestaña de Perfil.
class EstadisticasUsuario {
  const EstadisticasUsuario({
    required this.publicaciones,
    required this.comentarios,
    required this.soluciones,
    required this.votosRecibidos,
  });

  final int publicaciones;
  final int comentarios;
  final int soluciones;

  /// Votos positivos recibidos (eventos de puntos por voto positivo).
  final int votosRecibidos;
}

/// Lectura del sistema de gamificación: distintivos y estadísticas.
///
/// Solo lee; los puntos y los distintivos los calcula y otorga el backend.
class GamificacionRepository {
  GamificacionRepository(this._client);

  final SupabaseClient _client;

  static const _motivosVotoPositivo = [
    'voto_positivo_publicacion',
    'voto_positivo_comentario',
  ];

  /// Todos los distintivos activos, marcando cuáles ya obtuvo el usuario.
  Future<List<Insignia>> fetchInsignias(String usuarioId) async {
    final insignias = await _client
        .from('insignias')
        .select('id, codigo, nombre, descripcion, icono')
        .eq('activo', true)
        .order('codigo');

    final obtenidas = await _client
        .from('insignias_usuario')
        .select('insignia_id, obtenido_en')
        .eq('usuario_id', usuarioId);

    final porInsignia = <String, DateTime?>{};
    for (final fila in obtenidas) {
      final map = Map<String, dynamic>.from(fila as Map);
      final fecha = map['obtenido_en'] as String?;
      porInsignia[map['insignia_id'] as String] =
          fecha == null ? null : DateTime.tryParse(fecha);
    }

    return insignias.map((fila) {
      final map = Map<String, dynamic>.from(fila as Map);
      return Insignia.fromFila(
        map,
        obtenidoEn: porInsignia[map['id'] as String],
      );
    }).toList();
  }

  /// Estadísticas de participación del usuario para el perfil.
  Future<EstadisticasUsuario> fetchEstadisticas(String usuarioId) async {
    final publicaciones = await _client
        .from('publicaciones')
        .select('id')
        .eq('autor_id', usuarioId)
        .count(CountOption.exact);

    final comentarios = await _client
        .from('comentarios')
        .select('id')
        .eq('autor_id', usuarioId)
        .count(CountOption.exact);

    final soluciones = await _client
        .from('comentarios')
        .select('id')
        .eq('autor_id', usuarioId)
        .eq('es_solucion', true)
        .count(CountOption.exact);

    final votos = await _client
        .from('eventos_puntos')
        .select('id, motivo:maestra!motivo_id(codigo)')
        .eq('usuario_id', usuarioId);
    final votosPositivos = votos.where((fila) {
      final map = Map<String, dynamic>.from(fila as Map);
      final motivo = map['motivo'] as Map?;
      final codigo = motivo == null ? null : motivo['codigo'] as String?;
      return codigo != null && _motivosVotoPositivo.contains(codigo);
    }).length;

    return EstadisticasUsuario(
      publicaciones: publicaciones.count,
      comentarios: comentarios.count,
      soluciones: soluciones.count,
      votosRecibidos: votosPositivos,
    );
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/publicacion.dart';

/// Lectura de publicaciones para el feed, los canales y el detalle.
///
/// Los nombres de tipo y categoría se obtienen de `maestra` y se resuelven en
/// el cliente para evitar depender de la desambiguación de dos claves foráneas
/// hacia la misma tabla en una consulta embebida.
///
/// El autor se consulta por separado y solo para las publicaciones que no son
/// anónimas, de modo que el alias de una publicación anónima nunca se envía.
class PublicacionesRepository {
  PublicacionesRepository(this._client);

  final SupabaseClient _client;

  static const _columnas = 'id, canal_id, autor_id, tipo_id, categoria_id, '
      'titulo, cuerpo, anonimo, puntaje, metadatos, imagenes, creado_en, '
      'canal:canales(nombre), comentarios(count)';

  Future<List<Publicacion>> fetchRecientes({int limite = 30}) async {
    final estadoId = await _idEstadoPublicado();
    final rows = await _client
        .from('publicaciones')
        .select(_columnas)
        .eq('estado_id', estadoId)
        .order('creado_en', ascending: false)
        .limit(limite);
    return _mapear(rows);
  }

  Future<List<Publicacion>> fetchPorCanal(
    String canalId, {
    int limite = 30,
  }) async {
    final estadoId = await _idEstadoPublicado();
    final rows = await _client
        .from('publicaciones')
        .select(_columnas)
        .eq('canal_id', canalId)
        .eq('estado_id', estadoId)
        .order('creado_en', ascending: false)
        .limit(limite);
    return _mapear(rows);
  }

  Future<Publicacion?> fetchPorId(String publicacionId) async {
    final row = await _client
        .from('publicaciones')
        .select(_columnas)
        .eq('id', publicacionId)
        .maybeSingle();
    if (row == null) return null;
    final lista = await _mapear([row]);
    return lista.isEmpty ? null : lista.first;
  }

  /// Crea una publicación del usuario autenticado.
  ///
  /// No se envían `autor_id`, `estado_id` ni `puntaje`: los fija el backend
  /// (trigger) y RLS valida el tipo según el rol. `metadatos` solo se envía si
  /// tiene datos (según el tipo), para no guardar objetos vacíos.
  Future<void> crearPublicacion({
    required String canalId,
    required int tipoId,
    required int categoriaId,
    required String cuerpo,
    String? titulo,
    bool anonimo = false,
    List<String> imagenes = const [],
    Map<String, dynamic>? metadatos,
  }) async {
    await _client.from('publicaciones').insert({
      'canal_id': canalId,
      'tipo_id': tipoId,
      'categoria_id': categoriaId,
      'titulo': titulo,
      'cuerpo': cuerpo,
      'anonimo': anonimo,
      'imagenes': imagenes,
      if (metadatos != null && metadatos.isNotEmpty) 'metadatos': metadatos,
    });
  }

  /// Actualiza una publicación propia.
  ///
  /// Solo cambia campos editables por el autor (título, cuerpo, anonimato,
  /// imágenes y metadatos). El canal, tipo, categoría y la autoría los conserva
  /// RLS. Si `metadatos` es `null` se guarda `{}` porque la columna es
  /// `not null` y admite objetos vacíos.
  Future<void> actualizarPublicacion({
    required String id,
    required String cuerpo,
    String? titulo,
    bool anonimo = false,
    List<String> imagenes = const [],
    Map<String, dynamic>? metadatos,
  }) async {
    await _client
        .from('publicaciones')
        .update({
          'titulo': titulo,
          'cuerpo': cuerpo,
          'anonimo': anonimo,
          'imagenes': imagenes,
          'metadatos': metadatos ?? const <String, dynamic>{},
        })
        .eq('id', id);
  }

  /// Elimina una publicación propia (RLS valida la autoría).
  Future<void> eliminarPublicacion(String id) async {
    await _client.from('publicaciones').delete().eq('id', id);
  }

  Future<int> _idEstadoPublicado() async {
    final row = await _client
        .from('maestra')
        .select('id_maestra')
        .eq('grupo', 'estado_publicacion')
        .eq('codigo', 'publicado')
        .single();
    return row['id_maestra'] as int;
  }

  Future<List<Publicacion>> _mapear(List<dynamic> rows) async {
    final tipos = await _catalogo('tipo_publicacion');
    final categorias = await _catalogo('categoria_publicacion');

    final autorIds = <String>{
      for (final row in rows)
        if ((row['anonimo'] as bool?) != true && row['autor_id'] != null)
          row['autor_id'] as String,
    };
    final autores = await _perfiles(autorIds);

    return rows
        .map(
          (row) => Publicacion.fromJson(
            Map<String, dynamic>.from(row as Map),
            tipos: tipos.nombres,
            tiposCodigo: tipos.codigos,
            categorias: categorias.nombres,
            categoriasCodigo: categorias.codigos,
            autores: autores,
          ),
        )
        .toList();
  }

  Future<({Map<int, String> nombres, Map<int, String> codigos})> _catalogo(
    String grupo,
  ) async {
    final rows = await _client
        .from('maestra')
        .select('id_maestra, nombre, codigo')
        .eq('grupo', grupo)
        .eq('activo', true);
    final nombres = <int, String>{};
    final codigos = <int, String>{};
    for (final row in rows) {
      final id = row['id_maestra'] as int;
      nombres[id] = row['nombre'] as String;
      codigos[id] = row['codigo'] as String;
    }
    return (nombres: nombres, codigos: codigos);
  }

  Future<Map<String, Map<String, dynamic>>> _perfiles(
    Set<String> ids,
  ) async {
    if (ids.isEmpty) return const {};
    final rows = await _client
        .from('perfiles')
        .select('id, alias, avatar_url, es_verificada, puntos')
        .inFilter('id', ids.toList());
    return {
      for (final row in rows)
        row['id'] as String: Map<String, dynamic>.from(row as Map),
    };
  }
}

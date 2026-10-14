import 'metadatos_publicacion.dart';

/// Publicación del feed (`public.publicaciones`).
///
/// Los nombres de tipo y categoría se resuelven con los catálogos de `maestra`
/// porque son columnas de referencia y no deben asumirse en el cliente.
class Publicacion {
  const Publicacion({
    required this.id,
    required this.canalId,
    required this.tipoId,
    required this.categoriaId,
    required this.cuerpo,
    required this.anonimo,
    required this.puntaje,
    required this.creadoEn,
    this.comentariosCount = 0,
    this.imagenes = const [],
    this.metadatos = const MetadatosPublicacion(),
    this.autorId,
    this.canalNombre,
    this.tipoNombre,
    this.tipoCodigo,
    this.categoriaNombre,
    this.categoriaCodigo,
    this.titulo,
    this.autorAlias,
    this.autorAvatarUrl,
    this.autorVerificada = false,
    this.autorPuntos,
  });

  final String id;
  final String canalId;
  final String? canalNombre;
  final String? autorId;
  final int tipoId;
  final String? tipoNombre;
  final String? tipoCodigo;
  final int categoriaId;
  final String? categoriaNombre;
  final String? categoriaCodigo;
  final String? titulo;
  final String cuerpo;
  final bool anonimo;
  final int puntaje;
  final DateTime creadoEn;

  /// Cantidad de comentarios visibles de la publicación.
  final int comentariosCount;

  /// URLs públicas de las imágenes adjuntas (máximo 3).
  final List<String> imagenes;

  /// Metadatos específicos del tipo (venta, perdido, encontrado, evento).
  final MetadatosPublicacion metadatos;
  final String? autorAlias;
  final String? autorAvatarUrl;
  final bool autorVerificada;

  /// Puntos de reputación del autor; `null` en publicaciones anónimas.
  final int? autorPuntos;

  /// Texto corto de la categoría o, si falta, del tipo.
  String get etiquetaCategoria => categoriaNombre ?? tipoNombre ?? 'General';

  /// `true` si la publicación pertenece al usuario indicado.
  bool esDe(String? usuarioId) =>
      usuarioId != null && autorId != null && autorId == usuarioId;

  /// Construye una publicación a partir de una fila de `publicaciones`.
  ///
  /// `autores` mapea `autor_id` a los datos públicos del perfil. Para las
  /// publicaciones anónimas el autor no se incluye y sus datos no se exponen.
  factory Publicacion.fromJson(
    Map<String, dynamic> json, {
    Map<int, String> tipos = const {},
    Map<int, String> tiposCodigo = const {},
    required Map<int, String> categorias,
    Map<int, String> categoriasCodigo = const {},
    Map<String, Map<String, dynamic>> autores = const {},
  }) {
    final anonimo = (json['anonimo'] as bool?) ?? false;
    final autorId = json['autor_id'] as String?;
    final autor = anonimo ? null : autores[autorId];
    final tipoId = json['tipo_id'] as int;
    final categoriaId = json['categoria_id'] as int;
    final canal = json['canal'] as Map<String, dynamic>?;
    final metadatosJson = json['metadatos'] as Map<String, dynamic>?;
    final imagenes =
        (json['imagenes'] as List?)?.whereType<String>().toList() ??
        const <String>[];
    final comentarios = json['comentarios'];
    final comentariosCount = comentarios is List && comentarios.isNotEmpty
        ? (comentarios.first['count'] as int?) ?? 0
        : 0;

    return Publicacion(
      id: json['id'] as String,
      canalId: json['canal_id'] as String,
      canalNombre: canal?['nombre'] as String?,
      imagenes: imagenes,
      autorId: autorId,
      tipoId: tipoId,
      tipoNombre: tipos[tipoId],
      tipoCodigo: tiposCodigo[tipoId],
      categoriaId: categoriaId,
      categoriaNombre: categorias[categoriaId],
      categoriaCodigo: categoriasCodigo[categoriaId],
      titulo: json['titulo'] as String?,
      cuerpo: json['cuerpo'] as String,
      anonimo: anonimo,
      puntaje: (json['puntaje'] as int?) ?? 0,
      comentariosCount: comentariosCount,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      metadatos: metadatosJson == null
          ? const MetadatosPublicacion()
          : MetadatosPublicacion.fromJson(metadatosJson),
      autorAlias: anonimo ? null : autor?['alias'] as String?,
      autorAvatarUrl: anonimo ? null : autor?['avatar_url'] as String?,
      autorVerificada:
          !anonimo && ((autor?['es_verificada'] as bool?) ?? false),
      autorPuntos: anonimo ? null : autor?['puntos'] as int?,
    );
  }
}

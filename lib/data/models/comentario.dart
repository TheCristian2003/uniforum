/// Comentario de una publicación (`public.comentarios`).
///
/// Los comentarios no son anónimos, por lo que el alias del autor siempre se
/// puede mostrar.
class Comentario {
  const Comentario({
    required this.id,
    required this.publicacionId,
    required this.autorId,
    required this.cuerpo,
    required this.esSolucion,
    required this.puntaje,
    required this.creadoEn,
    this.imagenes = const [],
    this.autorAlias,
    this.autorAvatarUrl,
    this.autorVerificada = false,
  });

  final String id;
  final String publicacionId;
  final String autorId;
  final String cuerpo;
  final bool esSolucion;
  final int puntaje;
  final DateTime creadoEn;

  /// URL pública de la imagen adjunta (máximo 1).
  final List<String> imagenes;
  final String? autorAlias;
  final String? autorAvatarUrl;
  final bool autorVerificada;

  factory Comentario.fromJson(Map<String, dynamic> json) {
    final autor = json['autor'] as Map<String, dynamic>?;
    final imagenes =
        (json['imagenes'] as List?)?.whereType<String>().toList() ??
        const <String>[];
    return Comentario(
      id: json['id'] as String,
      publicacionId: json['publicacion_id'] as String,
      autorId: json['autor_id'] as String,
      cuerpo: json['cuerpo'] as String,
      esSolucion: json['es_solucion'] as bool,
      puntaje: json['puntaje'] as int,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      imagenes: imagenes,
      autorAlias: autor?['alias'] as String?,
      autorAvatarUrl: autor?['avatar_url'] as String?,
      autorVerificada: (autor?['es_verificada'] as bool?) ?? false,
    );
  }
}

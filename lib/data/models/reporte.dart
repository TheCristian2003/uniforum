/// Reporte de una publicación o de un comentario (`public.reportes`).
///
/// Cada reporte apunta a exactamente un objetivo (publicación o comentario),
/// tal como exige la restricción `reportes_un_objetivo`. El autor del reporte
/// no es anónimo ni para la moderación.
class Reporte {
  const Reporte({
    required this.id,
    required this.publicacionId,
    required this.comentarioId,
    required this.motivo,
    required this.estado,
    required this.descripcion,
    required this.creadoEn,
    required this.reportanteAlias,
    required this.contenido,
    required this.tituloContenido,
    required this.autorId,
  });

  final String id;
  final String? publicacionId;
  final String? comentarioId;
  final String motivo;
  final String estado;
  final String? descripcion;
  final DateTime creadoEn;
  final String? reportanteAlias;

  /// Autor del contenido reportado (publicación o comentario), si se conoce.
  final String? autorId;

  /// Texto del contenido reportado (cuerpo del comentario o de la publicación).
  final String? contenido;

  /// Título de la publicación reportada, si aplica.
  final String? tituloContenido;

  bool get esComentario => comentarioId != null;

  factory Reporte.fromJson(Map<String, dynamic> json) {
    final publicacion = json['publicacion'] as Map<String, dynamic>?;
    final comentario = json['comentario'] as Map<String, dynamic>?;
    final motivo = json['motivo'] as Map<String, dynamic>?;
    final estado = json['estado'] as Map<String, dynamic>?;
    final reportante = json['reportante'] as Map<String, dynamic>?;

    return Reporte(
      id: json['id'] as String,
      publicacionId: json['publicacion_id'] as String?,
      comentarioId: json['comentario_id'] as String?,
      motivo: (motivo?['nombre'] as String?) ?? 'Otro',
      estado: (estado?['codigo'] as String?) ?? 'pendiente',
      descripcion: json['descripcion'] as String?,
      creadoEn: DateTime.parse(json['creado_en'] as String),
      reportanteAlias: reportante?['alias'] as String?,
      contenido: (comentario?['cuerpo'] as String?) ??
          (publicacion?['cuerpo'] as String?),
      tituloContenido: publicacion?['titulo'] as String?,
      autorId: (comentario?['autor_id'] as String?) ??
          (publicacion?['autor_id'] as String?),
    );
  }
}

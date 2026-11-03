/// Respuesta de la Edge Function `campus-ai` (IA del Campus).
///
/// El backend devuelve el texto, las publicaciones usadas como contexto y, si
/// se pudo validar el cupo, cuántas consultas quedan hoy para el usuario.
class RespuestaIA {
  const RespuestaIA({
    required this.texto,
    required this.fuentes,
    this.restantes,
  });

  final String texto;
  final List<FuenteIA> fuentes;
  final int? restantes;
}

/// Turno previo de la conversación que se envía como memoria a la IA.
class MensajeHistorialIA {
  const MensajeHistorialIA({required this.rol, required this.texto});

  /// `usuario` o `ia`.
  final String rol;
  final String texto;

  Map<String, dynamic> toJson() => {'rol': rol, 'texto': texto};
}

/// Publicación citada por la IA. Solo se usa para abrir el detalle.
class FuenteIA {
  const FuenteIA({
    required this.id,
    required this.titulo,
    this.canal,
    this.tipo,
    this.creadoEn,
  });

  final String id;
  final String titulo;
  final String? canal;
  final String? tipo;
  final DateTime? creadoEn;

  factory FuenteIA.fromJson(Map<String, dynamic> json) {
    final titulo = (json['titulo'] as String?)?.trim();
    return FuenteIA(
      id: json['id'] as String,
      titulo: (titulo == null || titulo.isEmpty) ? 'Publicación' : titulo,
      canal: json['canal'] as String?,
      tipo: json['tipo'] as String?,
      creadoEn: DateTime.tryParse(json['creadoEn'] as String? ?? ''),
    );
  }
}

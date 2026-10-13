/// Canal o comunidad del campus (`public.canales`).
class Canal {
  const Canal({
    required this.id,
    required this.nombre,
    required this.slug,
    this.descripcion,
    this.icono,
    this.tipoCanalId,
  });

  final String id;
  final String nombre;
  final String slug;
  final String? descripcion;
  final String? icono;

  /// Id del registro `tipo_canal` en `maestra` (`null` si no aplica).
  final int? tipoCanalId;

  factory Canal.fromJson(Map<String, dynamic> json) {
    return Canal(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      slug: json['slug'] as String,
      descripcion: json['descripcion'] as String?,
      icono: json['icono'] as String?,
      tipoCanalId: json['tipo_canal_id'] as int?,
    );
  }
}

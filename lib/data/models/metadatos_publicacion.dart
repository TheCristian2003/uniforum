/// Metadatos específicos por tipo de publicación (`publicaciones.metadatos`).
///
/// Se guardan como un objeto JSON y solo se usan según el tipo:
/// - venta: `precio`, `moneda`, `lugar`, `disponible`.
/// - perdido: `fecha`, `lugar`, `recompensa`.
/// - encontrado: `fecha`, `lugar`, `entregado`.
/// - evento: `inicio`, `fin`, `lugar`, `enlace`.
///
/// No contiene datos personales (ni teléfonos ni correos). Las fechas se
/// guardan como texto ISO-8601 dentro del JSON.
class MetadatosPublicacion {
  const MetadatosPublicacion({
    this.precio,
    this.moneda,
    this.lugar,
    this.disponible,
    this.fecha,
    this.recompensa,
    this.entregado,
    this.inicio,
    this.fin,
    this.enlace,
  });

  final num? precio;
  final String? moneda;
  final String? lugar;
  final bool? disponible;
  final DateTime? fecha;
  final num? recompensa;
  final bool? entregado;
  final DateTime? inicio;
  final DateTime? fin;
  final String? enlace;

  /// `true` si no hay ningún campo con valor.
  bool get vacio =>
      precio == null &&
      moneda == null &&
      lugar == null &&
      disponible == null &&
      fecha == null &&
      recompensa == null &&
      entregado == null &&
      inicio == null &&
      fin == null &&
      enlace == null;

  factory MetadatosPublicacion.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String clave) {
      final valor = json[clave];
      return valor is String ? DateTime.tryParse(valor) : null;
    }

    return MetadatosPublicacion(
      precio: json['precio'] as num?,
      moneda: json['moneda'] as String?,
      lugar: json['lugar'] as String?,
      disponible: json['disponible'] as bool?,
      fecha: parse('fecha'),
      recompensa: json['recompensa'] as num?,
      entregado: json['entregado'] as bool?,
      inicio: parse('inicio'),
      fin: parse('fin'),
      enlace: json['enlace'] as String?,
    );
  }

  /// Objeto JSON sin las claves nulas.
  Map<String, dynamic> toJson() => {
    if (precio != null) 'precio': precio,
    if (moneda != null) 'moneda': moneda,
    if (lugar != null) 'lugar': lugar,
    if (disponible != null) 'disponible': disponible,
    if (fecha != null) 'fecha': fecha!.toIso8601String(),
    if (recompensa != null) 'recompensa': recompensa,
    if (entregado != null) 'entregado': entregado,
    if (inicio != null) 'inicio': inicio!.toIso8601String(),
    if (fin != null) 'fin': fin!.toIso8601String(),
    if (enlace != null) 'enlace': enlace,
  };
}

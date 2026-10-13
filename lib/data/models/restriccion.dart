/// Restricción (sanción) de una cuenta (`public.restricciones_usuario`).
///
/// Una restricción `permanente` no tiene `expiraEn`; una `temporal` caduca en
/// esa fecha. `vigente` combina el estado activo con la fecha de fin.
class Restriccion {
  const Restriccion({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.motivo,
    required this.iniciaEn,
    required this.expiraEn,
    required this.activa,
    required this.creadoEn,
  });

  final String id;
  final String usuarioId;

  /// Código del tipo: `temporal` o `permanente`.
  final String tipo;
  final String motivo;
  final DateTime iniciaEn;
  final DateTime? expiraEn;
  final bool activa;
  final DateTime creadoEn;

  bool get permanente => expiraEn == null;

  bool get vigente =>
      activa && (expiraEn == null || expiraEn!.isAfter(DateTime.now()));

  factory Restriccion.fromJson(Map<String, dynamic> json) {
    final tipo = json['tipo'];
    return Restriccion(
      id: json['id'] as String,
      usuarioId: json['usuario_id'] as String,
      tipo: tipo is Map ? (tipo['codigo'] as String? ?? 'temporal') : 'temporal',
      motivo: json['motivo'] as String,
      iniciaEn: DateTime.parse(json['inicia_en'] as String),
      expiraEn: json['expira_en'] == null
          ? null
          : DateTime.parse(json['expira_en'] as String),
      activa: (json['activa'] as bool?) ?? true,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );
  }
}

/// Distintivo (insignia) del sistema de gamificación.
///
/// `obtenida` indica si el usuario ya la desbloqueó y `obtenidoEn` cuándo.
class Insignia {
  const Insignia({
    required this.codigo,
    required this.nombre,
    this.descripcion,
    this.icono,
    required this.obtenida,
    this.obtenidoEn,
  });

  final String codigo;
  final String nombre;
  final String? descripcion;

  /// Nombre lógico del ícono (p. ej. `star`); la UI lo traduce a `IconData`.
  final String? icono;
  final bool obtenida;
  final DateTime? obtenidoEn;

  factory Insignia.fromFila(
    Map<String, dynamic> fila, {
    required DateTime? obtenidoEn,
  }) {
    return Insignia(
      codigo: fila['codigo'] as String,
      nombre: fila['nombre'] as String,
      descripcion: fila['descripcion'] as String?,
      icono: fila['icono'] as String?,
      obtenida: obtenidoEn != null,
      obtenidoEn: obtenidoEn,
    );
  }
}

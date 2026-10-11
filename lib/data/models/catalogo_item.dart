/// Elemento de catálogo de la tabla `maestra`.
///
/// El significado de cada registro depende de su `grupo`; el cliente debe
/// pedir siempre el grupo esperado y nunca asumir que un `codigo` es único
/// entre grupos.
class CatalogoItem {
  const CatalogoItem({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

  final int id;
  final String codigo;
  final String nombre;

  factory CatalogoItem.fromJson(Map<String, dynamic> json) {
    return CatalogoItem(
      id: json['id_maestra'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
    );
  }
}

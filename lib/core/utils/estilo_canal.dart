import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Estilo visual asociado a un `tipo_canal` de la tabla `maestra`.
class EstiloTipoCanal {
  const EstiloTipoCanal({
    required this.codigo,
    required this.etiqueta,
    required this.color,
    required this.fondo,
    required this.icono,
  });

  final String codigo;
  final String etiqueta;
  final Color color;
  final Color fondo;
  final IconData icono;
}

/// Traduce el `codigo` de un registro `tipo_canal` a su estilo visual.
///
/// Si el código no se reconoce (o es nulo) se usa el estilo "General".
EstiloTipoCanal estiloTipoCanal(BuildContext context, String? codigo) {
  final c = context.colors;
  switch (codigo) {
    case 'unidad_academica':
      return EstiloTipoCanal(
        codigo: 'unidad_academica',
        etiqueta: 'Unidad académica',
        color: c.ugYellowDark,
        fondo: c.ugOcreLight,
        icono: Icons.school,
      );
    case 'sede':
      return EstiloTipoCanal(
        codigo: 'sede',
        etiqueta: 'Sede',
        color: c.ugFlamenco,
        fondo: c.ugFlamencoLight,
        icono: Icons.location_city,
      );
    default:
      return EstiloTipoCanal(
        codigo: 'general',
        etiqueta: 'General',
        color: c.ugBlue,
        fondo: c.ugBlueLight,
        icono: Icons.groups,
      );
  }
}

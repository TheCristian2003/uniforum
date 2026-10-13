import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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
EstiloTipoCanal estiloTipoCanal(String? codigo) {
  switch (codigo) {
    case 'unidad_academica':
      return const EstiloTipoCanal(
        codigo: 'unidad_academica',
        etiqueta: 'Unidad académica',
        color: AppColors.ugYellowDark,
        fondo: AppColors.ugOcreLight,
        icono: Icons.school,
      );
    case 'sede':
      return const EstiloTipoCanal(
        codigo: 'sede',
        etiqueta: 'Sede',
        color: AppColors.ugFlamenco,
        fondo: AppColors.ugFlamencoLight,
        icono: Icons.location_city,
      );
    case 'general':
      return const EstiloTipoCanal(
        codigo: 'general',
        etiqueta: 'General',
        color: AppColors.ugBlue,
        fondo: AppColors.ugBlueLight,
        icono: Icons.groups,
      );
    default:
      return const EstiloTipoCanal(
        codigo: 'general',
        etiqueta: 'General',
        color: AppColors.ugBlue,
        fondo: AppColors.ugBlueLight,
        icono: Icons.groups,
      );
  }
}

import 'package:flutter/material.dart';

/// Colores institucionales tomados de `docs/design.md` (UniVibe Uniguajira).
///
/// Este sistema visual se adopta como referencia inicial. El nombre comercial
/// y la identidad final siguen pendientes de confirmación.
class AppColors {
  const AppColors._();

  // Amarillo institucional (primario).
  static const Color ugYellow = Color(0xFFF2AE1C);
  static const Color ugYellowDark = Color(0xFFD89608);

  // Azul institucional (secundario).
  static const Color ugBlue = Color(0xFF0F4C81);
  static const Color ugBlueLight = Color(0xFFE8F1F9);

  // Rojo institucional (alertas / terciario).
  static const Color ugRed = Color(0xFFC81D25);
  static const Color ugRedLight = Color(0xFFFDE8E9);

  // Superficies y neutros.
  static const Color background = Color(0xFFFBF8F5);
  static const Color surface = Color(0xFFFBF8F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFAF7F0);
  static const Color surfaceContainer = Color(0xFFF6F3EB);
  static const Color surfaceContainerHigh = Color(0xFFF0EBD9);
  static const Color surfaceContainerHighest = Color(0xFFEAE5D8);

  static const Color onPrimary = Color(0xFF4A3500);
  static const Color onSurface = Color(0xFF1E1E1E);
  static const Color onSurfaceVariant = Color(0xFF514533);
  static const Color outline = Color(0xFF837561);
  static const Color outlineVariant = Color(0xFFE5DCCE);
}

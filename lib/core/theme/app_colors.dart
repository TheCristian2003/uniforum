import 'package:flutter/material.dart';

/// Colores institucionales tomados de `docs/design/DESIGN.md`.
///
/// Este sistema visual se adopta como referencia inicial. El nombre comercial
/// y la identidad final siguen pendientes de confirmación.
class AppColors {
  const AppColors._();

  // Amarillo desierto como principal
  static const Color ugYellow = Color(0xFFC99A2E);
  static const Color ugYellowDark = Color(0xFFA67C1F);

  // Azul mar
  static const Color ugBlue = Color(0xFF0F4C81);
  static const Color ugBlueLight = Color(0xFFE8F1F9);

  // Rojo institucional (alertas)
  static const Color ugRed = Color(0xFFC81D25);
  static const Color ugRedLight = Color(0xFFFDE8E9);

  // Rosado flamenco
  static const Color ugFlamenco = Color(0xFFC2415A);
  static const Color ugFlamencoLight = Color(0xFFFBE3E8);

  // Paleta inspirada en La Guajira, ampliada para diferenciar tipos y
  // categorías de publicación. Se combina con los colores institucionales.
  //
  // Ocre (amarillo institucional).
  static const Color ugOcre = Color(0xFFF2AE1C);
  static const Color ugOcreLight = Color(0xFFFDF1D6);
  // Agua marina.
  static const Color ugAguaMarina = Color(0xFF0E8F9E);
  static const Color ugAguaMarinaLight = Color(0xFFDCF1F4);
  // Amarillo desierto
  static const Color ugAmarilloDesierto = Color(0xFFC99A2E);
  static const Color ugAmarilloDesiertoLight = Color(0xFFF7EBD2);
  // Azul mar
  static const Color ugAzulMar = Color(0xFF0F4C81);
  static const Color ugAzulMarLight = Color(0xFFE8F1F9);
  // Negro
  static const Color ugNegro = Color(0xFF1E1E1E);

  // Superficies y neutros.
  static const Color background = Color(0xFFFBF8F5);
  static const Color surface = Color(0xFFFBF8F5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFFAF7F0);
  static const Color surfaceContainer = Color(0xFFF6F3EB);
  static const Color surfaceContainerHigh = Color(0xFFF0EBD9);
  static const Color surfaceContainerHighest = Color(0xFFEAE5D8);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1E1E1E);
  static const Color onSurfaceVariant = Color(0xFF514533);
  static const Color outline = Color(0xFF837561);
  static const Color outlineVariant = Color(0xFFE5DCCE);
}

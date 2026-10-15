import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación, dependiente del tema (claro/oscuro).
///
/// Reemplaza a las constantes estáticas de `AppColors`: al ser un
/// [ThemeExtension], sus valores se resuelven en tiempo de build según el tema
/// activo. Accede a ella con `context.colors`.
///
/// Los colores institucionales (amarillo desierto, azul mar, rojo, flamenco,
/// ocre y agua marina) conservan su matiz de marca, pero se aclaran en modo
/// oscuro para mantener contraste; los tokens semánticos (superficies, textos,
/// bordes) sí cambian por completo.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.ugYellow,
    required this.ugYellowDark,
    required this.ugBlue,
    required this.ugBlueLight,
    required this.ugRed,
    required this.ugRedLight,
    required this.ugFlamenco,
    required this.ugFlamencoLight,
    required this.ugOcre,
    required this.ugOcreLight,
    required this.ugAguaMarina,
    required this.ugAguaMarinaLight,
    required this.ugAmarilloDesierto,
    required this.ugAmarilloDesiertoLight,
    required this.ugAzulMar,
    required this.ugAzulMarLight,
    required this.ugNegro,
    required this.background,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onPrimary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
  });

  // Amarillo desierto como principal
  final Color ugYellow;
  final Color ugYellowDark;

  // Azul mar
  final Color ugBlue;
  final Color ugBlueLight;

  // Rojo institucional (alertas)
  final Color ugRed;
  final Color ugRedLight;

  // Rosado flamenco
  final Color ugFlamenco;
  final Color ugFlamencoLight;

  // Ocre (amarillo institucional)
  final Color ugOcre;
  final Color ugOcreLight;

  // Agua marina
  final Color ugAguaMarina;
  final Color ugAguaMarinaLight;

  // Amarillo desierto (alias de categoría)
  final Color ugAmarilloDesierto;
  final Color ugAmarilloDesiertoLight;

  // Azul mar (alias de categoría)
  final Color ugAzulMar;
  final Color ugAzulMarLight;

  // Negro
  final Color ugNegro;

  // Superficies y neutros
  final Color background;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;

  final Color onPrimary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;

  /// Tema claro (valores originales de `docs/design/DESIGN.md`).
  static const AppPalette light = AppPalette(
    ugYellow: Color(0xFFC99A2E),
    ugYellowDark: Color(0xFFA67C1F),
    ugBlue: Color(0xFF0F4C81),
    ugBlueLight: Color(0xFFE8F1F9),
    ugRed: Color(0xFFC81D25),
    ugRedLight: Color(0xFFFDE8E9),
    ugFlamenco: Color(0xFFC2415A),
    ugFlamencoLight: Color(0xFFFBE3E8),
    ugOcre: Color(0xFFF2AE1C),
    ugOcreLight: Color(0xFFFDF1D6),
    ugAguaMarina: Color(0xFF0E8F9E),
    ugAguaMarinaLight: Color(0xFFDCF1F4),
    ugAmarilloDesierto: Color(0xFFC99A2E),
    ugAmarilloDesiertoLight: Color(0xFFF7EBD2),
    ugAzulMar: Color(0xFF0F4C81),
    ugAzulMarLight: Color(0xFFE8F1F9),
    ugNegro: Color(0xFF1E1E1E),
    background: Color(0xFFFBF8F5),
    surface: Color(0xFFFBF8F5),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAF7F0),
    surfaceContainer: Color(0xFFF6F3EB),
    surfaceContainerHigh: Color(0xFFF0EBD9),
    surfaceContainerHighest: Color(0xFFEAE5D8),
    onPrimary: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1E1E1E),
    onSurfaceVariant: Color(0xFF514533),
    outline: Color(0xFF837561),
    outlineVariant: Color(0xFFE5DCCE),
  );

  /// Tema oscuro: superficies gris neutro casi negras y acento primario blanco.
  ///
  /// El amarillo institucional no se usa como acento en oscuro (desentona con
  /// el negro): el primario pasa a un blanco roto con texto oscuro. Los demás
  /// acentos semánticos (azul, rojo, flamenco, agua marina) sí se conservan,
  /// aclarados para mantener contraste.
  static const AppPalette dark = AppPalette(
    ugYellow: Color(0xFFF2F2F2),
    ugYellowDark: Color(0xFFCFCFCF),
    ugBlue: Color(0xFF7FB0E0),
    ugBlueLight: Color(0xFF1C2C3D),
    ugRed: Color(0xFFF08A8F),
    ugRedLight: Color(0xFF3A1E20),
    ugFlamenco: Color(0xFFF094A6),
    ugFlamencoLight: Color(0xFF3A2129),
    ugOcre: Color(0xFFE6E6E6),
    ugOcreLight: Color(0xFF2A2A2A),
    ugAguaMarina: Color(0xFF5FD0DD),
    ugAguaMarinaLight: Color(0xFF123238),
    ugAmarilloDesierto: Color(0xFFF2F2F2),
    ugAmarilloDesiertoLight: Color(0xFF2E2E2E),
    ugAzulMar: Color(0xFF7FB0E0),
    ugAzulMarLight: Color(0xFF1C2C3D),
    ugNegro: Color(0xFFF2F2F2),
    background: Color(0xFF141414),
    surface: Color(0xFF141414),
    surfaceContainerLowest: Color(0xFF1C1C1C),
    surfaceContainerLow: Color(0xFF222222),
    surfaceContainer: Color(0xFF262626),
    surfaceContainerHigh: Color(0xFF303030),
    surfaceContainerHighest: Color(0xFF3A3A3A),
    onPrimary: Color(0xFF141414),
    onSurface: Color(0xFFF3F3F3),
    onSurfaceVariant: Color(0xFFBDBDBD),
    outline: Color(0xFF8A8A8A),
    outlineVariant: Color(0xFF3C3C3C),
  );

  @override
  AppPalette copyWith({
    Color? ugYellow,
    Color? ugYellowDark,
    Color? ugBlue,
    Color? ugBlueLight,
    Color? ugRed,
    Color? ugRedLight,
    Color? ugFlamenco,
    Color? ugFlamencoLight,
    Color? ugOcre,
    Color? ugOcreLight,
    Color? ugAguaMarina,
    Color? ugAguaMarinaLight,
    Color? ugAmarilloDesierto,
    Color? ugAmarilloDesiertoLight,
    Color? ugAzulMar,
    Color? ugAzulMarLight,
    Color? ugNegro,
    Color? background,
    Color? surface,
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? onPrimary,
    Color? onSurface,
    Color? onSurfaceVariant,
    Color? outline,
    Color? outlineVariant,
  }) {
    return AppPalette(
      ugYellow: ugYellow ?? this.ugYellow,
      ugYellowDark: ugYellowDark ?? this.ugYellowDark,
      ugBlue: ugBlue ?? this.ugBlue,
      ugBlueLight: ugBlueLight ?? this.ugBlueLight,
      ugRed: ugRed ?? this.ugRed,
      ugRedLight: ugRedLight ?? this.ugRedLight,
      ugFlamenco: ugFlamenco ?? this.ugFlamenco,
      ugFlamencoLight: ugFlamencoLight ?? this.ugFlamencoLight,
      ugOcre: ugOcre ?? this.ugOcre,
      ugOcreLight: ugOcreLight ?? this.ugOcreLight,
      ugAguaMarina: ugAguaMarina ?? this.ugAguaMarina,
      ugAguaMarinaLight: ugAguaMarinaLight ?? this.ugAguaMarinaLight,
      ugAmarilloDesierto: ugAmarilloDesierto ?? this.ugAmarilloDesierto,
      ugAmarilloDesiertoLight:
          ugAmarilloDesiertoLight ?? this.ugAmarilloDesiertoLight,
      ugAzulMar: ugAzulMar ?? this.ugAzulMar,
      ugAzulMarLight: ugAzulMarLight ?? this.ugAzulMarLight,
      ugNegro: ugNegro ?? this.ugNegro,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      onPrimary: onPrimary ?? this.onPrimary,
      onSurface: onSurface ?? this.onSurface,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      outline: outline ?? this.outline,
      outlineVariant: outlineVariant ?? this.outlineVariant,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) {
      return this;
    }
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      ugYellow: mix(ugYellow, other.ugYellow),
      ugYellowDark: mix(ugYellowDark, other.ugYellowDark),
      ugBlue: mix(ugBlue, other.ugBlue),
      ugBlueLight: mix(ugBlueLight, other.ugBlueLight),
      ugRed: mix(ugRed, other.ugRed),
      ugRedLight: mix(ugRedLight, other.ugRedLight),
      ugFlamenco: mix(ugFlamenco, other.ugFlamenco),
      ugFlamencoLight: mix(ugFlamencoLight, other.ugFlamencoLight),
      ugOcre: mix(ugOcre, other.ugOcre),
      ugOcreLight: mix(ugOcreLight, other.ugOcreLight),
      ugAguaMarina: mix(ugAguaMarina, other.ugAguaMarina),
      ugAguaMarinaLight: mix(ugAguaMarinaLight, other.ugAguaMarinaLight),
      ugAmarilloDesierto: mix(ugAmarilloDesierto, other.ugAmarilloDesierto),
      ugAmarilloDesiertoLight:
          mix(ugAmarilloDesiertoLight, other.ugAmarilloDesiertoLight),
      ugAzulMar: mix(ugAzulMar, other.ugAzulMar),
      ugAzulMarLight: mix(ugAzulMarLight, other.ugAzulMarLight),
      ugNegro: mix(ugNegro, other.ugNegro),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      surfaceContainerLowest:
          mix(surfaceContainerLowest, other.surfaceContainerLowest),
      surfaceContainerLow: mix(surfaceContainerLow, other.surfaceContainerLow),
      surfaceContainer: mix(surfaceContainer, other.surfaceContainer),
      surfaceContainerHigh: mix(surfaceContainerHigh, other.surfaceContainerHigh),
      surfaceContainerHighest:
          mix(surfaceContainerHighest, other.surfaceContainerHighest),
      onPrimary: mix(onPrimary, other.onPrimary),
      onSurface: mix(onSurface, other.onSurface),
      onSurfaceVariant: mix(onSurfaceVariant, other.onSurfaceVariant),
      outline: mix(outline, other.outline),
      outlineVariant: mix(outlineVariant, other.outlineVariant),
    );
  }
}

/// Acceso rápido a la paleta del tema activo: `context.colors.ugBlue`.
extension AppPaletteContext on BuildContext {
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

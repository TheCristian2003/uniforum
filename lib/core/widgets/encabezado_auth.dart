import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Encabezado degradado reutilizable para las pantallas de entrada
/// (login, registro y onboarding).
///
/// No proviene de Google Stitch: es una extensión coherente con el sistema
/// visual del resto de la app (tarjetas claras y acentos `ugYellow`).
class EncabezadoAuth extends StatelessWidget {
  const EncabezadoAuth({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.icono = Icons.school_rounded,
    this.onBack,
  });

  final String titulo;
  final String subtitulo;
  final IconData icono;
  final VoidCallback? onBack;

  static const _colorTexto = Color(0xFF3D2B00);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.ugOcre, AppColors.ugYellow],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: _orbe(150, Colors.white.withValues(alpha: 0.20)),
            ),
            Positioned(
              bottom: -50,
              left: -20,
              child: _orbe(140, AppColors.ugRed.withValues(alpha: 0.12)),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onBack != null) ...[
                      _BotonAtras(onTap: onBack!),
                      const SizedBox(height: 12),
                    ],
                    Container(
                      width: 60,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Icon(icono, size: 32, color: _colorTexto),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: _colorTexto,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitulo,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.3,
                        color: _colorTexto.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _orbe(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
    ),
  );
}

class _BotonAtras extends StatelessWidget {
  const _BotonAtras({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.25),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            Icons.arrow_back,
            size: 20,
            color: Color(0xFF3D2B00),
          ),
        ),
      ),
    );
  }
}

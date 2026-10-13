import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Control de voto reutilizable (arriba / puntaje / abajo).
///
/// Sigue el patrón de las tarjetas del feed en `docs/design/DESIGN.md`: una
/// píldora con borde suave y los botones resaltados cuando el usuario ya votó.
class ControlVoto extends StatelessWidget {
  const ControlVoto({
    super.key,
    required this.puntaje,
    required this.miVoto,
    required this.onVotar,
    this.habilitado = true,
  });

  final int puntaje;
  final int? miVoto;
  final ValueChanged<int> onVotar;

  /// Cuando es `false` (por ejemplo, contenido propio o acción en curso) los
  /// botones quedan deshabilitados.
  final bool habilitado;

  @override
  Widget build(BuildContext context) {
    final votoPositivo = miVoto == 1;
    final votoNegativo = miVoto == -1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: miVoto == null
            ? AppColors.surfaceContainerLow
            : (votoPositivo ? AppColors.ugBlueLight : AppColors.ugRedLight),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: votoPositivo
              ? AppColors.ugBlue
              : (votoNegativo ? AppColors.ugRed : AppColors.outlineVariant),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BotonVoto(
            icono: Icons.arrow_upward,
            activo: votoPositivo,
            colorActivo: AppColors.ugBlue,
            onTap: habilitado ? () => onVotar(1) : null,
            tooltip: 'Votar a favor',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              '$puntaje',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: votoPositivo
                    ? AppColors.ugBlue
                    : (votoNegativo ? AppColors.ugRed : AppColors.onSurface),
              ),
            ),
          ),
          _BotonVoto(
            icono: Icons.arrow_downward,
            activo: votoNegativo,
            colorActivo: AppColors.ugRed,
            onTap: habilitado ? () => onVotar(-1) : null,
            tooltip: 'Votar en contra',
          ),
        ],
      ),
    );
  }
}

class _BotonVoto extends StatelessWidget {
  const _BotonVoto({
    required this.icono,
    required this.activo,
    required this.colorActivo,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icono;
  final bool activo;
  final Color colorActivo;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: activo ? colorActivo : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icono,
            size: 18,
            color: activo
                ? Colors.white
                : (onTap == null
                    ? AppColors.outlineVariant
                    : AppColors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

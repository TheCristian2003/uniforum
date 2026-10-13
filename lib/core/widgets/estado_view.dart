import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Indicador de carga a pantalla completa reutilizable.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (mensaje != null) ...[
            const SizedBox(height: 12),
            Text(
              mensaje!,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

/// Estado vacío reutilizable: se usa cuando una lista o sección no tiene datos.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icono,
    required this.titulo,
    this.mensaje,
    this.etiquetaAccion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String? mensaje;
  final String? etiquetaAccion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.ugBlueLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 34, color: AppColors.ugBlue),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (mensaje != null) ...[
              const SizedBox(height: 6),
              Text(
                mensaje!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
            if (etiquetaAccion != null && onAccion != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onAccion,
                child: Text(etiquetaAccion!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado de error reutilizable con acción opcional de reintento.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.mensaje = 'Algo salió mal. Inténtalo de nuevo.',
    this.onReintentar,
  });

  final String mensaje;
  final VoidCallback? onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.ugRedLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 34,
                color: AppColors.ugRed,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.onSurfaceVariant),
            ),
            if (onReintentar != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onReintentar,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

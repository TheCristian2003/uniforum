import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mensaje en línea para estados de error o información en formularios.
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.texto,
    this.tipo = MessageCardTipo.error,
  });

  final String texto;
  final MessageCardTipo tipo;

  @override
  Widget build(BuildContext context) {
    final esError = tipo == MessageCardTipo.error;
    final color = esError ? AppColors.ugRed : AppColors.ugBlue;
    final fondo = esError ? AppColors.ugRedLight : AppColors.ugBlueLight;
    final icono = esError ? Icons.error_outline : Icons.info_outline;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icono, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

enum MessageCardTipo { error, info }

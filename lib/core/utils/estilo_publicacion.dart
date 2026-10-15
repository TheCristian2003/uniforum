import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Estilo visual (icono y color) para diferenciar tipos de publicación.
class EstiloTipo {
  const EstiloTipo({required this.icono, required this.color});

  final IconData icono;
  final Color color;
}

/// Icono y color de un tipo de publicación a partir de `maestra.codigo`.
EstiloTipo estiloTipo(BuildContext context, String? codigo) {
  final c = context.colors;
  switch (codigo) {
    case 'discusion':
      return EstiloTipo(icono: Icons.forum_outlined, color: c.ugAzulMar);
    case 'aviso':
      return EstiloTipo(icono: Icons.campaign_outlined, color: c.ugRed);
    case 'venta':
      return EstiloTipo(
        icono: Icons.storefront_outlined,
        color: c.ugAmarilloDesierto,
      );
    case 'perdido':
      return EstiloTipo(
        icono: Icons.search_off_outlined,
        color: c.ugAmarilloDesierto,
      );
    case 'encontrado':
      return EstiloTipo(
        icono: Icons.volunteer_activism_outlined,
        color: c.ugAguaMarina,
      );
    case 'evento':
      return EstiloTipo(icono: Icons.event_outlined, color: c.ugFlamenco);
    default:
      return EstiloTipo(
        icono: Icons.article_outlined,
        color: c.onSurfaceVariant,
      );
  }
}

/// Color asociado a una categoría de publicación a partir de `maestra.codigo`.
Color colorCategoria(BuildContext context, String? codigo) {
  final c = context.colors;
  switch (codigo) {
    case 'academico':
      return c.ugAzulMar;
    case 'vida_universitaria':
      return c.ugAguaMarina;
    case 'chisme':
      return c.ugFlamenco;
    case 'deportes':
      return c.ugOcre;
    case 'eventos':
      return c.ugRed;
    case 'marketplace':
      return c.ugAmarilloDesierto;
    case 'tecnologia':
      return c.ugNegro;
    case 'general':
      return c.ugBlue;
    default:
      return c.onSurfaceVariant;
  }
}

/// Fondo translúcido derivado de un color de acento.
Color fondoAcento(Color color) => color.withValues(alpha: 0.12);

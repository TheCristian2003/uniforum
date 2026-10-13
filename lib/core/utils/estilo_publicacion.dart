import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Estilo visual (icono y color) para diferenciar tipos de publicación.
class EstiloTipo {
  const EstiloTipo({required this.icono, required this.color});

  final IconData icono;
  final Color color;
}

const _estilosTipo = <String, EstiloTipo>{
  'discusion': EstiloTipo(icono: Icons.forum_outlined, color: AppColors.ugAzulMar),
  'aviso': EstiloTipo(icono: Icons.campaign_outlined, color: AppColors.ugRed),
  'venta': EstiloTipo(icono: Icons.storefront_outlined, color: AppColors.ugAmarilloDesierto),
  'perdido': EstiloTipo(
    icono: Icons.search_off_outlined,
    color: AppColors.ugAmarilloDesierto,
  ),
  'encontrado': EstiloTipo(
    icono: Icons.volunteer_activism_outlined,
    color: AppColors.ugAguaMarina,
  ),
  'evento': EstiloTipo(icono: Icons.event_outlined, color: AppColors.ugFlamenco),
};

const _estiloTipoPorDefecto =
    EstiloTipo(icono: Icons.article_outlined, color: AppColors.onSurfaceVariant);

/// Icono y color de un tipo de publicación a partir de `maestra.codigo`.
EstiloTipo estiloTipo(String? codigo) =>
    _estilosTipo[codigo] ?? _estiloTipoPorDefecto;

const _coloresCategoria = <String, Color>{
  'academico': AppColors.ugAzulMar,
  'vida_universitaria': AppColors.ugAguaMarina,
  'chisme': AppColors.ugFlamenco,
  'deportes': AppColors.ugOcre,
  'eventos': AppColors.ugRed,
  'marketplace': AppColors.ugAmarilloDesierto,
  'tecnologia': AppColors.ugNegro,
  'general': AppColors.ugBlue,
};

/// Color asociado a una categoría de publicación a partir de `maestra.codigo`.
Color colorCategoria(String? codigo) =>
    _coloresCategoria[codigo] ?? AppColors.onSurfaceVariant;

/// Fondo translúcido derivado de un color de acento.
Color fondoAcento(Color color) => color.withValues(alpha: 0.12);

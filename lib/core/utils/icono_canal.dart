import 'package:flutter/material.dart';

/// Traduce el nombre de icono guardado en `canales.icono` a un icono Material.
///
/// La base guarda el nombre corto (por ejemplo `groups`). Si no se reconoce, se
/// usa un icono genérico de canal.
IconData iconoCanal(String? nombre) {
  switch (nombre) {
    case 'groups':
      return Icons.groups;
    case 'engineering':
      return Icons.engineering;
    case 'favorite':
      return Icons.favorite;
    case 'school':
      return Icons.school;
    case 'campaign':
      return Icons.campaign;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'terminal':
      return Icons.terminal;
    case 'sports_soccer':
      return Icons.sports_soccer;
    case 'palette':
      return Icons.palette;
    case 'search_check':
      return Icons.search;
    case 'forum':
      return Icons.forum;
    default:
      return Icons.forum;
  }
}

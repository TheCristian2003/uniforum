/// Niveles de gamificación según los puntos de reputación.
///
/// Umbrales de referencia definidos en `AGENTS.md`:
/// Novato 0-49, Activo 50-149, Referente 150-399, Leyenda 400+.
class Nivel {
  const Nivel({
    required this.numero,
    required this.nombre,
    required this.minimo,
    this.siguiente,
  });

  /// Número de nivel (1..4) para insignias compactas como "Nv. 3".
  final int numero;
  final String nombre;
  final int minimo;

  /// Puntos necesarios para el siguiente nivel; `null` en el nivel máximo.
  final int? siguiente;
}

Nivel nivelDesdePuntos(int puntos) {
  if (puntos >= 400) {
    return const Nivel(numero: 4, nombre: 'Leyenda', minimo: 400);
  }
  if (puntos >= 150) {
    return const Nivel(numero: 3, nombre: 'Referente', minimo: 150, siguiente: 400);
  }
  if (puntos >= 50) {
    return const Nivel(numero: 2, nombre: 'Activo', minimo: 50, siguiente: 150);
  }
  return const Nivel(numero: 1, nombre: 'Novato', minimo: 0, siguiente: 50);
}

/// Progreso (0.0 a 1.0) hacia el siguiente nivel. En el nivel máximo es 1.0.
double progresoNivel(int puntos) {
  final nivel = nivelDesdePuntos(puntos);
  final siguiente = nivel.siguiente;
  if (siguiente == null) return 1;
  final rango = siguiente - nivel.minimo;
  final avance = (puntos - nivel.minimo).clamp(0, rango);
  return avance / rango;
}

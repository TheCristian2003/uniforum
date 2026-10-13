import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/gamification/niveles.dart';

void main() {
  test('nivelDesdePuntos aplica los umbrales de referencia', () {
    expect(nivelDesdePuntos(0).nombre, 'Novato');
    expect(nivelDesdePuntos(49).nombre, 'Novato');
    expect(nivelDesdePuntos(50).nombre, 'Activo');
    expect(nivelDesdePuntos(149).nombre, 'Activo');
    expect(nivelDesdePuntos(150).nombre, 'Referente');
    expect(nivelDesdePuntos(399).nombre, 'Referente');
    expect(nivelDesdePuntos(400).nombre, 'Leyenda');
    expect(nivelDesdePuntos(9999).nombre, 'Leyenda');
  });

  test('progresoNivel calcula el avance y satura en el nivel máximo', () {
    expect(progresoNivel(25), closeTo(0.5, 1e-9));
    expect(progresoNivel(100), closeTo(0.5, 1e-9));
    expect(progresoNivel(500), 1.0);
  });
}

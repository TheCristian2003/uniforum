import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/insignia.dart';

void main() {
  test('Insignia.fromFila marca obtenida cuando hay fecha', () {
    final insignia = Insignia.fromFila(
      const {
        'codigo': 'primer_paso',
        'nombre': 'Primer paso',
        'descripcion': 'Primera publicación válida.',
        'icono': 'star',
      },
      obtenidoEn: DateTime.utc(2026, 10, 12),
    );

    expect(insignia.codigo, 'primer_paso');
    expect(insignia.nombre, 'Primer paso');
    expect(insignia.icono, 'star');
    expect(insignia.obtenida, isTrue);
    expect(insignia.obtenidoEn, isNotNull);
  });

  test('sin fecha de obtención, la insignia queda pendiente', () {
    final insignia = Insignia.fromFila(
      const {
        'codigo': 'tendencia',
        'nombre': 'Tendencia',
        'descripcion': null,
        'icono': null,
      },
      obtenidoEn: null,
    );

    expect(insignia.obtenida, isFalse);
    expect(insignia.obtenidoEn, isNull);
    expect(insignia.descripcion, isNull);
  });
}

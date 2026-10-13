import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/auth/roles.dart';

void main() {
  test('puedePublicarTipo restringe el aviso a roles privilegiados', () {
    expect(puedePublicarTipo('aviso', privilegiado: false), isFalse);
    expect(puedePublicarTipo('aviso', privilegiado: true), isTrue);
  });

  test('puedePublicarTipo permite los tipos sociales a cualquier usuario', () {
    for (final codigo in ['discusion', 'venta', 'perdido', 'encontrado', 'evento']) {
      expect(puedePublicarTipo(codigo, privilegiado: false), isTrue);
    }
  });
}

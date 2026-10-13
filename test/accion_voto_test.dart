import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/utils/accion_voto.dart';

void main() {
  test('sin voto previo se inserta', () {
    expect(accionVoto(null, 1), AccionVoto.insertar);
    expect(accionVoto(null, -1), AccionVoto.insertar);
  });

  test('tocar el mismo valor quita el voto', () {
    expect(accionVoto(1, 1), AccionVoto.eliminar);
    expect(accionVoto(-1, -1), AccionVoto.eliminar);
  });

  test('cambiar de valor actualiza el voto existente', () {
    expect(accionVoto(1, -1), AccionVoto.actualizar);
    expect(accionVoto(-1, 1), AccionVoto.actualizar);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/restriccion.dart';

void main() {
  test('Restriccion.fromJson temporal está vigente si no ha expirado', () {
    final restriccion = Restriccion.fromJson({
      'id': 'r1',
      'usuario_id': 'u2',
      'motivo': 'Acoso',
      'inicia_en': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
      'expira_en': DateTime.now()
          .add(const Duration(days: 6))
          .toIso8601String(),
      'activa': true,
      'creado_en': DateTime.now().toIso8601String(),
      'tipo': {'codigo': 'temporal'},
    });

    expect(restriccion.tipo, 'temporal');
    expect(restriccion.permanente, isFalse);
    expect(restriccion.vigente, isTrue);
  });

  test('una restricción temporal expirada no está vigente', () {
    final restriccion = Restriccion.fromJson({
      'id': 'r2',
      'usuario_id': 'u2',
      'motivo': 'Spam',
      'inicia_en': DateTime.now()
          .subtract(const Duration(days: 10))
          .toIso8601String(),
      'expira_en': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
      'activa': true,
      'creado_en': DateTime.now().toIso8601String(),
      'tipo': {'codigo': 'temporal'},
    });

    expect(restriccion.vigente, isFalse);
  });

  test('una restricción permanente sin expiración está vigente', () {
    final restriccion = Restriccion.fromJson({
      'id': 'r3',
      'usuario_id': 'u2',
      'motivo': 'Fraude',
      'inicia_en': DateTime.now().toIso8601String(),
      'expira_en': null,
      'activa': true,
      'creado_en': DateTime.now().toIso8601String(),
      'tipo': {'codigo': 'permanente'},
    });

    expect(restriccion.permanente, isTrue);
    expect(restriccion.vigente, isTrue);
  });

  test('una restricción levantada no está vigente', () {
    final restriccion = Restriccion.fromJson({
      'id': 'r4',
      'usuario_id': 'u2',
      'motivo': 'Otro',
      'inicia_en': DateTime.now().toIso8601String(),
      'expira_en': null,
      'activa': false,
      'creado_en': DateTime.now().toIso8601String(),
      'tipo': {'codigo': 'permanente'},
    });

    expect(restriccion.vigente, isFalse);
  });
}

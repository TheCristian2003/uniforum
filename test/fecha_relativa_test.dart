import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/utils/fecha_relativa.dart';

void main() {
  final ahora = DateTime(2026, 10, 11, 12, 0, 0);

  test('fechaRelativa cubre segundos, minutos, horas, días y semanas', () {
    expect(
      fechaRelativa(ahora.subtract(const Duration(seconds: 30)), ahora: ahora),
      'hace un momento',
    );
    expect(
      fechaRelativa(ahora.subtract(const Duration(minutes: 5)), ahora: ahora),
      'hace 5 min',
    );
    expect(
      fechaRelativa(ahora.subtract(const Duration(hours: 3)), ahora: ahora),
      'hace 3 h',
    );
    expect(
      fechaRelativa(ahora.subtract(const Duration(days: 2)), ahora: ahora),
      'hace 2 d',
    );
    expect(
      fechaRelativa(ahora.subtract(const Duration(days: 14)), ahora: ahora),
      'hace 2 sem',
    );
  });
}

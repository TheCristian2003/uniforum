import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/metadatos_publicacion.dart';

void main() {
  test('vacio es true sin campos', () {
    expect(const MetadatosPublicacion().vacio, isTrue);
    expect(const MetadatosPublicacion(disponible: true).vacio, isFalse);
  });

  test('toJson omite claves nulas', () {
    const metadatos = MetadatosPublicacion(
      precio: 15000,
      moneda: 'COP',
      lugar: 'Bloque B',
      disponible: true,
    );
    final json = metadatos.toJson();

    expect(
      json.keys,
      containsAll(<String>['precio', 'moneda', 'lugar', 'disponible']),
    );
    expect(json.containsKey('fecha'), isFalse);
    expect(json.length, 4);
  });

  test('fromJson/toJson conservan números', () {
    const metadatos = MetadatosPublicacion(
      precio: 15000,
      recompensa: 20000,
      moneda: 'COP',
    );
    final leido = MetadatosPublicacion.fromJson(metadatos.toJson());

    expect(leido.precio, 15000);
    expect(leido.recompensa, 20000);
    expect(leido.moneda, 'COP');
  });

  test('fromJson parsea fechas ISO del evento', () {
    final inicio = DateTime.utc(2026, 10, 12, 18, 0);
    final fin = DateTime.utc(2026, 10, 12, 20, 30);
    final json = MetadatosPublicacion(inicio: inicio, fin: fin).toJson();

    final leido = MetadatosPublicacion.fromJson(json);
    expect(leido.inicio, inicio);
    expect(leido.fin, fin);
  });

  test('fromJson tolera fechas inválidas como nulas', () {
    final leido = MetadatosPublicacion.fromJson({'fecha': 'no-es-fecha'});

    expect(leido.fecha, isNull);
  });
}

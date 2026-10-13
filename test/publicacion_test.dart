import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/publicacion.dart';

const autorId = '11111111-1111-1111-1111-111111111111';

Map<String, dynamic> jsonPublicacion({
  bool anonimo = false,
  Map<String, dynamic>? metadatos,
}) => {
  'id': 'p1',
  'canal_id': 'c1',
  'autor_id': autorId,
  'tipo_id': 165,
  'categoria_id': 171,
  'titulo': 'Hola',
  'cuerpo': 'contenido de prueba',
  'anonimo': anonimo,
  'puntaje': 5,
  'creado_en': '2026-10-11T12:00:00.000Z',
      'canal': {'nombre': 'Comunidad general'},
      'metadatos': ?metadatos,
    };

const autores = {
  autorId: {'alias': 'mateo_dev', 'es_verificada': true},
};

void main() {
  test('Publicacion.fromJson resuelve tipo, categoría, canal y autor', () {
    final publicacion = Publicacion.fromJson(
      jsonPublicacion(),
      tipos: {165: 'Discusión'},
      categorias: {171: 'Académico'},
      autores: autores,
    );

    expect(publicacion.tipoNombre, 'Discusión');
    expect(publicacion.categoriaNombre, 'Académico');
    expect(publicacion.canalNombre, 'Comunidad general');
    expect(publicacion.autorId, autorId);
    expect(publicacion.autorAlias, 'mateo_dev');
    expect(publicacion.autorVerificada, isTrue);
    expect(publicacion.puntaje, 5);
    expect(publicacion.creadoEn.isUtc, isTrue);
  });

  test('Publicacion.fromJson parsea metadatos y usa vacío por defecto', () {
    final conDatos = Publicacion.fromJson(
      jsonPublicacion(
        metadatos: {'precio': 15000, 'moneda': 'COP', 'disponible': true},
      ),
      categorias: const {},
    );

    expect(conDatos.metadatos.precio, 15000);
    expect(conDatos.metadatos.moneda, 'COP');
    expect(conDatos.metadatos.disponible, isTrue);
    expect(conDatos.metadatos.vacio, isFalse);

    final sinDatos = Publicacion.fromJson(
      jsonPublicacion(),
      categorias: const {},
    );
    expect(sinDatos.metadatos.vacio, isTrue);
  });

  test('esDe compara con el usuario autenticado', () {
    final publicacion = Publicacion.fromJson(
      jsonPublicacion(),
      categorias: const {},
    );

    expect(publicacion.esDe(autorId), isTrue);
    expect(publicacion.esDe('otro'), isFalse);
    expect(publicacion.esDe(null), isFalse);
  });

  test('Publicacion anónima oculta autor y verificación', () {
    final publicacion = Publicacion.fromJson(
      jsonPublicacion(anonimo: true),
      categorias: {},
      autores: autores,
    );

    expect(publicacion.anonimo, isTrue);
    expect(publicacion.autorAlias, isNull);
    expect(publicacion.autorVerificada, isFalse);
    // La autoría real se conserva para moderación.
    expect(publicacion.autorId, autorId);
  });
}

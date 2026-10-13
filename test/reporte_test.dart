import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/reporte.dart';

void main() {
  test('Reporte.fromJson sobre una publicación', () {
    final reporte = Reporte.fromJson({
      'id': 'r1',
      'publicacion_id': 'p1',
      'comentario_id': null,
      'descripcion': 'Posible spam',
      'creado_en': '2026-10-11T12:00:00Z',
      'motivo': {'nombre': 'Desinformación'},
      'estado': {'codigo': 'pendiente'},
      'reportante': {'alias': 'ana'},
      'publicacion': {
        'id': 'p1',
        'titulo': 'Título',
        'cuerpo': 'Cuerpo',
        'autor_id': 'u2',
      },
      'comentario': null,
    });

    expect(reporte.esComentario, isFalse);
    expect(reporte.motivo, 'Desinformación');
    expect(reporte.estado, 'pendiente');
    expect(reporte.reportanteAlias, 'ana');
    expect(reporte.tituloContenido, 'Título');
    expect(reporte.contenido, 'Cuerpo');
    expect(reporte.autorId, 'u2');
  });

  test('Reporte.fromJson sobre un comentario y valores por defecto', () {
    final reporte = Reporte.fromJson({
      'id': 'r2',
      'publicacion_id': null,
      'comentario_id': 'c1',
      'descripcion': null,
      'creado_en': '2026-10-11T12:00:00Z',
      'motivo': null,
      'estado': null,
      'reportante': null,
      'publicacion': null,
      'comentario': {'id': 'c1', 'cuerpo': 'Comentario ofensivo'},
    });

    expect(reporte.esComentario, isTrue);
    expect(reporte.motivo, 'Otro');
    expect(reporte.estado, 'pendiente');
    expect(reporte.reportanteAlias, isNull);
    expect(reporte.tituloContenido, isNull);
    expect(reporte.contenido, 'Comentario ofensivo');
  });
}

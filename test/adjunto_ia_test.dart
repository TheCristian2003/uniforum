import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/adjunto_ia.dart';

void main() {
  test('AdjuntoIA serializa los bytes en base64 y detecta el tipo', () {
    final bytes = Uint8List.fromList(utf8.encode('hola campus'));
    final adjunto = AdjuntoIA(
      nombre: 'nota.txt',
      mimeType: 'text/plain',
      bytes: bytes,
    );

    final json = adjunto.toJson();

    expect(json['nombre'], 'nota.txt');
    expect(json['mimeType'], 'text/plain');
    expect(json['datosBase64'], base64Encode(bytes));
    expect(adjunto.tamano, bytes.length);
    expect(adjunto.esTexto, isTrue);
    expect(adjunto.esAudio, isFalse);
  });

  test('AdjuntoIA reconoce audio y PDF', () {
    final bytes = Uint8List.fromList([1, 2, 3]);

    expect(
      AdjuntoIA(nombre: 'audio.m4a', mimeType: 'audio/mp4', bytes: bytes)
          .esAudio,
      isTrue,
    );
    expect(
      AdjuntoIA(
        nombre: 'guia.pdf',
        mimeType: 'application/pdf',
        bytes: bytes,
      ).esPdf,
      isTrue,
    );
  });
}

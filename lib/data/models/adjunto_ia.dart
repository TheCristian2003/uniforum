import 'dart:convert';
import 'dart:typed_data';

/// Archivo que se envía junto a una consulta de la IA del Campus.
///
/// Los bytes viajan en base64 dentro de la solicitud autenticada a la Edge
/// Function. La función valida tipo y tamaño antes de pasarlos a Gemini; el
/// archivo no se guarda en Supabase Storage ni se persiste en la app.
class AdjuntoIA {
  const AdjuntoIA({
    required this.nombre,
    required this.mimeType,
    required this.bytes,
  });

  final String nombre;
  final String mimeType;
  final Uint8List bytes;

  int get tamano => bytes.length;

  bool get esAudio => mimeType.startsWith('audio/');
  bool get esImagen => mimeType.startsWith('image/');
  bool get esPdf => mimeType == 'application/pdf';
  bool get esTexto =>
      mimeType == 'text/plain' ||
      mimeType == 'text/markdown' ||
      mimeType == 'text/csv' ||
      mimeType == 'application/json';

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'mimeType': mimeType,
        'datosBase64': base64Encode(bytes),
      };
}

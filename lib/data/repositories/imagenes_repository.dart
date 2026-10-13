import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Subida de imágenes adjuntas a Supabase Storage.
///
/// Las imágenes se guardan en el bucket público `publicaciones` dentro de la
/// carpeta del usuario (`{uid}/archivo`); las políticas RLS de Storage usan esa
/// carpeta para permitir la escritura solo a su dueño.
class ImagenesRepository {
  ImagenesRepository(this._client);

  final SupabaseClient _client;
  static const _bucket = 'publicaciones';
  static final _azar = Random();

  /// Formatos permitidos y su tipo MIME.
  static const formatosPermitidos = {'jpg', 'jpeg', 'png', 'webp'};

  static const _mime = {
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
    'webp': 'image/webp',
  };

  /// Sube [bytes] a la carpeta de [usuarioId] y devuelve la URL pública.
  ///
  /// Lanza [ArgumentError] si la [extension] no está permitida.
  Future<String> subirAdjunto({
    required String usuarioId,
    required Uint8List bytes,
    required String extension,
  }) async {
    final ext = extension.toLowerCase().replaceFirst('.', '');
    final contentType = _mime[ext];
    if (contentType == null) {
      throw ArgumentError('Formato de imagen no permitido: $extension');
    }
    final sufijo = _azar.nextInt(1 << 32).toRadixString(16);
    final nombre = '${DateTime.now().microsecondsSinceEpoch}_$sufijo.$ext';
    final path = '$usuarioId/$nombre';
    final storage = _client.storage.from(_bucket);
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );
    return storage.getPublicUrl(path);
  }
}

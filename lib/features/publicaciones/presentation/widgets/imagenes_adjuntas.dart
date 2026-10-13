import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Imagen elegida en el cliente, en memoria, pendiente de subir a Storage.
class ImagenSeleccionada {
  const ImagenSeleccionada({required this.bytes, required this.extension});

  final Uint8List bytes;
  final String extension;
}

/// Muestra las imágenes adjuntas de una publicación o comentario.
///
/// Con una sola imagen se muestra a lo ancho; con varias, una fila desplazable.
class ImagenesAdjuntas extends StatelessWidget {
  const ImagenesAdjuntas({super.key, required this.urls, this.radio = 14});

  final List<String> urls;
  final double radio;

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();
    if (urls.length == 1) {
      return _Imagen(url: urls.first, alto: 200, radio: radio);
    }
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, indice) =>
            _Imagen(url: urls[indice], ancho: 130, alto: 130, radio: radio),
      ),
    );
  }
}

class _Imagen extends StatelessWidget {
  const _Imagen({
    required this.url,
    required this.alto,
    required this.radio,
    this.ancho,
  });

  final String url;
  final double alto;
  final double radio;
  final double? ancho;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: GestureDetector(
        onTap: () => _verAmpliada(context, url),
        child: Image.network(
          url,
          width: ancho,
          height: alto,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progreso) => Container(
            width: ancho,
            height: alto,
            color: AppColors.surfaceContainer,
            child: progreso == null
                ? child
                : const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
          ),
          errorBuilder: (_, _, _) => Container(
            width: ancho,
            height: alto,
            color: AppColors.surfaceContainer,
            alignment: Alignment.center,
            child: const Icon(
              Icons.broken_image_outlined,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  void _verAmpliada(BuildContext context, String url) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Icon(Icons.broken_image_outlined, color: Colors.white),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

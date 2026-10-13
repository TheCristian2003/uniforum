import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/estilo_publicacion.dart';
import '../../../core/utils/fecha_relativa.dart';
import '../../../core/widgets/estado_view.dart';
import '../../../data/models/comentario.dart';
import '../../../data/models/metadatos_publicacion.dart';
import '../../../data/models/mis_votos.dart';
import '../../../data/models/publicacion.dart';
import '../../feed/presentation/widgets/control_voto.dart';
import '../../moderacion/presentation/reportar_sheet.dart';
import 'crear_publicacion_screen.dart';
import 'widgets/imagenes_adjuntas.dart';

/// Detalle de una publicación: contenido, votos y comentarios.
///
/// No existe una pantalla equivalente en `docs/design/DESIGN.md`; se construye
/// reutilizando la tarjeta de feed, el control de voto y los widgets de estado
/// para mantener coherencia con el resto de la aplicación.
class PublicacionDetalleScreen extends ConsumerStatefulWidget {
  const PublicacionDetalleScreen({super.key, required this.publicacion});

  final Publicacion publicacion;

  @override
  ConsumerState<PublicacionDetalleScreen> createState() =>
      _PublicacionDetalleScreenState();
}

class _PublicacionDetalleScreenState
    extends ConsumerState<PublicacionDetalleScreen> {
  final _comentarioController = TextEditingController();
  final List<ImagenSeleccionada> _imagenesComentario = [];
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  Future<void> _elegirImagenComentario() async {
    if (_imagenesComentario.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes adjuntar 1 imagen.')),
      );
      return;
    }
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (!mounted || file == null) return;
    final bytes = await file.readAsBytes();
    const maxBytes = 5 * 1024 * 1024;
    if (bytes.length > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen supera los 5 MB. Selecciona una más ligera.'),
        ),
      );
      return;
    }
    setState(() {
      _imagenesComentario.add(
        ImagenSeleccionada(
          bytes: bytes,
          extension: file.path.split('.').last.toLowerCase(),
        ),
      );
    });
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _refrescarVotos() {
    ref.invalidate(misVotosProvider);
    ref.invalidate(publicacionDetalleProvider(widget.publicacion.id));
    ref.invalidate(comentariosDePublicacionProvider(widget.publicacion.id));
    ref.invalidate(feedRecientesProvider);
    ref.invalidate(publicacionesDeCanalProvider(widget.publicacion.canalId));
  }

  Future<void> _votarPublicacion(int valor) async {
    final actual = ref
        .read(misVotosProvider)
        .value
        ?.votoPublicacion(widget.publicacion.id);
    try {
      await ref
          .read(votosRepositoryProvider)
          .votarPublicacion(
            publicacionId: widget.publicacion.id,
            valor: valor,
            votoActual: actual,
          );
      _refrescarVotos();
    } catch (_) {
      _mostrarError('No se pudo registrar tu voto.');
    }
  }

  Future<void> _votarComentario(String comentarioId, int valor) async {
    final actual = ref
        .read(misVotosProvider)
        .value
        ?.votoComentario(comentarioId);
    try {
      await ref
          .read(votosRepositoryProvider)
          .votarComentario(
            comentarioId: comentarioId,
            valor: valor,
            votoActual: actual,
          );
      _refrescarVotos();
    } catch (_) {
      _mostrarError('No se pudo registrar tu voto.');
    }
  }

  Future<void> _comentar() async {
    final texto = _comentarioController.text.trim();
    if (texto.isEmpty || _enviando) return;
    final restriccion = ref.read(miRestriccionActivaProvider).value;
    if (restriccion != null && restriccion.vigente) {
      _mostrarError('Tu cuenta está restringida: no puedes comentar.');
      return;
    }
    setState(() => _enviando = true);
    try {
      List<String> imagenes = const [];
      final user = ref.read(currentUserProvider);
      if (_imagenesComentario.isNotEmpty && user != null) {
        final url = await ref.read(imagenesRepositoryProvider).subirAdjunto(
              usuarioId: user.id,
              bytes: _imagenesComentario.first.bytes,
              extension: _imagenesComentario.first.extension,
            );
        imagenes = [url];
      }
      await ref
          .read(comentariosRepositoryProvider)
          .crear(publicacionId: widget.publicacion.id, cuerpo: texto, imagenes: imagenes);
      _comentarioController.clear();
      setState(() => _imagenesComentario.clear());
      ref.invalidate(comentariosDePublicacionProvider(widget.publicacion.id));
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(publicacionesDeCanalProvider(widget.publicacion.canalId));
    } catch (_) {
      _mostrarError('No se pudo publicar tu comentario.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _marcarSolucion(String comentarioId) async {
    try {
      await ref
          .read(comentariosRepositoryProvider)
          .marcarSolucion(comentarioId);
      ref.invalidate(comentariosDePublicacionProvider(widget.publicacion.id));
    } catch (_) {
      _mostrarError(
        'Solo el autor de la publicación puede marcar una solución.',
      );
    }
  }

  Future<void> _reportarComentario(String comentarioId) {
    return mostrarReportarSheet(context, comentarioId: comentarioId);
  }

  Publicacion get _actual =>
      ref.read(publicacionDetalleProvider(widget.publicacion.id)).value ??
      widget.publicacion;

  Future<void> _editar() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CrearPublicacionScreen(publicacion: _actual),
      ),
    );
    ref.invalidate(publicacionDetalleProvider(widget.publicacion.id));
    ref.invalidate(feedRecientesProvider);
    ref.invalidate(publicacionesDeCanalProvider(widget.publicacion.canalId));
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar publicación'),
        content: const Text(
          '¿Seguro que quieres eliminar esta publicación? '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ugRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await ref
          .read(publicacionesRepositoryProvider)
          .eliminarPublicacion(widget.publicacion.id);
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(publicacionesDeCanalProvider(widget.publicacion.canalId));
      ref.invalidate(publicacionDetalleProvider(widget.publicacion.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación eliminada.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      _mostrarError('No se pudo eliminar la publicación.');
    }
  }

  Future<void> _reportarPublicacion() {
    return mostrarReportarSheet(context, publicacionId: widget.publicacion.id);
  }

  @override
  Widget build(BuildContext context) {
    final detalle = ref.watch(
      publicacionDetalleProvider(widget.publicacion.id),
    );
    final publicacion = detalle.value ?? widget.publicacion;
    final comentarios = ref.watch(
      comentariosDePublicacionProvider(widget.publicacion.id),
    );
    final misVotos =
        ref.watch(misVotosProvider).value ?? const MisVotos.vacia();
    final miId = ref.watch(currentUserProvider)?.id;
    final esMia = publicacion.esDe(miId);
    final totalComentarios = comentarios.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicación'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (value) {
              switch (value) {
                case 'editar':
                  _editar();
                case 'eliminar':
                  _eliminar();
                case 'reportar':
                  _reportarPublicacion();
              }
            },
            itemBuilder: (_) => esMia
                ? const [
                    PopupMenuItem(
                      value: 'editar',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'eliminar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.ugRed,
                          ),
                          SizedBox(width: 12),
                          Text('Eliminar'),
                        ],
                      ),
                    ),
                  ]
                : const [
                    PopupMenuItem(
                      value: 'reportar',
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            size: 20,
                            color: AppColors.ugRed,
                          ),
                          SizedBox(width: 12),
                          Text('Reportar'),
                        ],
                      ),
                    ),
                  ],
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _refrescarVotos();
            try {
              await ref.read(
                comentariosDePublicacionProvider(widget.publicacion.id).future,
              );
            } catch (_) {
              // El error se refleja en el estado de la vista.
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _TarjetaPublicacion(
                child: _EncabezadoPublicacion(
                  publicacion: publicacion,
                  miVoto: misVotos.votoPublicacion(publicacion.id),
                  habilitado: !esMia,
                  onVotar: _votarPublicacion,
                ),
              ),
              const SizedBox(height: 24),
              _EncabezadoComentarios(total: totalComentarios),
              const SizedBox(height: 12),
              comentarios.when(
                data: (items) => items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: EmptyView(
                          icono: Icons.forum_outlined,
                          titulo: 'Aún no hay comentarios',
                          mensaje: 'Sé la primera persona en comentar.',
                        ),
                      )
                    : Column(
                        children: [
                          for (final comentario in items)
                            _ComentarioTile(
                              comentario: comentario,
                              miVoto: misVotos.votoComentario(comentario.id),
                              esPropia: comentario.autorId == miId,
                              esAutorPublicacion: esMia,
                              onVotar: (valor) =>
                                  _votarComentario(comentario.id, valor),
                              onMarcarSolucion: () =>
                                  _marcarSolucion(comentario.id),
                              onReportar: comentario.autorId == miId
                                  ? null
                                  : () => _reportarComentario(comentario.id),
                            ),
                        ],
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: LoadingView(mensaje: 'Cargando comentarios…'),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: ErrorView(
                    mensaje: 'No se pudieron cargar los comentarios.',
                    onReintentar: () => ref.invalidate(
                      comentariosDePublicacionProvider(widget.publicacion.id),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _CampoComentario(
        controller: _comentarioController,
        enviando: _enviando,
        imagen: _imagenesComentario.isNotEmpty
            ? _imagenesComentario.first.bytes
            : null,
        onAnadirImagen: _elegirImagenComentario,
        onQuitarImagen: _imagenesComentario.isEmpty
            ? null
            : () => setState(() => _imagenesComentario.clear()),
        onEnviar: _comentar,
      ),
    );
  }
}

class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _EncabezadoComentarios extends StatelessWidget {
  const _EncabezadoComentarios({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.forum_outlined, size: 20, color: AppColors.onSurface),
        const SizedBox(width: 8),
        const Text(
          'Comentarios',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$total',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _EncabezadoPublicacion extends StatelessWidget {
  const _EncabezadoPublicacion({
    required this.publicacion,
    required this.miVoto,
    required this.habilitado,
    required this.onVotar,
  });

  final Publicacion publicacion;
  final int? miVoto;
  final bool habilitado;
  final ValueChanged<int> onVotar;

  @override
  Widget build(BuildContext context) {
    final alias = publicacion.anonimo
        ? 'Anónimo'
        : (publicacion.autorAlias ?? 'Usuario');
    final tieneAvatar =
        !publicacion.anonimo &&
        publicacion.autorAvatarUrl != null &&
        publicacion.autorAvatarUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Avatar(
              alias: alias,
              imagen: tieneAvatar ? publicacion.autorAvatarUrl : null,
              anonimo: publicacion.anonimo,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          alias,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (publicacion.autorVerificada) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          size: 16,
                          color: AppColors.ugBlue,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    [
                      if (publicacion.canalNombre != null)
                        publicacion.canalNombre!,
                      fechaRelativa(publicacion.creadoEn),
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (publicacion.titulo != null ||
            publicacion.metadatos.precio != null) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (publicacion.titulo != null)
                Expanded(
                  child: Text(
                    publicacion.titulo!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              if (publicacion.metadatos.precio != null) ...[
                if (publicacion.titulo != null) const SizedBox(width: 10),
                Text(
                  '\$${numeroCorto(publicacion.metadatos.precio!)} '
                  '${publicacion.metadatos.moneda ?? 'COP'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ugFlamenco,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
        ],
        Text(publicacion.cuerpo, style: const TextStyle(height: 1.5)),
        if (publicacion.imagenes.isNotEmpty) ...[
          const SizedBox(height: 14),
          ImagenesAdjuntas(urls: publicacion.imagenes),
        ],
        if (!publicacion.metadatos.vacio) ...[
          const SizedBox(height: 14),
          _DetalleMetadatos(metadatos: publicacion.metadatos),
        ],
        const SizedBox(height: 16),
        Container(height: 1, color: AppColors.outlineVariant),
        const SizedBox(height: 12),
        Row(
          children: [
            if (publicacion.categoriaNombre != null)
              _Etiqueta(
                texto: publicacion.categoriaNombre!,
                color: colorCategoria(publicacion.categoriaCodigo),
                fondo: fondoAcento(
                  colorCategoria(publicacion.categoriaCodigo),
                ),
              ),
            if (publicacion.tipoNombre != null) ...[
              const SizedBox(width: 6),
              _Etiqueta(
                texto: publicacion.tipoNombre!,
                icono: estiloTipo(publicacion.tipoCodigo).icono,
                color: estiloTipo(publicacion.tipoCodigo).color,
                fondo: fondoAcento(estiloTipo(publicacion.tipoCodigo).color),
              ),
            ],
            const Spacer(),
            ControlVoto(
              puntaje: publicacion.puntaje,
              miVoto: miVoto,
              habilitado: habilitado,
              onVotar: onVotar,
            ),
          ],
        ),
        if (!habilitado)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'No puedes votar tu propia publicación.',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class _DetalleMetadatos extends StatelessWidget {
  const _DetalleMetadatos({required this.metadatos});

  final MetadatosPublicacion metadatos;

  @override
  Widget build(BuildContext context) {
    final m = metadatos;
    final filas = <(String, String)>[];
    if (m.precio != null) {
      filas.add(('Precio', '${numeroCorto(m.precio!)} ${m.moneda ?? 'COP'}'));
    }
    if (m.recompensa != null) {
      filas.add((
        'Recompensa',
        '${numeroCorto(m.recompensa!)} ${m.moneda ?? 'COP'}',
      ));
    }
    if (m.fecha != null) filas.add(('Fecha', fechaCorta(m.fecha!)));
    if (m.inicio != null) filas.add(('Inicio', fechaHora(m.inicio!)));
    if (m.fin != null) filas.add(('Fin', fechaHora(m.fin!)));
    if (m.lugar != null) filas.add(('Lugar', m.lugar!));
    if (m.disponible != null) {
      filas.add(('Estado', m.disponible! ? 'Disponible' : 'No disponible'));
    }
    if (m.entregado != null) {
      filas.add(('Estado', m.entregado! ? 'Entregado' : 'Aún no entregado'));
    }
    if (m.enlace != null) filas.add(('Enlace', m.enlace!));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final fila in filas)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      fila.$1,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fila.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ComentarioTile extends StatelessWidget {
  const _ComentarioTile({
    required this.comentario,
    required this.miVoto,
    required this.esPropia,
    required this.esAutorPublicacion,
    required this.onVotar,
    required this.onMarcarSolucion,
    this.onReportar,
  });

  final Comentario comentario;
  final int? miVoto;
  final bool esPropia;
  final bool esAutorPublicacion;
  final ValueChanged<int> onVotar;
  final VoidCallback onMarcarSolucion;
  final VoidCallback? onReportar;

  @override
  Widget build(BuildContext context) {
    final alias = comentario.autorAlias ?? 'Usuario';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: comentario.esSolucion
              ? AppColors.ugBlue
              : AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(alias: alias, imagen: null, anonimo: false, radio: 14),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            alias,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (comentario.autorVerificada) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            size: 14,
                            color: AppColors.ugBlue,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      fechaRelativa(comentario.creadoEn),
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (comentario.esSolucion)
                _Etiqueta(
                  texto: 'Solución',
                  color: AppColors.ugBlue,
                  fondo: AppColors.surfaceContainerLowest,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comentario.cuerpo, style: const TextStyle(height: 1.5)),
          if (comentario.imagenes.isNotEmpty) ...[
            const SizedBox(height: 10),
            ImagenesAdjuntas(urls: comentario.imagenes, radio: 10),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              ControlVoto(
                puntaje: comentario.puntaje,
                miVoto: miVoto,
                habilitado: !esPropia,
                onVotar: onVotar,
              ),
              const Spacer(),
              if (esAutorPublicacion && !comentario.esSolucion)
                TextButton.icon(
                  onPressed: onMarcarSolucion,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.ugBlue,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Marcar solución'),
                ),
              if (onReportar != null)
                IconButton(
                  onPressed: onReportar,
                  tooltip: 'Reportar comentario',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CampoComentario extends StatelessWidget {
  const _CampoComentario({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
    this.imagen,
    this.onAnadirImagen,
    this.onQuitarImagen,
  });

  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;
  final Uint8List? imagen;
  final VoidCallback? onAnadirImagen;
  final VoidCallback? onQuitarImagen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: AppColors.outlineVariant)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imagen != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          imagen!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onQuitarImagen,
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                    tooltip: 'Adjuntar imagen',
                    onPressed: enviando ? null : onAnadirImagen,
                    icon: const Icon(Icons.image_outlined),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onEnviar(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Escribe un comentario...',
                        filled: true,
                        fillColor: AppColors.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: enviando
                        ? AppColors.surfaceContainerHigh
                        : AppColors.ugBlue,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: enviando ? null : onEnviar,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: enviando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              )
                            : const Icon(Icons.send, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.alias,
    required this.imagen,
    required this.anonimo,
    this.radio = 22,
  });

  final String alias;
  final String? imagen;
  final bool anonimo;
  final double radio;

  @override
  Widget build(BuildContext context) {
    final tieneImagen = imagen != null && imagen!.isNotEmpty;
    return CircleAvatar(
      radius: radio,
      backgroundColor: AppColors.ugBlueLight,
      backgroundImage: tieneImagen ? NetworkImage(imagen!) : null,
      child: tieneImagen
          ? null
          : (anonimo
                ? Icon(Icons.person, size: radio + 4, color: AppColors.ugBlue)
                : Text(
                    alias.isNotEmpty ? alias[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.ugBlue,
                      fontSize: radio * 0.8,
                    ),
                  )),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.color,
    required this.fondo,
    this.icono,
  });

  final String texto;
  final Color color;
  final Color fondo;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icono != null) ...[
            Icon(icono, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            texto,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

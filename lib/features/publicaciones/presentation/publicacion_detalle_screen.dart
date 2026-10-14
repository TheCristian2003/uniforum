import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/roles.dart';
import '../../../core/gamification/niveles.dart';
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
import '../../perfil/presentation/perfil_screen.dart';
import 'crear_publicacion_screen.dart';
import 'widgets/imagenes_adjuntas.dart';

/// Orden aplicado a la lista de comentarios del detalle.
enum _OrdenComentarios { votados, recientes }

/// Detalle de una publicación: contenido, votos y comentarios.
///
/// Sigue el diseño "Detalle de Publicación" de `docs/design/DESIGN.md` y
/// reutiliza el control de voto y los widgets de estado para mantener la
/// coherencia con el resto de la aplicación.
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
  _OrdenComentarios _orden = _OrdenComentarios.votados;

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

  Future<void> _editarComentario(Comentario comentario) async {
    final actualizado = await showDialog<bool>(
      context: context,
      builder: (_) => _EditarComentarioDialog(comentario: comentario),
    );
    if (actualizado == true) {
      ref.invalidate(comentariosDePublicacionProvider(widget.publicacion.id));
    }
  }

  Future<void> _eliminarComentario(
    Comentario comentario, {
    required bool propia,
  }) async {
    final confirmar = await _confirmar(
      titulo: 'Eliminar comentario',
      mensaje: '¿Seguro que quieres eliminar este comentario? '
          'Esta acción no se puede deshacer.',
    );
    if (!confirmar) return;
    try {
      if (propia) {
        await ref.read(comentariosRepositoryProvider).eliminar(comentario.id);
      } else {
        await ref
            .read(moderacionRepositoryProvider)
            .eliminarComentario(comentario.id);
      }
      ref.invalidate(comentariosDePublicacionProvider(widget.publicacion.id));
      ref.invalidate(comentariosRecientesProvider);
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(publicacionesDeCanalProvider(widget.publicacion.canalId));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentario eliminado.')),
      );
    } catch (_) {
      _mostrarError('No se pudo eliminar el comentario.');
    }
  }

  /// Diálogo de confirmación reutilizable para acciones destructivas.
  Future<bool> _confirmar({
    required String titulo,
    required String mensaje,
    String accion = 'Eliminar',
  }) async {
    final resultado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.ugRed),
            child: Text(accion),
          ),
        ],
      ),
    );
    return resultado == true;
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
    final confirmar = await _confirmar(
      titulo: 'Eliminar publicación',
      mensaje: '¿Seguro que quieres eliminar esta publicación? '
          'Esta acción no se puede deshacer.',
    );
    if (!confirmar) return;
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

  /// Oculta una publicación (moderación). Deja de aparecer en el feed.
  Future<void> _ocultarPublicacion() async {
    final confirmar = await _confirmar(
      titulo: 'Ocultar publicación',
      mensaje: 'La publicación dejará de mostrarse en el feed público. '
          'Podrás revisarla desde la pantalla de Moderación.',
      accion: 'Ocultar',
    );
    if (!confirmar) return;
    try {
      await ref
          .read(moderacionRepositoryProvider)
          .ocultarPublicacion(widget.publicacion.id);
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(publicacionesDeCanalProvider(widget.publicacion.canalId));
      ref.invalidate(publicacionDetalleProvider(widget.publicacion.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación oculta.')),
      );
    } catch (_) {
      _mostrarError('No se pudo ocultar la publicación.');
    }
  }

  /// Borrado duro de una publicación ajena (moderación).
  Future<void> _eliminarPorModeracion() async {
    final confirmar = await _confirmar(
      titulo: 'Eliminar publicación',
      mensaje: 'Como moderador, esta acción borra el contenido de forma '
          'permanente, junto con sus comentarios y votos. No se puede '
          'deshacer.',
    );
    if (!confirmar) return;
    try {
      await ref
          .read(moderacionRepositoryProvider)
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

  void _avisoIA() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('El asistente IA estará disponible próximamente.'),
      ),
    );
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
    final privilegiado = esRolPrivilegiado(ref.watch(currentUserProvider));
    final totalComentarios = comentarios.value?.length ?? 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            tooltip: 'Volver',
            onPressed: () => Navigator.of(context).maybePop(),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainer,
              foregroundColor: AppColors.ugBlue,
            ),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        titleSpacing: 4,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.ugOcre,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '#${publicacion.canalNombre ?? 'General'}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ugBlue,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 13,
                  color: AppColors.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  fechaRelativa(publicacion.creadoEn),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            icon: const Icon(
              Icons.more_vert,
              color: AppColors.onSurfaceVariant,
            ),
            onSelected: (value) {
              switch (value) {
                case 'editar':
                  _editar();
                case 'eliminar':
                  _eliminar();
                case 'ocultar':
                  _ocultarPublicacion();
                case 'eliminar_moderacion':
                  _eliminarPorModeracion();
                case 'reportar':
                  _reportarPublicacion();
              }
            },
            itemBuilder: (_) {
              if (esMia) {
                return const [
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
                ];
              }
              return [
                if (privilegiado) ...[
                  const PopupMenuItem(
                    value: 'ocultar',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_off_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Ocultar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'eliminar_moderacion',
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
                ],
                const PopupMenuItem(
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
              ];
            },
          ),
        ],
      ),
      body: SafeArea(
        top: false,
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _TarjetaPublicacion(
                publicacion: publicacion,
                miVoto: misVotos.votoPublicacion(publicacion.id),
                habilitado: !esMia,
                onVotar: _votarPublicacion,
                totalComentarios: totalComentarios,
                onTapAutor:
                    (esMia || publicacion.anonimo || publicacion.autorId == null)
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => PerfilUsuarioScreen(
                            usuarioId: publicacion.autorId!,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              _EncabezadoComentarios(
                total: totalComentarios,
                orden: _orden,
                onCambiarOrden: (orden) => setState(() => _orden = orden),
              ),
              const SizedBox(height: 12),
              comentarios.when(
                data: (items) {
                  if (items.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: EmptyView(
                        icono: Icons.forum_outlined,
                        titulo: 'Aún no hay comentarios',
                        mensaje: 'Sé la primera persona en comentar.',
                      ),
                    );
                  }
                  final ordenados = [...items];
                  switch (_orden) {
                    case _OrdenComentarios.votados:
                      ordenados.sort((a, b) => b.puntaje.compareTo(a.puntaje));
                    case _OrdenComentarios.recientes:
                      ordenados.sort((a, b) => b.creadoEn.compareTo(a.creadoEn));
                  }
                  return Column(
                    children: [
                      for (final comentario in ordenados)
                        _ComentarioTile(
                          comentario: comentario,
                          miVoto: misVotos.votoComentario(comentario.id),
                          esPropia: comentario.autorId == miId,
                          esAutorPublicacion: esMia,
                          esDelAutor: comentario.autorId == publicacion.autorId,
                          onVotar: (valor) =>
                              _votarComentario(comentario.id, valor),
                          onMarcarSolucion: () => _marcarSolucion(comentario.id),
                          onTapAutor: comentario.autorId == miId
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PerfilUsuarioScreen(
                                      usuarioId: comentario.autorId,
                                    ),
                                  ),
                                ),
                          onEditar: comentario.autorId == miId
                              ? () => _editarComentario(comentario)
                              : null,
                          onEliminar:
                              (comentario.autorId == miId || privilegiado)
                              ? () => _eliminarComentario(
                                  comentario,
                                  propia: comentario.autorId == miId,
                                )
                              : null,
                          onReportar: comentario.autorId == miId
                              ? null
                              : () => _reportarComentario(comentario.id),
                        ),
                    ],
                  );
                },
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
        onAsistenteIA: _avisoIA,
        onEnviar: _comentar,
      ),
    );
  }
}

/// Tarjeta principal con la publicación destacada.
class _TarjetaPublicacion extends StatelessWidget {
  const _TarjetaPublicacion({
    required this.publicacion,
    required this.miVoto,
    required this.habilitado,
    required this.onVotar,
    required this.totalComentarios,
    this.onTapAutor,
  });

  final Publicacion publicacion;
  final int? miVoto;
  final bool habilitado;
  final ValueChanged<int> onVotar;
  final int totalComentarios;
  final VoidCallback? onTapAutor;

  @override
  Widget build(BuildContext context) {
    final alias = publicacion.anonimo
        ? 'Anónimo'
        : (publicacion.autorAlias ?? 'Usuario');
    final tipo = estiloTipo(publicacion.tipoCodigo);
    final tieneAvatar = !publicacion.anonimo &&
        publicacion.autorAvatarUrl != null &&
        publicacion.autorAvatarUrl!.isNotEmpty;
    final nivel = publicacion.autorPuntos != null
        ? nivelDesdePuntos(publicacion.autorPuntos!).numero
        : null;
    final textoEtiqueta = [
      if (publicacion.categoriaNombre != null)
        publicacion.categoriaNombre!.toUpperCase(),
      if (publicacion.tipoNombre != null) publicacion.tipoNombre!,
    ].join(' • ');

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 4, color: tipo.color),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onTapAutor,
                      behavior: HitTestBehavior.opaque,
                      child: _AvatarNivel(
                        alias: alias,
                        imagen: tieneAvatar
                            ? publicacion.autorAvatarUrl
                            : null,
                        anonimo: publicacion.anonimo,
                        nivel: nivel,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: onTapAutor,
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(
                                    alias,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
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
                          const SizedBox(height: 2),
                          Text(
                            fechaRelativa(publicacion.creadoEn),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (publicacion.tipoNombre != null) ...[
                      const SizedBox(width: 8),
                      _ChipTipo(tipo: tipo, texto: publicacion.tipoNombre!),
                    ],
                  ],
                ),
                if (textoEtiqueta.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _EtiquetaCategoria(
                    texto: textoEtiqueta,
                    color: colorCategoria(publicacion.categoriaCodigo),
                  ),
                ],
                if (publicacion.titulo != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    publicacion.titulo!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  publicacion.cuerpo,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                ),
                if (publicacion.imagenes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ImagenesAdjuntas(urls: publicacion.imagenes),
                ],
                if (!publicacion.metadatos.vacio) ...[
                  const SizedBox(height: 14),
                  _DetalleMetadatos(metadatos: publicacion.metadatos),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      ControlVoto(
                        puntaje: publicacion.puntaje,
                        miVoto: miVoto,
                        habilitado: habilitado,
                        onVotar: onVotar,
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.forum_outlined,
                        size: 19,
                        color: AppColors.ugBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$totalComentarios',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!habilitado)
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text(
                      'No puedes votar tu propia publicación.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
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

/// Encabezado de la sección de comentarios con el selector de orden.
class _EncabezadoComentarios extends StatelessWidget {
  const _EncabezadoComentarios({
    required this.total,
    required this.orden,
    required this.onCambiarOrden,
  });

  final int total;
  final _OrdenComentarios orden;
  final ValueChanged<_OrdenComentarios> onCambiarOrden;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Comentarios',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.ugBlueLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ugBlue,
                ),
              ),
            ),
            const Spacer(),
            const Icon(Icons.tune, size: 16, color: AppColors.outline),
            const SizedBox(width: 4),
            const Text(
              'Filtro',
              style: TextStyle(fontSize: 12, color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _ChipFiltro(
                texto: 'Más votados',
                icono: Icons.trending_up,
                activo: orden == _OrdenComentarios.votados,
                onTap: () => onCambiarOrden(_OrdenComentarios.votados),
              ),
              const SizedBox(width: 8),
              _ChipFiltro(
                texto: 'Recientes',
                activo: orden == _OrdenComentarios.recientes,
                onTap: () => onCambiarOrden(_OrdenComentarios.recientes),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.texto,
    required this.activo,
    required this.onTap,
    this.icono,
  });

  final String texto;
  final bool activo;
  final VoidCallback onTap;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    const colorActivo = Color(0xFF644400);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? AppColors.ugOcre : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: activo
                ? AppColors.ugOcre
                : AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icono != null) ...[
              Icon(
                icono,
                size: 15,
                color: activo ? colorActivo : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                color: activo ? colorActivo : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Panel con los metadatos específicos del tipo de publicación.
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

/// Tarjeta de un comentario con su autor, votos y acciones.
class _ComentarioTile extends StatelessWidget {
  const _ComentarioTile({
    required this.comentario,
    required this.miVoto,
    required this.esPropia,
    required this.esAutorPublicacion,
    required this.esDelAutor,
    required this.onVotar,
    required this.onMarcarSolucion,
    this.onTapAutor,
    this.onEditar,
    this.onEliminar,
    this.onReportar,
  });

  final Comentario comentario;
  final int? miVoto;
  final bool esPropia;
  final bool esAutorPublicacion;
  final bool esDelAutor;
  final ValueChanged<int> onVotar;
  final VoidCallback onMarcarSolucion;
  final VoidCallback? onTapAutor;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;
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
              ? AppColors.ugAguaMarina
              : AppColors.outlineVariant.withValues(alpha: 0.4),
          width: comentario.esSolucion ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comentario.esSolucion) ...[
            const _BannerSolucion(),
            const SizedBox(height: 12),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onTapAutor,
                behavior: HitTestBehavior.opaque,
                child: _Avatar(
                  alias: alias,
                  imagen: comentario.autorAvatarUrl,
                  anonimo: false,
                  radio: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: GestureDetector(
                            onTap: onTapAutor,
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              alias,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
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
                        if (esDelAutor) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ugOcre,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Autor',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF644400),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
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
              if (onReportar != null)
                IconButton(
                  onPressed: onReportar,
                  tooltip: 'Reportar comentario',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              if (onEditar != null || onEliminar != null)
                PopupMenuButton<String>(
                  tooltip: 'Más opciones',
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                    color: AppColors.onSurfaceVariant,
                  ),
                  onSelected: (value) {
                    switch (value) {
                      case 'editar':
                        onEditar?.call();
                      case 'eliminar':
                        onEliminar?.call();
                    }
                  },
                  itemBuilder: (_) => [
                    if (onEditar != null)
                      const PopupMenuItem(
                        value: 'editar',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 12),
                            Text('Editar'),
                          ],
                        ),
                      ),
                    if (onEliminar != null)
                      const PopupMenuItem(
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
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comentario.cuerpo,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          if (comentario.imagenes.isNotEmpty) ...[
            const SizedBox(height: 10),
            ImagenesAdjuntas(urls: comentario.imagenes, radio: 10),
          ],
          const SizedBox(height: 8),
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
            ],
          ),
        ],
      ),
    );
  }
}

/// Diálogo para editar el cuerpo y la imagen de un comentario propio.
class _EditarComentarioDialog extends ConsumerStatefulWidget {
  const _EditarComentarioDialog({required this.comentario});

  final Comentario comentario;

  @override
  ConsumerState<_EditarComentarioDialog> createState() =>
      _EditarComentarioDialogState();
}

class _EditarComentarioDialogState
    extends ConsumerState<_EditarComentarioDialog> {
  late final TextEditingController _controller;
  final List<ImagenSeleccionada> _nueva = [];
  late String? _urlActual;
  bool _guardando = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comentario.cuerpo);
    _urlActual = widget.comentario.imagenes.isEmpty
        ? null
        : widget.comentario.imagenes.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _elegirImagen() async {
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
      _nueva
        ..clear()
        ..add(
          ImagenSeleccionada(
            bytes: bytes,
            extension: file.path.split('.').last.toLowerCase(),
          ),
        );
    });
  }

  void _quitarImagen() {
    setState(() {
      _nueva.clear();
      _urlActual = null;
    });
  }

  Future<void> _guardar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _guardando) return;
    setState(() => _guardando = true);
    try {
      final List<String> imagenes;
      if (_nueva.isNotEmpty) {
        final user = ref.read(currentUserProvider);
        if (user == null) throw StateError('Sin sesión');
        final url = await ref.read(imagenesRepositoryProvider).subirAdjunto(
              usuarioId: user.id,
              bytes: _nueva.first.bytes,
              extension: _nueva.first.extension,
            );
        imagenes = [url];
      } else if (_urlActual != null) {
        imagenes = [_urlActual!];
      } else {
        imagenes = const [];
      }
      await ref.read(comentariosRepositoryProvider).actualizar(
            comentarioId: widget.comentario.id,
            cuerpo: texto,
            imagenes: imagenes,
          );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar el comentario.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneImagen = _nueva.isNotEmpty || _urlActual != null;

    return AlertDialog(
      scrollable: true,
      title: const Text('Editar comentario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'Comentario',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          if (tieneImagen) ...[
            _VistaImagen(url: _urlActual, bytes: _nueva.isEmpty ? null : _nueva.first.bytes),
            const SizedBox(height: 4),
            TextButton.icon(
              onPressed: _guardando ? null : _quitarImagen,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Quitar imagen'),
            ),
          ] else
            OutlinedButton.icon(
              onPressed: _guardando ? null : _elegirImagen,
              icon: const Icon(Icons.image_outlined, size: 18),
              label: const Text('Añadir imagen'),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

/// Vista previa de una imagen de comentario (URL remota o bytes locales).
class _VistaImagen extends StatelessWidget {
  const _VistaImagen({this.url, this.bytes});

  final String? url;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: bytes != null
          ? Image.memory(
              bytes!,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.network(
              url ?? '',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 150,
                color: AppColors.surfaceContainer,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
    );
  }
}

/// Franja que destaca un comentario marcado como solución.
class _BannerSolucion extends StatelessWidget {
  const _BannerSolucion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ugAguaMarina.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.ugAguaMarina.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user,
            size: 18,
            color: AppColors.ugAguaMarina,
          ),
          const SizedBox(width: 8),
          const Text(
            'Solución verificada',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ugAguaMarina,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.ugOcre,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              '+15 EXP',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF644400),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra inferior fija para escribir un comentario.
class _CampoComentario extends StatelessWidget {
  const _CampoComentario({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
    required this.onAsistenteIA,
    this.imagen,
    this.onAnadirImagen,
    this.onQuitarImagen,
  });

  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;
  final VoidCallback onAsistenteIA;
  final Uint8List? imagen;
  final VoidCallback? onAnadirImagen;
  final VoidCallback? onQuitarImagen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          border: Border(
            top: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
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
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
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
                              child: Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
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
                    color: AppColors.onSurfaceVariant,
                    icon: const Icon(Icons.attach_file),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onEnviar(),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Escribe un aporte constructivo...',
                        filled: true,
                        fillColor: AppColors.background,
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          10,
                          48,
                          10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(
                            color: AppColors.ugBlue,
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Material(
                            color: AppColors.ugOcre,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: onAsistenteIA,
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 30,
                                height: 30,
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: Color(0xFF644400),
                                ),
                              ),
                            ),
                          ),
                        ),
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 34,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: enviando
                        ? AppColors.surfaceContainerHigh
                        : AppColors.ugOcre,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: enviando ? null : onEnviar,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: enviando
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_upward,
                                size: 20,
                                color: Color(0xFF644400),
                              ),
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

/// Avatar con anillo degradado y la insignia de nivel superpuesta.
class _AvatarNivel extends StatelessWidget {
  const _AvatarNivel({
    required this.alias,
    required this.imagen,
    required this.anonimo,
    this.nivel,
  });

  final String alias;
  final String? imagen;
  final bool anonimo;
  final int? nivel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ugOcre, AppColors.ugBlue],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: _Avatar(
                alias: alias,
                imagen: imagen,
                anonimo: anonimo,
                radio: 20,
              ),
            ),
          ),
          if (nivel != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.ugBlue,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  'Nv.$nivel',
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Chip con el tipo de publicación.
class _ChipTipo extends StatelessWidget {
  const _ChipTipo({required this.tipo, required this.texto});

  final EstiloTipo tipo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: fondoAcento(tipo.color),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tipo.color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tipo.icono, size: 13, color: tipo.color),
          const SizedBox(width: 4),
          Text(
            texto,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: tipo.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Etiqueta con la categoría y el tipo de la publicación.
class _EtiquetaCategoria extends StatelessWidget {
  const _EtiquetaCategoria({required this.texto, required this.color});

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_offer_outlined, size: 13, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              texto,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: color,
              ),
            ),
          ),
        ],
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

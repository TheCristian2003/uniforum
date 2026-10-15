import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/roles.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/fecha_relativa.dart';
import '../../../core/widgets/estado_view.dart';
import '../../../data/models/catalogo_item.dart';
import '../../../data/models/comentario.dart';
import '../../../data/models/publicacion.dart';
import '../../../data/models/reporte.dart';
import '../../../data/repositories/moderacion_repository.dart';
import '../../../data/repositories/reportes_repository.dart';

/// Pantalla mínima de moderación: lista los reportes pendientes y permite
/// ocultar o eliminar el contenido y restringir a su autor, además de marcar
/// el reporte como revisado o cerrado.
///
/// No existe un diseño equivalente en `docs/design/DESIGN.md`; reutiliza los
/// widgets de estado y el lenguaje visual de las tarjetas del feed.
class ModeracionScreen extends ConsumerStatefulWidget {
  const ModeracionScreen({super.key});

  @override
  ConsumerState<ModeracionScreen> createState() => _ModeracionScreenState();
}

class _ModeracionScreenState extends ConsumerState<ModeracionScreen> {
  int? _idCodigo(List<CatalogoItem> estados, String codigo) {
    for (final estado in estados) {
      if (estado.codigo == codigo) return estado.id;
    }
    return null;
  }

  Future<void> _cambiarEstado(String reporteId, int estadoId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(reportesRepositoryProvider)
          .marcarEstado(reporteId: reporteId, estadoId: estadoId);
      ref.invalidate(reportesPendientesProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Reporte actualizado.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el reporte.')),
      );
    }
  }

  Future<void> _ocultar(Reporte reporte, int? revisadoId) async {
    final publicacionId = reporte.publicacionId;
    if (publicacionId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(moderacionRepositoryProvider)
          .ocultarPublicacion(publicacionId);
      if (revisadoId != null) {
        await ref
            .read(reportesRepositoryProvider)
            .marcarEstado(reporteId: reporte.id, estadoId: revisadoId);
      }
      ref.invalidate(reportesPendientesProvider);
      ref.invalidate(feedRecientesProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Publicación oculta.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo ocultar la publicación.')),
      );
    }
  }

  Future<void> _eliminar(Reporte reporte) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar contenido'),
        content: const Text(
          'Esta acción borra el contenido de forma permanente, junto con sus '
          'comentarios y votos. No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.colors.ugRed),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      final repo = ref.read(moderacionRepositoryProvider);
      if (reporte.esComentario) {
        await repo.eliminarComentario(reporte.comentarioId!);
      } else {
        await repo.eliminarPublicacion(reporte.publicacionId!);
      }
      ref.invalidate(reportesPendientesProvider);
      ref.invalidate(feedRecientesProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Contenido eliminado.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el contenido.')),
      );
    }
  }

  Future<void> _restringir(Reporte reporte, int? revisadoId) async {
    final autorId = reporte.autorId;
    if (autorId == null) return;
    final messenger = ScaffoldMessenger.of(context);
    final entrada = await _showRestringirDialog(context);
    if (entrada == null) return;

    try {
      await ref
          .read(moderacionRepositoryProvider)
          .restringirUsuario(
            usuarioId: autorId,
            motivo: entrada.motivo,
            dias: entrada.dias,
            reporteId: reporte.id,
          );
      if (revisadoId != null) {
        await ref
            .read(reportesRepositoryProvider)
            .marcarEstado(reporteId: reporte.id, estadoId: revisadoId);
      }
      ref.invalidate(reportesPendientesProvider);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            entrada.dias == null
                ? 'Usuario restringido de forma permanente.'
                : 'Usuario restringido por ${entrada.dias} días.',
          ),
        ),
      );
    } catch (error) {
      final texto = error.toString().toLowerCase();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            texto.contains('ya tiene una restricción')
                ? 'El usuario ya tiene una restricción vigente.'
                : 'No se pudo restringir al usuario.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final privilegiado = esRolPrivilegiado(ref.watch(currentUserProvider));

    if (!privilegiado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Moderación')),
        body: const EmptyView(
          icono: Icons.gpp_maybe_outlined,
          titulo: 'Acceso restringido',
          mensaje: 'Solo el equipo de moderación puede revisar los reportes.',
        ),
      );
    }

    final miId = ref.watch(currentUserProvider)?.id;
    final reportes = ref.watch(reportesPendientesProvider);
    final estados = ref.watch(catalogoProvider(ReportesRepository.estado));
    final listaEstados = estados.value ?? const <CatalogoItem>[];
    final revisadoId = _idCodigo(listaEstados, 'revisado');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Moderación'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Reportes'),
              Tab(text: 'Contenido'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _reportesView(reportes, listaEstados, revisadoId, miId),
              const _ContenidoTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportesView(
    AsyncValue<List<Reporte>> reportes,
    List<CatalogoItem> listaEstados,
    int? revisadoId,
    String? miId,
  ) {
    return reportes.when(
      data: (items) => items.isEmpty
          ? _vacio()
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                for (final reporte in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ReporteTile(
                      reporte: reporte,
                      estados: listaEstados,
                      puedeRestringir:
                          reporte.autorId != null &&
                          reporte.autorId != miId,
                      onCambiarEstado: (estadoId) =>
                          _cambiarEstado(reporte.id, estadoId),
                      onOcultar: () => _ocultar(reporte, revisadoId),
                      onEliminar: () => _eliminar(reporte),
                      onRestringir: () => _restringir(reporte, revisadoId),
                    ),
                  ),
              ],
            ),
      loading: () => const LoadingView(mensaje: 'Cargando reportes…'),
      error: (_, _) => ErrorView(
        mensaje: 'No se pudieron cargar los reportes.',
        onReintentar: () => ref.invalidate(reportesPendientesProvider),
      ),
    );
  }
}

Widget _vacio() => ListView(
  physics: const AlwaysScrollableScrollPhysics(),
  children: const [
    Padding(
      padding: EdgeInsets.only(top: 80),
      child: EmptyView(
        icono: Icons.verified_user_outlined,
        titulo: 'Sin reportes pendientes',
        mensaje: 'Todo está en orden por ahora.',
      ),
    ),
  ],
);

/// Pestaña de moderación que lista contenido reciente sin depender de reportes.
class _ContenidoTab extends ConsumerStatefulWidget {
  const _ContenidoTab();

  @override
  ConsumerState<_ContenidoTab> createState() => _ContenidoTabState();
}

class _ContenidoTabState extends ConsumerState<_ContenidoTab> {
  Future<bool> _confirmar({
    required String titulo,
    required String mensaje,
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
            style: FilledButton.styleFrom(backgroundColor: context.colors.ugRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return resultado == true;
  }

  Future<void> _ocultarPublicacion(String id) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(moderacionRepositoryProvider).ocultarPublicacion(id);
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(publicacionDetalleProvider(id));
      messenger.showSnackBar(
        const SnackBar(content: Text('Publicación oculta.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo ocultar la publicación.')),
      );
    }
  }

  Future<void> _eliminarPublicacion(String id) async {
    final confirmar = await _confirmar(
      titulo: 'Eliminar publicación',
      mensaje: 'Esta acción borra la publicación de forma permanente, junto '
          'con sus comentarios y votos. No se puede deshacer.',
    );
    if (!confirmar) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(moderacionRepositoryProvider).eliminarPublicacion(id);
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(comentariosRecientesProvider);
      messenger.showSnackBar(
        const SnackBar(content: Text('Publicación eliminada.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la publicación.')),
      );
    }
  }

  Future<void> _eliminarComentario(Comentario comentario) async {
    final confirmar = await _confirmar(
      titulo: 'Eliminar comentario',
      mensaje: 'Esta acción borra el comentario de forma permanente. '
          'No se puede deshacer.',
    );
    if (!confirmar) return;
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(moderacionRepositoryProvider)
          .eliminarComentario(comentario.id);
      ref.invalidate(comentariosRecientesProvider);
      ref.invalidate(
        comentariosDePublicacionProvider(comentario.publicacionId),
      );
      messenger.showSnackBar(
        const SnackBar(content: Text('Comentario eliminado.')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar el comentario.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final publicaciones = ref.watch(feedRecientesProvider);
    final comentarios = ref.watch(comentariosRecientesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(feedRecientesProvider);
        ref.invalidate(comentariosRecientesProvider);
        try {
          await Future.wait([
            ref.read(feedRecientesProvider.future),
            ref.read(comentariosRecientesProvider.future),
          ]);
        } catch (_) {
          // El error se refleja en el estado de la vista.
        }
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const _SeccionTitulo(texto: 'Publicaciones recientes'),
          const SizedBox(height: 8),
          publicaciones.when(
            data: (items) => items.isEmpty
                ? const _Aviso(texto: 'No hay publicaciones recientes.')
                : Column(
                    children: [
                      for (final publicacion in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ContenidoPublicacionTile(
                            publicacion: publicacion,
                            onOcultar: () =>
                                _ocultarPublicacion(publicacion.id),
                            onEliminar: () =>
                                _eliminarPublicacion(publicacion.id),
                          ),
                        ),
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: LoadingView(mensaje: 'Cargando publicaciones…'),
            ),
            error: (_, _) => ErrorView(
              mensaje: 'No se pudieron cargar las publicaciones.',
              onReintentar: () => ref.invalidate(feedRecientesProvider),
            ),
          ),
          const SizedBox(height: 24),
          const _SeccionTitulo(texto: 'Comentarios recientes'),
          const SizedBox(height: 8),
          comentarios.when(
            data: (items) => items.isEmpty
                ? const _Aviso(texto: 'No hay comentarios recientes.')
                : Column(
                    children: [
                      for (final comentario in items)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ContenidoComentarioTile(
                            comentario: comentario,
                            onEliminar: () => _eliminarComentario(comentario),
                          ),
                        ),
                    ],
                  ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: LoadingView(mensaje: 'Cargando comentarios…'),
            ),
            error: (_, _) => ErrorView(
              mensaje: 'No se pudieron cargar los comentarios.',
              onReintentar: () => ref.invalidate(comentariosRecientesProvider),
            ),
          ),
        ],
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  const _SeccionTitulo({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: context.colors.ugBlue,
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(color: context.colors.onSurfaceVariant),
      ),
    );
  }
}

class _ContenidoPublicacionTile extends StatelessWidget {
  const _ContenidoPublicacionTile({
    required this.publicacion,
    required this.onOcultar,
    required this.onEliminar,
  });

  final Publicacion publicacion;
  final VoidCallback onOcultar;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final autor =
        publicacion.anonimo ? 'Anónimo' : (publicacion.autorAlias ?? 'Usuario');
    final titulo = publicacion.titulo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(
                texto: publicacion.tipoNombre ?? 'Publicación',
                color: context.colors.ugBlue,
                fondo: context.colors.ugBlueLight,
              ),
              if (publicacion.canalNombre != null) ...[
                const SizedBox(width: 6),
                _Chip(
                  texto: '#${publicacion.canalNombre}',
                  color: context.colors.onSurfaceVariant,
                  fondo: context.colors.surfaceContainer,
                ),
              ],
              const Spacer(),
              Text(
                fechaRelativa(publicacion.creadoEn),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (titulo != null && titulo.isNotEmpty) ...[
            Text(
              titulo,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            publicacion.cuerpo,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Text(
            'Por $autor',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOcultar,
                icon: const Icon(Icons.visibility_off_outlined, size: 18),
                label: const Text('Ocultar'),
              ),
              OutlinedButton.icon(
                onPressed: onEliminar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.ugRed,
                  side: BorderSide(color: context.colors.ugRed),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContenidoComentarioTile extends StatelessWidget {
  const _ContenidoComentarioTile({
    required this.comentario,
    required this.onEliminar,
  });

  final Comentario comentario;
  final VoidCallback onEliminar;

  @override
  Widget build(BuildContext context) {
    final alias = comentario.autorAlias ?? 'Usuario';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(
                texto: 'Comentario',
                color: context.colors.onSurfaceVariant,
                fondo: context.colors.surfaceContainer,
              ),
              const Spacer(),
              Text(
                fechaRelativa(comentario.creadoEn),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            comentario.cuerpo,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Text(
            'Por @$alias',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onEliminar,
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.ugRed,
                side: BorderSide(color: context.colors.ugRed),
              ),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReporteTile extends StatelessWidget {
  const _ReporteTile({
    required this.reporte,
    required this.estados,
    required this.puedeRestringir,
    required this.onCambiarEstado,
    required this.onOcultar,
    required this.onEliminar,
    required this.onRestringir,
  });

  final Reporte reporte;
  final List<CatalogoItem> estados;
  final bool puedeRestringir;
  final ValueChanged<int> onCambiarEstado;
  final VoidCallback onOcultar;
  final VoidCallback onEliminar;
  final VoidCallback onRestringir;

  int? _id(String codigo) {
    for (final estado in estados) {
      if (estado.codigo == codigo) return estado.id;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final revisado = _id('revisado');
    final cerrado = _id('cerrado');
    final descripcion = reporte.descripcion;
    final contenido = reporte.contenido;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Chip(
                texto: reporte.motivo,
                color: context.colors.ugRed,
                fondo: context.colors.ugRedLight,
              ),
              const SizedBox(width: 6),
              _Chip(
                texto: reporte.esComentario ? 'Comentario' : 'Publicación',
                color: context.colors.onSurfaceVariant,
                fondo: context.colors.surfaceContainer,
              ),
              const Spacer(),
              Text(
                fechaRelativa(reporte.creadoEn),
                style: TextStyle(
                  fontSize: 12,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (reporte.tituloContenido != null) ...[
            Text(
              reporte.tituloContenido!,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
          ],
          Text(
            contenido == null || contenido.isEmpty
                ? 'Contenido no disponible.'
                : contenido,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: context.colors.onSurfaceVariant),
          ),
          if (descripcion != null && descripcion.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '“$descripcion”',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            'Reportado por @${reporte.reportanteAlias ?? 'usuario'}',
            style: TextStyle(
              fontSize: 12,
              color: context.colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!reporte.esComentario)
                OutlinedButton.icon(
                  onPressed: onOcultar,
                  icon: const Icon(Icons.visibility_off_outlined, size: 18),
                  label: const Text('Ocultar'),
                ),
              OutlinedButton.icon(
                onPressed: onEliminar,
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.colors.ugRed,
                  side: BorderSide(color: context.colors.ugRed),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar'),
              ),
              if (puedeRestringir)
                OutlinedButton.icon(
                  onPressed: onRestringir,
                  icon: const Icon(Icons.block_outlined, size: 18),
                  label: const Text('Restringir autor'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: revisado == null
                      ? null
                      : () => onCambiarEstado(revisado),
                  child: const Text('Marcar revisado'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonal(
                  onPressed: cerrado == null
                      ? null
                      : () => onCambiarEstado(cerrado),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Resultado del diálogo de restricción.
class _RestriccionInput {
  const _RestriccionInput({required this.motivo, required this.dias});

  final String motivo;
  final int? dias;
}

/// Abre el diálogo para restringir a un usuario. Devuelve `null` si se cancela.
Future<_RestriccionInput?> _showRestringirDialog(BuildContext context) {
  return showDialog<_RestriccionInput>(
    context: context,
    builder: (_) => const _RestringirDialog(),
  );
}

class _RestringirDialog extends StatefulWidget {
  const _RestringirDialog();

  @override
  State<_RestringirDialog> createState() => _RestringirDialogState();
}

class _RestringirDialogState extends State<_RestringirDialog> {
  final _motivoController = TextEditingController();
  int? _dias = 7;

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  void _enviar() {
    final motivo = _motivoController.text.trim();
    if (motivo.length < 3) return;
    Navigator.of(context).pop(_RestriccionInput(motivo: motivo, dias: _dias));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Restringir usuario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'El usuario no podrá publicar ni comentar mientras la restricción '
            'esté vigente.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _motivoController,
            maxLength: 300,
            minLines: 2,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Motivo',
              alignLabelWithHint: true,
              hintText: 'Explica brevemente la sanción',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final opcion in ModeracionRepository.duraciones)
                ChoiceChip(
                  label: Text(opcion.label),
                  selected: _dias == opcion.value,
                  onSelected: (_) => setState(() => _dias = opcion.value),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: context.colors.ugRed),
          onPressed: _motivoController.text.trim().length < 3 ? null : _enviar,
          child: const Text('Restringir'),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.texto, required this.color, required this.fondo});

  final String texto;
  final Color color;
  final Color fondo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

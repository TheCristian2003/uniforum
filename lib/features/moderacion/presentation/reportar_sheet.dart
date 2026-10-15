import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/repositories/reportes_repository.dart';

/// Muestra la hoja inferior para reportar una publicación o un comentario.
Future<void> mostrarReportarSheet(
  BuildContext context, {
  String? publicacionId,
  String? comentarioId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.colors.surfaceContainerLowest,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ReportarSheet(
      publicacionId: publicacionId,
      comentarioId: comentarioId,
    ),
  );
}

class _ReportarSheet extends ConsumerStatefulWidget {
  const _ReportarSheet({this.publicacionId, this.comentarioId});

  final String? publicacionId;
  final String? comentarioId;

  @override
  ConsumerState<_ReportarSheet> createState() => _ReportarSheetState();
}

class _ReportarSheetState extends ConsumerState<_ReportarSheet> {
  final _descripcionController = TextEditingController();
  int? _motivoId;
  bool _enviando = false;

  bool get _esComentario => widget.comentarioId != null;

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final motivoId = _motivoId;
    if (motivoId == null || _enviando) {
      if (motivoId == null) {
        _mostrarMensaje('Elige un motivo para continuar.');
      }
      return;
    }
    setState(() => _enviando = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(reportesRepositoryProvider)
          .crear(
            publicacionId: widget.publicacionId,
            comentarioId: widget.comentarioId,
            motivoId: motivoId,
            descripcion: _descripcionController.text,
          );
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Gracias, revisaremos tu reporte.')),
      );
    } on PostgrestException catch (error) {
      final duplicado = error.message.toLowerCase().contains(
        'reporte pendiente',
      );
      _mostrarMensaje(
        duplicado
            ? 'Ya reportaste este contenido y sigue en revisión.'
            : 'No se pudo enviar el reporte.',
      );
    } catch (_) {
      _mostrarMensaje('No se pudo enviar el reporte.');
    }
  }

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;
    setState(() => _enviando = false);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final motivos = ref.watch(catalogoProvider(ReportesRepository.motivo));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colors.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.flag_outlined, color: context.colors.ugRed),
                    const SizedBox(width: 8),
                    Text(
                      _esComentario
                          ? 'Reportar comentario'
                          : 'Reportar publicación',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Cuéntanos por qué este contenido no debería estar aquí.',
                  style: TextStyle(
                    color: context.colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                motivos.when(
                  data: (items) => Column(
                    children: [
                      for (final motivo in items)
                        _OpcionMotivo(
                          texto: motivo.nombre,
                          seleccionado: _motivoId == motivo.id,
                          onTap: () => setState(() => _motivoId = motivo.id),
                        ),
                    ],
                  ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'No se pudieron cargar los motivos.',
                      style: TextStyle(color: context.colors.onSurfaceVariant),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descripcionController,
                  maxLength: 500,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    hintText: 'Cuéntanos qué ocurre…',
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _enviando ? null : _enviar,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.colors.ugRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: const Text('Enviar reporte'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OpcionMotivo extends StatelessWidget {
  const _OpcionMotivo({
    required this.texto,
    required this.seleccionado,
    required this.onTap,
  });

  final String texto;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Row(
          children: [
            Icon(
              seleccionado
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: seleccionado ? context.colors.ugRed : context.colors.outline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                texto,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

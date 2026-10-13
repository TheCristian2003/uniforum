import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/estilo_canal.dart';
import '../../../core/utils/icono_canal.dart';
import '../../../core/widgets/estado_view.dart';
import '../../../data/models/canal.dart';
import '../../feed/presentation/widgets/publicacion_card.dart';
import '../../publicaciones/presentation/publicacion_detalle_screen.dart';

/// Detalle de un canal: cabecera de la comunidad y sus publicaciones.
class CanalDetalleScreen extends ConsumerWidget {
  const CanalDetalleScreen({super.key, required this.canal});

  final Canal canal;

  Future<void> _refrescar(WidgetRef ref) async {
    ref.invalidate(publicacionesDeCanalProvider(canal.id));
    try {
      await ref.read(publicacionesDeCanalProvider(canal.id).future);
    } catch (_) {
      // El error se refleja en el estado de la vista.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final publicaciones = ref.watch(publicacionesDeCanalProvider(canal.id));
    final tipos = ref.watch(catalogoProvider('tipo_canal')).value ?? const [];
    String? tipoCodigo;
    for (final tipo in tipos) {
      if (tipo.id == canal.tipoCanalId) {
        tipoCodigo = tipo.codigo;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(canal.nombre)),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refrescar(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _CabeceraCanal(canal: canal, tipoCodigo: tipoCodigo),
              const SizedBox(height: 20),
              const Text(
                'Publicaciones',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              publicaciones.when(
                data: (items) => items.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: EmptyView(
                          icono: Icons.dynamic_feed_outlined,
                          titulo: 'Este canal está vacío',
                          mensaje:
                              'Cuando alguien publique aquí, lo verás en esta lista.',
                        ),
                      )
                    : Column(
                        children: [
                          for (final publicacion in items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: PublicacionCard(
                                publicacion: publicacion,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => PublicacionDetalleScreen(
                                      publicacion: publicacion,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: LoadingView(mensaje: 'Cargando publicaciones…'),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: ErrorView(
                    mensaje: 'No se pudieron cargar las publicaciones.',
                    onReintentar: () => ref
                        .invalidate(publicacionesDeCanalProvider(canal.id)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cabecera enriquecida del canal: icono, nombre, tipo y descripción.
class _CabeceraCanal extends StatelessWidget {
  const _CabeceraCanal({required this.canal, required this.tipoCodigo});

  final Canal canal;
  final String? tipoCodigo;

  @override
  Widget build(BuildContext context) {
    final estilo = estiloTipoCanal(tipoCodigo);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: estilo.fondo,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(iconoCanal(canal.icono), color: estilo.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canal.nombre,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _EtiquetaTipo(estilo: estilo),
                  ],
                ),
              ),
            ],
          ),
          if (canal.descripcion != null) ...[
            const SizedBox(height: 14),
            Text(
              canal.descripcion!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EtiquetaTipo extends StatelessWidget {
  const _EtiquetaTipo({required this.estilo});

  final EstiloTipoCanal estilo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estilo.icono, size: 13, color: estilo.color),
          const SizedBox(width: 4),
          Text(
            estilo.etiqueta,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: estilo.color,
            ),
          ),
        ],
      ),
    );
  }
}

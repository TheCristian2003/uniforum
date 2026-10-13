import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/estilo_canal.dart';
import '../../../core/utils/icono_canal.dart';
import '../../../core/widgets/estado_view.dart';
import '../../../data/models/canal.dart';
import '../../../data/models/perfil.dart';
import '../../shell/presentation/widgets/cabecera_perfil.dart';
import 'canal_detalle_screen.dart';

/// Pestaña de Canales: buscador, filtros por tipo y listado de comunidades.
class CanalesScreen extends ConsumerStatefulWidget {
  const CanalesScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<CanalesScreen> createState() => _CanalesScreenState();
}

class _CanalesScreenState extends ConsumerState<CanalesScreen> {
  final _busqueda = TextEditingController();
  String _consulta = '';
  _FiltroCanal _filtro = _FiltroCanal.todos;

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  Future<void> _refrescar() async {
    ref.invalidate(canalesProvider);
    try {
      await ref.read(canalesProvider.future);
    } catch (_) {
      // El error se refleja en el estado de la vista.
    }
  }

  String? _tipoDe(Canal canal, Map<int, String> tipoPorId) {
    final tipo = canal.tipoCanalId;
    return tipo == null ? null : tipoPorId[tipo];
  }

  List<Canal> _filtrar(List<Canal> items, Map<int, String> tipoPorId) {
    final consulta = _consulta.trim().toLowerCase();
    return items.where((canal) {
      final coincideTexto = consulta.isEmpty ||
          canal.nombre.toLowerCase().contains(consulta) ||
          (canal.descripcion?.toLowerCase().contains(consulta) ?? false);
      if (!coincideTexto) return false;
      if (_filtro.codigo == null) return true;
      final tipo = canal.tipoCanalId;
      return tipo != null && tipoPorId[tipo] == _filtro.codigo;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final canales = ref.watch(canalesProvider);
    final tipos = ref.watch(catalogoProvider('tipo_canal')).value ?? const [];
    final tipoPorId = {for (final tipo in tipos) tipo.id: tipo.codigo};

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        toolbarHeight: 68,
        titleSpacing: 16,
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: CabeceraPerfil(perfil: widget.perfil, saludo: false),
        actions: [
          BotonCabecera(icono: Icons.tune, onTap: () {}),
          const SizedBox(width: 6),
          BotonCabecera(
            icono: Icons.notifications_none,
            badge: '3',
            onTap: () {},
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.ugYellow.withValues(alpha: 0.25),
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refrescar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 16, bottom: 24),
            children: [
              _margen(const _HeroCanales()),
              const SizedBox(height: 16),
              _margen(
                _Buscador(
                  controller: _busqueda,
                  onCambio: (valor) => setState(() => _consulta = valor),
                ),
              ),
              const SizedBox(height: 12),
              _ChipsFiltro(
                seleccionado: _filtro,
                onSeleccionar: (filtro) => setState(() => _filtro = filtro),
              ),
              const SizedBox(height: 20),
              canales.when(
                data: (items) {
                  final filtradas = _filtrar(items, tipoPorId);
                  if (filtradas.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: EmptyView(
                        icono: Icons.forum_outlined,
                        titulo: items.isEmpty
                            ? 'Sin canales todavía'
                            : 'Nada por aquí',
                        mensaje: items.isEmpty
                            ? 'Cuando existan comunidades disponibles, '
                                  'aparecerán aquí.'
                            : 'No hay canales que coincidan con tu búsqueda '
                                  'o filtro.',
                      ),
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _margen(_TituloSeccion(cantidad: filtradas.length)),
                      const SizedBox(height: 12),
                      for (final canal in filtradas)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: _CanalCard(
                            canal: canal,
                            tipoCodigo: _tipoDe(canal, tipoPorId),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: LoadingView(mensaje: 'Cargando canales…'),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: ErrorView(
                    mensaje: 'No se pudieron cargar los canales.',
                    onReintentar: () => ref.invalidate(canalesProvider),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _margen(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

/// Filtros rápidos por tipo de canal (`maestra.tipo_canal`).
enum _FiltroCanal {
  todos('Todos', Icons.all_inclusive, null),
  generales('Generales', Icons.groups, 'general'),
  unidades('Unidades académicas', Icons.school, 'unidad_academica'),
  sedes('Sedes', Icons.location_city, 'sede');

  const _FiltroCanal(this.etiqueta, this.icono, this.codigo);

  final String etiqueta;
  final IconData icono;
  final String? codigo;
}

class _HeroCanales extends StatelessWidget {
  const _HeroCanales();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Canales y Comunidades',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            height: 1.15,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Explora lo que pasa en tu facultad y grupos de interés '
          'institucional.',
          style: TextStyle(
            fontSize: 14,
            height: 1.35,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Buscador extends StatelessWidget {
  const _Buscador({required this.controller, required this.onCambio});

  final TextEditingController controller;
  final ValueChanged<String> onCambio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.ugYellow.withValues(alpha: 0.6),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onCambio,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar canales, facultades, clubes…',
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.ugYellowDark, size: 22),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar',
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.onSurfaceVariant,
                  onPressed: () {
                    controller.clear();
                    onCambio('');
                  },
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _ChipsFiltro extends StatelessWidget {
  const _ChipsFiltro({required this.seleccionado, required this.onSeleccionar});

  final _FiltroCanal seleccionado;
  final ValueChanged<_FiltroCanal> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final filtro in _FiltroCanal.values)
            _ChipFiltro(
              filtro: filtro,
              activo: filtro == seleccionado,
              onTap: () => onSeleccionar(filtro),
            ),
        ],
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.filtro,
    required this.activo,
    required this.onTap,
  });

  final _FiltroCanal filtro;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorTexto = activo ? AppColors.onPrimary : AppColors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: activo ? AppColors.ugYellow : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: activo
                    ? AppColors.ugYellow
                    : AppColors.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(filtro.icono, size: 15, color: colorTexto),
                const SizedBox(width: 6),
                Text(
                  filtro.etiqueta,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                    color: colorTexto,
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

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion({required this.cantidad});

  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Comunidades del campus',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.ugYellow.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$cantidad',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.ugYellowDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _CanalCard extends StatelessWidget {
  const _CanalCard({required this.canal, required this.tipoCodigo});

  final Canal canal;
  final String? tipoCodigo;

  @override
  Widget build(BuildContext context) {
    final estilo = estiloTipoCanal(tipoCodigo);

    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => CanalDetalleScreen(canal: canal),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: estilo.fondo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(iconoCanal(canal.icono), color: estilo.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      canal.nombre,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _EtiquetaTipo(estilo: estilo),
                    if (canal.descripcion != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        canal.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.3,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: estilo.fondo,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(estilo.icono, size: 12, color: estilo.color),
          const SizedBox(width: 4),
          Text(
            estilo.etiqueta,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: estilo.color,
            ),
          ),
        ],
      ),
    );
  }
}

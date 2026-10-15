import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/estado_view.dart';
import '../../../data/models/perfil.dart';
import '../../../data/models/publicacion.dart';
import '../../feed/presentation/widgets/publicacion_card.dart';
import '../../perfil/presentation/perfil_screen.dart';
import '../../publicaciones/presentation/publicacion_detalle_screen.dart';
import '../../shell/presentation/widgets/cabecera_perfil.dart';

/// Pestaña de Inicio: barra con perfil, banner de IA del Campus, chips de
/// filtro y feed.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    required this.perfil,
    required this.onAbrirIA,
  });

  final Perfil perfil;

  /// Abre la pestaña de IA del Campus (botones del banner destacado).
  final VoidCallback onAbrirIA;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  _FiltroFeed _filtro = _FiltroFeed.todo;

  Future<void> _refrescar() async {
    ref.invalidate(feedRecientesProvider);
    try {
      await ref.read(feedRecientesProvider.future);
    } catch (_) {
      // El error se refleja en el estado de la vista.
    }
  }

  /// Filtra el feed ya cargado según el chip seleccionado.
  List<Publicacion> _filtrar(List<Publicacion> items) {
    switch (_filtro) {
      case _FiltroFeed.todo:
        return items;
      case _FiltroFeed.tendencias:
        return [...items]..sort((a, b) => b.puntaje.compareTo(a.puntaje));
      case _FiltroFeed.avisos:
        return items.where((p) => p.tipoCodigo == 'aviso').toList();
      case _FiltroFeed.ventas:
        return items.where((p) => p.tipoCodigo == 'venta').toList();
      case _FiltroFeed.perdidos:
        return items
            .where(
              (p) => p.tipoCodigo == 'perdido' || p.tipoCodigo == 'encontrado',
            )
            .toList();
      case _FiltroFeed.chisme:
        return items.where((p) => p.categoriaCodigo == 'chisme').toList();
      case _FiltroFeed.torneos:
        return items.where((p) => p.categoriaCodigo == 'deportes').toList();
    }
  }

  /// Abre el perfil del autor de una publicación (si no es anónima ni propia).
  VoidCallback? _abrirAutor(Publicacion publicacion) {
    final autorId = publicacion.autorId;
    if (publicacion.anonimo || autorId == null) return null;
    if (autorId == ref.read(currentUserProvider)?.id) return null;
    return () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PerfilUsuarioScreen(usuarioId: autorId),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedRecientesProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        toolbarHeight: 68,
        titleSpacing: 16,
        backgroundColor: context.colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: CabeceraPerfil(perfil: widget.perfil),
        actions: [
          BotonCabecera(icono: Icons.search, onTap: () {}),
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
            color: context.colors.ugYellow.withValues(alpha: 0.25),
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
              _margen(_BannerIA(onAccion: widget.onAbrirIA)),
              const SizedBox(height: 16),
              _ChipsFiltro(
                seleccionado: _filtro,
                onSeleccionar: (f) => setState(() => _filtro = f),
              ),
              const SizedBox(height: 16),
              _margen(
                const Text(
                  'Feed del Campus',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              _margen(
                feed.when(
                  data: (items) {
                    final filtradas = _filtrar(items);
                    if (filtradas.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: EmptyView(
                          icono: Icons.dynamic_feed_outlined,
                          titulo: _filtro == _FiltroFeed.todo
                              ? 'Aún no hay publicaciones'
                              : 'Nada por aquí todavía',
                          mensaje: _filtro == _FiltroFeed.todo
                              ? 'Cuando la comunidad publique algo, '
                                    'aparecerá aquí.'
                              : 'No hay publicaciones que coincidan '
                                    'con este filtro.',
                        ),
                      );
                    }
                    return Column(
                      children: [
                        for (final publicacion in filtradas)
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
                              onTapAutor: _abrirAutor(publicacion),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: LoadingView(mensaje: 'Cargando publicaciones…'),
                  ),
                  error: (_, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: ErrorView(
                      mensaje: 'No se pudo cargar el feed.',
                      onReintentar: () => ref.invalidate(feedRecientesProvider),
                    ),
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

/// Filtros disponibles en la fila de chips del feed.
enum _FiltroFeed {
  todo('Todo', null),
  tendencias('Tendencias', Icons.local_fire_department),
  avisos('Avisos', Icons.campaign_outlined),
  chisme('Chisme & Café', Icons.forum_outlined),
  ventas('Ventas', Icons.storefront_outlined),
  perdidos('Perdidos', Icons.search_off_outlined),
  torneos('Torneos', Icons.sports_soccer);

  const _FiltroFeed(this.etiqueta, this.icono);

  final String etiqueta;
  final IconData? icono;
}

class _ChipsFiltro extends StatelessWidget {
  const _ChipsFiltro({required this.seleccionado, required this.onSeleccionar});

  final _FiltroFeed seleccionado;
  final ValueChanged<_FiltroFeed> onSeleccionar;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final filtro in _FiltroFeed.values)
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

  final _FiltroFeed filtro;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorTexto = activo ? context.colors.onPrimary : context.colors.onSurface;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: activo ? context.colors.ugYellow : context.colors.surfaceContainerHigh,
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
                    ? context.colors.ugYellow
                    : context.colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filtro.icono != null) ...[
                  Icon(filtro.icono, size: 15, color: colorTexto),
                  const SizedBox(width: 6),
                ],
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

/// Banner destacado de la IA del Campus con accesos rápidos.
class _BannerIA extends StatelessWidget {
  const _BannerIA({required this.onAccion});

  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.surfaceContainerLowest,
              context.colors.surfaceContainerLow,
              context.colors.ugOcreLight,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.ugYellow.withValues(alpha: 0.4),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: _orbe(150, context.colors.ugYellow.withValues(alpha: 0.22)),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: _orbe(130, context.colors.ugBlue.withValues(alpha: 0.12)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: _insignia(context)),
                      const SizedBox(width: 8),
                      _sincronizado(context),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¿Qué quieres saber de tu campus hoy?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Horarios, cupos en biblioteca, eventos y resúmenes '
                    'de asambleas al instante.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _AccionIA(
                            icono: Icons.bolt,
                            etiqueta: '¿Qué me perdí?',
                            colorIcono: context.colors.ugRed,
                            fondoIcono: context.colors.ugRedLight,
                            onTap: onAccion,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AccionIA(
                            icono: Icons.chat_bubble_outline,
                            etiqueta: 'Preguntar a IA',
                            colorIcono: context.colors.onPrimary,
                            fondoIcono: Colors.black12,
                            destacado: true,
                            onTap: onAccion,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _AccionIA(
                            icono: Icons.manage_search,
                            etiqueta: 'Buscar con IA',
                            colorIcono: context.colors.ugBlue,
                            fondoIcono: context.colors.ugBlueLight,
                            onTap: onAccion,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _insignia(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.ugOcreLight,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.colors.ugYellow.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 14,
            color: context.colors.ugYellowDark,
          ),
          const SizedBox(width: 6),
          Text(
            'IA del Campus activa',
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: context.colors.ugYellowDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sincronizado(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF059669),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Sincronizado',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _orbe(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _AccionIA extends StatelessWidget {
  const _AccionIA({
    required this.icono,
    required this.etiqueta,
    required this.colorIcono,
    required this.fondoIcono,
    required this.onTap,
    this.destacado = false,
  });

  final IconData icono;
  final String etiqueta;
  final Color colorIcono;
  final Color fondoIcono;
  final VoidCallback onTap;
  final bool destacado;

  @override
  Widget build(BuildContext context) {
    final colorTexto = destacado ? context.colors.onPrimary : context.colors.onSurface;

    return Material(
      color: destacado ? context.colors.ugYellow : context.colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: destacado
                ? null
                : Border.all(
                    color: context.colors.outlineVariant.withValues(alpha: 0.5),
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: destacado
                      ? Colors.black.withValues(alpha: 0.1)
                      : fondoIcono,
                ),
                child: Icon(icono, size: 18, color: colorIcono),
              ),
              const SizedBox(height: 6),
              Text(
                etiqueta,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: colorTexto,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



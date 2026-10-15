import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/perfil.dart';
import '../../../data/models/restriccion.dart';
import '../../canales/presentation/canales_screen.dart';
import '../../home/presentation/home_screen.dart';
import '../../ia/presentation/ia_screen.dart';
import '../../perfil/presentation/perfil_screen.dart';
import '../../publicaciones/presentation/crear_publicacion_screen.dart';

/// Contenedor principal con navegación inferior (Inicio, Canales, IA, Perfil)
/// y botón flotante central para publicar.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  void _publicar() {
    final restriccion = ref.read(miRestriccionActivaProvider).value;
    if (restriccion != null && restriccion.vigente) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu cuenta está restringida: no puedes publicar.'),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const CrearPublicacionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const _BannerRestriccion(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                HomeScreen(
                  perfil: widget.perfil,
                  onAbrirIA: () => setState(() => _index = 2),
                ),
                CanalesScreen(perfil: widget.perfil),
                IaScreen(perfil: widget.perfil),
                PerfilScreen(perfil: widget.perfil),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _publicar,
        backgroundColor: context.colors.ugYellow,
        foregroundColor: context.colors.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
        tooltip: 'Publicar',
        child: const Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onSelect: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BannerRestriccion extends ConsumerWidget {
  const _BannerRestriccion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final restriccion = ref.watch(miRestriccionActivaProvider).value;
    if (restriccion == null || !restriccion.vigente) {
      return const SizedBox.shrink();
    }

    return Material(
      color: context.colors.ugRedLight,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.block, color: context.colors.ugRed, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tu cuenta está restringida',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: context.colors.ugRed,
                      ),
                    ),
                    Text(
                      _detalle(restriccion),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.ugRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _detalle(Restriccion restriccion) {
    final motivo = restriccion.motivo;
    if (restriccion.permanente) {
      return '$motivo · Sanción permanente';
    }
    final dias = restriccion.expiraEn!.difference(DateTime.now()).inDays;
    final restante = dias <= 0 ? 'menos de un día' : '$dias días';
    return '$motivo · Vence en $restante';
  }
}

class _NavDestino {
  const _NavDestino({
    required this.icono,
    required this.iconoActivo,
    required this.etiqueta,
  });

  final IconData icono;
  final IconData iconoActivo;
  final String etiqueta;
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  static const _destinos = [
    _NavDestino(
      icono: Icons.home_outlined,
      iconoActivo: Icons.home,
      etiqueta: 'Inicio',
    ),
    _NavDestino(
      icono: Icons.forum_outlined,
      iconoActivo: Icons.forum,
      etiqueta: 'Canales',
    ),
    _NavDestino(
      icono: Icons.auto_awesome_outlined,
      iconoActivo: Icons.auto_awesome,
      etiqueta: 'IA',
    ),
    _NavDestino(
      icono: Icons.person_outline,
      iconoActivo: Icons.person,
      etiqueta: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: context.colors.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(child: _destino(context, 0)),
              Expanded(child: _destino(context, 1)),
              const SizedBox(width: 72),
              Expanded(child: _destino(context, 2)),
              Expanded(child: _destino(context, 3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destino(BuildContext context, int indice) {
    final destino = _destinos[indice];
    final activo = index == indice;
    final color =
        activo ? context.colors.onPrimary : context.colors.onSurfaceVariant;

    return InkWell(
      onTap: () => onSelect(indice),
      borderRadius: BorderRadius.circular(999),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: activo ? context.colors.ugYellow : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(activo ? destino.iconoActivo : destino.icono,
                  size: 22, color: color),
              const SizedBox(height: 2),
              Text(
                destino.etiqueta,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

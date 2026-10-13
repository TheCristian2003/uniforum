import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/roles.dart';
import '../../../core/gamification/niveles.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/estilo_publicacion.dart';
import '../../../data/models/insignia.dart';
import '../../../data/models/perfil.dart';
import '../../ajustes/presentation/ajustes_screen.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../moderacion/presentation/moderacion_screen.dart';
import '../../shell/presentation/widgets/cabecera_perfil.dart';

/// Pestaña de Perfil: identidad, nivel, estadísticas y distintivos.
///
/// Las estadísticas y los distintivos se leen de Supabase; los puntos y los
/// distintivos los calcula y otorga el backend.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nivel = nivelDesdePuntos(perfil.puntos);

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
        title: Row(
          children: [
            AvatarNivel(perfil: perfil),
            const SizedBox(width: 12),
            const Text(
              'Mi Perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          BotonCabecera(
            icono: Icons.settings_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AjustesScreen()),
            ),
          ),
          const SizedBox(width: 6),
          BotonCabecera(
            icono: Icons.logout,
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeroPerfil(perfil: perfil, nivel: nivel),
          const SizedBox(height: 16),
          _GridEstadisticas(usuarioId: perfil.id),
          if (esRolPrivilegiado(ref.watch(currentUserProvider))) ...[
            const SizedBox(height: 16),
            _TarjetaModeracion(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ModeracionScreen(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          _Distintivos(usuarioId: perfil.id),
        ],
      ),
    );
  }
}

/// Tarjeta principal de identidad con nivel y progreso hacia el siguiente.
class _HeroPerfil extends StatelessWidget {
  const _HeroPerfil({required this.perfil, required this.nivel});

  final Perfil perfil;
  final Nivel nivel;

  @override
  Widget build(BuildContext context) {
    final progreso = progresoNivel(perfil.puntos);
    final nombreOficial = perfil.nombreOficial;
    final titulo = nombreOficial ?? perfil.alias;
    final subtitulo = nombreOficial != null
        ? '@${perfil.alias}'
        : '@${perfil.id.substring(0, 8)}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -60,
              child: _orbe(180, AppColors.ugYellow.withValues(alpha: 0.18)),
            ),
            Positioned(
              bottom: -60,
              left: -60,
              child: _orbe(180, AppColors.ugBlue.withValues(alpha: 0.12)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _AvatarPerfilGrande(perfil: perfil, nivel: nivel),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    titulo,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                if (perfil.esVerificada) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 18,
                                    color: AppColors.ugBlue,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitulo,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _BadgeNivel(nivel: nivel),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ProgresoNivel(
                    puntos: perfil.puntos,
                    nivel: nivel,
                    progreso: progreso,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

/// Avatar grande con aro degradado y placa de nivel flotante.
class _AvatarPerfilGrande extends StatelessWidget {
  const _AvatarPerfilGrande({required this.perfil, required this.nivel});

  final Perfil perfil;
  final Nivel nivel;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = perfil.avatarUrl;
    final tieneAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final inicial =
        perfil.alias.isNotEmpty ? perfil.alias[0].toUpperCase() : '?';

    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.ugYellow, AppColors.ugOcre, AppColors.ugRed],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: SizedBox.expand(
                  child: tieneAvatar
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _inicial(inicial),
                        )
                      : _inicial(inicial),
                ),
              ),
            ),
          ),
          Positioned(bottom: 0, child: _BadgeNivel(nivel: nivel)),
        ],
      ),
    );
  }

  Widget _inicial(String inicial) {
    return Container(
      color: AppColors.ugBlueLight,
      alignment: Alignment.center,
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: AppColors.ugBlue,
        ),
      ),
    );
  }
}

/// Placa compacta con el número y nombre del nivel.
class _BadgeNivel extends StatelessWidget {
  const _BadgeNivel({required this.nivel});

  final Nivel nivel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.ugOcre, AppColors.ugYellow],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 13, color: Color(0xFF4A3500)),
          const SizedBox(width: 4),
          Text(
            'NIVEL ${nivel.numero} · ${nivel.nombre}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A3500),
            ),
          ),
        ],
      ),
    );
  }
}

/// Barra de progreso hacia el siguiente nivel con puntos restantes.
class _ProgresoNivel extends StatelessWidget {
  const _ProgresoNivel({
    required this.puntos,
    required this.nivel,
    required this.progreso,
  });

  final int puntos;
  final Nivel nivel;
  final double progreso;

  @override
  Widget build(BuildContext context) {
    final siguiente = nivel.siguiente;
    final porcentaje = (progreso * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              siguiente != null ? '$puntos / $siguiente EXP' : '$puntos pts',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            Text(
              'Nivel ${nivel.numero} (${nivel.nombre})',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.ugBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _BarraProgreso(valor: progreso),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.ugOcreLight,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.ugYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt,
                      size: 13,
                      color: AppColors.ugYellowDark,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        siguiente != null
                            ? '+${siguiente - puntos} pts para subir de rango'
                            : 'Nivel máximo alcanzado',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ugYellowDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$porcentaje% completado',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BarraProgreso extends StatelessWidget {
  const _BarraProgreso({required this.valor});

  final double valor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 12,
        color: AppColors.surfaceContainer,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ancho = (constraints.maxWidth * valor).clamp(
              0.0,
              constraints.maxWidth,
            );
            return Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: ancho,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.ugOcre, AppColors.ugYellowDark],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.icono,
    required this.etiqueta,
    required this.color,
    this.valor,
    this.extra,
  });

  final IconData icono;
  final String etiqueta;
  final Color color;
  final int? valor;
  final String? extra;
}

/// Rejilla 2x2 con las estadísticas de participación del usuario.
class _GridEstadisticas extends ConsumerWidget {
  const _GridEstadisticas({required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(estadisticasUsuarioProvider(usuarioId)).value;

    final items = [
      _StatItem(
        icono: Icons.edit_note,
        etiqueta: 'Publicaciones',
        color: AppColors.ugBlue,
        valor: datos?.publicaciones,
      ),
      _StatItem(
        icono: Icons.chat_bubble_outline,
        etiqueta: 'Comentarios',
        color: AppColors.ugBlue,
        valor: datos?.comentarios,
      ),
      _StatItem(
        icono: Icons.lightbulb,
        etiqueta: 'Soluciones',
        color: AppColors.ugYellow,
        valor: datos?.soluciones,
        extra: '+15 pts',
      ),
      _StatItem(
        icono: Icons.rocket_launch,
        etiqueta: 'Votos recibidos',
        color: AppColors.ugRed,
        valor: datos?.votosRecibidos,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _StatCard(item: items[0])),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(item: items[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _StatCard(item: items[2])),
            const SizedBox(width: 12),
            Expanded(child: _StatCard(item: items[3])),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item});

  final _StatItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fondoAcento(item.color),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icono, size: 20, color: item.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.valor?.toString() ?? '—',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (item.extra != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ugYellow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.extra!,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A3500),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  item.etiqueta,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
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

class _TarjetaModeracion extends StatelessWidget {
  const _TarjetaModeracion({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ugBlueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.ugBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moderación',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Revisa los reportes pendientes.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

const _coloresInsignia = <String, Color>{
  'primer_paso': AppColors.ugYellow,
  'buen_samaritano': Color(0xFF059669),
  'resuelve_dudas': AppColors.ugBlue,
  'vendedor_activo': Color(0xFF7C3AED),
  'voz_del_campus': AppColors.ugRed,
  'constante': AppColors.ugOcre,
  'gran_colaborador': AppColors.ugAguaMarina,
  'tendencia': AppColors.ugFlamenco,
};

const _iconosInsignia = <String, IconData>{
  'star': Icons.star,
  'handshake': Icons.handshake,
  'lightbulb': Icons.lightbulb,
  'storefront': Icons.storefront,
  'campaign': Icons.campaign,
  'bolt': Icons.bolt,
  'workspace_premium': Icons.workspace_premium,
  'trending_up': Icons.trending_up,
};

/// Vitrina de distintivos con su estado de desbloqueo.
class _Distintivos extends ConsumerWidget {
  const _Distintivos({required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insignias = ref.watch(insigniasUsuarioProvider(usuarioId));

    return insignias.when(
      data: (lista) {
        if (lista.isEmpty) return const _DistintivosVacio();
        final obtenidas = lista.where((i) => i.obtenida).length;
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
                children: [
                  const Icon(
                    Icons.military_tech,
                    size: 22,
                    color: AppColors.ugYellowDark,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Vitrina de distintivos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '$obtenidas de ${lista.length} desbloqueados',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  mainAxisExtent: 172,
                ),
                children: [
                  for (final insignia in lista)
                    _TarjetaInsignia(insignia: insignia),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const _MensajeDistintivos(
        texto: 'No se pudieron cargar tus distintivos.',
      ),
    );
  }
}

class _TarjetaInsignia extends StatelessWidget {
  const _TarjetaInsignia({required this.insignia});

  final Insignia insignia;

  @override
  Widget build(BuildContext context) {
    final obtenida = insignia.obtenida;
    final color = _colorInsignia(insignia.codigo);
    final colorTexto = obtenida ? color : AppColors.outline;

    return Tooltip(
      message: insignia.descripcion ?? insignia.nombre,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: obtenida
              ? AppColors.surfaceContainerLow
              : AppColors.surfaceContainerLow.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: obtenida ? color : AppColors.outlineVariant,
            width: obtenida ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Opacity(
              opacity: obtenida ? 1 : 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: obtenida
                          ? fondoAcento(color)
                          : AppColors.surfaceContainer,
                    ),
                    child: Icon(
                      _iconosInsignia[insignia.icono] ?? Icons.military_tech,
                      size: 22,
                      color: obtenida ? color : AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    insignia.nombre,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: obtenida
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insignia.descripcion ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      height: 1.25,
                      color: obtenida
                          ? AppColors.onSurfaceVariant
                          : AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: obtenida
                          ? fondoAcento(color)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          obtenida ? Icons.check_circle : Icons.lock,
                          size: 11,
                          color: colorTexto,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          obtenida ? 'Desbloqueado' : 'Bloqueado',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: colorTexto,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!obtenida)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.lock, size: 15, color: AppColors.outline),
              ),
          ],
        ),
      ),
    );
  }

  Color _colorInsignia(String codigo) =>
      _coloresInsignia[codigo] ?? AppColors.ugYellow;
}

class _MensajeDistintivos extends StatelessWidget {
  const _MensajeDistintivos({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _DistintivosVacio extends StatelessWidget {
  const _DistintivosVacio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.military_tech, size: 36, color: AppColors.ugYellow),
          SizedBox(height: 12),
          Text(
            'Tus distintivos llegarán pronto',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Publica, comenta y colabora para desbloquear logros.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

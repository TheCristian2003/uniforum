import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/roles.dart';
import '../../../core/gamification/niveles.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/insignia.dart';
import '../../../data/models/perfil.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../moderacion/presentation/moderacion_screen.dart';
import '../../ajustes/presentation/ajustes_screen.dart';

/// Pestaña de Perfil: identidad, nivel, estadísticas y distintivos.
///
/// Las estadísticas y los distintivos se leen de Supabase; los puntos y los
/// distintivos los calcula y otorga el backend. La edición de datos básicos del
/// perfil llega en una etapa posterior.
class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nivel = nivelDesdePuntos(perfil.puntos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        actions: [
          IconButton(
            tooltip: 'Ajustes',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AjustesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Encabezado(perfil: perfil, nivel: nivel),
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
          const SizedBox(height: 16),
          const _TituloSeccion('Estadísticas'),
          const SizedBox(height: 8),
          _Estadisticas(usuarioId: perfil.id),
          const SizedBox(height: 16),
          const _TituloSeccion('Distintivos'),
          const SizedBox(height: 8),
          _Distintivos(usuarioId: perfil.id),
        ],
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.perfil, required this.nivel});

  final Perfil perfil;
  final Nivel nivel;

  @override
  Widget build(BuildContext context) {
    final progreso = progresoNivel(perfil.puntos);
    final siguiente = nivel.siguiente;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.ugBlueLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.ugYellow, width: 3),
                ),
                child: Text(
                  perfil.alias.isNotEmpty
                      ? perfil.alias[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ugBlue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            perfil.alias,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (perfil.esVerificada) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified,
                              size: 18, color: AppColors.ugBlue),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      perfil.nombreOficial ?? '@${perfil.id.substring(0, 8)}',
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${perfil.puntos} pts',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                nivel.nombre,
                style: const TextStyle(
                  color: AppColors.ugBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainer,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.ugYellow),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            siguiente == null
                ? 'Nivel máximo alcanzado'
                : 'Te faltan ${siguiente - perfil.puntos} pts para el siguiente nivel',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
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
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.ugBlue),
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
              const Icon(Icons.chevron_right,
                  color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  const _TituloSeccion(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
    );
  }
}

class _Estadisticas extends ConsumerWidget {
  const _Estadisticas({required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final datos = ref.watch(estadisticasUsuarioProvider(usuarioId)).value;

    final items = [
      (
        icono: Icons.edit_note,
        etiqueta: 'Publicaciones',
        valor: datos?.publicaciones,
      ),
      (
        icono: Icons.chat_bubble_outline,
        etiqueta: 'Comentarios',
        valor: datos?.comentarios,
      ),
      (
        icono: Icons.lightbulb_outline,
        etiqueta: 'Soluciones',
        valor: datos?.soluciones,
      ),
      (
        icono: Icons.arrow_upward,
        etiqueta: 'Votos recibidos',
        valor: datos?.votosRecibidos,
      ),
    ];

    return Row(
      children: [
        for (final item in items) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: Column(
                children: [
                  Icon(item.icono, size: 20, color: AppColors.ugBlue),
                  const SizedBox(height: 6),
                  Text(
                    item.valor?.toString() ?? '—',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.etiqueta,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item != items.last) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _Distintivos extends ConsumerWidget {
  const _Distintivos({required this.usuarioId});

  final String usuarioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insignias = ref.watch(insigniasUsuarioProvider(usuarioId));

    return insignias.when(
      data: (lista) {
        if (lista.isEmpty) return const _DistintivosVacio();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final insignia in lista)
              _TarjetaInsignia(insignia: insignia),
          ],
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

  static const _iconos = <String, IconData>{
    'star': Icons.star,
    'handshake': Icons.handshake,
    'lightbulb': Icons.lightbulb,
    'storefront': Icons.storefront,
    'campaign': Icons.campaign,
    'bolt': Icons.bolt,
    'workspace_premium': Icons.workspace_premium,
    'trending_up': Icons.trending_up,
  };

  @override
  Widget build(BuildContext context) {
    final obtenida = insignia.obtenida;

    return Tooltip(
      message: insignia.descripcion ?? insignia.nombre,
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: obtenida ? AppColors.ugYellow : AppColors.outlineVariant,
            width: obtenida ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _iconos[insignia.icono] ?? Icons.military_tech,
              size: 28,
              color: obtenida ? AppColors.ugYellow : AppColors.outlineVariant,
            ),
            const SizedBox(height: 8),
            Text(
              insignia.nombre,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: obtenida
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
        border: Border.all(color: AppColors.outlineVariant),
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
        border: Border.all(color: AppColors.outlineVariant),
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

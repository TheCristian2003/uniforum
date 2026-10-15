import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/gamification/niveles.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/catalogo_item.dart';
import '../../../data/models/perfil.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../perfil/presentation/editar/editar_perfil_screen.dart';

/// Pantalla de Ajustes y Opciones.
///
/// Recrea el diseño de Stitch (perfil superior + secciones de IA, notificaciones,
/// privacidad, apariencia y soporte). Los interruptores se mantienen como
/// preferencias locales de la interfaz a la espera de su persistencia; el cierre
/// de sesión y el acceso a "Editar perfil" sí son funcionales.
class AjustesScreen extends ConsumerStatefulWidget {
  const AjustesScreen({super.key});

  @override
  ConsumerState<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends ConsumerState<AjustesScreen> {
  bool _resumenesIA = true;
  bool _sugerenciasIA = true;
  bool _alertasInstitucionales = true;
  bool _actividadPublicaciones = true;
  bool _radarPerdidos = true;
  bool _rankingSemanal = true;
  bool _publicarAnonimo = true;
  int _tema = 0; // 0: Claro, 1: Oscuro, 2: Sistema

  void _proximamente(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfil = ref.watch(perfilActualProvider).value;
    final email = ref.watch(currentUserProvider)?.email ?? '';
    final sedes = ref.watch(catalogoProvider('sede')).value ?? const [];
    final programas = ref.watch(catalogoProvider('programa')).value ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleSpacing: 0,
        shape: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _BotonIcono(
            icono: Icons.arrow_back,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ),
        title: const Text(
          'Ajustes y Opciones',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _BotonIcono(
              icono: Icons.help_outline,
              onTap: () =>
                  _proximamente('La ayuda y el soporte estarán disponibles pronto.'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          32 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          if (perfil != null)
            _ResumenUsuario(
              perfil: perfil,
              email: email,
              sedes: sedes,
              programas: programas,
              onEditar: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const EditarPerfilScreen(),
                ),
              ),
              onQr: () =>
                  _proximamente('Tu carné QR estará disponible pronto.'),
            ),
          const SizedBox(height: 24),
          _CopilotoIA(
            resumenes: _resumenesIA,
            sugerencias: _sugerenciasIA,
            onResumenes: (v) => setState(() => _resumenesIA = v),
            onSugerencias: (v) => setState(() => _sugerenciasIA = v),
            onProximamente: _proximamente,
          ),
          const SizedBox(height: 24),
          _Notificaciones(
            alertas: _alertasInstitucionales,
            actividad: _actividadPublicaciones,
            radar: _radarPerdidos,
            onAlertas: (v) => setState(() => _alertasInstitucionales = v),
            onActividad: (v) => setState(() => _actividadPublicaciones = v),
            onRadar: (v) => setState(() => _radarPerdidos = v),
            onProximamente: _proximamente,
          ),
          const SizedBox(height: 24),
          _Privacidad(
            ranking: _rankingSemanal,
            anonimo: _publicarAnonimo,
            puntos: perfil?.puntos ?? 0,
            onRanking: (v) => setState(() => _rankingSemanal = v),
            onAnonimo: (v) => setState(() => _publicarAnonimo = v),
            onProximamente: _proximamente,
          ),
          const SizedBox(height: 24),
          _Apariencia(
            tema: _tema,
            onTema: (v) => setState(() => _tema = v),
            onProximamente: _proximamente,
          ),
          const SizedBox(height: 24),
          _Soporte(onProximamente: _proximamente),
          const SizedBox(height: 20),
          _BotonCerrarSesion(
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
          const SizedBox(height: 16),
          const _PieVersion(),
        ],
      ),
    );
  }
}

/// Botón circular de cabecera con borde sutil.
class _BotonIcono extends StatelessWidget {
  const _BotonIcono({required this.icono, required this.onTap});

  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainer,
      shape: CircleBorder(
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icono, size: 22, color: AppColors.ugBlue),
        ),
      ),
    );
  }
}

String _nombreCatalogo(List<CatalogoItem> items, int? id) {
  if (id == null) return '';
  for (final item in items) {
    if (item.id == id) return item.nombre;
  }
  return '';
}

class _ResumenUsuario extends StatelessWidget {
  const _ResumenUsuario({
    required this.perfil,
    required this.email,
    required this.sedes,
    required this.programas,
    required this.onEditar,
    required this.onQr,
  });

  final Perfil perfil;
  final String email;
  final List<CatalogoItem> sedes;
  final List<CatalogoItem> programas;
  final VoidCallback onEditar;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    final nivel = nivelDesdePuntos(perfil.puntos);
    final sede = _nombreCatalogo(sedes, perfil.sedeId);
    final programa = _nombreCatalogo(programas, perfil.programaId);
    final titulo = perfil.nombreOficial ?? perfil.alias;
    final avatarUrl = perfil.avatarUrl;
    final tieneAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final inicial =
        perfil.alias.isNotEmpty ? perfil.alias[0].toUpperCase() : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.outline.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -50,
              right: -50,
              child: _orbe(160, AppColors.ugOcre.withValues(alpha: 0.20)),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: _orbe(130, AppColors.ugFlamenco.withValues(alpha: 0.10)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 72,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: AppColors.ugBlueLight,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.ugBlue,
                                  width: 2,
                                ),
                              ),
                              child: tieneAvatar
                                  ? Image.network(
                                      avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _inicial(inicial),
                                    )
                                  : _inicial(inicial),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.ugOcre,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: AppColors.surfaceContainerLowest,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.bolt,
                                      size: 11,
                                      color: Color(0xFF4A3500),
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Nv. ${nivel.numero}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF4A3500),
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
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
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                if (perfil.esVerificada) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 17,
                                    color: AppColors.ugBlue,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              programa.isEmpty
                                  ? '@${perfil.alias}'
                                  : '@${perfil.alias} • $programa',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            if (sede.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.ugOcreLight,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 13,
                                      color: AppColors.ugYellowDark,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      sede,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ugYellowDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 16,
                            color: AppColors.ugBlue,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              email,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Divider(
                    height: 1,
                    color: AppColors.surfaceContainerHigh,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onEditar,
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text('Editar perfil'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.ugBlue,
                            side: const BorderSide(color: AppColors.ugBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Material(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: onQr,
                          borderRadius: BorderRadius.circular(12),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(
                              Icons.qr_code_2,
                              size: 22,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
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
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.ugBlue,
        ),
      ),
    );
  }

  Widget _orbe(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class _CopilotoIA extends StatelessWidget {
  const _CopilotoIA({
    required this.resumenes,
    required this.sugerencias,
    required this.onResumenes,
    required this.onSugerencias,
    required this.onProximamente,
  });

  final bool resumenes;
  final bool sugerencias;
  final ValueChanged<bool> onResumenes;
  final ValueChanged<bool> onSugerencias;
  final ValueChanged<String> onProximamente;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ugFlamenco,
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'COPILOTO IA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.ugFlamencoLight,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 12, color: AppColors.ugFlamenco),
                  SizedBox(width: 3),
                  Text(
                    'IA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ugFlamenco,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _Tarjeta(
          child: Column(
            children: [
              _FilaToggle(
                icono: Icons.summarize,
                color: AppColors.ugFlamenco,
                titulo: 'Resúmenes semanales de canales',
                subtitulo: 'Síntesis de tareas y foros estudiantiles',
                valor: resumenes,
                onChanged: onResumenes,
              ),
              _divisor(),
              _FilaNav(
                icono: Icons.psychology,
                color: AppColors.ugOcre,
                titulo: 'Personalidad del asistente',
                subtitulo: 'Adapta el tono y modismos en respuestas',
                etiqueta: 'Cercano',
                onTap: () =>
                    onProximamente('La personalidad del asistente estará disponible pronto.'),
              ),
              _divisor(),
              _FilaToggle(
                icono: Icons.auto_fix_high,
                color: AppColors.ugOcre,
                titulo: 'Sugerencias al crear publicaciones',
                subtitulo: 'Optimiza etiquetas y hashtags del campus',
                valor: sugerencias,
                onChanged: onSugerencias,
              ),
              _divisor(),
              _FilaNav(
                icono: Icons.delete_sweep,
                color: AppColors.ugRed,
                titulo: 'Borrar memoria de conversaciones',
                subtitulo: 'Reinicia el contexto privado del copiloto',
                onTap: () =>
                    onProximamente('El copiloto IA estará disponible próximamente.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Notificaciones extends StatelessWidget {
  const _Notificaciones({
    required this.alertas,
    required this.actividad,
    required this.radar,
    required this.onAlertas,
    required this.onActividad,
    required this.onRadar,
    required this.onProximamente,
  });

  final bool alertas;
  final bool actividad;
  final bool radar;
  final ValueChanged<bool> onAlertas;
  final ValueChanged<bool> onActividad;
  final ValueChanged<bool> onRadar;
  final ValueChanged<String> onProximamente;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Notificaciones y Alertas',
      child: _Tarjeta(
        child: Column(
          children: [
            _FilaToggle(
              icono: Icons.notifications_active,
              color: AppColors.ugBlue,
              titulo: 'Alertas institucionales y académicas',
              subtitulo: 'Avisos de rectoría, cancelaciones, notas oficiales',
              valor: alertas,
              onChanged: onAlertas,
            ),
            _divisor(),
            _FilaToggle(
              icono: Icons.favorite,
              color: AppColors.ugFlamenco,
              titulo: 'Actividad en mis publicaciones',
              subtitulo: 'Puntos (+EXP), votos y respuestas',
              valor: actividad,
              onChanged: onActividad,
            ),
            _divisor(),
            _FilaToggle(
              icono: Icons.radar,
              color: AppColors.ugOcre,
              titulo: 'Radar de objetos perdidos',
              subtitulo: 'Avisos de carnés o llaves cerca de tu facultad',
              valor: radar,
              onChanged: onRadar,
            ),
            _divisor(),
            _FilaNav(
              icono: Icons.storefront,
              color: AppColors.onSurfaceVariant,
              titulo: 'Novedades de compra y venta',
              subtitulo: 'Libros, calculadoras y servicios del campus',
              etiqueta: 'Solo menciones',
              onTap: () =>
                  onProximamente('Las alertas de compra y venta estarán disponibles pronto.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Privacidad extends StatelessWidget {
  const _Privacidad({
    required this.ranking,
    required this.anonimo,
    required this.puntos,
    required this.onRanking,
    required this.onAnonimo,
    required this.onProximamente,
  });

  final bool ranking;
  final bool anonimo;
  final int puntos;
  final ValueChanged<bool> onRanking;
  final ValueChanged<bool> onAnonimo;
  final ValueChanged<String> onProximamente;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Privacidad y Comunidad',
      child: _Tarjeta(
        child: Column(
          children: [
            _FilaToggle(
              icono: Icons.leaderboard,
              color: AppColors.ugOcre,
              titulo: 'Ranking semanal del campus',
              subtitulo: 'Tu perfil compite por el podio de aportes',
              extra: '$puntos pts',
              valor: ranking,
              onChanged: onRanking,
            ),
            _divisor(),
            _FilaToggle(
              icono: Icons.visibility_off,
              color: AppColors.ugBlue,
              titulo: 'Permitir publicar en modo anónimo',
              subtitulo: 'Oculta tu autoría públicamente en foros libres',
              valor: anonimo,
              onChanged: onAnonimo,
            ),
            _divisor(),
            _FilaNav(
              icono: Icons.military_tech,
              color: AppColors.ugBlue,
              titulo: 'Quién puede ver mis distintivos',
              subtitulo: 'Insignias y logros de la comunidad',
              etiqueta: 'Toda la comunidad',
              onTap: () => onProximamente(
                  'La visibilidad de distintivos estará disponible pronto.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Apariencia extends StatelessWidget {
  const _Apariencia({
    required this.tema,
    required this.onTema,
    required this.onProximamente,
  });

  final int tema;
  final ValueChanged<int> onTema;
  final ValueChanged<String> onProximamente;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Apariencia e Identidad',
      child: _Tarjeta(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tema visual',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _TarjetaTema(
                      icono: Icons.light_mode,
                      texto: 'Claro',
                      activo: tema == 0,
                      onTap: () => onTema(0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaTema(
                      icono: Icons.dark_mode,
                      texto: 'Oscuro',
                      activo: tema == 1,
                      onTap: () => onTema(1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TarjetaTema(
                      icono: Icons.settings_brightness,
                      texto: 'Sistema',
                      activo: tema == 2,
                      onTap: () => onTema(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(height: 1, color: AppColors.surfaceContainerHigh),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paleta institucional activa',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sol & Flamenco Guajiro',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PaletaPreview(),
                ],
              ),
              const SizedBox(height: 14),
              Divider(height: 1, color: AppColors.surfaceContainerHigh),
              _FilaNav(
                icono: Icons.format_size,
                color: AppColors.onSurfaceVariant,
                titulo: 'Tamaño del texto',
                subtitulo: 'Optimizado para lectura móvil',
                etiqueta: 'Estándar',
                padding: EdgeInsets.zero,
                onTap: () =>
                    onProximamente('El tamaño del texto estará disponible pronto.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaTema extends StatelessWidget {
  const _TarjetaTema({
    required this.icono,
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo
          ? AppColors.surfaceContainerLow
          : AppColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: activo ? AppColors.ugOcre : AppColors.surfaceContainerHigh,
              width: activo ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icono,
                size: 22,
                color: activo ? AppColors.ugYellowDark : AppColors.outline,
              ),
              const SizedBox(height: 6),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: activo ? AppColors.onSurface : AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaletaPreview extends StatelessWidget {
  const _PaletaPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.surfaceContainerHigh),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _punto(AppColors.ugOcre),
          _punto(AppColors.ugFlamenco),
          _punto(AppColors.ugBlue),
        ],
      ),
    );
  }

  Widget _punto(Color color) {
    return Container(
      width: 20,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: AppColors.surfaceContainerLowest, width: 2),
      ),
    );
  }
}

class _Soporte extends StatelessWidget {
  const _Soporte({required this.onProximamente});

  final ValueChanged<String> onProximamente;

  @override
  Widget build(BuildContext context) {
    return _Seccion(
      titulo: 'Soporte y Normas',
      child: _Tarjeta(
        child: Column(
          children: [
            _FilaNav(
              icono: Icons.gavel,
              color: AppColors.ugBlue,
              titulo: 'Normas de convivencia y código de honor',
              onTap: () => onProximamente('Las normas estarán disponibles pronto.'),
            ),
            _divisor(),
            _FilaNav(
              icono: Icons.inbox,
              color: AppColors.ugOcre,
              titulo: 'Buzón de sugerencias para Bienestar',
              onTap: () =>
                  onProximamente('El buzón de sugerencias estará disponible pronto.'),
            ),
            _divisor(),
            _FilaNav(
              icono: Icons.quiz,
              color: AppColors.onSurfaceVariant,
              titulo: 'Preguntas frecuentes del campus',
              onTap: () =>
                  onProximamente('Las preguntas frecuentes estarán disponibles pronto.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotonCerrarSesion extends StatelessWidget {
  const _BotonCerrarSesion({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout, size: 20),
      label: const Text('Cerrar sesión'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ugRed,
        side: const BorderSide(color: AppColors.ugRed),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    );
  }
}

class _PieVersion extends StatelessWidget {
  const _PieVersion();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Campus · Universidad de La Guajira v1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
            color: AppColors.outline,
          ),
        ),
      ],
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class _FilaToggle extends StatelessWidget {
  const _FilaToggle({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.onChanged,
    this.extra,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;
  final String? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CajaIcono(icono: icono, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (extra != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.ugOcreLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          extra!,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ugYellowDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.25,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeTrackColor: color,
            inactiveTrackColor: AppColors.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }
}

class _FilaNav extends StatelessWidget {
  const _FilaNav({
    required this.icono,
    required this.color,
    required this.titulo,
    this.subtitulo,
    this.etiqueta,
    this.padding = const EdgeInsets.all(14),
    required this.onTap,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final String? subtitulo;
  final String? etiqueta;
  final EdgeInsets padding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CajaIcono(icono: icono, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitulo != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitulo!,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (etiqueta != null) ...[
              const SizedBox(width: 8),
              Text(
                etiqueta!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                ),
              ),
            ],
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _CajaIcono extends StatelessWidget {
  const _CajaIcono({required this.icono, required this.color});

  final IconData icono;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icono, size: 21, color: color),
    );
  }
}

Widget _divisor() {
  return Divider(height: 1, thickness: 1, color: AppColors.surfaceContainerHigh);
}

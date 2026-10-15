import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../data/models/perfil.dart';
import '../../shell/presentation/widgets/cabecera_perfil.dart';

/// Pestaña de la IA del Campus. Por ahora es solo la experiencia visual:
/// la integración con la Edge Function se conecta en la etapa de IA.
class IaScreen extends StatefulWidget {
  const IaScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  State<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends State<IaScreen> {
  final _entrada = TextEditingController();
  final _foco = FocusNode();

  @override
  void dispose() {
    _entrada.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _usarSugerencia(String texto) {
    _entrada.text = texto;
    _entrada.selection = TextSelection.collapsed(offset: texto.length);
    _foco.requestFocus();
  }

  void _enviar() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('La IA del Campus estará disponible muy pronto.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        title: CabeceraPerfil(perfil: widget.perfil, saludo: false),
        actions: [
          BotonCabecera(icono: Icons.history, onTap: () {}),
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              children: [
                _margen(
                  _HeroIA(
                    alias: widget.perfil.alias,
                    onSugerencia: _usarSugerencia,
                  ),
                ),
                const SizedBox(height: 20),
                _margen(const _EncabezadoConversacion()),
                const SizedBox(height: 12),
                _margen(const _Bienvenida()),
              ],
            ),
          ),
          _ConsolaIA(
            controller: _entrada,
            focus: _foco,
            onEnviar: _enviar,
          ),
        ],
      ),
    );
  }

  Widget _margen(Widget child) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

/// Tarjeta superior con el orbe de la IA, pregunta de bienvenida y
/// acciones rápidas sugeridas.
class _HeroIA extends StatelessWidget {
  const _HeroIA({required this.alias, required this.onSugerencia});

  final String alias;
  final ValueChanged<String> onSugerencia;

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
          border: Border.all(color: context.colors.ugYellow.withValues(alpha: 0.4)),
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
                      const _OrbeIA(),
                      const SizedBox(width: 12),
                      const Expanded(child: _EstadoIA()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¿En qué te puedo ayudar hoy, $alias?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pregúntame por las publicaciones, avisos, eventos y '
                    'objetos perdidos de tus canales.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'ACCIONES RÁPIDAS SUGERIDAS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.colors.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _Sugerencias(onSugerencia: onSugerencia),
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

/// Orbe animado con el ícono de la IA y un punto rojo de actividad.
class _OrbeIA extends StatelessWidget {
  const _OrbeIA();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [context.colors.ugYellow, context.colors.ugYellowDark],
              ),
            ),
            child: const Center(
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 26),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: context.colors.ugRed,
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colors.surfaceContainerLowest,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Píldora de estado "IA del Campus · En línea".
class _EstadoIA extends StatelessWidget {
  const _EstadoIA({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: context.colors.ugOcreLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: context.colors.ugYellow.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'IA del Campus · En línea',
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: context.colors.ugYellowDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sugerencia {
  const _Sugerencia(this.texto, this.icono, this.color);

  final String texto;
  final IconData icono;
  final Color color;
}

class _Sugerencias extends StatelessWidget {
  const _Sugerencias({required this.onSugerencia});

  final ValueChanged<String> onSugerencia;

  static List<_Sugerencia> _items(BuildContext context) => [
        _Sugerencia(
          '¿Qué me perdí esta semana?',
          Icons.bolt,
          context.colors.ugRed,
        ),
        _Sugerencia(
          'Resumen de un canal',
          Icons.topic_outlined,
          context.colors.ugBlue,
        ),
        _Sugerencia(
          'Buscar un tema',
          Icons.manage_search,
          context.colors.ugBlue,
        ),
        _Sugerencia(
          'Avisos importantes',
          Icons.campaign_outlined,
          context.colors.ugRed,
        ),
        _Sugerencia(
          'Objetos perdidos',
          Icons.search_off_outlined,
          context.colors.ugYellowDark,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in _items(context))
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ChipSugerencia(
                item: item,
                onTap: () => onSugerencia(item.texto),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChipSugerencia extends StatelessWidget {
  const _ChipSugerencia({required this.item, required this.onTap});

  final _Sugerencia item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: context.colors.ugYellow.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icono, size: 15, color: item.color),
              const SizedBox(width: 6),
              Text(
                item.texto,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EncabezadoConversacion extends StatelessWidget {
  const _EncabezadoConversacion();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.forum_outlined, size: 20, color: context.colors.onSurface),
        const SizedBox(width: 8),
        const Text(
          'Conversación',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: context.colors.ugYellow.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Nueva',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: context.colors.ugYellowDark,
            ),
          ),
        ),
      ],
    );
  }
}

/// Estado vacío de la conversación: aún no hay mensajes.
class _Bienvenida extends StatelessWidget {
  const _Bienvenida();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.ugOcreLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 30,
              color: context.colors.ugYellowDark,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Empieza una conversación',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Escribe tu pregunta o toca una acción rápida. Aquí verás mis '
            'respuestas junto con las publicaciones que las respaldan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Consola de entrada inferior con adjuntar, voz y envío.
class _ConsolaIA extends StatelessWidget {
  const _ConsolaIA({
    required this.controller,
    required this.focus,
    required this.onEnviar,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: Row(
        children: [
          _botonIcono(context, Icons.attach_file, 'Adjuntar'),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: controller,
                focusNode: focus,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                decoration: InputDecoration(
                  hintText: 'Pregunta sobre clases, canales o trámites…',
                  hintStyle: TextStyle(color: context.colors.outline, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          _botonIcono(context, Icons.mic_none, 'Dictar por voz'),
          const SizedBox(width: 6),
          _BotonEnviar(onTap: onEnviar),
        ],
      ),
    );
  }

  Widget _botonIcono(BuildContext context, IconData icono, String tooltip) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {},
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icono, size: 22, color: context.colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

class _BotonEnviar extends StatelessWidget {
  const _BotonEnviar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.ugRed,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: const SizedBox(
          width: 46,
          height: 46,
          child: Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

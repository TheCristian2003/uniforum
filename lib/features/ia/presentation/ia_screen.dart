import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../data/models/canal.dart';
import '../../../data/models/perfil.dart';
import '../../../data/models/respuesta_ia.dart';
import '../../../data/repositories/ia_repository.dart';
import '../../publicaciones/presentation/publicacion_detalle_screen.dart';
import '../../shell/presentation/widgets/cabecera_perfil.dart';

/// Pestaña de la IA del Campus.
///
/// Envía preguntas y resúmenes ("¿Qué me perdí?") a la Edge Function
/// `campus-ai`, que recupera el contexto bajo RLS y aplica el cupo diario.
class IaScreen extends ConsumerStatefulWidget {
  const IaScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<IaScreen> createState() => _IaScreenState();
}

class _IaScreenState extends ConsumerState<IaScreen> {
  final _entrada = TextEditingController();
  final _foco = FocusNode();
  final _scroll = ScrollController();
  final List<_MensajeIA> _mensajes = [];

  bool _enviando = false;
  int? _restantes;

  @override
  void dispose() {
    _entrada.dispose();
    _foco.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _usarSugerencia(_Sugerencia item) {
    switch (item.accion) {
      case _AccionSugerencia.enviar:
        _enviar(texto: item.consulta ?? item.texto);
      case _AccionSugerencia.buscar:
        const prefijo = 'Busca en el campus publicaciones sobre ';
        _entrada.text = prefijo;
        _entrada.selection =
            const TextSelection.collapsed(offset: prefijo.length);
        _foco.requestFocus();
      case _AccionSugerencia.completar:
        _entrada.text = item.texto;
        _entrada.selection =
            TextSelection.collapsed(offset: item.texto.length);
        _foco.requestFocus();
      case _AccionSugerencia.resumenSemanal:
      case _AccionSugerencia.resumenCanal:
        break;
    }
  }

  List<MensajeHistorialIA> _historialActual() {
    final historial = <MensajeHistorialIA>[
      for (final mensaje in _mensajes)
        if (!mensaje.esError && mensaje.texto.isNotEmpty)
          MensajeHistorialIA(
            rol: mensaje.esUsuario ? 'usuario' : 'ia',
            texto: mensaje.texto,
          ),
    ];
    const maximo = 6;
    return historial.length > maximo
        ? historial.sublist(historial.length - maximo)
        : historial;
  }

  Future<void> _enviar({
    String? texto,
    bool resumen = false,
    int dias = 30,
    String? canalId,
  }) async {
    if (_enviando) return;

    final pregunta = (texto ?? _entrada.text).trim();
    if (pregunta.isEmpty) return;
    if (pregunta.length > IaRepository.maxPregunta) {
      _avisar(
        'La pregunta no puede superar ${IaRepository.maxPregunta} caracteres.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    _entrada.clear();
    final diasFinales = IaRepository.diasSugeridos(
      pregunta,
      predeterminado: dias,
    );
    final historial = _historialActual();
    setState(() {
      _mensajes.add(
        _MensajeIA.usuario(
          pregunta,
          resumen: resumen,
          dias: diasFinales,
          canalId: canalId,
        ),
      );
    });
    _desplazar();

    await _consultar(
      pregunta: pregunta,
      resumen: resumen,
      dias: diasFinales,
      canalId: canalId,
      historial: historial,
    );
  }

  Future<void> _consultar({
    required String pregunta,
    required bool resumen,
    required int dias,
    String? canalId,
    List<MensajeHistorialIA> historial = const [],
  }) async {
    if (_enviando) return;

    setState(() => _enviando = true);
    _desplazar();

    try {
      final respuesta = await ref.read(iaRepositoryProvider).consultar(
            pregunta: pregunta,
            resumen: resumen,
            dias: dias,
            canalId: canalId,
            historial: historial,
          );
      if (!mounted) return;
      setState(() {
        _mensajes.add(
          _MensajeIA.ia(respuesta.texto, fuentes: respuesta.fuentes),
        );
        _restantes = respuesta.restantes;
      });
    } on IaException catch (error) {
      if (!mounted) return;
      setState(() {
        _mensajes.add(
          _MensajeIA.error(
            error.mensaje,
            pregunta: pregunta,
            resumen: resumen,
            dias: dias,
            canalId: canalId,
            historial: historial,
          ),
        );
      });
      _avisar(error.mensaje);
    } catch (_) {
      if (!mounted) return;
      const mensaje = 'La IA no pudo responder. Inténtalo de nuevo.';
      setState(() {
        _mensajes.add(
          _MensajeIA.error(
            mensaje,
            pregunta: pregunta,
            resumen: resumen,
            dias: dias,
            canalId: canalId,
            historial: historial,
          ),
        );
      });
      _avisar(mensaje);
    } finally {
      if (mounted) {
        setState(() => _enviando = false);
        _desplazar();
      }
    }
  }

  void _reintentar(_MensajeIA mensaje) {
    if (_enviando) return;
    setState(() => _mensajes.remove(mensaje));
    _consultar(
      pregunta: mensaje.pregunta ?? '',
      resumen: mensaje.resumen,
      dias: mensaje.dias,
      canalId: mensaje.canalId,
      historial: mensaje.historial,
    );
  }

  Future<void> _elegirCanalResumen() async {
    final canal = await showModalBottomSheet<Canal>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _SelectorCanal(),
    );
    if (canal == null || !mounted) return;
    await _enviar(
      texto: '¿Qué me perdí en ${canal.nombre}?',
      resumen: true,
      canalId: canal.id,
    );
  }

  Future<void> _abrirFuente(FuenteIA fuente) async {
    try {
      final publicacion =
          await ref.read(publicacionDetalleProvider(fuente.id).future);
      if (!mounted) return;
      if (publicacion == null) {
        _avisar('No se pudo abrir esa publicación.');
        return;
      }
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PublicacionDetalleScreen(publicacion: publicacion),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      _avisar('No se pudo abrir esa publicación.');
    }
  }

  void _avisar(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _desplazar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
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
              controller: _scroll,
              padding: const EdgeInsets.only(top: 16, bottom: 16),
              children: [
                _margen(
                  _HeroIA(
                    alias: widget.perfil.alias,
                    restantes: _restantes,
                    onSugerencia: _usarSugerencia,
                    onResumenSemanal: () => _enviar(
                      texto: '¿Qué me perdí esta semana?',
                      resumen: true,
                      dias: 7,
                    ),
                    onResumenCanal: _elegirCanalResumen,
                  ),
                ),
                const SizedBox(height: 20),
                _margen(
                  _EncabezadoConversacion(cantidad: _mensajes.length),
                ),
                const SizedBox(height: 12),
                if (_mensajes.isEmpty) _margen(const _Bienvenida()),
                for (final mensaje in _mensajes) ...[
                  _margen(
                    _BurbujaMensaje(
                      mensaje: mensaje,
                      onReintentar: () => _reintentar(mensaje),
                      onFuente: _abrirFuente,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                if (_enviando) _margen(const _Escribiendo()),
              ],
            ),
          ),
          _ConsolaIA(
            controller: _entrada,
            focus: _foco,
            enviando: _enviando,
            onEnviar: () => _enviar(),
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
  const _HeroIA({
    required this.alias,
    required this.onSugerencia,
    required this.onResumenSemanal,
    required this.onResumenCanal,
    this.restantes,
  });

  final String alias;
  final ValueChanged<_Sugerencia> onSugerencia;
  final VoidCallback onResumenSemanal;
  final VoidCallback onResumenCanal;
  final int? restantes;

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
                  _Sugerencias(
                    onSugerencia: onSugerencia,
                    onResumenSemanal: onResumenSemanal,
                    onResumenCanal: onResumenCanal,
                  ),
                  if (restantes != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Te quedan $restantes consultas de IA hoy.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
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
  const _EstadoIA();

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

enum _AccionSugerencia {
  completar,
  buscar,
  enviar,
  resumenSemanal,
  resumenCanal,
}

class _Sugerencia {
  const _Sugerencia(
    this.texto,
    this.icono,
    this.color, {
    this.accion = _AccionSugerencia.completar,
    this.consulta,
  });

  final String texto;
  final IconData icono;
  final Color color;
  final _AccionSugerencia accion;
  final String? consulta;
}

class _Sugerencias extends StatelessWidget {
  const _Sugerencias({
    required this.onSugerencia,
    required this.onResumenSemanal,
    required this.onResumenCanal,
  });

  final ValueChanged<_Sugerencia> onSugerencia;
  final VoidCallback onResumenSemanal;
  final VoidCallback onResumenCanal;

  static List<_Sugerencia> _items(BuildContext context) => [
        _Sugerencia(
          '¿Qué me perdí esta semana?',
          Icons.bolt,
          context.colors.ugRed,
          accion: _AccionSugerencia.resumenSemanal,
        ),
        _Sugerencia(
          'Resumen de un canal',
          Icons.topic_outlined,
          context.colors.ugBlue,
          accion: _AccionSugerencia.resumenCanal,
        ),
        _Sugerencia(
          'Buscar un tema',
          Icons.manage_search,
          context.colors.ugBlue,
          accion: _AccionSugerencia.buscar,
        ),
        _Sugerencia(
          'Avisos importantes',
          Icons.campaign_outlined,
          context.colors.ugRed,
          accion: _AccionSugerencia.enviar,
          consulta: '¿Cuáles son los avisos más importantes del campus?',
        ),
        _Sugerencia(
          'Objetos perdidos',
          Icons.search_off_outlined,
          context.colors.ugYellowDark,
          accion: _AccionSugerencia.enviar,
          consulta:
              '¿Hay publicaciones de objetos perdidos o encontrados en el campus?',
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
                onTap: () {
                  if (item.accion == _AccionSugerencia.resumenSemanal) {
                    onResumenSemanal();
                  } else if (item.accion == _AccionSugerencia.resumenCanal) {
                    onResumenCanal();
                  } else {
                    onSugerencia(item);
                  }
                },
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
  const _EncabezadoConversacion({required this.cantidad});

  final int cantidad;

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
            cantidad == 0 ? 'Nueva' : '$cantidad mensajes',
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

class _SelectorCanal extends ConsumerWidget {
  const _SelectorCanal();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canales = ref.watch(canalesProvider);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                'Elige un canal para el resumen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: context.colors.onSurface,
                ),
              ),
            ),
            Expanded(
              child: canales.when(
                data: (lista) {
                  if (lista.isEmpty) {
                    return const Center(child: Text('Todavía no hay canales.'));
                  }
                  return ListView.separated(
                    itemCount: lista.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, indice) {
                      final canal = lista[indice];
                      final inicial =
                          canal.nombre.isEmpty ? '#' : canal.nombre[0].toUpperCase();
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              context.colors.ugBlue.withValues(alpha: 0.12),
                          foregroundColor: context.colors.ugBlue,
                          child: Text(
                            inicial,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        title: Text(canal.nombre),
                        subtitle: canal.descripcion == null
                            ? null
                            : Text(
                                canal.descripcion!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        onTap: () => Navigator.of(context).pop(canal),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => const Center(
                  child: Text('No se pudieron cargar los canales.'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mensaje de la conversación: pregunta del usuario, respuesta de la IA o error.
class _MensajeIA {
  const _MensajeIA._({
    required this.texto,
    required this.esUsuario,
    this.fuentes = const [],
    this.esError = false,
    this.pregunta,
    this.resumen = false,
    this.dias = 30,
    this.canalId,
    this.historial = const [],
  });

  factory _MensajeIA.usuario(
    String texto, {
    required bool resumen,
    required int dias,
    String? canalId,
  }) =>
      _MensajeIA._(
        texto: texto,
        esUsuario: true,
        pregunta: texto,
        resumen: resumen,
        dias: dias,
        canalId: canalId,
      );

  factory _MensajeIA.ia(String texto, {List<FuenteIA> fuentes = const []}) =>
      _MensajeIA._(texto: texto, esUsuario: false, fuentes: fuentes);

  factory _MensajeIA.error(
    String texto, {
    required String pregunta,
    required bool resumen,
    required int dias,
    String? canalId,
    List<MensajeHistorialIA> historial = const [],
  }) =>
      _MensajeIA._(
        texto: texto,
        esUsuario: false,
        esError: true,
        pregunta: pregunta,
        resumen: resumen,
        dias: dias,
        canalId: canalId,
        historial: historial,
      );

  final String texto;
  final bool esUsuario;
  final List<FuenteIA> fuentes;
  final bool esError;
  final String? pregunta;
  final bool resumen;
  final int dias;
  final String? canalId;
  final List<MensajeHistorialIA> historial;
}

class _TextoIA extends StatelessWidget {
  const _TextoIA(this.texto, {required this.estilo});

  final String texto;
  final TextStyle estilo;

  static final RegExp _negritas = RegExp(r'\*\*(.+?)\*\*', dotAll: true);
  static final RegExp _vinetas = RegExp(r'^(\s*)[*-]\s+', multiLine: true);

  @override
  Widget build(BuildContext context) {
    final limpio = texto.replaceAllMapped(
      _vinetas,
      (coincidencia) => '${coincidencia[1]}• ',
    );
    final spans = <TextSpan>[];
    var inicio = 0;
    for (final coincidencia in _negritas.allMatches(limpio)) {
      if (coincidencia.start > inicio) {
        spans.add(TextSpan(text: limpio.substring(inicio, coincidencia.start)));
      }
      spans.add(
        TextSpan(
          text: coincidencia.group(1),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      );
      inicio = coincidencia.end;
    }
    if (inicio < limpio.length) {
      spans.add(TextSpan(text: limpio.substring(inicio)));
    }
    return Text.rich(TextSpan(style: estilo, children: spans));
  }
}

class _BurbujaMensaje extends StatelessWidget {
  const _BurbujaMensaje({
    required this.mensaje,
    required this.onReintentar,
    required this.onFuente,
  });

  final _MensajeIA mensaje;
  final VoidCallback onReintentar;
  final ValueChanged<FuenteIA> onFuente;

  @override
  Widget build(BuildContext context) {
    final maxAncho = MediaQuery.sizeOf(context).width * 0.84;
    return Align(
      alignment:
          mensaje.esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxAncho),
        child: mensaje.esUsuario
            ? _burbujaUsuario(context)
            : _burbujaIA(context),
      ),
    );
  }

  Widget _burbujaUsuario(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.ugBlue.withValues(alpha: 0.14),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
        border: Border.all(color: context.colors.ugBlue.withValues(alpha: 0.35)),
      ),
      child: Text(
        mensaje.texto,
        style: TextStyle(
          fontSize: 14.5,
          height: 1.45,
          fontWeight: FontWeight.w600,
          color: context.colors.onSurface,
        ),
      ),
    );
  }

  Widget _burbujaIA(BuildContext context) {
    final esError = mensaje.esError;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: esError
            ? context.colors.ugRed.withValues(alpha: 0.06)
            : context.colors.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(
          color: esError
              ? context.colors.ugRed.withValues(alpha: 0.45)
              : context.colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                esError ? Icons.error_outline : Icons.auto_awesome,
                size: 16,
                color: esError
                    ? context.colors.ugRed
                    : context.colors.ugYellowDark,
              ),
              const SizedBox(width: 6),
              Text(
                esError ? 'No se pudo responder' : 'IA del Campus',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: esError
                      ? context.colors.ugRed
                      : context.colors.ugYellowDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _TextoIA(
            mensaje.texto,
            estilo: TextStyle(
              fontSize: 14.5,
              height: 1.5,
              color: context.colors.onSurface,
            ),
          ),
          if (esError) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onReintentar,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reintentar'),
              ),
            ),
          ],
          if (!esError && mensaje.fuentes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(color: context.colors.outlineVariant.withValues(alpha: 0.6)),
            const SizedBox(height: 4),
            Text(
              'FUENTES USADAS',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: context.colors.outline,
              ),
            ),
            const SizedBox(height: 6),
            for (var i = 0; i < mensaje.fuentes.length; i++)
              _FuenteItem(
                indice: i + 1,
                fuente: mensaje.fuentes[i],
                onTap: () => onFuente(mensaje.fuentes[i]),
              ),
          ],
        ],
      ),
    );
  }
}

class _FuenteItem extends StatelessWidget {
  const _FuenteItem({
    required this.indice,
    required this.fuente,
    required this.onTap,
  });

  final int indice;
  final FuenteIA fuente;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detalle = [
      if (fuente.canal != null) fuente.canal!,
      if (fuente.tipo != null) fuente.tipo!,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.ugYellow.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'P$indice',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: context.colors.ugYellowDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fuente.titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          color: context.colors.onSurface,
                        ),
                      ),
                      if (detalle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          detalle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: context.colors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Indicador de "escribiendo" mientras se espera la Edge Function.
class _Escribiendo extends StatelessWidget {
  const _Escribiendo();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.ugYellowDark,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Buscando en el campus…',
              style: TextStyle(
                fontSize: 13,
                color: context.colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
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
    required this.enviando,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final VoidCallback onEnviar;
  final bool enviando;

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
          _BotonEnviar(onTap: enviando ? null : onEnviar, enviando: enviando),
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
  const _BotonEnviar({required this.onTap, required this.enviando});

  final VoidCallback? onTap;
  final bool enviando;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.ugRed,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 46,
          height: 46,
          child: enviando
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : const Icon(Icons.send, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

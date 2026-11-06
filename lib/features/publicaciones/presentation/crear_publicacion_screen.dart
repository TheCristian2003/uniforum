import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/roles.dart';
import '../../../core/gamification/niveles.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/utils/estilo_publicacion.dart';
import '../../../core/utils/fecha_relativa.dart';
import '../../../data/models/catalogo_item.dart';
import '../../../data/models/publicacion.dart';
import 'widgets/imagenes_adjuntas.dart';

/// Selector de fecha para campos de metadatos (evento, perdido/encontrado).
class _SelectorFechaFormField extends FormField<DateTime> {
  _SelectorFechaFormField({
    required String label,
    required DateTime? valor,
    required Future<DateTime?> Function() onSeleccionar,
    bool conHora = false,
    super.validator,
  }) : super(
         initialValue: valor,
         builder: (state) => InkWell(
           onTap: () async {
             final elegido = await onSeleccionar();
             if (elegido != null) state.didChange(elegido);
           },
           borderRadius: BorderRadius.circular(12),
           child: InputDecorator(
             decoration: InputDecoration(
               labelText: label,
               prefixIcon: Icon(
                 conHora ? Icons.schedule_outlined : Icons.event_outlined,
               ),
               errorText: state.errorText,
             ),
             child: Text(
               state.value == null
                   ? 'Seleccionar'
                   : (conHora ? fechaHora(state.value!) : fechaCorta(state.value!)),
             ),
           ),
         ),
       );
}

class _MiniaturaBytes extends StatelessWidget {
  const _MiniaturaBytes({required this.bytes, required this.onQuitar});

  final Uint8List bytes;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Material(
            color: context.colors.ugRed,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onQuitar,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniaturaUrl extends StatelessWidget {
  const _MiniaturaUrl({required this.url, required this.onQuitar});

  final String url;
  final VoidCallback onQuitar;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 96,
            height: 96,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Material(
            color: context.colors.ugRed,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onQuitar,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta blanca que agrupa un bloque del formulario con su encabezado.
class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  final String titulo;
  final IconData icono;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.colors.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: context.colors.ugBlue),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// Etiqueta en mayúsculas sobre un campo, con acción opcional a la derecha.
class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, {this.accion});

  final String texto;
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            texto.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: context.colors.outline,
            ),
          ),
          ?accion,
        ],
      ),
    );
  }
}

String _descripcionTipo(String codigo) => switch (codigo) {
  'discusion' => 'Pregunta, debate o conversación',
  'aviso' => 'Información oficial del campus',
  'venta' => 'Ofrece un producto',
  'perdido' => 'Reporta algo que perdiste',
  'encontrado' => 'Reporta algo que encontraste',
  'evento' => 'Actividad con fecha y lugar',
  _ => 'Publica en el campus',
};

/// Opción visual para elegir el tipo de publicación.
class _ChipTipo extends StatelessWidget {
  const _ChipTipo({
    required this.estilo,
    required this.nombre,
    required this.descripcion,
    required this.seleccionado,
    required this.onTap,
  });

  final EstiloTipo estilo;
  final String nombre;
  final String descripcion;
  final bool seleccionado;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: seleccionado
          ? estilo.color.withValues(alpha: 0.1)
          : context.colors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: seleccionado
                  ? estilo.color
                  : context.colors.outlineVariant.withValues(alpha: 0.6),
              width: seleccionado ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: seleccionado
                      ? estilo.color
                      : estilo.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  estilo.icono,
                  size: 19,
                  color: seleccionado ? Colors.white : estilo.color,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: seleccionado
                            ? FontWeight.w800
                            : FontWeight.w700,
                        color: context.colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        height: 1.2,
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (seleccionado) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle, size: 16, color: estilo.color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila con las acciones rápidas para adjuntar contenido (solo Foto activo).
class _BotonAdjuntar extends StatelessWidget {
  const _BotonAdjuntar({
    required this.icono,
    required this.texto,
    required this.color,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icono, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarPerfil extends StatelessWidget {
  const _AvatarPerfil({
    required this.alias,
    required this.avatarUrl,
    required this.nivel,
  });

  final String alias;
  final String? avatarUrl;
  final int nivel;

  @override
  Widget build(BuildContext context) {
    final recortado = alias.trim();
    final inicial = recortado.isEmpty
        ? '?'
        : String.fromCharCode(recortado.runes.first).toUpperCase();
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.ugOcre, width: 2),
            color: context.colors.ugBlueLight,
          ),
          clipBehavior: Clip.antiAlias,
          child: (avatarUrl != null && avatarUrl!.isNotEmpty)
              ? Image.network(
                  avatarUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      inicial,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: context.colors.ugBlue,
                      ),
                    ),
                  ),
                )
              : Center(
                  child: Text(
                    inicial,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: context.colors.ugBlue,
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: context.colors.ugOcre,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Nv $nivel',
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1B1D28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CrearPublicacionScreen extends ConsumerStatefulWidget {
  const CrearPublicacionScreen({super.key, this.publicacion});

  final Publicacion? publicacion;

  @override
  ConsumerState<CrearPublicacionScreen> createState() =>
      _CrearPublicacionScreenState();
}

class _CrearPublicacionScreenState
    extends ConsumerState<CrearPublicacionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cuerpoController = TextEditingController();
  final _tituloController = TextEditingController();
  final _precioController = TextEditingController();
  final _recompensaController = TextEditingController();
  final _lugarController = TextEditingController();
  final _enlaceController = TextEditingController();

  String? _canalId;
  int? _tipoId;
  int? _categoriaId;
  bool _anonimo = false;
  bool _disponible = true;
  bool _entregado = false;
  bool _mostrarErrorTipo = false;
  DateTime? _fecha;
  DateTime? _inicio;
  DateTime? _fin;

  final ImagePicker _picker = ImagePicker();
  final List<ImagenSeleccionada> _nuevas = [];
  final List<String> _existentes = [];

  bool _enviando = false;

  bool get _editando => widget.publicacion != null;

  @override
  void initState() {
    super.initState();
    final pub = widget.publicacion;
    if (pub != null) {
      _canalId = pub.canalId;
      _tipoId = pub.tipoId;
      _categoriaId = pub.categoriaId;
      _anonimo = pub.anonimo;
      _tituloController.text = pub.titulo ?? '';
      _cuerpoController.text = pub.cuerpo;
      _precioController.text = pub.metadatos.precio?.toStringAsFixed(0) ?? '';
      _recompensaController.text =
          pub.metadatos.recompensa?.toStringAsFixed(0) ?? '';
      _lugarController.text = pub.metadatos.lugar ?? '';
      _enlaceController.text = pub.metadatos.enlace ?? '';
      _disponible = pub.metadatos.disponible ?? true;
      _entregado = pub.metadatos.entregado ?? false;
      _fecha = pub.metadatos.fecha;
      _inicio = pub.metadatos.inicio;
      _fin = pub.metadatos.fin;
      _existentes.addAll(pub.imagenes);
    }
  }

  @override
  void dispose() {
    _cuerpoController.dispose();
    _tituloController.dispose();
    _precioController.dispose();
    _recompensaController.dispose();
    _lugarController.dispose();
    _enlaceController.dispose();
    super.dispose();
  }

  Future<void> _elegirImagenes() async {
    final limite = 3 - _existentes.length - _nuevas.length;
    if (limite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes adjuntar hasta 3 imágenes.')),
      );
      return;
    }
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (!mounted) return;
    if (files.isEmpty) return;
    for (final file in files.take(limite)) {
      final bytes = await file.readAsBytes();
      const maxBytes = 5 * 1024 * 1024;
      if (bytes.length > maxBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La imagen supera los 5 MB. Selecciona una más ligera.'),
          ),
        );
        continue;
      }
      setState(() {
        _nuevas.add(
          ImagenSeleccionada(
            bytes: bytes,
            extension: file.path.split('.').last.toLowerCase(),
          ),
        );
      });
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<DateTime?> _seleccionarFecha({bool conHora = false}) async {
    final fecha = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );
    if (fecha == null) return null;
    if (!conHora) return fecha;
    final hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (hora == null) return fecha;
    return DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
  }

  Future<void> _publicar() async {
    final restriccion = ref.read(miRestriccionActivaProvider).value;
    if (restriccion != null && restriccion.vigente) {
      _mostrarError('Tu cuenta está restringida: no puedes publicar.');
      return;
    }
    if (_tipoId == null) {
      setState(() => _mostrarErrorTipo = true);
      _mostrarError('Selecciona el tipo de publicación.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final canalId = _canalId;
    final tipoId = _tipoId;
    final tipos = ref.read(catalogoProvider('tipo_publicacion')).value ?? [];
    final tipo = tipos.where((t) => t.id == tipoId).firstOrNull;
    final categorias =
        ref.read(catalogoProvider('categoria_publicacion')).value ?? [];
    final categoriaGeneral =
        categorias.where((c) => c.codigo == 'general').firstOrNull;
    final categoriaId = _tipoUsaCategoria(tipo?.codigo)
        ? _categoriaId
        : (_categoriaId ?? categoriaGeneral?.id);
    if (canalId == null || tipoId == null || categoriaId == null) {
      _mostrarError(
        categoriaId == null && _tipoUsaCategoria(tipo?.codigo)
            ? 'Selecciona una categoría.'
            : 'No se pudo resolver la clasificación de la publicación.',
      );
      return;
    }

    setState(() => _enviando = true);
    try {
      List<String> imagenes = List<String>.from(_existentes);
      final user = ref.read(currentUserProvider);
      if (_nuevas.isNotEmpty && user != null) {
        final repo = ref.read(imagenesRepositoryProvider);
        for (final img in _nuevas) {
          final url = await repo.subirAdjunto(
            usuarioId: user.id,
            bytes: img.bytes,
            extension: img.extension,
          );
          imagenes.add(url);
        }
      }
      imagenes = imagenes.take(3).toList();

      final metadatos = _construirMetadatos();
      final pubRepo = ref.read(publicacionesRepositoryProvider);
      if (_editando) {
        await pubRepo.actualizarPublicacion(
          id: widget.publicacion!.id,
          cuerpo: _cuerpoController.text.trim(),
          titulo: _tituloController.text.trim().isEmpty
              ? null
              : _tituloController.text.trim(),
          anonimo: _anonimo,
          imagenes: imagenes,
          metadatos: metadatos.isEmpty ? null : metadatos,
        );
        _mostrarExito('Publicación actualizada.');
      } else {
        await pubRepo.crearPublicacion(
          canalId: canalId,
          tipoId: tipoId,
          categoriaId: categoriaId,
          cuerpo: _cuerpoController.text.trim(),
          titulo: _tituloController.text.trim().isEmpty
              ? null
              : _tituloController.text.trim(),
          anonimo: _anonimo,
          imagenes: imagenes,
          metadatos: metadatos.isEmpty ? null : metadatos,
        );
        _mostrarExito('Publicación creada.');
      }
      ref.invalidate(feedRecientesProvider);
      ref.invalidate(publicacionesDeCanalProvider(canalId));
      if (_editando) {
        ref.invalidate(
          publicacionDetalleProvider(widget.publicacion!.id),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      _mostrarError('No se pudo guardar la publicación: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarExito(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Map<String, dynamic> _construirMetadatos() {
    final tipo = _tipoSeleccionado();
    final meta = <String, dynamic>{};
    if (tipo?.codigo == 'venta') {
      final precio = double.tryParse(
        _precioController.text.replaceAll(',', '.'),
      );
      if (precio != null) meta['precio'] = precio;
      meta['moneda'] = 'COP';
      if (_lugarController.text.trim().isNotEmpty) {
        meta['lugar'] = _lugarController.text.trim();
      }
      meta['disponible'] = _disponible;
    }
    if (tipo?.codigo == 'perdido') {
      if (_fecha != null) meta['fecha'] = _fecha!.toIso8601String();
      if (_lugarController.text.trim().isNotEmpty) {
        meta['lugar'] = _lugarController.text.trim();
      }
      final recompensa = double.tryParse(
        _recompensaController.text.replaceAll(',', '.'),
      );
      if (recompensa != null) meta['recompensa'] = recompensa;
      if (meta['moneda'] == null && recompensa != null) meta['moneda'] = 'COP';
    }
    if (tipo?.codigo == 'encontrado') {
      if (_fecha != null) meta['fecha'] = _fecha!.toIso8601String();
      if (_lugarController.text.trim().isNotEmpty) {
        meta['lugar'] = _lugarController.text.trim();
      }
      meta['entregado'] = _entregado;
    }
    if (tipo?.codigo == 'evento') {
      if (_inicio != null) meta['inicio'] = _inicio!.toIso8601String();
      if (_fin != null) meta['fin'] = _fin!.toIso8601String();
      if (_lugarController.text.trim().isNotEmpty) {
        meta['lugar'] = _lugarController.text.trim();
      }
      final enlace = _enlaceController.text.trim();
      if (enlace.isNotEmpty) meta['enlace'] = enlace;
    }
    return meta;
  }

  CatalogoItem? _tipoSeleccionado() {
    final tipos = ref.watch(catalogoProvider('tipo_publicacion')).value ?? [];
    return tipos.where((t) => t.id == _tipoId).cast<CatalogoItem?>().firstOrNull;
  }

  bool _tipoUsaCategoria(String? codigo) =>
      codigo == 'discusion' || codigo == 'aviso';

  String? _nombrePorId(List<CatalogoItem> items, int? id) {
    if (id == null) return null;
    return items.where((e) => e.id == id).map((e) => e.nombre).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final canalesAsync = ref.watch(canalesProvider);
    final tiposAsync = ref.watch(catalogoProvider('tipo_publicacion'));
    final categoriasAsync = ref.watch(catalogoProvider('categoria_publicacion'));
    final esPrivilegiado = esRolPrivilegiado(ref.watch(currentUserProvider));
    final tiposFiltrados = (tiposAsync.value ?? []).where((t) {
      if (t.codigo == 'aviso') return esPrivilegiado;
      return true;
    }).toList();
    final tipoSel = _tipoSeleccionado();
    final requiereCategoria = _tipoUsaCategoria(tipoSel?.codigo);
    final categoriasDisponibles = (categoriasAsync.value ?? []).where((c) {
      if (c.id == _categoriaId) return true;
      return c.codigo != 'marketplace' && c.codigo != 'eventos';
    }).toList();

    final perfil = ref.watch(perfilActualProvider).value;
    final sedes = ref.watch(catalogoProvider('sede')).value ?? [];
    final programas = ref.watch(catalogoProvider('programa')).value ?? [];
    final sedeNombre = _nombrePorId(sedes, perfil?.sedeId);
    final programaNombre = _nombrePorId(programas, perfil?.programaId);
    final nivel = nivelDesdePuntos(perfil?.puntos ?? 0).numero;

    final totalImgs = _existentes.length + _nuevas.length;
    final puedeAnadir = totalImgs < 3;
    final tituloPantalla =
        _editando ? 'Editar publicación' : 'Nueva publicación';

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppBar(
        toolbarHeight: 68,
        backgroundColor: context.colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tituloPantalla,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!_editando) ...[
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.ugBlueLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 13,
                      color: context.colors.ugBlue,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      sedeNombre == null ? 'Campus' : 'Sede $sedeNombre',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: context.colors.ugBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: context.colors.ugBlue.withValues(alpha: 0.12),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_editando) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colors.ugBlueLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.colors.ugBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: context.colors.ugBlue,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            requiereCategoria
                                ? 'No se puede cambiar el canal, tipo ni categoría.'
                                : 'No se puede cambiar el canal ni el tipo.',
                            style: TextStyle(
                              fontSize: 13,
                              color: context.colors.ugBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const _Etiqueta('¿Qué quieres publicar?'),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final ancho = (constraints.maxWidth - 10) / 2;
                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final t in tiposFiltrados)
                          SizedBox(
                            width: ancho,
                            child: _ChipTipo(
                              estilo: estiloTipo(context, t.codigo),
                              nombre: t.nombre,
                              descripcion: _descripcionTipo(t.codigo),
                              seleccionado: t.id == _tipoId,
                              onTap: _editando
                                  ? null
                                  : () {
                                      setState(() {
                                        _tipoId = t.id;
                                        _mostrarErrorTipo = false;
                                        if (!_tipoUsaCategoria(t.codigo)) {
                                          _categoriaId = null;
                                        }
                                        if (t.codigo != 'venta') {
                                          _disponible = true;
                                        }
                                      });
                                    },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                if (_mostrarErrorTipo) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Selecciona el tipo de publicación.',
                    style: TextStyle(fontSize: 12, color: context.colors.ugRed),
                  ),
                ],
                const SizedBox(height: 16),
                _Seccion(
                  titulo: 'Dónde y cómo se clasifica',
                  icono: Icons.tune,
                  children: [
                    const _Etiqueta('Canal de destino'),
                    DropdownButtonFormField<String>(
                      initialValue: _canalId,
                      decoration: const InputDecoration(
                        hintText: 'Selecciona un canal',
                        prefixIcon: Icon(Icons.forum_outlined),
                      ),
                      items: canalesAsync.when(
                        data: (canales) => canales
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.nombre),
                              ),
                            )
                            .toList(),
                        loading: () => [],
                        error: (_, _) => [],
                      ),
                      onChanged: _editando
                          ? null
                          : (v) => setState(() => _canalId = v),
                      validator: (v) =>
                          v == null ? 'Selecciona un canal' : null,
                    ),
                    if (requiereCategoria) ...[
                      const SizedBox(height: 12),
                      const _Etiqueta('Categoría'),
                      DropdownButtonFormField<int>(
                        initialValue: _categoriaId,
                        decoration: const InputDecoration(
                          hintText: 'Selecciona una categoría',
                          prefixIcon: Icon(Icons.label_outline),
                        ),
                        items: categoriasDisponibles
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Text(c.nombre),
                              ),
                            )
                            .toList(),
                        onChanged: _editando
                            ? null
                            : (v) => setState(() => _categoriaId = v),
                        validator: (v) =>
                            v == null ? 'Selecciona una categoría' : null,
                      ),
                    ] else if (tipoSel != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 17,
                            color: context.colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              'Este tipo no necesita categoría: el tipo ya '
                              'describe la publicación.',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.35,
                                color: context.colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                _Seccion(
                  titulo: 'Contenido',
                  icono: Icons.edit_note,
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _tituloController,
                      builder: (context, valor, _) => _Etiqueta(
                        'Título (opcional)',
                        accion: Text(
                          '${valor.text.runes.length} / 120',
                          style: TextStyle(
                            fontSize: 11,
                            color: context.colors.outline,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: _tituloController,
                      maxLength: 120,
                      buildCounter: (
                        _, {
                        required currentLength,
                        required isFocused,
                        maxLength,
                      }) => null,
                      decoration: const InputDecoration(
                        hintText: 'Título claro y descriptivo',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _Etiqueta('Contenido'),
                    TextFormField(
                      controller: _cuerpoController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        hintText:
                            'Comparte tu duda, información relevante o anuncio...',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Escribe el contenido de tu publicación'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    const _Etiqueta('Fotos (opcional, máx. 3)'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final url in _existentes)
                          _MiniaturaUrl(
                            url: url,
                            onQuitar: () =>
                                setState(() => _existentes.remove(url)),
                          ),
                        for (final img in _nuevas)
                          _MiniaturaBytes(
                            bytes: img.bytes,
                            onQuitar: () => setState(() => _nuevas.remove(img)),
                          ),
                        if (puedeAnadir)
                          _BotonAdjuntar(
                            icono: Icons.add_photo_alternate_outlined,
                            texto: 'Añadir foto',
                            color: context.colors.ugBlue,
                            onTap: _elegirImagenes,
                          ),
                      ],
                    ),
                  ],
                ),
                if (tipoSel?.codigo == 'venta') ...[
                  const SizedBox(height: 16),
                  _Seccion(
                    titulo: 'Datos de la venta',
                    icono: Icons.sell_outlined,
                    children: [
                      TextFormField(
                        controller: _precioController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio (COP)',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                        ),
                        validator: (v) {
                          final texto = v?.trim() ?? '';
                          if (texto.isEmpty) return 'Ingresa un valor';
                          final valor = double.tryParse(
                            texto.replaceAll(',', '.'),
                          );
                          return valor == null || valor <= 0
                              ? 'Ingresa un valor mayor que 0'
                              : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lugarController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar (opcional)',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_editando)
                        Material(
                          type: MaterialType.transparency,
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Disponible'),
                            value: _disponible,
                            onChanged: (v) => setState(() => _disponible = v),
                          ),
                        )
                      else
                        Text(
                          'El estado se establecerá como disponible al crear la publicación.',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ],
                if (tipoSel?.codigo == 'perdido') ...[
                  const SizedBox(height: 16),
                  _Seccion(
                    titulo: 'Datos del objeto perdido',
                    icono: Icons.search_off_outlined,
                    children: [
                      _SelectorFechaFormField(
                        label: 'Fecha del incidente',
                        valor: _fecha,
                        onSeleccionar: () => _seleccionarFecha(),
                        validator: (v) =>
                            v == null ? 'Selecciona la fecha' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lugarController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa el lugar'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _recompensaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Recompensa (COP, opcional)',
                          prefixIcon: Icon(Icons.attach_money_outlined),
                        ),
                        validator: (v) {
                          final texto = v?.trim() ?? '';
                          if (texto.isEmpty) return null;
                          final valor = double.tryParse(
                            texto.replaceAll(',', '.'),
                          );
                          return valor == null || valor < 0
                              ? 'Recompensa inválida'
                              : null;
                        },
                      ),
                    ],
                  ),
                ],
                if (tipoSel?.codigo == 'encontrado') ...[
                  const SizedBox(height: 16),
                  _Seccion(
                    titulo: 'Datos del hallazgo',
                    icono: Icons.handshake_outlined,
                    children: [
                      _SelectorFechaFormField(
                        label: 'Fecha del hallazgo',
                        valor: _fecha,
                        onSeleccionar: () => _seleccionarFecha(),
                        validator: (v) =>
                            v == null ? 'Selecciona la fecha' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lugarController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa el lugar'
                            : null,
                      ),
                      if (_editando) ...[
                        const SizedBox(height: 12),
                        Material(
                          type: MaterialType.transparency,
                          child: SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Entregado'),
                            value: _entregado,
                            onChanged: (v) => setState(() => _entregado = v),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (tipoSel?.codigo == 'evento') ...[
                  const SizedBox(height: 16),
                  _Seccion(
                    titulo: 'Datos del evento',
                    icono: Icons.event_outlined,
                    children: [
                      _SelectorFechaFormField(
                        label: 'Inicio',
                        valor: _inicio,
                        onSeleccionar: () => _seleccionarFecha(conHora: true),
                        conHora: true,
                        validator: (v) =>
                            v == null ? 'Selecciona el inicio' : null,
                      ),
                      const SizedBox(height: 12),
                      _SelectorFechaFormField(
                        label: 'Fin (opcional)',
                        valor: _fin,
                        onSeleccionar: () => _seleccionarFecha(conHora: true),
                        conHora: true,
                        validator: (v) {
                          if (v != null &&
                              _inicio != null &&
                              v.isBefore(_inicio!)) {
                            return 'El fin debe ser posterior al inicio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lugarController,
                        decoration: const InputDecoration(
                          labelText: 'Lugar',
                          prefixIcon: Icon(Icons.place_outlined),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa el lugar'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _enlaceController,
                        decoration: const InputDecoration(
                          labelText: 'Enlace (opcional)',
                          prefixIcon: Icon(Icons.link_outlined),
                        ),
                        validator: (v) {
                          final enlace = v?.trim() ?? '';
                          if (enlace.isEmpty) return null;
                          final uri = Uri.tryParse(enlace);
                          if (uri == null ||
                              (uri.scheme != 'http' && uri.scheme != 'https') ||
                              uri.host.isEmpty) {
                            return 'Usa un enlace http(s) válido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.colors.ugBlue.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.visibility_off_outlined,
                            size: 20,
                            color: context.colors.ugBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Publicar de forma anónima',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tu nombre y avatar se ocultarán en el feed.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: context.colors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _anonimo,
                            activeTrackColor: context.colors.ugBlue,
                            onChanged: (v) => setState(() => _anonimo = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(height: 1, color: context.colors.outlineVariant),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _AvatarPerfil(
                            alias: perfil?.alias ?? 'Usuario',
                            avatarUrl: _anonimo ? null : perfil?.avatarUrl,
                            nivel: nivel,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _anonimo ? 'Anónimo' : (perfil?.alias ?? 'Usuario'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  [
                                    ?programaNombre,
                                    if (sedeNombre != null) 'Sede $sedeNombre',
                                  ].join(' • '),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: context.colors.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.ugOcre.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: context.colors.ugOcre.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '+2 EXP',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF644400),
                                  ),
                                ),
                                Text(
                                  'al publicar',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: context.colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Al publicar aceptas las Normas de Convivencia Uniguajira. '
                      'Tu aporte fortalece el campus digital.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.35,
                        color: context.colors.outline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerLowest,
            border: Border(
              top: BorderSide(color: context.colors.ugBlue.withValues(alpha: 0.12)),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: _BotonPublicar(
              etiqueta: _editando ? 'Guardar cambios' : 'Publicar ahora',
              enviando: _enviando,
              onPressed: _publicar,
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón dorado principal (cabecera y barra inferior).
class _BotonPublicar extends StatelessWidget {
  const _BotonPublicar({
    required this.etiqueta,
    required this.enviando,
    required this.onPressed,
  });

  final String etiqueta;
  final bool enviando;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: enviando ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colors.ugOcre,
        foregroundColor: const Color(0xFF1B1D28),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
      child: enviando
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(etiqueta),
    );
  }
}

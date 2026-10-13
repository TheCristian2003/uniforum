import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/roles.dart';
import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
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
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            bytes,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Material(
            color: Colors.black54,
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
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            url,
            width: 110,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Material(
            color: Colors.black54,
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
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 18, color: AppColors.ugBlue),
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
    if (!_formKey.currentState!.validate()) return;
    final restriccion = ref.read(miRestriccionActivaProvider).value;
    if (restriccion != null && restriccion.vigente) {
      _mostrarError('Tu cuenta está restringida: no puedes publicar.');
      return;
    }
    final canalId = _canalId;
    final tipoId = _tipoId;
    final categoriaId = _categoriaId;
    if (canalId == null || tipoId == null || categoriaId == null) return;

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

    final totalImgs = _existentes.length + _nuevas.length;
    final puedeAnadir = totalImgs < 3;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(_editando ? 'Editar publicación' : 'Nueva publicación'),
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.ugYellow.withValues(alpha: 0.25),
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
                      color: AppColors.ugBlueLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.ugBlue.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppColors.ugBlue,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'No se puede cambiar el canal, tipo ni categoría.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.ugBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _Seccion(
                  titulo: 'Clasificación',
                  icono: Icons.tune,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _canalId,
                      decoration: const InputDecoration(
                        labelText: 'Canal',
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
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _tipoId,
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        prefixIcon: Icon(Icons.category_outlined),
                      ),
                      items: tiposAsync.when(
                        data: (_) => tiposFiltrados
                            .map(
                              (t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.nombre),
                              ),
                            )
                            .toList(),
                        loading: () => [],
                        error: (_, _) => [],
                      ),
                      onChanged: _editando
                          ? null
                          : (v) {
                              setState(() => _tipoId = v);
                              if (tipoSel?.codigo != 'venta') {
                                _disponible = true;
                              }
                            },
                      validator: (v) =>
                          v == null ? 'Selecciona un tipo' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _categoriaId,
                      decoration: const InputDecoration(
                        labelText: 'Categoría',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      items: categoriasAsync.when(
                        data: (cats) => cats
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
                          : (v) => setState(() => _categoriaId = v),
                      validator: (v) =>
                          v == null ? 'Selecciona una categoría' : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Seccion(
                  titulo: 'Tu publicación',
                  icono: Icons.edit_note,
                  children: [
                    TextFormField(
                      controller: _tituloController,
                      decoration: const InputDecoration(
                        labelText: 'Título (opcional)',
                        prefixIcon: Icon(Icons.title_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cuerpoController,
                      minLines: 4,
                      maxLines: 8,
                      decoration: const InputDecoration(
                        labelText: 'Contenido',
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Escribe el contenido de tu publicación'
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Checkbox(
                          value: _anonimo,
                          onChanged: (v) =>
                              setState(() => _anonimo = v ?? false),
                        ),
                        const Expanded(child: Text('Publicar como anónimo')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Seccion(
                  titulo: 'Imágenes (máx. 3)',
                  icono: Icons.photo_library_outlined,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
                          ActionChip(
                            avatar: const Icon(
                              Icons.add_photo_alternate_outlined,
                            ),
                            label: const Text('Añadir imagen'),
                            onPressed: _elegirImagenes,
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
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ingresa un valor'
                            : (double.tryParse(v.replaceAll(',', '.')) == null
                                  ? 'Valor inválido'
                                  : null),
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
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Disponible'),
                          value: _disponible,
                          onChanged: (v) => setState(() => _disponible = v),
                        )
                      else
                        const Text(
                          'El estado se establecerá como disponible al crear la publicación.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
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
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Entregado'),
                        value: _entregado,
                        onChanged: (v) => setState(() => _entregado = v),
                      ),
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
                          if (uri == null || !uri.isAbsolute) {
                            return 'Enlace inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _enviando ? null : _publicar,
                    icon: _enviando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),
                    label: Text(_editando ? 'Guardar cambios' : 'Publicar'),
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

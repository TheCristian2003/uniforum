import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/encabezado_auth.dart';
import '../../../core/widgets/message_card.dart';
import '../../../data/models/catalogo_item.dart';
import '../../../data/models/perfil.dart';

/// Tipos de perfil que un usuario puede elegir por sí mismo. Los tipos
/// administrativos e institucionales se asignan desde backend, no aquí.
const _tiposAutoSeleccionables = {
  'estudiante',
  'docente',
  'egresado',
  'visitante',
};

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  int? _tipoId;
  int? _programaId;
  int? _sedeId;
  bool _guardando = false;
  String? _error;

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate() || _tipoId == null) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(perfilRepositoryProvider).updatePerfil(
            id: widget.perfil.id,
            alias: _aliasController.text,
            tipoPerfilId: _tipoId!,
            programaId: _programaId,
            sedeId: _sedeId,
          );
      ref.invalidate(perfilActualProvider);
    } catch (error) {
      setState(() {
        _guardando = false;
        _error = _traducirError(error);
      });
    }
  }

  String _traducirError(Object error) {
    final text = error.toString().toLowerCase();
    if (text.contains('duplicate') || text.contains('alias')) {
      return 'Ese alias ya está en uso. Elige otro.';
    }
    if (text.contains('char_length') || text.contains('alias_no_vacio')) {
      return 'El alias debe tener entre 3 y 50 caracteres.';
    }
    return 'No se pudo guardar tu perfil. Intenta de nuevo.';
  }

  @override
  Widget build(BuildContext context) {
    final tipos = ref.watch(catalogoProvider('tipo_perfil'));
    final programas = ref.watch(catalogoProvider('programa'));
    final sedes = ref.watch(catalogoProvider('sede'));

    final cargando = tipos.isLoading || programas.isLoading || sedes.isLoading;
    final errorCarga = tipos.hasError || programas.hasError || sedes.hasError;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          const EncabezadoAuth(
            titulo: 'Completa tu perfil',
            subtitulo: 'Cuéntanos sobre ti y tu vínculo con la universidad.',
            icono: Icons.person_outline_rounded,
          ),
          Expanded(
            child: _cuerpo(cargando, errorCarga, tipos.value ?? [],
                programas.value ?? [], sedes.value ?? []),
          ),
        ],
      ),
    );
  }

  Widget _cuerpo(
    bool cargando,
    bool errorCarga,
    List<CatalogoItem> tipos,
    List<CatalogoItem> programas,
    List<CatalogoItem> sedes,
  ) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorCarga) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: MessageCard(
            texto:
                'No se pudieron cargar los catálogos. Revisa tu conexión e intenta de nuevo.',
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Elige tu alias y perfil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _aliasController,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Alias',
                      prefixIcon: Icon(Icons.alternate_email),
                      helperText: 'Entre 3 y 50 caracteres',
                    ),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3) {
                        return 'El alias debe tener al menos 3 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  _DropdownCatalogo(
                    label: 'Tipo de perfil',
                    icono: Icons.badge_outlined,
                    items: _filtrarTipos(tipos),
                    valor: _tipoId,
                    onChanged: (value) => setState(() => _tipoId = value),
                    validator: (value) => value == null
                        ? 'Selecciona tu tipo de perfil'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _DropdownCatalogo(
                    label: 'Programa (opcional)',
                    icono: Icons.school_outlined,
                    items: programas,
                    valor: _programaId,
                    opcional: true,
                    onChanged: (value) => setState(() => _programaId = value),
                  ),
                  const SizedBox(height: 12),
                  _DropdownCatalogo(
                    label: 'Sede (opcional)',
                    icono: Icons.location_on_outlined,
                    items: sedes,
                    valor: _sedeId,
                    opcional: true,
                    onChanged: (value) => setState(() => _sedeId = value),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    MessageCard(texto: _error!),
                  ],
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _guardando ? null : _guardar,
                    child: _guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Guardar y continuar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<CatalogoItem> _filtrarTipos(List<CatalogoItem> items) {
    return items
        .where((item) => _tiposAutoSeleccionables.contains(item.codigo))
        .toList();
  }
}

class _DropdownCatalogo extends StatelessWidget {
  const _DropdownCatalogo({
    required this.label,
    required this.icono,
    required this.items,
    required this.valor,
    required this.onChanged,
    this.validator,
    this.opcional = false,
  });

  final String label;
  final IconData icono;
  final List<CatalogoItem> items;
  final int? valor;
  final ValueChanged<int?> onChanged;
  final FormFieldValidator<int?>? validator;

  /// Cuando es `true`, agrega una opción para dejar el campo sin asignar.
  final bool opcional;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: valor,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
      ),
      items: [
        if (opcional)
          const DropdownMenuItem<int>(
            value: null,
            child: Text(
              'Ninguna',
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ),
        ...items.map(
          (item) => DropdownMenuItem<int>(
            value: item.id,
            child: Text(item.nombre, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
      onChanged: onChanged,
      validator: validator,
    );
  }
}

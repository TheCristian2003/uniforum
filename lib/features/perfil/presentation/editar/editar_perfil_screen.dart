import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/gamification/niveles.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/auth_widgets.dart';
import '../../../../data/models/catalogo_item.dart';
import '../../../../data/models/perfil.dart';

/// Pantalla para editar el perfil propio.
///
/// Recrea el diseño de Stitch (tarjeta de identidad, datos del perfil y bio) y
/// guarda los cambios con [PerfilRepository.updatePerfil]. La foto de perfil se
/// sube a Supabase Storage con [ImagenesRepository.subirAdjunto] y se persiste
/// con [PerfilRepository.updateAvatar]. Los campos sin respaldo en el modelo
/// (semestre, intereses, distintivo destacado y enlaces sociales) se omiten.
class EditarPerfilScreen extends ConsumerStatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  ConsumerState<EditarPerfilScreen> createState() =>
      _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends ConsumerState<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _bioController = TextEditingController();
  final _celularController = TextEditingController();
  final _fechaController = TextEditingController();
  int? _programaId;
  int? _sedeId;
  DateTime? _fechaNacimiento;
  bool _inicializado = false;
  bool _guardando = false;
  bool _subiendoFoto = false;
  String? _error;

  @override
  void dispose() {
    _aliasController.dispose();
    _bioController.dispose();
    _celularController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  void _cargarDesde(Perfil perfil) {
    if (_inicializado) return;
    _aliasController.text = perfil.alias;
    _bioController.text = perfil.biografia ?? '';
    _celularController.text = perfil.celular ?? '';
    _fechaNacimiento = perfil.fechaNacimiento;
    _fechaController.text = _formatoFecha(perfil.fechaNacimiento);
    _programaId = perfil.programaId;
    _sedeId = perfil.sedeId;
    _inicializado = true;
  }

  void _descartar(Perfil perfil) {
    FocusScope.of(context).unfocus();
    setState(() {
      _aliasController.text = perfil.alias;
      _bioController.text = perfil.biografia ?? '';
      _celularController.text = perfil.celular ?? '';
      _fechaNacimiento = perfil.fechaNacimiento;
      _fechaController.text = _formatoFecha(perfil.fechaNacimiento);
      _programaId = perfil.programaId;
      _sedeId = perfil.sedeId;
      _error = null;
    });
  }

  String _formatoFecha(DateTime? fecha) {
    if (fecha == null) return '';
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    return '$dia/$mes/${fecha.year}';
  }

  Future<void> _seleccionarFecha() async {
    FocusScope.of(context).unfocus();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Fecha de nacimiento',
    );
    if (elegida == null || !mounted) return;
    setState(() {
      _fechaNacimiento = elegida;
      _fechaController.text = _formatoFecha(elegida);
    });
  }

  Future<void> _cambiarFoto(Perfil perfil) async {
    final archivo = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (archivo == null || !mounted) return;

    final bytes = await archivo.readAsBytes();
    const maxBytes = 5 * 1024 * 1024;
    if (bytes.length > maxBytes) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La imagen supera los 5 MB. Elige una más liviana.'),
        ),
      );
      return;
    }

    setState(() => _subiendoFoto = true);
    try {
      final url = await ref.read(imagenesRepositoryProvider).subirAdjunto(
            usuarioId: perfil.id,
            bytes: bytes,
            extension: archivo.path.split('.').last,
          );
      await ref.read(perfilRepositoryProvider).updateAvatar(
            id: perfil.id,
            avatarUrl: url,
          );
      ref.invalidate(perfilActualProvider);
      if (!mounted) return;
      setState(() => _subiendoFoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto de perfil actualizada.')),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _subiendoFoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo subir la foto. Intenta de nuevo.'),
        ),
      );
    }
  }

  Future<void> _guardar(Perfil perfil) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref.read(perfilRepositoryProvider).updatePerfil(
            id: perfil.id,
            alias: _aliasController.text,
            tipoPerfilId: perfil.tipoPerfilId,
            programaId: _programaId,
            sedeId: _sedeId,
            biografia: _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
            celular: _celularController.text,
            fechaNacimiento: _fechaNacimiento,
          );
      ref.invalidate(perfilActualProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error =
            'No se pudo guardar. Revisa tu conexión e intenta de nuevo. Si el alias ya está en uso, elige otro.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilActualProvider);
    final perfil = perfilAsync.value;
    if (perfil != null) _cargarDesde(perfil);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _appBar(),
      body: perfil == null
          ? _cargando(perfilAsync.isLoading)
          : _formulario(perfil),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      backgroundColor: AppColors.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      shape: Border(
        bottom: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      leadingWidth: 56,
      leading: Center(
        child: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
          color: AppColors.onSurface,
          tooltip: 'Volver',
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceContainer,
          ),
        ),
      ),
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Editar Perfil',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 1),
          Text(
            'Campus ID',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cargando(bool cargando) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 40,
              color: AppColors.outline,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudo cargar tu perfil. Intenta de nuevo más tarde.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formulario(Perfil perfil) {
    final nivel = nivelDesdePuntos(perfil.puntos);
    final programas = ref.watch(catalogoProvider('programa')).value ?? const [];
    final sedes = ref.watch(catalogoProvider('sede')).value ?? const [];
    final cargandoCatalogos =
        ref.watch(catalogoProvider('programa')).isLoading ||
            ref.watch(catalogoProvider('sede')).isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TarjetaAvatar(
              perfil: perfil,
              nivel: nivel,
              aliasListenable: _aliasController,
              subiendo: _subiendoFoto,
              onCambiarFoto: () => _cambiarFoto(perfil),
            ),
            const SizedBox(height: 20),
            _DatosPerfil(
              cargando: cargandoCatalogos,
              aliasController: _aliasController,
              celularController: _celularController,
              fechaController: _fechaController,
              programas: programas,
              sedes: sedes,
              programaId: _programaId,
              sedeId: _sedeId,
              onPrograma: (v) => setState(() => _programaId = v),
              onSede: (v) => setState(() => _sedeId = v),
              onFecha: _seleccionarFecha,
            ),
            const SizedBox(height: 20),
            _Biografia(bioController: _bioController),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _MensajeError(texto: _error!),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardando ? null : () => _guardar(perfil),
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF3A2A00),
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 20),
              label: Text(_guardando ? 'Guardando...' : 'Guardar cambios'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ugOcre,
                foregroundColor: const Color(0xFF3A2A00),
                disabledBackgroundColor:
                    AppColors.ugOcre.withValues(alpha: 0.5),
                disabledForegroundColor:
                    const Color(0xFF3A2A00).withValues(alpha: 0.6),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _guardando ? null : () => _descartar(perfil),
              icon: const Icon(Icons.restart_alt, size: 20),
              label: const Text('Descartar cambios no guardados'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ugRed,
                side: const BorderSide(color: AppColors.ugRed),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.security, size: 16, color: AppColors.ugBlue),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Tu información se usa solo dentro de la comunidad y bajo la '
                    'política de privacidad de la Universidad de La Guajira.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.outline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaAvatar extends StatelessWidget {
  const _TarjetaAvatar({
    required this.perfil,
    required this.nivel,
    required this.aliasListenable,
    required this.subiendo,
    required this.onCambiarFoto,
  });

  final Perfil perfil;
  final Nivel nivel;
  final TextEditingController aliasListenable;
  final bool subiendo;
  final VoidCallback onCambiarFoto;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = perfil.avatarUrl;
    final tieneAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.outline.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
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
              bottom: -50,
              left: -50,
              child: _orbe(150, AppColors.ugFlamenco.withValues(alpha: 0.12)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 128,
                    height: 120,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: 112,
                          height: 112,
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.ugOcre,
                                AppColors.ugFlamenco,
                                AppColors.ugBlue,
                              ],
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.surfaceContainerLowest,
                              border: Border.all(
                                color: AppColors.surfaceContainerLowest,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: SizedBox.expand(
                                child: tieneAvatar
                                    ? Image.network(
                                        avatarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            _inicial(perfil.alias),
                                      )
                                    : ValueListenableBuilder<
                                        TextEditingValue>(
                                        valueListenable: aliasListenable,
                                        builder: (_, value, _) =>
                                            _inicial(value.text),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Material(
                            color: AppColors.ugFlamenco,
                            shape: CircleBorder(
                              side: BorderSide(
                                color: AppColors.surfaceContainerLowest,
                                width: 2,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: subiendo ? null : onCambiarFoto,
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: subiendo
                                    ? const Padding(
                                        padding: EdgeInsets.all(9),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.photo_camera,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: AppColors.ugOcre.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department,
                                  size: 13,
                                  color: AppColors.ugYellowDark,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Nivel ${nivel.numero} • ${nivel.nombre}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ugYellowDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: aliasListenable,
                    builder: (_, value, _) => SizedBox(
                      width: double.infinity,
                      child: Text(
                        value.text.trim().isEmpty ? perfil.alias : value.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID Universitario: #UG-${_idCorto(perfil.id)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: AppColors.ugBlue,
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

  Widget _inicial(String alias) {
    final letra = alias.trim().isNotEmpty
        ? alias.trim()[0].toUpperCase()
        : '?';
    return Container(
      color: AppColors.ugBlueLight,
      alignment: Alignment.center,
      child: Text(
        letra,
        style: const TextStyle(
          fontSize: 40,
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

String _idCorto(String id) {
  final limpio = id.replaceAll('-', '').toUpperCase();
  return limpio.length >= 8 ? limpio.substring(0, 8) : limpio;
}

class _DatosPerfil extends StatelessWidget {
  const _DatosPerfil({
    required this.cargando,
    required this.aliasController,
    required this.celularController,
    required this.fechaController,
    required this.programas,
    required this.sedes,
    required this.programaId,
    required this.sedeId,
    required this.onPrograma,
    required this.onSede,
    required this.onFecha,
  });

  final bool cargando;
  final TextEditingController aliasController;
  final TextEditingController celularController;
  final TextEditingController fechaController;
  final List<CatalogoItem> programas;
  final List<CatalogoItem> sedes;
  final int? programaId;
  final int? sedeId;
  final ValueChanged<int?> onPrograma;
  final ValueChanged<int?> onSede;
  final VoidCallback onFecha;

  @override
  Widget build(BuildContext context) {
    return _TarjetaSeccion(
      icono: Icons.badge_outlined,
      color: AppColors.ugBlue,
      titulo: 'Datos del perfil',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CampoAuth(
            label: 'Alias en el campus',
            requerido: true,
            icono: Icons.alternate_email,
            controller: aliasController,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.length < 3) {
                return 'Tu alias debe tener al menos 3 caracteres';
              }
              if (text.length > 50) return 'Máximo 50 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            CampoAuthDropdown(
              label: 'Programa académico',
              icono: Icons.menu_book_outlined,
              placeholder: 'Selecciona tu programa',
              valor: programaId,
              items: programas
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.nombre, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onPrograma,
            ),
            const SizedBox(height: 16),
            CampoAuthDropdown(
              label: 'Sede principal',
              icono: Icons.location_on_outlined,
              placeholder: 'Selecciona tu sede',
              valor: sedeId,
              items: sedes
                  .map(
                    (item) => DropdownMenuItem<int>(
                      value: item.id,
                      child: Text(item.nombre, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: onSede,
            ),
          ],
          const SizedBox(height: 16),
          CampoAuth(
            label: 'Número de celular',
            icono: Icons.phone_iphone,
            hint: 'Ej. 3001234567',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: celularController,
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return null;
              if (text.length < 7 || text.length > 15) {
                return 'Ingresa un número válido (7 a 15 dígitos)';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CampoAuth(
            label: 'Fecha de nacimiento',
            icono: Icons.cake_outlined,
            hint: 'Selecciona tu fecha',
            readOnly: true,
            onTap: onFecha,
            controller: fechaController,
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
        ],
      ),
    );
  }
}

class _Biografia extends StatelessWidget {
  const _Biografia({required this.bioController});

  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return _TarjetaSeccion(
      icono: Icons.psychology,
      color: AppColors.ugOcre,
      titulo: 'Biografía & Vibra',
      trailing: ValueListenableBuilder<TextEditingValue>(
        valueListenable: bioController,
        builder: (_, value, _) => Text(
          '${value.text.runes.length} / 250',
          style: const TextStyle(fontSize: 11, color: AppColors.outline),
        ),
      ),
      child: TextFormField(
        controller: bioController,
        maxLines: 3,
        maxLength: 250,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'Cuéntale al campus sobre ti...',
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF8D91A5),
          ),
          counterText: '',
          filled: true,
          fillColor: AppColors.surfaceContainerLow,
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.ugBlue, width: 2),
          ),
        ),
      ),
    );
  }
}

class _TarjetaSeccion extends StatelessWidget {
  const _TarjetaSeccion({
    required this.icono,
    required this.color,
    required this.titulo,
    required this.child,
    this.trailing,
  });

  final IconData icono;
  final Color color;
  final String titulo;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.outline.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icono, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _MensajeError extends StatelessWidget {
  const _MensajeError({required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.ugRedLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.ugRed.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 20, color: AppColors.ugRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.ugRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

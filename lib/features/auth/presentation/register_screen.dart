import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/auth_widgets.dart';
import '../../../core/widgets/message_card.dart';
import '../../../data/models/catalogo_item.dart';
import 'auth_controller.dart';

/// Tipos de perfil que un usuario puede elegir por sí mismo. Los tipos
/// administrativos e institucionales se asignan desde backend, no aquí.
const _tiposAutoSeleccionables = {
  'estudiante',
  'docente',
  'egresado',
  'visitante',
};

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  int? _tipoId;
  int? _programaId;
  int? _sedeId;
  bool _obscure = true;
  bool _acepta = false;
  bool _confirmado = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final sessionActive =
        await ref.read(authControllerProvider.notifier).signUp(
              email: _emailController.text,
              password: _passwordController.text,
              alias: _nombreController.text,
              tipoPerfilId: _tipoId!,
              programaId: _programaId,
              sedeId: _sedeId,
            );
    if (!mounted) return;
    if (sessionActive) {
      // La sesión ya está activa: volvemos a la raíz para que el AuthGate
      // decida la siguiente pantalla.
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    final message = ref.read(authControllerProvider).message;
    if (message != null) {
      setState(() => _confirmado = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final tipos = ref.watch(catalogoProvider('tipo_perfil'));
    final programas = ref.watch(catalogoProvider('programa'));
    final sedes = ref.watch(catalogoProvider('sede'));

    final cargando = tipos.isLoading || programas.isLoading || sedes.isLoading;
    final errorCarga = tipos.hasError || programas.hasError || sedes.hasError;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: FondoAuth(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    _BotonCircular(
                      icono: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    const _PillInstitucional(),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const MarcaCampus(badgeDorado: true),
                          const SizedBox(height: 18),
                          const Text(
                            'Crear cuenta',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Únete a la comunidad universitaria',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 18),
                          _TarjetaRegistro(
                            formKey: _formKey,
                            authState: authState,
                            nombreController: _nombreController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmController: _confirmController,
                            cargando: cargando,
                            errorCarga: errorCarga,
                            tipos: _filtrarTipos(tipos.value ?? []),
                            programas: programas.value ?? [],
                            sedes: sedes.value ?? [],
                            tipoId: _tipoId,
                            programaId: _programaId,
                            sedeId: _sedeId,
                            obscure: _obscure,
                            acepta: _acepta,
                            confirmado: _confirmado,
                            onTipo: (value) => setState(() => _tipoId = value),
                            onPrograma: (value) =>
                                setState(() => _programaId = value),
                            onSede: (value) => setState(() => _sedeId = value),
                            onToggleObscure: () =>
                                setState(() => _obscure = !_obscure),
                            onAcepta: (value) =>
                                setState(() => _acepta = value),
                            onSalir: () => Navigator.of(context).pop(),
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'UNIVERSIDAD DE LA GUAJIRA · ACREDITACIÓN INSTITUCIONAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF9A9689),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

class _TarjetaRegistro extends StatelessWidget {
  const _TarjetaRegistro({
    required this.formKey,
    required this.authState,
    required this.nombreController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.cargando,
    required this.errorCarga,
    required this.tipos,
    required this.programas,
    required this.sedes,
    required this.tipoId,
    required this.programaId,
    required this.sedeId,
    required this.obscure,
    required this.acepta,
    required this.confirmado,
    required this.onTipo,
    required this.onPrograma,
    required this.onSede,
    required this.onToggleObscure,
    required this.onAcepta,
    required this.onSalir,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final AuthFormState authState;
  final TextEditingController nombreController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool cargando;
  final bool errorCarga;
  final List<CatalogoItem> tipos;
  final List<CatalogoItem> programas;
  final List<CatalogoItem> sedes;
  final int? tipoId;
  final int? programaId;
  final int? sedeId;
  final bool obscure;
  final bool acepta;
  final bool confirmado;
  final ValueChanged<int?> onTipo;
  final ValueChanged<int?> onPrograma;
  final ValueChanged<int?> onSede;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool> onAcepta;
  final VoidCallback onSalir;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: _contenido(context),
    );
  }

  Widget _contenido(BuildContext context) {
    if (cargando) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorCarga) {
      return MessageCard(
        texto:
            'No se pudieron cargar los catálogos. Revisa tu conexión e intenta de nuevo.',
      );
    }
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CampoAuth(
            label: 'Nombre completo',
            requerido: true,
            icono: Icons.person_outline_rounded,
            hint: 'Ej. Waymar Pushaina Epieyu',
            controller: nombreController,
            autofillHints: const [AutofillHints.name],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.length < 3) {
                return 'Escribe tu nombre (mínimo 3 caracteres)';
              }
              if (text.length > 50) {
                return 'Máximo 50 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CampoAuth(
            label: 'Correo',
            requerido: true,
            icono: Icons.mail_outline_rounded,
            hint: 'ejemplo@correo.com',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (value) {
              final text = value?.trim() ?? '';
              if (text.isEmpty) return 'Ingresa tu correo';
              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!emailRegex.hasMatch(text)) return 'Correo no válido';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CampoAuthDropdown(
            label: 'Tipo de perfil',
            requerido: true,
            icono: Icons.badge_outlined,
            placeholder: 'Selecciona tu tipo de perfil',
            valor: tipoId,
            items: tipos
                .map(
                  (item) => DropdownMenuItem<int>(
                    value: item.id,
                    child: Text(item.nombre, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: onTipo,
            validator: (value) =>
                value == null ? 'Selecciona tu tipo de perfil' : null,
          ),
          const SizedBox(height: 14),
          CampoAuthDropdown(
            label: 'Facultad / Programa',
            icono: Icons.school_outlined,
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
          const SizedBox(height: 14),
          CampoAuthDropdown(
            label: 'Sede',
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
          const SizedBox(height: 14),
          CampoAuth(
            label: 'Contraseña',
            requerido: true,
            icono: Icons.lock_outline_rounded,
            hint: 'Mínimo 6 caracteres',
            controller: passwordController,
            obscureText: obscure,
            autofillHints: const [AutofillHints.newPassword],
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa una contraseña';
              }
              if (value.length < 6) {
                return 'Debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          CampoAuth(
            label: 'Confirmar contraseña',
            requerido: true,
            icono: Icons.lock_reset_rounded,
            hint: 'Repite tu contraseña',
            controller: confirmController,
            obscureText: obscure,
            validator: (value) => value != passwordController.text
                ? 'Las contraseñas no coinciden'
                : null,
          ),
          const SizedBox(height: 16),
          FormField<bool>(
            initialValue: acepta,
            validator: (value) => (value ?? false)
                ? null
                : 'Debes aceptar los términos y la política de datos',
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: acepta,
                          onChanged: (value) {
                            onAcepta(value ?? false);
                            state.didChange(value ?? false);
                          },
                          activeColor: AppColors.ugBlue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Acepto los Términos de Servicio y la Política de '
                          'Tratamiento de Datos de la Universidad de La Guajira.',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.35,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.hasError) ...[
                    const SizedBox(height: 4),
                    Text(
                      state.errorText!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.ugRed,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (authState.status == AuthStatus.error &&
              authState.message != null) ...[
            const SizedBox(height: 14),
            MessageCard(texto: authState.message!),
          ],
          if (confirmado) ...[
            const SizedBox(height: 14),
            const MessageCard(
              texto:
                  'Cuenta creada. Confirma tu correo antes de iniciar sesión.',
              tipo: MessageCardTipo.info,
            ),
          ],
          const SizedBox(height: 20),
          BotonAuth(
            texto: 'Crear cuenta',
            cargando: authState.isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Ya tienes una cuenta?',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              TextButton(
                onPressed: authState.isLoading ? null : onSalir,
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ugRed,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonCircular extends StatelessWidget {
  const _BotonCircular({required this.icono, required this.onTap});

  final IconData icono;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceContainerLowest,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icono, size: 22, color: AppColors.onSurface),
        ),
      ),
    );
  }
}

class _PillInstitucional extends StatelessWidget {
  const _PillInstitucional();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ugRed,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'Portal Campus',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: AppColors.ugBlue,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.ugRedLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'NUEVO',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: AppColors.ugRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

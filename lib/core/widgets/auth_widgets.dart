import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

/// Fondo cálido y difuminado reutilizable para las pantallas de autenticación.
class FondoAuth extends StatelessWidget {
  const FondoAuth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDF0), Color(0xFFFCFAF2), Color(0xFFFBFBF9)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _Orbe(
              tamano: 240,
              color: AppColors.ugOcre.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 320,
            left: -80,
            child: _Orbe(
              tamano: 200,
              color: AppColors.ugBlue.withValues(alpha: 0.10),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Orbe extends StatelessWidget {
  const _Orbe({required this.tamano, required this.color});

  final double tamano;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: tamano,
        height: tamano,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

/// Marca institucional compartida por login y registro.
///
/// Evita fijar el nombre comercial (pendiente) y usa un identificador neutro.
class MarcaCampus extends StatelessWidget {
  const MarcaCampus({super.key, this.badgeDorado = false});

  /// En registro la insignia tiene fondo dorado degradado.
  final bool badgeDorado;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _InsigniaCampus(dorado: badgeDorado),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Campus',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppColors.ugBlue,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.ugRed,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.ugBlueLight,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.ugRed.withValues(alpha: 0.25),
                ),
              ),
              child: const Text(
                'UNIVERSIDAD',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: AppColors.ugBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        const Text(
          'Universidad de La Guajira',
          style: TextStyle(fontSize: 12.5, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _InsigniaCampus extends StatelessWidget {
  const _InsigniaCampus({required this.dorado});

  final bool dorado;

  @override
  Widget build(BuildContext context) {
    final lado = dorado ? 64.0 : 56.0;
    return SizedBox(
      width: lado + 8,
      height: lado + 8,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: lado,
            height: lado,
            decoration: BoxDecoration(
              color: dorado ? null : AppColors.surfaceContainerLowest,
              gradient: dorado
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF2AE1C),
                        Color(0xFFF7C044),
                        Color(0xFFFDE047),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(dorado ? 20 : 18),
              border: Border.all(
                color: dorado ? Colors.white : AppColors.outlineVariant,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ugOcre.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.wb_sunny_rounded,
                size: lado * 0.55,
                color: dorado ? Colors.white : AppColors.ugOcre,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: dorado
                    ? AppColors.ugBlue
                    : AppColors.surfaceContainerLowest,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                Icons.school_rounded,
                size: 12,
                color: dorado ? Colors.white : AppColors.ugRed,
              ),
            ),
          ),
          if (dorado)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ugRed,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Campo de formulario con etiqueta superior, ícono y estilo de las pantallas
/// de autenticación.
class CampoAuth extends StatelessWidget {
  const CampoAuth({
    super.key,
    required this.label,
    required this.icono,
    this.controller,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.autofillHints,
    this.suffixIcon,
    this.validator,
    this.requerido = false,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final IconData icono;
  final TextEditingController? controller;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool requerido;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (requerido) ...[
              const SizedBox(width: 3),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ugRed,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          autofillHints: autofillHints,
          validator: validator,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8D91A5)),
            prefixIcon: Icon(icono, size: 20),
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: borde,
            enabledBorder: borde,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.ugBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.ugRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.ugRed, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// Selector de catálogo con la misma presentación que [CampoAuth].
class CampoAuthDropdown extends StatelessWidget {
  const CampoAuthDropdown({
    super.key,
    required this.label,
    required this.icono,
    required this.valor,
    required this.onChanged,
    required this.items,
    this.validator,
    this.requerido = false,
    this.placeholder = 'Selecciona una opción',
  });

  final String label;
  final IconData icono;
  final int? valor;
  final ValueChanged<int?> onChanged;
  final List<DropdownMenuItem<int>> items;
  final FormFieldValidator<int?>? validator;
  final bool requerido;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (requerido) ...[
              const SizedBox(width: 3),
              const Text(
                '*',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ugRed,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: valor,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded),
          hint: Text(
            placeholder,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8D91A5)),
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icono, size: 20),
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: borde,
            enabledBorder: borde,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.ugBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.ugRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.ugRed, width: 2),
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}

/// Botón principal dorado de las pantallas de autenticación.
class BotonAuth extends StatelessWidget {
  const BotonAuth({
    super.key,
    required this.texto,
    required this.onPressed,
    this.cargando = false,
  });

  final String texto;
  final VoidCallback? onPressed;
  final bool cargando;

  static const Color _textoSobreDorado = Color(0xFF3A2A00);

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: cargando ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.ugOcre,
        foregroundColor: _textoSobreDorado,
        disabledBackgroundColor: AppColors.ugOcre.withValues(alpha: 0.5),
        disabledForegroundColor: _textoSobreDorado.withValues(alpha: 0.6),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
      child: cargando
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: _textoSobreDorado,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(texto),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
    );
  }
}

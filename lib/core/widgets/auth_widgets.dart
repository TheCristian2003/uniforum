import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_palette.dart';

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
              color: context.colors.ugOcre.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            top: 320,
            left: -80,
            child: _Orbe(
              tamano: 200,
              color: context.colors.ugBlue.withValues(alpha: 0.10),
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

/// Marca Vybe compartida por login y registro.
class MarcaCampus extends StatelessWidget {
  const MarcaCampus({super.key, this.badgeDorado = false});

  /// No usado con el nuevo logo; se mantiene por compatibilidad API.
  @Deprecated('No usado con branding Vybe')
  final bool badgeDorado;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/branding/vybe_logo.png',
          height: 64,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 3),
        Text(
          'Universidad de La Guajira',
          style: TextStyle(fontSize: 12.5, color: context.colors.onSurfaceVariant),
        ),
      ],
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
      borderSide: BorderSide(color: context.colors.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
            if (requerido) ...[
              const SizedBox(width: 3),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: context.colors.ugRed,
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
              borderSide: BorderSide(color: context.colors.ugBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.ugRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.ugRed, width: 2),
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
    this.onClear,
  });

  final String label;
  final IconData icono;
  final int? valor;
  final ValueChanged<int?> onChanged;
  final List<DropdownMenuItem<int>> items;
  final FormFieldValidator<int?>? validator;
  final bool requerido;
  final String placeholder;

  /// Si se define, muestra un botón para volver a dejar el campo vacío.
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.colors.outlineVariant),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colors.onSurface,
              ),
            ),
            if (requerido) ...[
              const SizedBox(width: 3),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: context.colors.ugRed,
                ),
              ),
            ],
            if (onClear != null && valor != null) ...[
              const Spacer(),
              InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: context.colors.onSurfaceVariant,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Limpiar',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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
            fillColor: context.colors.surfaceContainerLowest,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: borde,
            enabledBorder: borde,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.ugBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.ugRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: context.colors.ugRed, width: 2),
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
        backgroundColor: context.colors.ugOcre,
        foregroundColor: _textoSobreDorado,
        disabledBackgroundColor: context.colors.ugOcre.withValues(alpha: 0.5),
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

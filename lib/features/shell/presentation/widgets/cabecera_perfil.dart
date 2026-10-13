import 'package:flutter/material.dart';

import '../../../../core/gamification/niveles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/perfil.dart';

/// Cabecera de perfil que se muestra en la barra superior de las pestañas
/// (Inicio, Canales): avatar con nivel, alias y nivel/puntos.
class CabeceraPerfil extends StatelessWidget {
  const CabeceraPerfil({super.key, required this.perfil, this.saludo = true});

  final Perfil perfil;

  /// Si es `true` antepone "¡Hola, " al alias (usado en Inicio).
  final bool saludo;

  @override
  Widget build(BuildContext context) {
    final nivel = nivelDesdePuntos(perfil.puntos);

    return Row(
      children: [
        AvatarNivel(perfil: perfil),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      saludo ? '¡Hola, ${perfil.alias}!' : perfil.alias,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                  if (perfil.esVerificada) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 15,
                      color: AppColors.ugBlue,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 13,
                    color: AppColors.ugBlue,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${nivel.nombre} · ${perfil.puntos} pts',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Avatar circular con insignia de nivel superpuesta.
class AvatarNivel extends StatelessWidget {
  const AvatarNivel({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = perfil.avatarUrl;
    final tieneAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    final inicial =
        perfil.alias.isNotEmpty ? perfil.alias[0].toUpperCase() : '?';
    final numero = nivelDesdePuntos(perfil.puntos).numero;

    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ugBlueLight,
              border: Border.all(color: AppColors.ugYellow, width: 2),
            ),
            child: tieneAvatar
                ? Image.network(
                    avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _inicial(inicial),
                  )
                : _inicial(inicial),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.ugRed,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: AppColors.surfaceContainerLowest,
                  width: 1.5,
                ),
              ),
              child: Text(
                'Nv. $numero',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inicial(String inicial) {
    return Center(
      child: Text(
        inicial,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.ugBlue,
        ),
      ),
    );
  }
}

/// Botón circular de la cabecera (búsqueda, filtros, notificaciones) con
/// badge opcional.
class BotonCabecera extends StatelessWidget {
  const BotonCabecera({
    super.key,
    required this.icono,
    required this.onTap,
    this.badge,
  });

  final IconData icono;
  final VoidCallback onTap;
  final String? badge;

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
          width: 38,
          height: 38,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icono, size: 20, color: AppColors.onSurfaceVariant),
              if (badge != null)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.ugRed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceContainerLowest,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
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
}

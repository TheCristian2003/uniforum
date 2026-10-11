import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/perfil.dart';
import '../../auth/presentation/auth_controller.dart';

/// Pantalla de inicio provisional. La navegación Inicio/Canales/IA/Perfil y el
/// feed se implementan en la siguiente etapa.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, required this.perfil});

  final Perfil perfil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nivel = _nivelDe(perfil.puntos);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.ugBlueLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        perfil.alias.isNotEmpty
                            ? perfil.alias[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ugBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  perfil.alias,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              if (perfil.esVerificada) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    size: 18, color: AppColors.ugBlue),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$nivel · ${perfil.puntos} pts',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: const [
                    Icon(Icons.auto_awesome, size: 40,
                        color: AppColors.ugYellow),
                    SizedBox(height: 12),
                    Text(
                      'El feed llegará pronto',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Canales, publicaciones, comentarios y la IA del Campus se implementan en las siguientes etapas.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _nivelDe(int puntos) {
    if (puntos >= 400) return 'Leyenda';
    if (puntos >= 150) return 'Referente';
    if (puntos >= 50) return 'Activo';
    return 'Novato';
  }
}

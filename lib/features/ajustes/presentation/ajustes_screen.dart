import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../perfil/presentation/editar/editar_perfil_screen.dart';

class AjustesScreen extends StatelessWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Seccion(
            titulo: 'Cuenta',
            items: [
              _Opcion(
                icono: Icons.person_outline,
                titulo: 'Editar perfil',
                subtitulo: 'Actualiza tu información',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditarPerfilScreen(),
                  ),
                ),
              ),
              const _Opcion(
                icono: Icons.lock_outline,
                titulo: 'Seguridad',
                subtitulo: 'Contraseña y sesiones',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Seccion(
            titulo: 'Preferencias',
            items: [
              _Opcion(
                icono: Icons.dark_mode_outlined,
                titulo: 'Tema',
                subtitulo: 'Claro / Oscuro',
              ),
              _Opcion(
                icono: Icons.notifications_outlined,
                titulo: 'Notificaciones',
                subtitulo: 'Gestionar alertas',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _Seccion(
            titulo: 'Acerca de',
            items: [
              _Opcion(
                icono: Icons.info_outline,
                titulo: 'Versión',
                subtitulo: '1.0.0',
              ),
              _Opcion(
                icono: Icons.help_outline,
                titulo: 'Ayuda y soporte',
                subtitulo: 'Preguntas frecuentes',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  const _Seccion({required this.titulo, required this.items});

  final String titulo;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ugAzulMar,
            ),
          ),
        ),
        Card(
          child: Column(
            children: ListTile.divideTiles(
              context: context,
              tiles: items,
            ).toList(),
          ),
        ),
      ],
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.ugAmarilloDesiertoLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icono, color: AppColors.ugAmarilloDesierto),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitulo),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
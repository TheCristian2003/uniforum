import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _nombreController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _aliasController.dispose();
    _nombreController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.ugBlueLight,
                    child: Text(
                      _aliasController.text.isNotEmpty
                          ? _aliasController.text[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ugAzulMar,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.ugAmarilloDesierto,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _aliasController,
                decoration: const InputDecoration(
                  labelText: 'Alias',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Biografía',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

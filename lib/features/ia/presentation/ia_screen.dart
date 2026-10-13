import 'package:flutter/material.dart';

import '../../../core/widgets/estado_view.dart';

/// Pestaña de la IA del Campus. La integración con la Edge Function se
/// implementa en la etapa de IA.
class IaScreen extends StatelessWidget {
  const IaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IA del Campus')),
      body: const EmptyView(
        icono: Icons.auto_awesome,
        titulo: 'IA del Campus en camino',
        mensaje:
            'Podrás preguntar por el contenido del campus y resumir lo que te perdiste.',
      ),
    );
  }
}

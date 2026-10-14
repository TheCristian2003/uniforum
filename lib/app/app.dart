import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/message_card.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/shell/presentation/main_shell.dart';

/// Raíz de la aplicación.
///
/// El nombre comercial sigue pendiente; el título usa un texto genérico.
class App extends StatelessWidget {
  const App({super.key, this.configured = true});

  final bool configured;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plataforma Social Universitaria',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: configured ? const _AuthGate() : const _ConfigMissingScreen(),
    );
  }
}

/// Decide qué pantalla mostrar según la sesión y el estado del perfil.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const LoginScreen();
    }

    final perfilAsync = ref.watch(perfilActualProvider);
    return perfilAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: MessageCard(
              texto: 'No se pudo cargar tu perfil. Reinicia la aplicación.',
            ),
          ),
        ),
      ),
      data: (perfil) {
        if (perfil == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return MainShell(perfil: perfil);
      },
    );
  }
}

class _ConfigMissingScreen extends StatelessWidget {
  const _ConfigMissingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.settings, size: 40, color: AppColors.ugYellow),
              SizedBox(height: 12),
              Text(
                'Configuración pendiente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Falta SUPABASE_URL y SUPABASE_ANON_KEY. Copia .env.example a .env y completa los valores de desarrollo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

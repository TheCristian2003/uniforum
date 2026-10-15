import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers.dart';
import '../core/theme/app_palette.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../core/widgets/message_card.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/shell/presentation/main_shell.dart';

/// Raíz de la aplicación.
///
/// El nombre comercial sigue pendiente; el título usa un texto genérico.
class App extends ConsumerWidget {
  const App({super.key, this.configured = true});

  final bool configured;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modo = ref.watch(themeControllerProvider);
    return MaterialApp(
      title: 'Vybe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: modo,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MessageCard(
                  texto: 'No se pudo cargar tu perfil.',
                ),
                const SizedBox(height: 12),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => ref.invalidate(perfilActualProvider),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reintentar'),
                ),
              ],
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
            children: [
              Icon(Icons.settings, size: 40, color: context.colors.ugYellow),
              SizedBox(height: 12),
              Text(
                'Configuración pendiente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Falta SUPABASE_URL y SUPABASE_ANON_KEY. Copia .env.example a .env y completa los valores de desarrollo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

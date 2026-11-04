import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniforum/app/app.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/core/services/preferences_service.dart';
import 'package:uniforum/features/auth/presentation/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login se mantiene claro aunque el tema guardado sea oscuro',
      (tester) async {
    SharedPreferences.setMockInitialValues({'tema.modo': 'dark'});
    final prefs = await PreferencesService.create();
    final cliente = SupabaseClient(
      'http://localhost',
      'anon',
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesServiceProvider.overrideWithValue(prefs),
          supabaseClientProvider.overrideWithValue(cliente),
          currentUserProvider.overrideWithValue(null),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    final contexto = tester.element(find.byType(LoginScreen));
    expect(Theme.of(contexto).brightness, Brightness.light);
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

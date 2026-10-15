import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/core/services/preferences_service.dart';
import 'package:uniforum/core/theme/theme_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('el modo de tema se restaura desde las preferencias', () async {
    SharedPreferences.setMockInitialValues({'tema.modo': 'dark'});
    final prefs = await PreferencesService.create();
    final container = ProviderContainer(
      overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeControllerProvider), ThemeMode.dark);
  });

  test('cambiar el modo de tema lo persiste en las preferencias', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.create();
    final container = ProviderContainer(
      overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeControllerProvider), ThemeMode.system);

    container.read(themeControllerProvider.notifier).setModo(ThemeMode.light);
    expect(container.read(themeControllerProvider), ThemeMode.light);

    final recargado = await PreferencesService.create();
    expect(recargado.modoTema(), ThemeMode.light);
  });

  test('los switches de Ajustes se persisten como flags', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await PreferencesService.create();

    expect(prefs.flag(PreferencesService.claveRadarPerdidos), isTrue);

    await prefs.guardarFlag(PreferencesService.claveRadarPerdidos, false);
    expect(prefs.flag(PreferencesService.claveRadarPerdidos), isFalse);
  });
}

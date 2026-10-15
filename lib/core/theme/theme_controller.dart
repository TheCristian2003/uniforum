import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Controla el [ThemeMode] activo y lo persiste en las preferencias locales.
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(preferencesServiceProvider).modoTema();

  void setModo(ThemeMode modo) {
    if (state == modo) return;
    state = modo;
    ref.read(preferencesServiceProvider).guardarModoTema(modo);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Acceso a las preferencias locales persistidas con `shared_preferences`.
///
/// Se instancia una sola vez en `main()` y se inyecta vía
/// `preferencesServiceProvider`. Los widgets nunca deben crear su propia
/// instancia ni leer `SharedPreferences` directamente.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static Future<PreferencesService> create() async =>
      PreferencesService(await SharedPreferences.getInstance());

  // Claves de preferencias.
  static const claveModo = 'tema.modo';
  static const claveResumenesIA = 'ajustes.resumenes_ia';
  static const claveSugerenciasIA = 'ajustes.sugerencias_ia';
  static const claveAlertasInstitucionales = 'ajustes.alertas_institucionales';
  static const claveActividadPublicaciones = 'ajustes.actividad_publicaciones';
  static const claveRadarPerdidos = 'ajustes.radar_perdidos';
  static const claveRankingSemanal = 'ajustes.ranking_semanal';
  static const clavePublicarAnonimo = 'ajustes.publicar_anonimo';

  ThemeMode modoTema() {
    switch (_prefs.getString(claveModo)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> guardarModoTema(ThemeMode modo) {
    final valor = switch (modo) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    return _prefs.setString(claveModo, valor);
  }

  bool flag(String clave, {bool porDefecto = true}) =>
      _prefs.getBool(clave) ?? porDefecto;

  Future<void> guardarFlag(String clave, bool valor) =>
      _prefs.setBool(clave, valor);
}

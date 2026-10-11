import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración local de la aplicación.
///
/// Las credenciales se leen de `.env` (excluido de Git) o de `--dart-define`.
/// Solo se admiten la URL del proyecto y la clave pública. Nunca se debe
/// incluir aquí la service-role key ni claves de proveedores de IA.
class AppConfig {
  const AppConfig._();

  static bool _dotenvLoaded = false;

  static Future<void> load({String fileName = '.env'}) async {
    if (_dotenvLoaded) return;
    try {
      await dotenv.load(fileName: fileName);
    } catch (_) {
      // Si el archivo no está disponible (por ejemplo en pruebas), se usa
      // --dart-define o la configuración queda vacía y se avisa en la UI.
    }
    _dotenvLoaded = true;
  }

  static String get supabaseUrl => _read('SUPABASE_URL');

  static String get supabaseAnonKey => _read('SUPABASE_ANON_KEY');

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String _read(String key) {
    final compileTime = _compileTime(key);
    if (compileTime.isNotEmpty) return compileTime;
    try {
      return dotenv.get(key, fallback: '').trim();
    } catch (_) {
      return '';
    }
  }

  static String _compileTime(String key) {
    switch (key) {
      case 'SUPABASE_URL':
        return const String.fromEnvironment('SUPABASE_URL');
      case 'SUPABASE_ANON_KEY':
        return const String.fromEnvironment('SUPABASE_ANON_KEY');
      default:
        return '';
    }
  }
}

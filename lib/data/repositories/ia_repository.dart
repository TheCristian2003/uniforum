import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/respuesta_ia.dart';

/// Error legible de la IA del Campus. Las vistas muestran [mensaje] tal cual.
class IaException implements Exception {
  const IaException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Llamadas a la Edge Function `campus-ai`.
///
/// La función valida el JWT, recupera el contexto bajo RLS y aplica el cupo
/// diario. El cliente nunca envía ni recibe claves del proveedor de IA.
class IaRepository {
  IaRepository(this._client);

  final SupabaseClient _client;

  static const _funcion = 'campus-ai';
  static const maxPregunta = 500;

  /// Deduce el periodo cuando la pregunta lo menciona ("hoy", "esta semana",
  /// "este mes", "este semestre") y conserva [predeterminado] en otro caso.
  static int diasSugeridos(String pregunta, {int predeterminado = 30}) {
    final texto = pregunta.toLowerCase();
    if (RegExp(r'\bhoy\b|\b24 horas\b|\b[uú]ltimas? horas?\b').hasMatch(texto)) {
      return 1;
    }
    if (RegExp(r'\bsemana\b|\b7 d[ií]as\b').hasMatch(texto)) return 7;
    if (RegExp(r'\bsemestre\b|\b90 d[ií]as\b').hasMatch(texto)) return 90;
    if (RegExp(r'\bmes\b|\b30 d[ií]as\b').hasMatch(texto)) return 30;
    return predeterminado;
  }

  /// Envía una pregunta o pide un resumen. `resumen` activa el modo
  /// "¿Qué me perdí?" para el canal y el periodo indicados.
  Future<RespuestaIA> consultar({
    required String pregunta,
    String? canalId,
    int dias = 30,
    bool resumen = false,
    List<MensajeHistorialIA> historial = const [],
  }) async {
    final diasEfectivos = diasSugeridos(pregunta, predeterminado: dias);
    try {
      final respuesta = await _client.functions.invoke(
        _funcion,
        body: {
          'pregunta': pregunta,
          'modo': resumen ? 'resumen' : 'pregunta',
          'dias': diasEfectivos,
          'canalId': ?canalId,
          if (historial.isNotEmpty)
            'historial': [for (final mensaje in historial) mensaje.toJson()],
        },
      );

      final datos = respuesta.data;
      if (datos is! Map) {
        throw const IaException('La IA devolvió una respuesta inesperada.');
      }

      final mapa = Map<String, dynamic>.from(datos);
      final texto = (mapa['respuesta'] as String?)?.trim() ?? '';
      if (texto.isEmpty) {
        throw const IaException('La IA no devolvió texto. Intenta reformular.');
      }

      final fuentes = (mapa['fuentes'] as List? ?? const [])
          .whereType<Map>()
          .map((fuente) => FuenteIA.fromJson(Map<String, dynamic>.from(fuente)))
          .toList();

      return RespuestaIA(
        texto: texto,
        fuentes: fuentes,
        restantes: (mapa['restantes'] as num?)?.toInt(),
      );
    } on FunctionException catch (error) {
      throw IaException(_mensajeDeError(error));
    } on IaException {
      rethrow;
    } catch (_) {
      throw const IaException(
        'No se pudo contactar a la IA. Revisa tu conexión e inténtalo de nuevo.',
      );
    }
  }

  String _mensajeDeError(FunctionException error) {
    final detalles = error.details;
    if (detalles is Map) {
      final mensaje = detalles['error'];
      if (mensaje is String && mensaje.trim().isNotEmpty) {
        return mensaje.trim();
      }
    }

    switch (error.status) {
      case 401:
        return 'Tu sesión expiró. Vuelve a iniciar sesión.';
      case 429:
        return 'Alcanzaste el límite diario de consultas de IA. Intenta mañana.';
      case 503:
        return 'La IA todavía no está configurada en el servidor.';
      default:
        return 'La IA no pudo responder. Inténtalo de nuevo.';
    }
  }
}

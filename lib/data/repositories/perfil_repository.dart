import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/perfil.dart';

/// Acceso a la tabla `perfiles`. La RLS solo permite leer/editar el perfil
/// propio; `puntos`, `es_verificada` y `nombre_oficial` no son editables desde
/// el cliente.
///
/// Los datos personales (`celular`, `fecha_nacimiento`) no son legibles como
/// columnas de `perfiles` para el resto de usuarios: solo el dueño los obtiene
/// a través de la vista `mi_perfil`.
class PerfilRepository {
  PerfilRepository(this._client);

  final SupabaseClient _client;

  /// Columnas de `perfiles` legibles por cualquier usuario autenticado.
  static const _columnasPublicas =
      'id, alias, tipo_perfil_id, programa_id, sede_id, biografia, '
      'avatar_url, es_verificada, nombre_oficial, puntos, activo';

  Future<Perfil?> fetchById(String id) async {
    final fila = await _client
        .from('perfiles')
        .select(_columnasPublicas)
        .eq('id', id)
        .maybeSingle();
    if (fila == null) return null;

    final data = Map<String, dynamic>.from(fila);
    if (_client.auth.currentUser?.id == id) {
      try {
        final privado = await _client
            .from('mi_perfil')
            .select('celular, fecha_nacimiento')
            .maybeSingle();
        if (privado != null) {
          data['celular'] = privado['celular'];
          data['fecha_nacimiento'] = privado['fecha_nacimiento'];
        }
      } catch (_) {
        // La vista `mi_perfil` aún no está disponible (migración pendiente):
        // se devuelve el perfil sin los datos personales.
      }
    }
    return Perfil.fromJson(data);
  }

  Future<Perfil> updatePerfil({
    required String id,
    required String alias,
    required int tipoPerfilId,
    int? programaId,
    int? sedeId,
    String? biografia,
    String? celular,
    DateTime? fechaNacimiento,
  }) async {
    await _client
        .from('perfiles')
        .update({
          'alias': alias.trim(),
          'tipo_perfil_id': tipoPerfilId,
          'programa_id': programaId,
          'sede_id': sedeId,
          'biografia': biografia,
          'celular': _celularValido(celular),
          'fecha_nacimiento': _fechaISO(fechaNacimiento),
        })
        .eq('id', id);
    return _releerPerfil(id);
  }

  String? _celularValido(String? celular) {
    final limpio = celular?.replaceAll(RegExp(r'\D'), '');
    return (limpio == null || limpio.isEmpty) ? null : limpio;
  }

  String? _fechaISO(DateTime? fecha) {
    if (fecha == null) return null;
    final mes = fecha.month.toString().padLeft(2, '0');
    final dia = fecha.day.toString().padLeft(2, '0');
    return '${fecha.year.toString().padLeft(4, '0')}-$mes-$dia';
  }

  /// Actualiza únicamente la foto de perfil (URL pública en Storage).
  Future<Perfil> updateAvatar({
    required String id,
    required String avatarUrl,
  }) async {
    await _client
        .from('perfiles')
        .update({'avatar_url': avatarUrl})
        .eq('id', id);
    return _releerPerfil(id);
  }

  Future<Perfil> _releerPerfil(String id) async {
    final perfil = await fetchById(id);
    if (perfil == null) {
      throw StateError('No se pudo releer el perfil actualizado.');
    }
    return perfil;
  }
}

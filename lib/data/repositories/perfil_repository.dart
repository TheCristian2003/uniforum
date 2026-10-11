import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/perfil.dart';

/// Acceso a la tabla `perfiles`. La RLS solo permite leer/editar el perfil
/// propio; `puntos`, `es_verificada` y `nombre_oficial` no son editables desde
/// el cliente.
class PerfilRepository {
  PerfilRepository(this._client);

  final SupabaseClient _client;

  Future<Perfil?> fetchById(String id) async {
    final data = await _client
        .from('perfiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return Perfil.fromJson(data);
  }

  Future<Perfil> updatePerfil({
    required String id,
    required String alias,
    required int tipoPerfilId,
    int? programaId,
    int? sedeId,
    String? biografia,
  }) async {
    final data = await _client
        .from('perfiles')
        .update({
          'alias': alias.trim(),
          'tipo_perfil_id': tipoPerfilId,
          'programa_id': programaId,
          'sede_id': sedeId,
          'biografia': biografia,
        })
        .eq('id', id)
        .select()
        .single();
    return Perfil.fromJson(data);
  }
}

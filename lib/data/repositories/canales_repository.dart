import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/canal.dart';

/// Lectura de canales activos (`public.canales`).
class CanalesRepository {
  CanalesRepository(this._client);

  final SupabaseClient _client;

  Future<List<Canal>> fetchCanales() async {
    final rows = await _client
        .from('canales')
        .select('id, nombre, slug, descripcion, icono, tipo_canal_id')
        .eq('activo', true)
        .order('nombre');
    return rows.map((row) => Canal.fromJson(row)).toList();
  }
}

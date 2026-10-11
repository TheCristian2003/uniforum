import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/catalogo_item.dart';

/// Lectura de catálogos de la tabla `maestra`, siempre acotada a un `grupo`
/// para respetar la clave `UNIQUE (grupo, codigo)`.
class CatalogoRepository {
  CatalogoRepository(this._client);

  final SupabaseClient _client;

  Future<List<CatalogoItem>> fetchGrupo(String grupo) async {
    final rows = await _client
        .from('maestra')
        .select('id_maestra, codigo, nombre')
        .eq('grupo', grupo)
        .eq('activo', true)
        .order('orden');
    return rows.map((row) => CatalogoItem.fromJson(row)).toList();
  }
}

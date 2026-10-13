import 'package:supabase_flutter/supabase_flutter.dart';

/// Roles privilegiados de `app_metadata.app_role`.
///
/// Solo el backend puede asignarlos. El cliente los lee únicamente para adaptar
/// la interfaz; la autorización real la aplica RLS en la base de datos.
const rolesPrivilegiados = {'administrador', 'moderador', 'institucional'};

bool esRolPrivilegiado(User? user) {
  final rol = (user?.appMetadata ?? const {})['app_role'];
  return rol is String && rolesPrivilegiados.contains(rol);
}

/// Refleja `public.puede_publicar_tipo`: los `aviso` solo los publica un rol
/// privilegiado. Se usa para ocultar esa opción en el formulario.
bool puedePublicarTipo(String codigoTipo, {required bool privilegiado}) {
  return codigoTipo != 'aviso' || privilegiado;
}

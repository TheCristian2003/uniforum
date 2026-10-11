/// Perfil de usuario enlazado con `auth.users` (relación 1:1 por id).
class Perfil {
  const Perfil({
    required this.id,
    required this.alias,
    required this.tipoPerfilId,
    this.programaId,
    this.sedeId,
    this.biografia,
    this.avatarUrl,
    this.esVerificada = false,
    this.nombreOficial,
    this.puntos = 0,
  });

  final String id;
  final String alias;
  final int tipoPerfilId;
  final int? programaId;
  final int? sedeId;
  final String? biografia;
  final String? avatarUrl;
  final bool esVerificada;
  final String? nombreOficial;
  final int puntos;

  /// Un alias con el patrón temporal `usuario_<8 hex>` indica que el onboarding
  /// aún no se completó. El trigger de base de datos crea ese alias inicial.
  bool get needsOnboarding =>
      RegExp(r'^usuario_[0-9a-fA-F]{8}$').hasMatch(alias);

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id'] as String,
      alias: json['alias'] as String,
      tipoPerfilId: json['tipo_perfil_id'] as int,
      programaId: json['programa_id'] as int?,
      sedeId: json['sede_id'] as int?,
      biografia: json['biografia'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      esVerificada: (json['es_verificada'] as bool?) ?? false,
      nombreOficial: json['nombre_oficial'] as String?,
      puntos: (json['puntos'] as int?) ?? 0,
    );
  }
}

/// Votos del usuario autenticado, indexados por id de publicación o comentario.
///
/// Evita consultar el voto de cada tarjeta por separado.
class MisVotos {
  const MisVotos({required this.publicaciones, required this.comentarios});

  const MisVotos.vacia() : publicaciones = const {}, comentarios = const {};

  final Map<String, int> publicaciones;
  final Map<String, int> comentarios;

  int? votoPublicacion(String publicacionId) => publicaciones[publicacionId];
  int? votoComentario(String comentarioId) => comentarios[comentarioId];
}

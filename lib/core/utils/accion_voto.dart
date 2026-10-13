/// Acción a ejecutar sobre un voto existente (o inexistente).
///
/// - Si el usuario toca el mismo valor que ya tenía, se quita el voto.
/// - Si no había voto, se inserta.
/// - Si había un valor distinto, se actualiza el registro existente.
enum AccionVoto { insertar, actualizar, eliminar }

AccionVoto accionVoto(int? valorActual, int nuevoValor) {
  if (valorActual == null) return AccionVoto.insertar;
  if (valorActual == nuevoValor) return AccionVoto.eliminar;
  return AccionVoto.actualizar;
}

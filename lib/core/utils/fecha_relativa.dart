/// Formatea una fecha como texto relativo en español ("hace 5 min").
///
/// `ahora` permite inyectar la referencia actual en pruebas.
String fechaRelativa(DateTime fecha, {DateTime? ahora}) {
  final referencia = ahora ?? DateTime.now();
  final diferencia = referencia.difference(fecha);

  if (diferencia.isNegative || diferencia.inSeconds < 60) {
    return 'hace un momento';
  }
  if (diferencia.inMinutes < 60) {
    return 'hace ${diferencia.inMinutes} min';
  }
  if (diferencia.inHours < 24) {
    return 'hace ${diferencia.inHours} h';
  }
  if (diferencia.inDays < 7) {
    return 'hace ${diferencia.inDays} d';
  }
  if (diferencia.inDays < 30) {
    return 'hace ${diferencia.inDays ~/ 7} sem';
  }
  if (diferencia.inDays < 365) {
    return 'hace ${diferencia.inDays ~/ 30} meses';
  }
  return 'hace ${diferencia.inDays ~/ 365} años';
}

String _dosDigitos(int valor) => valor.toString().padLeft(2, '0');

/// Formatea una fecha como `dd/mm/aaaa`.
String fechaCorta(DateTime fecha) =>
    '${_dosDigitos(fecha.day)}/${_dosDigitos(fecha.month)}/${fecha.year}';

/// Formatea una fecha y hora como `dd/mm/aaaa hh:mm`.
String fechaHora(DateTime fecha) =>
    '${fechaCorta(fecha)} ${_dosDigitos(fecha.hour)}:${_dosDigitos(fecha.minute)}';

/// Formatea un número entero sin decimales y con decimales si los tiene.
String numeroCorto(num valor) {
  if (valor == valor.roundToDouble()) return valor.toInt().toString();
  return valor.toString();
}

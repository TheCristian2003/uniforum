import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/data/models/perfil.dart';

void main() {
  group('Perfil.needsOnboarding', () {
    test('detecta el alias temporal generado por el trigger', () {
      const perfil = Perfil(
        id: '11111111-1111-1111-1111-111111111111',
        alias: 'usuario_1a2b3c4d',
        tipoPerfilId: 1,
      );
      expect(perfil.needsOnboarding, isTrue);
    });

    test('un alias elegido por la persona no exige onboarding', () {
      const perfil = Perfil(
        id: '11111111-1111-1111-1111-111111111111',
        alias: 'mateo_dev',
        tipoPerfilId: 1,
      );
      expect(perfil.needsOnboarding, isFalse);
    });
  });

  group('Perfil.fromJson', () {
    test('mapea columnas de la tabla perfiles', () {
      final perfil = Perfil.fromJson(const {
        'id': '11111111-1111-1111-1111-111111111111',
        'alias': 'ana',
        'tipo_perfil_id': 7,
        'programa_id': 12,
        'sede_id': null,
        'biografia': null,
        'avatar_url': null,
        'es_verificada': true,
        'nombre_oficial': 'Facultad',
        'puntos': 30,
      });
      expect(perfil.alias, 'ana');
      expect(perfil.programaId, 12);
      expect(perfil.sedeId, isNull);
      expect(perfil.esVerificada, isTrue);
      expect(perfil.puntos, 30);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/theme/app_theme.dart';
import 'package:uniforum/data/models/publicacion.dart';
import 'package:uniforum/features/feed/presentation/widgets/publicacion_card.dart';

void main() {
  testWidgets('votar desde la tarjeta no abre el detalle', (tester) async {
    var votos = 0;
    var abrioDetalle = false;
    final publicacion = Publicacion(
      id: 'p1',
      canalId: 'c1',
      tipoId: 1,
      categoriaId: 10,
      cuerpo: 'Publicación de prueba para votar desde el feed.',
      anonimo: false,
      puntaje: 3,
      creadoEn: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: PublicacionCard(
            publicacion: publicacion,
            onTap: () => abrioDetalle = true,
            onVotar: (valor) => votos = valor,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Votar a favor'));
    await tester.pump();

    expect(votos, 1);
    expect(abrioDetalle, isFalse);
  });
}

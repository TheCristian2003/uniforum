import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/features/feed/presentation/widgets/control_voto.dart';

void main() {
  testWidgets('ControlVoto muestra el puntaje y emite el valor tocado',
      (tester) async {
    final valores = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ControlVoto(
            puntaje: 7,
            miVoto: null,
            onVotar: valores.add,
          ),
        ),
      ),
    );

    expect(find.text('7'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.tap(find.byIcon(Icons.arrow_downward));
    await tester.pump();

    expect(valores, [1, -1]);
  });

  testWidgets('ControlVoto deshabilitado no emite votos', (tester) async {
    var emitido = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ControlVoto(
            puntaje: 3,
            miVoto: 1,
            habilitado: false,
            onVotar: (_) => emitido = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_upward));
    await tester.pump();

    expect(emitido, isFalse);
  });
}

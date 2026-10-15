import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/widgets/auth_widgets.dart';

void main() {
  testWidgets('CampoAuthDropdown permite limpiar la selección',
      (WidgetTester tester) async {
    int? valor = 2;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => CampoAuthDropdown(
              label: 'Programa',
              icono: Icons.school_outlined,
              placeholder: 'Selecciona tu programa',
              valor: valor,
              items: const [
                DropdownMenuItem<int>(value: 1, child: Text('Uno')),
                DropdownMenuItem<int>(value: 2, child: Text('Dos')),
              ],
              onChanged: (v) => setState(() => valor = v),
              onClear: () => setState(() => valor = null),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Dos'), findsOneWidget);
    expect(find.text('Limpiar'), findsOneWidget);

    await tester.tap(find.text('Limpiar'));
    await tester.pumpAndSettle();

    expect(valor, isNull);
    expect(find.text('Selecciona tu programa'), findsOneWidget);
    expect(find.text('Limpiar'), findsNothing);
  });

  testWidgets('Sin selección no se muestra el botón de limpiar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CampoAuthDropdown(
            label: 'Tipo',
            icono: Icons.badge_outlined,
            valor: null,
            items: const [
              DropdownMenuItem<int>(value: 1, child: Text('Uno')),
            ],
            onChanged: (_) {},
            onClear: () {},
          ),
        ),
      ),
    );

    expect(find.text('Selecciona una opción'), findsOneWidget);
    expect(find.text('Limpiar'), findsNothing);
  });

  testWidgets('Sin onClear no se muestra el botón de limpiar',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CampoAuthDropdown(
            label: 'Tipo',
            icono: Icons.badge_outlined,
            valor: 1,
            items: const [
              DropdownMenuItem<int>(value: 1, child: Text('Uno')),
            ],
            onChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Uno'), findsOneWidget);
    expect(find.text('Limpiar'), findsNothing);
  });
}

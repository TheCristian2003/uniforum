import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/data/models/catalogo_item.dart';
import 'package:uniforum/features/moderacion/presentation/reportar_sheet.dart';

void main() {
  testWidgets('el reporte lista los motivos y permite enviar', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogoProvider('motivo_reporte').overrideWith((ref) async => const [
                CatalogoItem(id: 1, codigo: 'acoso', nombre: 'Acoso'),
                CatalogoItem(id: 2, codigo: 'otro', nombre: 'Otro'),
              ]),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      mostrarReportarSheet(context, publicacionId: 'p1'),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Reportar publicación'), findsOneWidget);
    expect(find.text('Acoso'), findsOneWidget);
    expect(find.text('Otro'), findsOneWidget);
    expect(find.text('Enviar reporte'), findsOneWidget);
  });

  testWidgets('el reporte no desborda con el teclado abierto',
      (tester) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogoProvider('motivo_reporte').overrideWith((ref) async => const [
                CatalogoItem(id: 1, codigo: 'acoso', nombre: 'Acoso'),
                CatalogoItem(id: 2, codigo: 'otro', nombre: 'Otro'),
              ]),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      mostrarReportarSheet(context, publicacionId: 'p1'),
                  child: const Text('Abrir'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Enviar reporte'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/data/models/perfil.dart';
import 'package:uniforum/data/models/restriccion.dart';
import 'package:uniforum/features/shell/presentation/main_shell.dart';

void main() {
  const perfil = Perfil(
    id: '00000000-0000-0000-0000-000000000000',
    alias: 'usuario_demo',
    tipoPerfilId: 1,
    puntos: 0,
  );

  testWidgets('MainShell muestra la navegación y el FAB de publicar',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(null)],
        child: const MaterialApp(home: MainShell(perfil: perfil)),
      ),
    );

    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Canales'), findsWidgets);
    expect(find.text('IA'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.text('Nueva publicación'), findsOneWidget);
  });

  testWidgets('MainShell avisa y bloquea publicar si hay restricción',
      (tester) async {
    final restriccion = Restriccion(
      id: 'r1',
      usuarioId: perfil.id,
      tipo: 'temporal',
      motivo: 'Acoso',
      iniciaEn: DateTime.now().subtract(const Duration(days: 1)),
      expiraEn: DateTime.now().add(const Duration(days: 2)),
      activa: true,
      creadoEn: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(null),
          miRestriccionActivaProvider.overrideWith((ref) async => restriccion),
        ],
        child: const MaterialApp(home: MainShell(perfil: perfil)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tu cuenta está restringida'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(
      find.text('Tu cuenta está restringida: no puedes publicar.'),
      findsOneWidget,
    );
    expect(find.text('Nueva publicación'), findsNothing);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/data/models/catalogo_item.dart';
import 'package:uniforum/data/models/comentario.dart';
import 'package:uniforum/data/models/publicacion.dart';
import 'package:uniforum/data/models/reporte.dart';
import 'package:uniforum/features/moderacion/presentation/moderacion_screen.dart';

User usuario({String? rol}) => User(
      id: 'u1',
      appMetadata: rol == null ? const {} : {'app_role': rol},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-10-11T00:00:00Z',
    );

const estados = [
  CatalogoItem(id: 1, codigo: 'pendiente', nombre: 'Pendiente'),
  CatalogoItem(id: 2, codigo: 'revisado', nombre: 'Revisado'),
  CatalogoItem(id: 3, codigo: 'cerrado', nombre: 'Cerrado'),
];

final reporte = Reporte(
  id: 'r1',
  publicacionId: 'p1',
  comentarioId: null,
  motivo: 'Desinformación',
  estado: 'pendiente',
  descripcion: 'No coincide con la fuente',
  creadoEn: DateTime.utc(2026, 10, 11, 12),
  reportanteAlias: 'ana',
  contenido: 'Contenido reportado de prueba',
  tituloContenido: 'Título de prueba',
  autorId: 'u2',
);

void main() {
  testWidgets('moderación exige rol privilegiado', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(usuario()),
        ],
        child: const MaterialApp(home: ModeracionScreen()),
      ),
    );

    expect(find.text('Acceso restringido'), findsOneWidget);
  });

  testWidgets('moderación lista reportes pendientes y sus acciones',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(usuario(rol: 'moderador')),
          reportesPendientesProvider.overrideWith((ref) async => [reporte]),
          catalogoProvider('estado_reporte')
              .overrideWith((ref) async => estados),
        ],
        child: const MaterialApp(home: ModeracionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Desinformación'), findsOneWidget);
    expect(find.text('Título de prueba'), findsOneWidget);
    expect(find.textContaining('@ana'), findsOneWidget);
    expect(find.text('Ocultar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);
    expect(find.text('Restringir autor'), findsOneWidget);
    expect(find.text('Marcar revisado'), findsOneWidget);
    expect(find.text('Cerrar'), findsOneWidget);
  });

  testWidgets('moderación abre el diálogo de restricción', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(usuario(rol: 'moderador')),
          reportesPendientesProvider.overrideWith((ref) async => [reporte]),
          catalogoProvider('estado_reporte')
              .overrideWith((ref) async => estados),
        ],
        child: const MaterialApp(home: ModeracionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restringir autor'));
    await tester.pumpAndSettle();

    expect(find.text('Restringir usuario'), findsOneWidget);
    expect(find.text('7 días'), findsOneWidget);
    expect(find.text('Permanente'), findsOneWidget);
    expect(find.text('Motivo'), findsOneWidget);
  });

  testWidgets('el diálogo de restricción no desborda con el teclado abierto',
      (tester) async {
    tester.view.viewInsets = const FakeViewPadding(bottom: 400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(usuario(rol: 'moderador')),
          reportesPendientesProvider.overrideWith((ref) async => [reporte]),
          catalogoProvider('estado_reporte')
              .overrideWith((ref) async => estados),
        ],
        child: const MaterialApp(home: ModeracionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restringir autor'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Restringir usuario'), findsOneWidget);
  });

  testWidgets('moderación muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(usuario(rol: 'administrador')),
          reportesPendientesProvider.overrideWith((ref) async => []),
          catalogoProvider('estado_reporte')
              .overrideWith((ref) async => estados),
        ],
        child: const MaterialApp(home: ModeracionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin reportes pendientes'), findsOneWidget);
  });

  testWidgets('moderación lista contenido reciente para moderar',
      (tester) async {
    final publicacion = Publicacion(
      id: 'p1',
      canalId: 'c1',
      canalNombre: 'General',
      tipoId: 1,
      tipoNombre: 'Discusión',
      categoriaId: 1,
      categoriaNombre: 'Académico',
      cuerpo: 'Publicación reciente de prueba',
      anonimo: false,
      puntaje: 0,
      creadoEn: DateTime.utc(2026, 10, 11, 12),
      autorId: 'u9',
      autorAlias: 'leo',
    );
    final comentario = Comentario(
      id: 'co1',
      publicacionId: 'p1',
      autorId: 'u9',
      cuerpo: 'Comentario reciente de prueba',
      esSolucion: false,
      puntaje: 0,
      creadoEn: DateTime.utc(2026, 10, 11, 13),
      autorAlias: 'leo',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(usuario(rol: 'moderador')),
          reportesPendientesProvider.overrideWith((ref) async => []),
          catalogoProvider('estado_reporte')
              .overrideWith((ref) async => estados),
          feedRecientesProvider.overrideWith((ref) async => [publicacion]),
          comentariosRecientesProvider.overrideWith((ref) async => [comentario]),
        ],
        child: const MaterialApp(home: ModeracionScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Contenido'));
    await tester.pumpAndSettle();

    expect(find.text('Publicación reciente de prueba'), findsOneWidget);
    expect(find.text('Comentario reciente de prueba'), findsOneWidget);
    expect(find.text('Ocultar'), findsOneWidget);
    expect(find.text('Eliminar'), findsNWidgets(2));
  });
}

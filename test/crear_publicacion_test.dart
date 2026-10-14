import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/data/models/canal.dart';
import 'package:uniforum/data/models/catalogo_item.dart';
import 'package:uniforum/data/models/metadatos_publicacion.dart';
import 'package:uniforum/data/models/publicacion.dart';
import 'package:uniforum/features/publicaciones/presentation/crear_publicacion_screen.dart';

void main() {
  const canal = Canal(
    id: 'c1',
    nombre: 'Comunidad general',
    slug: 'comunidad-general',
  );
  const discusion = CatalogoItem(
    id: 1,
    codigo: 'discusion',
    nombre: 'Discusión',
  );
  const aviso = CatalogoItem(id: 2, codigo: 'aviso', nombre: 'Aviso');
  const venta = CatalogoItem(id: 3, codigo: 'venta', nombre: 'Venta');
  const general = CatalogoItem(id: 10, codigo: 'general', nombre: 'General');

  Widget app({Publicacion? publicacion}) {
    return ProviderScope(
      overrides: [
        currentUserProvider.overrideWithValue(null),
        canalesProvider.overrideWith((ref) async => [canal]),
        catalogoProvider.overrideWith((ref, grupo) async {
          if (grupo == 'tipo_publicacion') return [discusion, aviso, venta];
          if (grupo == 'categoria_publicacion') return [general];
          return <CatalogoItem>[];
        }),
      ],
      child: MaterialApp(home: CrearPublicacionScreen(publicacion: publicacion)),
    );
  }

  testWidgets('CrearPublicacionScreen muestra los campos base', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Nueva publicación'), findsOneWidget);
    expect(find.text('TIPO DE PUBLICACIÓN'), findsOneWidget);
    expect(find.text('CANAL DE DESTINO'), findsOneWidget);
    expect(find.text('CATEGORÍA'), findsOneWidget);
    expect(find.text('TÍTULO (OPCIONAL)'), findsOneWidget);
    expect(find.text('CONTENIDO'), findsOneWidget);
    expect(find.text('Publicar'), findsOneWidget);
  });

  testWidgets('valida que el contenido no esté vacío', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Discusión'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Publicar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicar'));
    await tester.pump();

    expect(find.text('Escribe el contenido de tu publicación'), findsOneWidget);
  });

  testWidgets('muestra los metadatos al elegir el tipo venta', (tester) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();

    expect(find.text('Precio (COP)'), findsNothing);

    await tester.ensureVisible(find.text('Venta'));
    await tester.tap(find.text('Venta'));
    await tester.pumpAndSettle();

    expect(find.text('Precio (COP)'), findsOneWidget);
    // En modo creación el estado se asigna automáticamente, no se pregunta.
    expect(find.text('Disponible'), findsNothing);

    await tester.ensureVisible(find.text('Publicar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Publicar'));
    await tester.pump();

    expect(find.text('Ingresa un valor'), findsOneWidget);
  });

  testWidgets('en modo edición precarga los datos y muestra el estado', (
    tester,
  ) async {
    final publicacion = Publicacion(
      id: 'p1',
      canalId: 'c1',
      tipoId: 3,
      categoriaId: 10,
      cuerpo: 'Vendo una calculadora en buen estado.',
      anonimo: false,
      puntaje: 0,
      creadoEn: DateTime(2026, 1, 1),
      titulo: 'Calculadora',
      metadatos: const MetadatosPublicacion(
        precio: 15000,
        moneda: 'COP',
        disponible: true,
      ),
    );

    await tester.pumpWidget(app(publicacion: publicacion));
    await tester.pumpAndSettle();

    expect(find.text('Editar publicación'), findsOneWidget);
    expect(
      find.text('No se puede cambiar el canal, tipo ni categoría.'),
      findsOneWidget,
    );
    expect(find.text('Precio (COP)'), findsOneWidget);
    expect(find.text('Disponible'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Calculadora'), findsOneWidget);
  });
}

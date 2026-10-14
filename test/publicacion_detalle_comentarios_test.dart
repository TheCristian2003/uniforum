import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/data/models/comentario.dart';
import 'package:uniforum/data/models/insignia.dart';
import 'package:uniforum/data/models/mis_votos.dart';
import 'package:uniforum/data/models/perfil.dart';
import 'package:uniforum/data/models/publicacion.dart';
import 'package:uniforum/data/repositories/gamificacion_repository.dart';
import 'package:uniforum/features/perfil/presentation/perfil_screen.dart';
import 'package:uniforum/features/publicaciones/presentation/publicacion_detalle_screen.dart';

const miId = '11111111-1111-1111-1111-111111111111';
const autorPublicacion = '22222222-2222-2222-2222-222222222222';
const otroAutor = '33333333-3333-3333-3333-333333333333';

User usuario({String id = miId, String? rol}) => User(
      id: id,
      appMetadata: rol == null ? const {} : {'app_role': rol},
      userMetadata: const {},
      aud: 'authenticated',
      createdAt: '2026-10-11T00:00:00Z',
    );

final publicacion = Publicacion(
  id: 'p1',
  canalId: 'c1',
  canalNombre: 'Comunidad general',
  tipoId: 1,
  tipoNombre: 'Discusión',
  categoriaId: 1,
  categoriaNombre: 'Académico',
  cuerpo: 'Contenido de la publicación',
  anonimo: false,
  puntaje: 0,
  creadoEn: DateTime.utc(2026, 10, 11, 12),
  autorId: autorPublicacion,
  autorAlias: 'mateo_dev',
);

Comentario comentarioDe(String autorId) => Comentario(
      id: 'co1',
      publicacionId: 'p1',
      autorId: autorId,
      cuerpo: 'Un comentario de prueba',
      esSolucion: false,
      puntaje: 0,
      creadoEn: DateTime.utc(2026, 10, 11, 13),
      autorAlias: 'ana',
    );

Widget app({
  required User user,
  required String autorComentario,
  List<Override> extra = const [],
}) {
  return ProviderScope(
    overrides: [
      currentUserProvider.overrideWithValue(user),
      publicacionDetalleProvider('p1').overrideWith((ref) async => publicacion),
      comentariosDePublicacionProvider('p1')
          .overrideWith((ref) async => [comentarioDe(autorComentario)]),
      misVotosProvider.overrideWith((ref) async => const MisVotos.vacia()),
      ...extra,
    ],
    child: MaterialApp(
      home: PublicacionDetalleScreen(publicacion: publicacion),
    ),
  );
}

void main() {
  Finder menuComentario() => find.descendant(
        of: find.byType(ListView),
        matching: find.byIcon(Icons.more_vert),
      );

  testWidgets('un comentario propio ofrece Editar y Eliminar', (tester) async {
    await tester.pumpWidget(app(user: usuario(), autorComentario: miId));
    await tester.pumpAndSettle();

    await tester.tap(menuComentario());
    await tester.pumpAndSettle();

    expect(find.text('Editar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    expect(find.text('Editar comentario'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });

  testWidgets('un comentario ajeno no ofrece Editar sin privilegios',
      (tester) async {
    await tester.pumpWidget(app(user: usuario(), autorComentario: otroAutor));
    await tester.pumpAndSettle();

    // Solo el menú de la publicación (ajena) usa `more_vert`; el comentario
    // ajeno solo ofrece reportar.
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byIcon(Icons.flag_outlined), findsOneWidget);
    expect(menuComentario(), findsNothing);
  });

  testWidgets('un moderador puede eliminar un comentario ajeno',
      (tester) async {
    await tester.pumpWidget(
      app(user: usuario(rol: 'moderador'), autorComentario: otroAutor),
    );
    await tester.pumpAndSettle();

    // Menú de la publicación + menú del comentario.
    expect(find.byIcon(Icons.more_vert), findsNWidgets(2));

    await tester.tap(menuComentario());
    await tester.pumpAndSettle();

    expect(find.text('Eliminar'), findsOneWidget);
    expect(find.text('Editar'), findsNothing);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(find.text('Eliminar comentario'), findsOneWidget);
  });

  testWidgets('tocar el autor de un comentario abre su perfil', (tester) async {
    await tester.pumpWidget(
      app(
        user: usuario(),
        autorComentario: otroAutor,
        extra: [
          perfilPorIdProvider(otroAutor).overrideWith(
            (ref) async => const Perfil(
              id: otroAutor,
              alias: 'ana',
              tipoPerfilId: 1,
            ),
          ),
          insigniasUsuarioProvider(otroAutor)
              .overrideWith((ref) async => const <Insignia>[]),
          estadisticasUsuarioProvider(otroAutor).overrideWith(
            (ref) async => const EstadisticasUsuario(
              publicaciones: 0,
              comentarios: 0,
              soluciones: 0,
              votosRecibidos: 0,
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('ana'));
    await tester.pumpAndSettle();

    expect(find.byType(PerfilUsuarioScreen), findsOneWidget);
    expect(find.text('@ana'), findsOneWidget);
  });
}

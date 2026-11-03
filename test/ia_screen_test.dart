import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniforum/core/providers.dart';
import 'package:uniforum/core/theme/app_theme.dart';
import 'package:uniforum/data/models/canal.dart';
import 'package:uniforum/data/models/perfil.dart';
import 'package:uniforum/data/models/respuesta_ia.dart';
import 'package:uniforum/data/repositories/ia_repository.dart';
import 'package:uniforum/features/ia/presentation/ia_screen.dart';

const _perfil = Perfil(
  id: '00000000-0000-0000-0000-000000000001',
  alias: 'usuario_demo',
  tipoPerfilId: 1,
  puntos: 0,
);

class _FakeIaRepository extends IaRepository {
  _FakeIaRepository({this.respuesta, this.error})
      : super(
          SupabaseClient(
            'http://localhost',
            'anon',
            authOptions: const AuthClientOptions(autoRefreshToken: false),
          ),
        );

  final RespuestaIA? respuesta;
  final IaException? error;
  int llamadas = 0;
  bool? ultimoResumen;
  int? ultimosDias;
  String? ultimoCanalId;
  String? ultimaPregunta;
  List<MensajeHistorialIA>? ultimoHistorial;

  @override
  Future<RespuestaIA> consultar({
    required String pregunta,
    String? canalId,
    int dias = 30,
    bool resumen = false,
    List<MensajeHistorialIA> historial = const [],
  }) async {
    llamadas++;
    ultimoResumen = resumen;
    ultimosDias = dias;
    ultimoCanalId = canalId;
    ultimaPregunta = pregunta;
    ultimoHistorial = historial;
    if (error != null) throw error!;
    return respuesta!;
  }
}

Widget _app(IaRepository repo, {List<Canal>? canales}) {
  return ProviderScope(
    overrides: [
      iaRepositoryProvider.overrideWithValue(repo),
      if (canales != null)
        canalesProvider.overrideWith((ref) async => canales),
    ],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: const IaScreen(perfil: _perfil),
    ),
  );
}

Future<void> _preguntar(WidgetTester tester, String texto) async {
  await tester.enterText(find.byType(TextField), texto);
  await tester.tap(find.byIcon(Icons.send));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la IA muestra la respuesta y sus fuentes', (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Hay dos avisos sobre el examen de cálculo.',
        fuentes: [
          FuenteIA(
            id: '00000000-0000-0000-0000-000000000099',
            titulo: 'Examen de cálculo',
            canal: 'Académico',
            tipo: 'Discusión',
          ),
        ],
        restantes: 19,
      ),
    );

    await tester.pumpWidget(_app(repo));
    await _preguntar(tester, '¿Qué pasó con el examen de cálculo?');

    expect(repo.llamadas, 1);
    expect(
      find.text('¿Qué pasó con el examen de cálculo?'),
      findsOneWidget,
    );
    expect(
      find.text('Hay dos avisos sobre el examen de cálculo.'),
      findsOneWidget,
    );
    expect(find.text('FUENTES USADAS'), findsOneWidget);
    expect(find.text('Examen de cálculo'), findsOneWidget);
    expect(find.text('Te quedan 19 consultas de IA hoy.'), findsOneWidget);
  });

  testWidgets('un error muestra el mensaje y permite reintentar',
      (tester) async {
    final repo = _FakeIaRepository(
      error: const IaException(
        'Alcanzaste el límite diario de consultas de IA. Intenta mañana.',
      ),
    );

    await tester.pumpWidget(_app(repo));
    await _preguntar(tester, '¿Qué me perdí?');

    expect(repo.llamadas, 1);
    expect(
      find.text('Alcanzaste el límite diario de consultas de IA. Intenta mañana.'),
      findsWidgets,
    );
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(repo.llamadas, 2);
  });

  testWidgets('el chip de resumen pide el modo resumen de la semana',
      (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Resumen de la semana.',
        fuentes: [],
        restantes: 18,
      ),
    );

    await tester.pumpWidget(_app(repo));
    await tester.tap(find.text('¿Qué me perdí esta semana?'));
    await tester.pumpAndSettle();

    expect(repo.llamadas, 1);
    expect(repo.ultimoResumen, isTrue);
    expect(repo.ultimosDias, 7);
    expect(find.text('Resumen de la semana.'), findsOneWidget);
  });

  testWidgets('el resumen de un canal envía el canal elegido', (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Resumen de Ingeniería.',
        fuentes: [],
        restantes: 17,
      ),
    );
    const canal = Canal(
      id: '00000000-0000-0000-0000-000000000010',
      nombre: 'Ingeniería',
      slug: 'ingenieria',
    );

    await tester.pumpWidget(_app(repo, canales: [canal]));
    await tester.tap(find.text('Resumen de un canal'));
    await tester.pumpAndSettle();

    expect(find.text('Elige un canal para el resumen'), findsOneWidget);

    await tester.tap(find.text('Ingeniería'));
    await tester.pumpAndSettle();

    expect(repo.llamadas, 1);
    expect(repo.ultimoResumen, isTrue);
    expect(repo.ultimoCanalId, canal.id);
    expect(repo.ultimosDias, 30);
    expect(find.text('Resumen de Ingeniería.'), findsOneWidget);
  });

  test('diasSugeridos interpreta el periodo de la pregunta', () {
    expect(IaRepository.diasSugeridos('¿Qué pasó hoy?'), 1);
    expect(IaRepository.diasSugeridos('¿Qué me perdí esta semana?'), 7);
    expect(IaRepository.diasSugeridos('resumen del mes'), 30);
    expect(IaRepository.diasSugeridos('lo del semestre'), 90);
    expect(IaRepository.diasSugeridos('examen de cálculo'), 30);
  });

  testWidgets('el chip de avisos envía la consulta directamente',
      (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Los avisos del campus.',
        fuentes: [],
        restantes: 16,
      ),
    );

    await tester.pumpWidget(_app(repo));
    await tester.ensureVisible(find.text('Avisos importantes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Avisos importantes'));
    await tester.pumpAndSettle();

    expect(repo.llamadas, 1);
    expect(
      repo.ultimaPregunta,
      '¿Cuáles son los avisos más importantes del campus?',
    );
    expect(find.text('Los avisos del campus.'), findsOneWidget);
  });

  testWidgets('el chip de buscar prepara la consulta sin enviarla',
      (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Sin respuesta.',
        fuentes: [],
        restantes: 16,
      ),
    );

    await tester.pumpWidget(_app(repo));
    await tester.ensureVisible(find.text('Buscar un tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar un tema'));
    await tester.pump();

    final campo = tester.widget<TextField>(find.byType(TextField));
    expect(campo.controller?.text, 'Busca en el campus publicaciones sobre ');
    expect(repo.llamadas, 0);
  });

  testWidgets('la segunda pregunta envía el historial de la conversación',
      (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Una respuesta.',
        fuentes: [],
        restantes: 15,
      ),
    );

    await tester.pumpWidget(_app(repo));
    await _preguntar(tester, '¿Qué es la recursividad?');

    expect(repo.llamadas, 1);
    expect(repo.ultimoHistorial, isEmpty);

    await _preguntar(tester, '¿Y un ejemplo?');

    expect(repo.llamadas, 2);
    final historial = repo.ultimoHistorial!;
    expect(historial.length, 2);
    expect(historial[0].rol, 'usuario');
    expect(historial[0].texto, '¿Qué es la recursividad?');
    expect(historial[1].rol, 'ia');
    expect(historial[1].texto, 'Una respuesta.');
  });

  testWidgets('la IA convierte las negritas en texto resaltado', (tester) async {
    final repo = _FakeIaRepository(
      respuesta: const RespuestaIA(
        texto: 'Hay **tres entregados** este mes.',
        fuentes: [],
        restantes: 14,
      ),
    );

    await tester.pumpWidget(_app(repo));
    await _preguntar(tester, '¿Cuántos entregados?');

    expect(find.textContaining('**', findRichText: true), findsNothing);
    expect(
      find.textContaining('Hay tres entregados este mes.', findRichText: true),
      findsOneWidget,
    );
  });
}

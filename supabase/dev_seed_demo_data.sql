-- Datos de DEMO para desarrollo (NO aplicar en producción).
--
-- Pasos previos:
--   1. Ejecutar supabase/seed.sql (canales y catálogos base).
--   2. Crear estos 12 usuarios en Supabase > Authentication > Users (email confirmado):
--        alice.rivera@univ.test, bruno.torres@univ.test, camila.ortiz@univ.test,
--        diego.martinez@univ.test, elena.vargas@univ.test, fabian.lopez@univ.test,
--        gabriela.rios@univ.test, hugo.mendoza@univ.test, ivan.sanchez@univ.test,
--        julia.herrera@univ.test, kevin.duarte@univ.test, lucia.ramirez@univ.test
--   3. Ejecutar este archivo en el SQL Editor de Supabase (rol postgres).
--
-- Notas:
--   * Los triggers de publicaciones/comentarios/votos/reportes fuerzan
--     autor_id/usuario_id/reportante_id := auth.uid(). Como el editor SQL no trae
--     sesión, este script simula la sesión de cada usuario con
--     request.jwt.claims + request.jwt.claim.sub antes de cada inserción.
--   * Idempotente: si ya existen publicaciones con estos títulos, no hace nada.

do $$
declare
  -- usuarios de prueba (resueltos desde auth.users)
  u_alice     uuid;
  u_bruno     uuid;
  u_camila    uuid;
  u_diego     uuid;
  u_elena     uuid;
  u_fabian    uuid;
  u_gabriela  uuid;
  u_hugo      uuid;
  u_ivan      uuid;
  u_julia     uuid;
  u_kevin     uuid;
  u_lucia     uuid;
  users       uuid[];

  -- canales
  c_general     uuid;
  c_ingenieria  uuid;
  c_vida        uuid;

  -- catálogos (maestra.id_maestra es integer)
  e_pub        integer;  -- estado_publicacion.publicado
  e_pend       integer;  -- estado_reporte.pendiente
  p_estudiante integer;
  p_docente    integer;
  p_egresado   integer;

  -- datos por usuario (índice = orden de users)
  aliases text[] := array['AliceR','BrunoT','CamiO','DiegoM','Elenita','FabL','GabyR','HugoM','IvanS','JuliH','KevinD','LuciR'];
  p_tipos text[] := array['estudiante','estudiante','estudiante','estudiante','docente','estudiante','estudiante','estudiante','estudiante','egresado','estudiante','estudiante'];
  bios    text[] := array[
    'Estudiante de Sistemas. Le gusta resolver dudas y compartir recursos.',
    'Curioso, práctico y siempre dispuesto a echar una mano.',
    'Apasionada por la organización de eventos del campus.',
    'Fan de datos, bugs y soluciones limpias.',
    'Docente de Programación. Promueve el aprendizaje colaborativo.',
    'Le encanta el deporte y la tecnología.',
    'Siempre comparte apuntes útiles.',
    'Resolver ejercicios en grupo es lo suyo.',
    'Curioso, lee todo antes de preguntar.',
    'Egresada de Medicina, vuelve a compartir oportunidades.',
    'Marketplace y tips para sobrevivir al semestre.',
    'Organizada, siempre deja todo claro en comentarios.'
  ];
  vers   boolean[] := array[true,false,false,false,true,false,false,false,false,true,false,false];

  -- títulos de las 24 publicaciones (deben calzar 1 a 1 con el VALUES de abajo)
  titles text[] := array[
    'Aviso: Parcial de Programación II',
    'Duda sobre recursividad',
    'VS Code + Flutter tips',
    'Convocatoria: Día del Estudiante',
    'Material de estudio Git',
    'Partido interfacultades',
    'Apuntes de Base de Datos',
    'El cafetín hoy estuvo brutal',
    'IA para estudiar',
    'Oportunidad de pasantía (Salud)',
    'Venta: Libro de Algoritmos',
    'Venta: Mouse inalámbrico',
    'Venta: Maleta para laptop',
    'Perdido: Cartera negra',
    'Perdido: Audífonos',
    'Encontrado: Cartera',
    'Encontrado: Llave USB',
    'Evento: Charla IA aplicada',
    'Taller: Git y GitHub',
    'Jornada de donación de sangre',
    'Se rumora que hay torta gratis hoy',
    'Tips para sobrevivir al semestre',
    '¿Debo aprender Rust o Go?',
    'Consulta anónima: estrés por parciales'
  ];
  post_ids     uuid[];
  post_authors uuid[];
  c_ids        uuid[];
  c_authors    uuid[];
  rep_com      uuid;
begin
  ---------------------------------------------------------------------------
  -- 0) Resolver usuarios de auth.users
  ---------------------------------------------------------------------------
  select id into u_alice    from auth.users where lower(email) = 'alice.rivera@univ.test';
  select id into u_bruno    from auth.users where lower(email) = 'bruno.torres@univ.test';
  select id into u_camila   from auth.users where lower(email) = 'camila.ortiz@univ.test';
  select id into u_diego    from auth.users where lower(email) = 'diego.martinez@univ.test';
  select id into u_elena    from auth.users where lower(email) = 'elena.vargas@univ.test';
  select id into u_fabian   from auth.users where lower(email) = 'fabian.lopez@univ.test';
  select id into u_gabriela from auth.users where lower(email) = 'gabriela.rios@univ.test';
  select id into u_hugo     from auth.users where lower(email) = 'hugo.mendoza@univ.test';
  select id into u_ivan     from auth.users where lower(email) = 'ivan.sanchez@univ.test';
  select id into u_julia    from auth.users where lower(email) = 'julia.herrera@univ.test';
  select id into u_kevin    from auth.users where lower(email) = 'kevin.duarte@univ.test';
  select id into u_lucia    from auth.users where lower(email) = 'lucia.ramirez@univ.test';

  if u_alice is null or u_bruno is null or u_camila is null or u_diego is null
     or u_elena is null or u_fabian is null or u_gabriela is null or u_hugo is null
     or u_ivan is null or u_julia is null or u_kevin is null or u_lucia is null then
    raise exception 'Faltan usuarios en auth.users. Crea primero estos correos en Supabase > Authentication > Users: alice.rivera@univ.test, bruno.torres@univ.test, camila.ortiz@univ.test, diego.martinez@univ.test, elena.vargas@univ.test, fabian.lopez@univ.test, gabriela.rios@univ.test, hugo.mendoza@univ.test, ivan.sanchez@univ.test, julia.herrera@univ.test, kevin.duarte@univ.test, lucia.ramirez@univ.test';
  end if;
  users := array[u_alice, u_bruno, u_camila, u_diego, u_elena, u_fabian,
                 u_gabriela, u_hugo, u_ivan, u_julia, u_kevin, u_lucia];

  -- Guard de idempotencia
  if exists (select 1 from public.publicaciones where titulo = any (titles)) then
    raise notice 'El seed de demo ya fue aplicado; nada que hacer.';
    return;
  end if;

  ---------------------------------------------------------------------------
  -- 1) Catálogos y canales base
  ---------------------------------------------------------------------------
  select id into c_general    from public.canales where slug = 'comunidad-general';
  select id into c_ingenieria from public.canales where slug = 'ingenieria';
  select id into c_vida       from public.canales where slug = 'vida-universitaria';
  if c_general is null or c_ingenieria is null or c_vida is null then
    raise exception 'Faltan canales base. Ejecuta primero supabase/seed.sql.';
  end if;

  e_pub        := public.id_maestra('estado_publicacion', 'publicado');
  e_pend       := public.id_maestra('estado_reporte', 'pendiente');
  p_estudiante := public.id_maestra('tipo_perfil', 'estudiante');
  p_docente    := public.id_maestra('tipo_perfil', 'docente');
  p_egresado   := public.id_maestra('tipo_perfil', 'egresado');
  if e_pub is null or e_pend is null or p_estudiante is null or p_docente is null or p_egresado is null then
    raise exception 'Catálogos de maestra incompletos. Ejecuta la migración inicial y supabase/seed.sql.';
  end if;

  ---------------------------------------------------------------------------
  -- 2) Perfiles (12)
  ---------------------------------------------------------------------------
  for i in 1..12 loop
    insert into public.perfiles (id, alias, tipo_perfil_id, programa_id, sede_id, biografia, es_verificada)
    values (
      users[i],
      aliases[i],
      case p_tipos[i] when 'docente' then p_docente when 'egresado' then p_egresado else p_estudiante end,
      public.id_maestra('programa', case when users[i] = u_julia then 'medicina' else 'ingenieria_sistemas' end),
      public.id_maestra('sede', 'riohacha'),
      bios[i],
      vers[i]
    )
    on conflict (id) do update set
      alias          = excluded.alias,
      tipo_perfil_id = excluded.tipo_perfil_id,
      programa_id    = excluded.programa_id,
      sede_id        = excluded.sede_id,
      biografia      = excluded.biografia,
      es_verificada  = excluded.es_verificada;
  end loop;

  ---------------------------------------------------------------------------
  -- 3) Publicaciones (24) - una sentencia por autor con su sesión simulada
  ---------------------------------------------------------------------------
  for a_ord in 1..12 loop
    perform set_config('request.jwt.claims',
      json_build_object('sub', users[a_ord]::text, 'role', 'authenticated')::text, true);
    perform set_config('request.jwt.claim.sub', users[a_ord]::text, true);

    insert into public.publicaciones
      (autor_id, canal_id, tipo_id, categoria_id, estado_id, titulo, cuerpo, anonimo, metadatos, creado_en, actualizado_en)
    select
      users[a_ord],
      (select id from public.canales where slug = v.canal),
      public.id_maestra('tipo_publicacion', v.tipo),
      public.id_maestra('categoria_publicacion', v.cat),
      e_pub,
      v.titulo,
      v.cuerpo,
      v.anonimo,
      v.meta::jsonb,
      now() - make_interval(hours => v.age),
      now() - make_interval(hours => v.age)
    from (values
      (1,'ingenieria','aviso','academico','Aviso: Parcial de Programación II','El parcial se realizará el viernes a las 7:00 a.m. en el salón 302. Traer lápiz y carnet. No se permite el uso de calculadora.',false,'{}',162),
      (1,'ingenieria','discusion','academico','Duda sobre recursividad','¿Alguien me explica la diferencia entre recursividad directa e indirecta con un ejemplo corto?',false,'{}',156),
      (2,'ingenieria','discusion','tecnologia','VS Code + Flutter tips','Comparto atajos que me han ahorrado mucho tiempo para trabajar con Flutter. ¿Qué atajos usan ustedes?',false,'{}',150),
      (3,'vida-universitaria','discusion','eventos','Convocatoria: Día del Estudiante','Estamos organizando actividades para el Día del Estudiante. ¿Qué propuesta les gustaría ver?',false,'{}',144),
      (4,'ingenieria','discusion','academico','Material de estudio Git','Subo este pequeño resumen de Git por si alguien lo necesita para el taller.',false,'{}',138),
      (6,'vida-universitaria','discusion','deportes','Partido interfacultades','¿Quién se anima a inscribirse para el torneo de fútbol interfacultades este semestre?',false,'{}',132),
      (7,'ingenieria','discusion','academico','Apuntes de Base de Datos','Dejo mis apuntes de normalización organizados por temas. Espero les sirvan.',false,'{}',126),
      (8,'vida-universitaria','discusion','chisme','El cafetín hoy estuvo brutal','El cafetín llenísimo a las 10:00. ¿Siempre pasa los viernes?',false,'{}',120),
      (9,'ingenieria','discusion','tecnologia','IA para estudiar','¿Qué herramientas de IA usan para estudiar sin hacer trampa?',false,'{}',114),
      (10,'vida-universitaria','aviso','vida_universitaria','Oportunidad de pasantía (Salud)','Convocatoria para pasantía en área comunitaria. Plazo hasta el viernes. Interesados escriban por interno.',false,'{}',108),
      (11,'vida-universitaria','venta','marketplace','Venta: Libro de Algoritmos','Libro en buen estado, $40.000 COP. Entrega en entrada principal.',false,'{"precio": 40000, "moneda": "COP", "lugar": "Entrada principal", "disponible": true}',102),
      (12,'vida-universitaria','venta','marketplace','Venta: Mouse inalámbrico','Mouse Logitech en perfecto estado, $60.000 COP. Disponible hoy.',false,'{"precio": 60000, "moneda": "COP", "lugar": "Biblioteca", "disponible": true}',96),
      (2,'vida-universitaria','venta','marketplace','Venta: Maleta para laptop','Maleta acolchada, casi nueva. $70.000 COP.',false,'{"precio": 70000, "moneda": "COP", "lugar": "Bloque A", "disponible": true}',90),
      (4,'vida-universitaria','perdido','marketplace','Perdido: Cartera negra','Perdí mi cartera negra cerca del cafetín hace unos días entre 12:00 y 13:00. Recompensa simbólica.',false,'{"fecha": "2026-10-13", "lugar": "Cafetín", "recompensa": 15000}',84),
      (7,'vida-universitaria','perdido','marketplace','Perdido: Audífonos','Audífonos JBL perdidos en el salón 205 hace unos días. Si los encontraron, avísenme por favor.',false,'{"fecha": "2026-10-12", "lugar": "Salón 205"}',78),
      (8,'vida-universitaria','encontrado','marketplace','Encontrado: Cartera','Encontré una cartera negra en la plazoleta. Si coincide con lo que reportaron, contactenme para la entrega.',false,'{"fecha": "2026-10-13", "lugar": "Plazoleta central", "entregado": false}',72),
      (9,'vida-universitaria','encontrado','marketplace','Encontrado: Llave USB','Llave USB encontrada en la sala de cómputo. Para reclamar, describir el contenido.',false,'{"fecha": "2026-10-14", "lugar": "Sala de cómputo", "entregado": false}',66),
      (3,'vida-universitaria','evento','eventos','Evento: Charla IA aplicada','Charla sobre IA aplicada a proyectos estudiantiles. Jueves 5:00 p.m. en el Auditorio.',false,'{"inicio": "2026-10-22T17:00:00", "lugar": "Auditorio", "enlace": "https://univ.test/eventos/ia-aplicada"}',60),
      (5,'ingenieria','evento','eventos','Taller: Git y GitHub','Taller práctico para principiantes. Miércoles 3:00 p.m. en el Laboratorio 4.',false,'{"inicio": "2026-10-21T15:00:00", "lugar": "Laboratorio 4"}',54),
      (10,'vida-universitaria','evento','eventos','Jornada de donación de sangre','Jornada solidaria organizada con Bienestar. Viernes 8:00 a.m. en la plazoleta.',false,'{"inicio": "2026-10-24T08:00:00", "fin": "2026-10-24T16:00:00", "lugar": "Plazoleta central"}',48),
      (1,'vida-universitaria','discusion','chisme','Se rumora que hay torta gratis hoy','¿Alguien confirmó si hay torta en Bienestar? Solo por chisme sano.',false,'{}',42),
      (11,'vida-universitaria','discusion','general','Tips para sobrevivir al semestre','Comparto mis 5 tips infalibles para no colapsar entre parciales. ¿Qué agregan?',false,'{}',36),
      (6,'ingenieria','discusion','tecnologia','¿Debo aprender Rust o Go?','Debate sano: ¿qué lenguaje complementa mejor a Flutter o al backend para proyectos?',false,'{}',30),
      (12,'ingenieria','discusion','academico','Consulta anónima: estrés por parciales','Me gustaría saber cómo manejan el estrés antes de parciales. Pregunta anónima para abrir el espacio.',true,'{}',24)
    ) as v(a, canal, tipo, cat, titulo, cuerpo, anonimo, meta, age)
    where v.a = a_ord;
  end loop;

  select
    array_agg(id order by array_position(titles, titulo)),
    array_agg(autor_id order by array_position(titles, titulo))
  into post_ids, post_authors
  from public.publicaciones
  where titulo = any (titles);

  if coalesce(array_length(post_ids, 1), 0) <> 24 then
    raise exception 'Se esperaban 24 publicaciones de demo y quedaron %', coalesce(array_length(post_ids, 1), 0);
  end if;

  ---------------------------------------------------------------------------
  -- 4) Comentarios (36, 2 marcados como solución) - sesión por autor
  ---------------------------------------------------------------------------
  for a_ord in 1..12 loop
    perform set_config('request.jwt.claims',
      json_build_object('sub', users[a_ord]::text, 'role', 'authenticated')::text, true);
    perform set_config('request.jwt.claim.sub', users[a_ord]::text, true);

    insert into public.comentarios (publicacion_id, autor_id, cuerpo, es_solucion, creado_en, actualizado_en)
    select
      post_ids[v.pidx],
      users[a_ord],
      v.cuerpo,
      v.sol,
      p.creado_en + make_interval(hours => v.after_h),
      p.creado_en + make_interval(hours => v.after_h)
    from (values
      (4, 1,'Gracias por el aviso. ¿Se puede llevar el carnet digital?',false,3),
      (2, 1,'Confirmo, el salón es 302.',false,5),
      (8, 2,'Directa: una función se llama a sí misma. Indirecta: A llama a B y B llama a A.',true,6),
      (6, 2,'A mí me sirvió ver el ejemplo de factorial antes que el de Fibonacci.',false,8),
      (3, 3,'El atajo para abrir la terminal en VS Code me cambió la vida: Ctrl + `.',false,4),
      (5, 3,'Agrego Ctrl + Shift + P para la paleta de comandos.',false,7),
      (7, 4,'Propongo una dinámica con música y un concurso de memes.',false,5),
      (8, 4,'Yo puedo ayudar con el sonido y la logística.',false,9),
      (10,5,'Excelente material. Recuerden que el taller es el miércoles.',false,6),
      (2, 5,'Me sirvió para despegarme de la guía oficial, gracias.',false,10),
      (1, 6,'Yo me inscribo, juego en la delantera.',false,5),
      (9, 6,'¿Cuántos necesitan? Puedo anotar a tres más.',false,8),
      (3, 7,'Los diagramas de la tercera parte están perfectos.',false,6),
      (8, 7,'Guardado. ¿Tienes de transacciones?',false,9),
      (4, 8,'Jajaja hoy sí estaba lleno, llegué tarde a clase.',false,4),
      (1, 8,'Los viernes siempre son así.',false,7),
      (7, 9,'Uso IA para explicar conceptos, nunca para entregar tareas.',false,5),
      (2, 9,'Gemini con fotos de la pizarra va muy bien.',false,8),
      (11,10,'¿Aplica para recién graduados también?',false,6),
      (12,11,'¿El libro es la edición en español?',false,4),
      (5, 11,'Yo lo compro si Kevin no responde :).',false,7),
      (6, 12,'¿Cuántos DPI? Para ver si me sirve.',false,3),
      (9, 13,'¿La maleta cabe un laptop de 15.6?',false,5),
      (1, 14,'Ojalá la encuentres, a mí me robaron una igual.',false,6),
      (10,14,'Revisa en Bienestar, ahí llevan el objeto perdido.',false,9),
      (8, 15,'Yo los vi en la sala 302 la semana pasada.',false,4),
      (4, 16,'¿Tenía documentos dentro? Coincide con lo que perdí.',false,5),
      (11,16,'Un héroe sin capa.',false,8),
      (7, 17,'La mía decía "BD II - Lab". Si coincide, es mía.',false,4),
      (2, 18,'Voy, llevo a dos compañeros.',false,6),
      (6, 18,'¿Habrá grabación para los que trabajamos?',false,9),
      (4, 19,'Me apunto, nunca usé bien un merge.',false,5),
      (12,20,'Voy temprano, la cola es larga.',false,7),
      (8, 21,'Yo vi la torta en el segundo piso, confirmado.',false,3),
      (9, 23,'Go es más simple para empezar; Rust te hace entender la memoria.',true,6),
      (3, 24,'Respira, date un descanso cada 50 minutos, funciona.',false,5)
    ) as v(a, pidx, cuerpo, sol, after_h)
    join public.publicaciones p on p.id = post_ids[v.pidx]
    where v.a = a_ord;
  end loop;

  select
    array_agg(id order by cuerpo),
    array_agg(autor_id order by cuerpo)
  into c_ids, c_authors
  from public.comentarios
  where publicacion_id = any (post_ids);

  if coalesce(array_length(c_ids, 1), 0) <> 36 then
    raise exception 'Se esperaban 36 comentarios de demo y quedaron %', coalesce(array_length(c_ids, 1), 0);
  end if;

  ---------------------------------------------------------------------------
  -- 5) Votos (~140) - sin votos propios, mezcla de +1 y -1
  ---------------------------------------------------------------------------
  for i in 1..array_length(post_ids, 1) loop
    for u_ord in 1..12 loop
      if ((i * 3 + u_ord) % 4 = 0) and users[u_ord] <> post_authors[i] then
        perform set_config('request.jwt.claims',
          json_build_object('sub', users[u_ord]::text, 'role', 'authenticated')::text, true);
        perform set_config('request.jwt.claim.sub', users[u_ord]::text, true);
        insert into public.votos (publicacion_id, valor)
        values (post_ids[i], case when (i + u_ord) % 5 = 0 then -1 else 1 end)
        on conflict do nothing;
      end if;
    end loop;
  end loop;

  for j in 1..array_length(c_ids, 1) loop
    for u_ord in 1..12 loop
      if ((j * 2 + u_ord) % 6 = 0) and users[u_ord] <> c_authors[j] then
        perform set_config('request.jwt.claims',
          json_build_object('sub', users[u_ord]::text, 'role', 'authenticated')::text, true);
        perform set_config('request.jwt.claim.sub', users[u_ord]::text, true);
        insert into public.votos (comentario_id, valor)
        values (c_ids[j], case when (j + u_ord) % 6 = 0 then -1 else 1 end)
        on conflict do nothing;
      end if;
    end loop;
  end loop;

  ---------------------------------------------------------------------------
  -- 6) Reportes (6 pendientes, todos distintos)
  ---------------------------------------------------------------------------
  select id into rep_com
  from public.comentarios
  where cuerpo = 'Yo lo compro si Kevin no responde :).';
  if rep_com is null then
    raise exception 'No se encontró el comentario de demo usado para reportes.';
  end if;

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_hugo::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', u_hugo::text, true);
  insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, descripcion, estado_id)
  values (post_ids[21], null, u_hugo, public.id_maestra('motivo_reporte', 'desinformacion'),
          'Publica rumores sin verificar sobre comida gratuita.', e_pend);

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_kevin::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', u_kevin::text, true);
  insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, descripcion, estado_id)
  values (post_ids[12], null, u_kevin, public.id_maestra('motivo_reporte', 'otro'),
          'Pide pago por adelantado y no responde mensajes.', e_pend);

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_camila::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', u_camila::text, true);
  insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, descripcion, estado_id)
  values (null, rep_com, u_camila, public.id_maestra('motivo_reporte', 'otro'),
          'Comentario fuera de contexto en una publicación de venta.', e_pend);

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_ivan::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', u_ivan::text, true);
  insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, descripcion, estado_id)
  values (post_ids[8], null, u_ivan, public.id_maestra('motivo_reporte', 'otro'),
          'El chisme se salió de control y hay comentarios agresivos.', e_pend);

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_fabian::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', u_fabian::text, true);
  insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, descripcion, estado_id)
  values (post_ids[22], null, u_fabian, public.id_maestra('motivo_reporte', 'otro'),
          'Parece contenido repetido para ganar puntos.', e_pend);

  perform set_config('request.jwt.claims',
    json_build_object('sub', u_diego::text, 'role', 'authenticated')::text, true);
  perform set_config('request.jwt.claim.sub', u_diego::text, true);
  insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, descripcion, estado_id)
  values (post_ids[11], null, u_diego, public.id_maestra('motivo_reporte', 'otro'),
          'Sospecho que el libro no está en el estado que dice.', e_pend);

  raise notice 'Seed de demo aplicado: 12 perfiles, 24 publicaciones, 36 comentarios, % votos y 6 reportes.',
    (select count(*) from public.votos v where v.publicacion_id = any (post_ids) or v.comentario_id = any (c_ids));
end $$;

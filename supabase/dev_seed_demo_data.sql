-- Datos de DEMO para desarrollo (NO aplicar en producción)
-- Requiere que existan los usuarios de auth.users con los UUIDs indicados
-- (ver docs/dev_seed_instructions.md o el paso previo). Idempotente con ON CONFLICT.

do $$
declare
  -- UUIDs de usuarios de prueba (coinciden con los emails sugeridos)
  u_alice   uuid := '11111111-1111-1111-1111-111111111111';
  u_bruno   uuid := '22222222-2222-2222-2222-222222222222';
  u_camila  uuid := '33333333-3333-3333-3333-333333333333';
  u_diego   uuid := '44444444-4444-4444-4444-444444444444';
  u_elena   uuid := '55555555-5555-5555-5555-555555555555';
  u_fabian  uuid := '66666666-6666-6666-6666-666666666666';
  u_gabriela uuid := '77777777-7777-7777-7777-777777777777';
  u_hugo    uuid := '88888888-8888-8888-8888-888888888888';
  u_ivan    uuid := '99999999-9999-9999-9999-999999999999';
  u_julia   uuid := 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  u_kevin   uuid := 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb';
  u_lucia   uuid := 'cccccccc-cccc-cccc-cccc-cccccccccccc';

  -- Canales
  c_general uuid;
  c_ingenieria uuid;
  c_vida uuid;

  -- Tipos/categorías (ids de maestra)
  t_disc   uuid; t_aviso uuid; t_venta uuid; t_perd uuid; t_enc uuid; t_ev uuid;
  cat_acad uuid; cat_vida uuid; cat_chisme uuid; cat_dep uuid; cat_evcat uuid;
  cat_mkt  uuid; cat_tec uuid; cat_gen uuid;
  m_acoso  uuid; m_spam uuid; m_falso uuid; m_ofens uuid; m_ilegal uuid; m_otro uuid;
begin
  -- Obtener IDs de canales
  select id_canal into c_general from public.canales where slug='comunidad-general';
  select id_canal into c_ingenieria from public.canales where slug='ingenieria';
  select id_canal into c_vida from public.canales where slug='vida-universitaria';

  -- Obtener IDs de maestra (tipos)
  select id_maestra into t_disc from public.maestra where grupo='tipo_publicacion' and codigo='discusion';
  select id_maestra into t_aviso from public.maestra where grupo='tipo_publicacion' and codigo='aviso';
  select id_maestra into t_venta from public.maestra where grupo='tipo_publicacion' and codigo='venta';
  select id_maestra into t_perd from public.maestra where grupo='tipo_publicacion' and codigo='perdido';
  select id_maestra into t_enc  from public.maestra where grupo='tipo_publicacion' and codigo='encontrado';
  select id_maestra into t_ev   from public.maestra where grupo='tipo_publicacion' and codigo='evento';

  -- Categorías
  select id_maestra into cat_acad  from public.maestra where grupo='categoria_publicacion' and codigo='academico';
  select id_maestra into cat_vida  from public.maestra where grupo='categoria_publicacion' and codigo='vida_universitaria';
  select id_maestra into cat_chisme from public.maestra where grupo='categoria_publicacion' and codigo='chisme';
  select id_maestra into cat_dep   from public.maestra where grupo='categoria_publicacion' and codigo='deportes';
  select id_maestra into cat_evcat from public.maestra where grupo='categoria_publicacion' and codigo='eventos';
  select id_maestra into cat_mkt   from public.maestra where grupo='categoria_publicacion' and codigo='marketplace';
  select id_maestra into cat_tec   from public.maestra where grupo='categoria_publicacion' and codigo='tecnologia';
  select id_maestra into cat_gen   from public.maestra where grupo='categoria_publicacion' and codigo='general';

  -- Motivos reporte
  select id_maestra into m_acoso  from public.maestra where grupo='motivo_reporte' and codigo='acoso';
  select id_maestra into m_spam   from public.maestra where grupo='motivo_reporte' and codigo='spam';
  select id_maestra into m_falso  from public.maestra where grupo='motivo_reporte' and codigo='informacion_falsa';
  select id_maestra into m_ofens  from public.maestra where grupo='motivo_reporte' and codigo='contenido_ofensivo';
  select id_maestra into m_ilegal from public.maestra where grupo='motivo_reporte' and codigo='contenido_ilegal';
  select id_maestra into m_otro   from public.maestra where grupo='motivo_reporte' and codigo='otro';

  -- 1) PERFILES (complemento de datos)
  update public.perfiles set
    alias = 'AliceR', bio = 'Estudiante de Sistemas. Le gusta resolver dudas y compartir recursos.', avatar_url = null, programa_id = (select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id = (select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada = true
  where id = u_alice;
  update public.perfiles set alias='BrunoT', bio='Curioso, práctico y siempre dispuesto a echar una mano.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_bruno;
  update public.perfiles set alias='CamiO', bio='Apasionada por la organización de eventos del campus.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_camila;
  update public.perfiles set alias='DiegoM', bio='Fan de datos, bugs y soluciones limpias.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_diego;
  update public.perfiles set alias='Elenita', bio='Docente de Programación. Promueve el aprendizaje colaborativo.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=true where id=u_elena;
  update public.perfiles set alias='FabL', bio='Le encanta el deporte y la tecnología.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_fabian;
  update public.perfiles set alias='GabyR', bio='Siempre comparte apuntes útiles.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_gabriela;
  update public.perfiles set alias='HugoM', bio='Resolver ejercicios en grupo es lo suyo.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_hugo;
  update public.perfiles set alias='IvanS', bio='Curioso, lee todo antes de preguntar.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_ivan;
  update public.perfiles set alias='JuliH', bio='Egresada de Medicina, vuelve a compartir oportunidades.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='medicina'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=true where id=u_julia;
  update public.perfiles set alias='KevinD', bio='Marketplace y tips para sobrevivir al semestre.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_kevin;
  update public.perfiles set alias='LuciR', bio='Organizada, siempre deja todo claro en comentarios.', programa_id=(select id_maestra from public.maestra where grupo='programa' and codigo='ingenieria_sistemas'), sede_id=(select id_maestra from public.maestra where grupo='sede' and codigo='riohacha'), es_verificada=false where id=u_lucia;

  -- 2) PUBLICACIONES (24)
  insert into public.publicaciones (autor_id, canal_id, tipo_publicacion_id, categoria_id, titulo, cuerpo, anonimo, metadatos) values
  (u_elena,c_ingenieria,t_aviso,cat_acad,'Aviso: Parcial de Programación II','El parcial se realizará el viernes a las 7:00 a.m. en el salón 302. Traer calculadora no necesaria, solo lápiz y carnet.',false,null),
  (u_alice,c_ingenieria,t_disc,cat_acad,'Duda sobre recursividad','¿Alguien me explica la diferencia entre recursividad directa e indirecta con un ejemplo corto?',false,null),
  (u_bruno,c_ingenieria,t_disc,cat_tec,'VS Code + Flutter tips','Comparto atajos que me han ahorrado mucho tiempo para trabajar con Flutter. ¿Qué atajos usan ustedes?',false,null),
  (u_camila,c_vida,t_disc,cat_evcat,'Convocatoria: Día del Estudiante','Estamos organizando actividades para el Día del Estudiante. ¿Qué propuesta les gustaría ver?',false,null),
  (u_diego,c_ingenieria,t_disc,cat_acad,'Material de estudio Git','Subo este pequeño resumen de Git por si alguien lo necesita para el taller.',false,null),
  (u_fabian,c_vida,t_disc,cat_dep,'Partido interfacultades','¿Quién se anima a inscribirse para el torneo de fútbol interfacultades este semestre?',false,null),
  (u_gabriela,c_ingenieria,t_disc,cat_acad,'Apuntes de Base de Datos','Dejo mis apuntes de normalización organizados por temas. Espero les sirvan.',false,null),
  (u_hugo,c_vida,t_disc,cat_chisme,'El cafetín hoy estuvo brutal','El cafetín llenísimo a las 10:00. ¿Siempre pasa los viernes?',false,null),
  (u_ivan,c_ingenieria,t_disc,cat_tec,'IA para estudiar','¿Qué herramientas de IA usan para estudiar sin hacer trampa?',false,null),
  (u_julia,c_vida,t_aviso,cat_vida,'Oportunidad de pasantía (Salud)','Convocatoria para pasantía en área comunitaria. Plazo hasta el viernes. Interesados escriban por interno.',false,null),
  (u_kevin,c_vida,t_venta,cat_mkt,'Venta: Libro de Algoritmos','Libro en buen estado, $40.000 COP. Entrega en entrada principal.',false,jsonb_build_object('precio',40000,'moneda','COP','lugar','Entrada principal','disponible',true)),
  (u_lucia,c_vida,t_venta,cat_mkt,'Venta: Mouse inalámbrico','Mouse Logitech en perfecto estado, $60.000 COP. Disponible hoy.',false,jsonb_build_object('precio',60000,'moneda','COP','lugar','Biblioteca','disponible',true)),
  (u_bruno,c_vida,t_venta,cat_mkt,'Venta: Maleta para laptop','Maleta acolchada, casi nueva. $70.000 COP.',false,jsonb_build_object('precio',70000,'moneda','COP','lugar','Bloque A','disponible',true)),
  (u_diego,c_vida,t_perd,cat_mkt,'Perdido: Cartera negra','Perdí mi cartera negra cerca del cafetín ayer entre 12:00–13:00. Recompensa simbólica.',false,jsonb_build_object('fecha','2026-10-14','lugar','Cafetín','recompensa',15000)),
  (u_gabriela,c_vida,t_perd,cat_mkt,'Perdido: Audífonos','Audífonos JBL perdidos en salón 205 el miércoles. Si los encontraron, avísenme por favor.',false,jsonb_build_object('fecha','2026-10-13','lugar','Salón 205')),
  (u_hugo,c_vida,t_enc,cat_mkt,'Encontrado: Cartera','Encontré una cartera negra en la plazoleta. Descripción coincide con reporte. Contactar para entrega.',false,jsonb_build_object('fecha','2026-10-14','lugar','Plazoleta central','entregado',false)),
  (u_ivan,c_vida,t_enc,cat_mkt,'Encontrado: Llave USB','Llave USB encontrada en sala de cómputo. Para reclamar con descripción del contenido.',false,jsonb_build_object('fecha','2026-10-15','lugar','Sala de cómputo','entregado',false)),
  (u_camila,c_vida,t_ev,cat_evcat,'Evento: Charla IA aplicada','Charla sobre IA aplicada a proyectos estudiantiles. Jueves 5:00 p.m. en Auditorio.',false,jsonb_build_object('inicio','2026-10-22T17:00:00','lugar','Auditorio','enlace','https://univ.test/eventos/ia-aplicada')),
  (u_elena,c_ingenieria,t_ev,cat_evcat,'Taller: Git y GitHub','Taller práctico para principiantes. Miércoles 3:00 p.m. en Lab 4.',false,jsonb_build_object('inicio','2026-10-21T15:00:00','lugar','Lab 4')),
  (u_julia,c_vida,t_ev,cat_evcat,'Jornada de donación de sangre','Jornada solidaria organizada con bienestar. Viernes 8:00 a.m. en plazoleta.',false,jsonb_build_object('inicio','2026-10-24T08:00:00','fin','2026-10-24T16:00:00','lugar','Plazoleta central')),
  (u_alice,c_vida,t_disc,cat_chisme,'Se rumora que hay torta gratis hoy','¿Alguien confirmó si hay torta en Bienestar? (sólo por chisme sano)',false,null),
  (u_kevin,c_vida,t_disc,cat_gen,'Tips para sobrevivir al semestre','Comparto mis 5 tips infalibles para no colapsar entre parciales. ¿Qué agregan?',false,null),
  (u_fabian,c_ingenieria,t_disc,cat_tec,'¿Debo aprender Rust o Go?','Debate sano: ¿qué lenguaje complementa mejor Flutter/Backend para proyectos?',false,null),
  (u_lucia,c_ingenieria,t_disc,cat_acad,'Consulta anónima: estrés por parciales','Me gustaría saber cómo manejan el estrés antes de parciales. Pregunta anónima para abrir espacio.',true,null)
  on conflict do nothing;
end $$;

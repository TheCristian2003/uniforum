-- Pruebas de integridad y RLS del esquema V1.1.
--
-- Como ejecutarlas:
--   Opcion A (recomendada): Supabase -> SQL Editor -> New query -> pegar este
--   archivo -> Run. Debe salir una fila con "TODAS LAS PRUEBAS PASARON".
--   Opcion B: con psql contra la cadena de conexion de DESARROLLO:
--     psql "$DATABASE_URL_DEV" -v ON_ERROR_STOP=1 -f supabase/tests/integrity_and_rls_test.sql
--
--   Requiere una instancia de DESARROLLO descartable con las migraciones
--   aplicadas. NUNCA ejecutar contra produccion.
--
-- El script se envuelve en una transaccion que termina en ROLLBACK: no deja
-- datos. Si una comprobacion falla, lanza una excepcion y aborta.
--
-- Estado: secciones 1–9 ejecutadas y en verde sobre la instancia de desarrollo
-- el 2026-10-11 (salida "TODAS LAS PRUEBAS PASARON"). Las secciones 10–12
-- (moderación, restricciones y distintivos) están pendientes de ejecutar en
-- desarrollo.

begin;

create function pg_temp.fail(msg text) returns void language plpgsql as $$
begin
  raise exception 'TEST FAIL: %', msg;
end $$;

-- Espera que el comando falle.
create function pg_temp.expect_error(cmd text) returns void language plpgsql as $$
declare ok boolean := false;
begin
  begin
    execute cmd;
  exception when others then
    ok := true;
  end;
  if not ok then
    perform pg_temp.fail('se esperaba un error para: ' || cmd);
  end if;
end $$;

-- Espera que el comando tenga exito.
create function pg_temp.expect_ok(cmd text) returns void language plpgsql as $$
begin
  begin
    execute cmd;
  exception when others then
    perform pg_temp.fail('comando inesperadamente fallo (' || sqlerrm || '): ' || cmd);
  end;
end $$;

-- Simula la sesion de un usuario autenticado para auth.uid()/auth.jwt().
-- Fija tanto request.jwt.claim.sub como request.jwt.claims.
create function pg_temp.act_as(p_uid text, p_app_role text default null)
returns void language plpgsql as $$
declare
  claims jsonb;
begin
  claims := jsonb_build_object('sub', p_uid);
  if p_app_role is not null then
    claims := claims || jsonb_build_object(
      'app_metadata', jsonb_build_object('app_role', p_app_role)
    );
  end if;
  perform set_config('request.jwt.claim.sub', p_uid, true);
  perform set_config('request.jwt.claims', claims::text, true);
end $$;

-- Helper para leer catalogos por grupo/codigo.
create or replace function pg_temp.cat(p_grupo text, p_codigo text) returns integer
language sql stable as $$
  select id_maestra from public.maestra where grupo = p_grupo and codigo = p_codigo;
$$;

-- Datos de apoyo: dos usuarios de Auth. El trigger crea sus perfiles.
insert into auth.users (id, instance_id, aud, role, email) values
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'u1@example.test'),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'u2@example.test');

-- ============================================================
-- 1. maestra: UNIQUE (grupo, codigo), permitiendo mismo codigo en otro grupo
-- ============================================================
do $$
begin
  perform pg_temp.expect_error(
    'insert into public.maestra (grupo, codigo, nombre) values (''tipo_perfil'', ''estudiante'', ''Duplicado'')'
  );
  -- Mismo codigo en grupo distinto debe permitirse.
  perform pg_temp.expect_ok(
    'insert into public.maestra (grupo, codigo, nombre) values (''grupo_prueba'', ''estudiante'', ''Permitido'')'
  );
end $$;

-- ============================================================
-- 2. votos: exactamente un objetivo, valor en (1,-1), sin autocvote ni duplicados
-- ============================================================
do $$
declare
  v_pub uuid;
begin
  insert into public.canales (nombre, slug, tipo_canal_id)
  values ('Canal Test', 'canal-test', pg_temp.cat('tipo_canal', 'general'));

  -- Publicacion de u1 (autoria forzada por trigger a partir de la sesion).
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
  select c.id, pg_temp.cat('tipo_publicacion','discusion'),
         pg_temp.cat('categoria_publicacion','general'), 'Cuerpo de prueba'
  from public.canales c where c.slug = 'canal-test'
  returning id into v_pub;

  -- A partir de aqui votamos como u2: el trigger fija usuario_id = auth.uid().
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');

  -- Dos objetivos a la vez -> debe fallar.
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, comentario_id, valor) values (%L, gen_random_uuid(), 1)',
    v_pub
  ));

  -- Cero objetivos -> debe fallar.
  perform pg_temp.expect_error('insert into public.votos (valor) values (1)');

  -- valor fuera de (1,-1) -> debe fallar.
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, valor) values (%L, 5)',
    v_pub
  ));

  -- Voto propio: la sesion pasa a ser u1 (autor) -> debe fallar por trigger.
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, valor) values (%L, 1)',
    v_pub
  ));

  -- Voto valido de u2.
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  perform pg_temp.expect_ok(format(
    'insert into public.votos (publicacion_id, valor) values (%L, 1)',
    v_pub
  ));

  -- Voto duplicado de u2 sobre la misma publicacion -> debe fallar.
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, valor) values (%L, 1)',
    v_pub
  ));
end $$;

-- ============================================================
-- 3. Puntos: idempotencia por votante+objetivo (borrar y revotar no re-premia)
-- ============================================================
do $$
declare
  v_pub uuid;
  v_voto uuid;
  v_puntos_antes integer;
  v_puntos_despues integer;
  v_eventos integer;
begin
  select id into v_pub from public.publicaciones order by creado_en desc limit 1;

  select puntos into v_puntos_antes from public.perfiles
   where id = '11111111-1111-1111-1111-111111111111';

  select id into v_voto from public.votos
   where publicacion_id = v_pub and usuario_id = '22222222-2222-2222-2222-222222222222';

  delete from public.votos where id = v_voto;
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  insert into public.votos (publicacion_id, valor) values (v_pub, 1);

  select puntos into v_puntos_despues from public.perfiles
   where id = '11111111-1111-1111-1111-111111111111';

  select count(*) into v_eventos from public.eventos_puntos
   where usuario_id = '11111111-1111-1111-1111-111111111111'
     and publicacion_id = v_pub
     and motivo_id = pg_temp.cat('motivo_puntos', 'voto_positivo_publicacion');

  if v_puntos_despues <> v_puntos_antes then
    perform pg_temp.fail('el voto repetido volvio a otorgar puntos');
  end if;
  if v_eventos <> 1 then
    perform pg_temp.fail('se esperaba un unico evento de voto positivo, hay ' || v_eventos);
  end if;
end $$;

-- ============================================================
-- 4. insignias_usuario: UNIQUE (usuario_id, insignia_id)
-- ============================================================
do $$
declare
  v_ins uuid;
begin
  select id into v_ins from public.insignias order by codigo limit 1;

  perform pg_temp.expect_ok(format(
    'insert into public.insignias_usuario (usuario_id, insignia_id) values (%L, %L)',
    '11111111-1111-1111-1111-111111111111', v_ins
  ));
  perform pg_temp.expect_error(format(
    'insert into public.insignias_usuario (usuario_id, insignia_id) values (%L, %L)',
    '11111111-1111-1111-1111-111111111111', v_ins
  ));
end $$;

-- ============================================================
-- 5. reportes: exactamente un objetivo
-- ============================================================
do $$
declare
  v_pub uuid;
begin
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  select id into v_pub from public.publicaciones order by creado_en desc limit 1;
  perform pg_temp.expect_error(format(
    'insert into public.reportes (publicacion_id, comentario_id, reportante_id, motivo_id, estado_id) values (%L, gen_random_uuid(), %L, %s, %s)',
    v_pub, '22222222-2222-2222-2222-222222222222',
    pg_temp.cat('motivo_reporte', 'otro'),
    pg_temp.cat('estado_reporte', 'pendiente')
  ));
  perform pg_temp.expect_ok(format(
    'insert into public.reportes (publicacion_id, reportante_id, motivo_id, estado_id) values (%L, %L, %s, %s)',
    v_pub, '22222222-2222-2222-2222-222222222222',
    pg_temp.cat('motivo_reporte', 'otro'),
    pg_temp.cat('estado_reporte', 'pendiente')
  ));
end $$;

-- ============================================================
-- 6. Privilegios: el cliente no ejecuta RPC internas ni escribe columnas calculadas
-- ============================================================
do $$
begin
  if has_function_privilege('authenticated',
       'public.otorgar_puntos(uuid,text,integer,text,uuid,integer)', 'EXECUTE') then
    perform pg_temp.fail('authenticated NO deberia poder ejecutar otorgar_puntos');
  end if;
  if has_function_privilege('anon',
       'public.marcar_comentario_solucion(uuid)', 'EXECUTE') then
    perform pg_temp.fail('anon NO deberia poder ejecutar marcar_comentario_solucion');
  end if;
  if not has_function_privilege('authenticated',
       'public.marcar_comentario_solucion(uuid)', 'EXECUTE') then
    perform pg_temp.fail('authenticated deberia poder ejecutar marcar_comentario_solucion');
  end if;
  if has_table_privilege('authenticated', 'public.perfiles', 'INSERT') then
    perform pg_temp.fail('authenticated NO deberia poder insertar perfiles');
  end if;
  if has_column_privilege('authenticated', 'public.perfiles', 'puntos', 'UPDATE') then
    perform pg_temp.fail('authenticated NO deberia poder actualizar puntos');
  end if;
  if has_column_privilege('authenticated', 'public.publicaciones', 'puntaje', 'UPDATE') then
    perform pg_temp.fail('authenticated NO deberia poder actualizar puntaje');
  end if;
  if not has_table_privilege('anon', 'public.maestra', 'SELECT') then
    perform pg_temp.fail('anon deberia poder leer maestra para el registro');
  end if;
end $$;

-- ============================================================
-- 7. es_rol_privilegiado lee exclusivamente app_metadata.app_role
-- ============================================================
do $$
begin
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  if public.es_rol_privilegiado() then
    perform pg_temp.fail('sin app_role no deberia ser privilegiado');
  end if;

  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111', 'moderador');
  if not public.es_rol_privilegiado() then
    perform pg_temp.fail('con app_role=moderador deberia ser privilegiado');
  end if;
end $$;

-- ============================================================
-- 8. RLS: el autor ve su publicacion oculta; otro usuario no
-- ============================================================
do $$
declare
  v_pub uuid;
  v_visibles integer;
begin
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
  select c.id, pg_temp.cat('tipo_publicacion','discusion'),
         pg_temp.cat('categoria_publicacion','general'), 'Oculta'
  from public.canales c where c.slug = 'canal-test'
  returning id into v_pub;

  -- El trigger fija estado 'publicado' en el insert; lo ocultamos despues
  -- (la moderacion real lo haria por otra via; aqui solo preparamos el caso).
  update public.publicaciones
     set estado_id = pg_temp.cat('estado_publicacion','oculto')
   where id = v_pub;

  -- Como u2, no debe verla.
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  set local role authenticated;
  select count(*) into v_visibles from public.publicaciones where id = v_pub;
  reset role;
  if v_visibles <> 0 then
    perform pg_temp.fail('u2 no deberia ver la publicacion oculta de u1');
  end if;

  -- El autor si la ve.
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  set local role authenticated;
  select count(*) into v_visibles from public.publicaciones where id = v_pub;
  reset role;
  if v_visibles <> 1 then
    perform pg_temp.fail('el autor deberia ver su publicacion oculta');
  end if;
end $$;

-- ============================================================
-- 9. Catalogos: un tipo_id fuera de grupo debe ser rechazado
-- ============================================================
do $$
begin
  perform pg_temp.expect_error(format(
    'insert into public.canales (nombre, slug, tipo_canal_id) values (''Canal malo'', ''canal-malo'', %s)',
    pg_temp.cat('tipo_publicacion', 'discusion')  -- grupo equivocado
  ));
end $$;

-- ============================================================
-- 10. Moderación: ocultar publicación y restringir usuarios
-- ============================================================
do $$
declare
  v_mod uuid := '33333333-3333-3333-3333-333333333333';
  v_tipo integer := pg_temp.cat('tipo_publicacion', 'discusion');
  v_cat integer := pg_temp.cat('categoria_publicacion', 'general');
  v_canal uuid;
  v_pub uuid;
  v_visible integer;
  v_bloqueado boolean;
begin
  -- Necesitamos un tercer usuario como moderador (auth.uid() -> perfiles).
  insert into auth.users (id, instance_id, aud, role, email) values
    (v_mod, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mod@example.test');

  insert into public.canales (nombre, slug, tipo_canal_id)
  values ('Canal Moderación', 'canal-moderacion', pg_temp.cat('tipo_canal', 'general'))
  returning id into v_canal;

  -- u2 publica contenido que luego será "oculto".
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
  values (v_canal, v_tipo, v_cat, 'Contenido de u2')
  returning id into v_pub;

  -- Un usuario sin rol no puede ocultar ni restringir.
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  perform pg_temp.expect_error(format(
    'select public.moderar_ocultar_publicacion(%L)', v_pub));
  perform pg_temp.expect_error(format(
    'select public.moderar_restringir_usuario(%L, ''spam'', 7, null)',
    '22222222-2222-2222-2222-222222222222'));

  -- Moderación oculta la publicación.
  perform pg_temp.act_as(v_mod::text, 'moderador');
  perform pg_temp.expect_ok(format(
    'select public.moderar_ocultar_publicacion(%L)', v_pub));

  if (select estado_id from public.publicaciones where id = v_pub)
     <> pg_temp.cat('estado_publicacion', 'oculto') then
    perform pg_temp.fail('la publicación no quedó en estado oculto');
  end if;

  -- Un tercero ya no la ve; el autor sí.
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  set local role authenticated;
  select count(*) into v_visible from public.publicaciones where id = v_pub;
  reset role;
  if v_visible <> 0 then
    perform pg_temp.fail('u1 no debería ver la publicación oculta de u2');
  end if;

  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  set local role authenticated;
  select count(*) into v_visible from public.publicaciones where id = v_pub;
  reset role;
  if v_visible <> 1 then
    perform pg_temp.fail('el autor debería seguir viendo su publicación oculta');
  end if;

  -- Restricción temporal de u2.
  perform pg_temp.act_as(v_mod::text, 'moderador');
  perform pg_temp.expect_ok(format(
    'select public.moderar_restringir_usuario(%L, ''Acoso reiterado'', 7, null)',
    '22222222-2222-2222-2222-222222222222'));

  -- No se permite duplicar una restricción vigente.
  perform pg_temp.expect_error(format(
    'select public.moderar_restringir_usuario(%L, ''Otra vez'', 1, null)',
    '22222222-2222-2222-2222-222222222222'));

  -- u2 no puede publicar ni comentar mientras esté restringido.
  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  if not public.usuario_restringido() then
    perform pg_temp.fail('u2 debería aparecer restringido');
  end if;

  set local role authenticated;
  v_bloqueado := false;
  begin
    insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
    values (v_canal, v_tipo, v_cat, 'Bloqueado');
  exception when others then
    v_bloqueado := true;
  end;
  reset role;
  if not v_bloqueado then
    perform pg_temp.fail('u2 restringido no debería poder publicar');
  end if;

  set local role authenticated;
  v_bloqueado := false;
  begin
    insert into public.comentarios (publicacion_id, cuerpo) values (v_pub, 'Bloqueado');
  exception when others then
    v_bloqueado := true;
  end;
  reset role;
  if not v_bloqueado then
    perform pg_temp.fail('u2 restringido no debería poder comentar');
  end if;

  -- Moderación levanta la restricción y u2 puede volver a publicar.
  perform pg_temp.act_as(v_mod::text, 'moderador');
  perform pg_temp.expect_ok(
    'select public.moderar_levantar_restriccion(('
    || 'select id from public.restricciones_usuario '
    || 'where usuario_id = ''22222222-2222-2222-2222-222222222222'' and activa))');

  perform pg_temp.act_as('22222222-2222-2222-2222-222222222222');
  if public.usuario_restringido() then
    perform pg_temp.fail('u2 ya no debería estar restringido');
  end if;
  set local role authenticated;
  perform pg_temp.expect_ok(format(
    'insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo) '
    || 'values (%L, %s, %s, ''De vuelta'')',
    v_canal, v_tipo, v_cat));
  reset role;
end $$;

-- ============================================================
-- 11. Privilegios de las funciones de moderación
-- ============================================================
do $$
begin
  if has_table_privilege('authenticated', 'public.restricciones_usuario', 'INSERT') then
    perform pg_temp.fail('authenticated no debería insertar en restricciones_usuario');
  end if;
  if not has_table_privilege('authenticated', 'public.restricciones_usuario', 'SELECT') then
    perform pg_temp.fail('authenticated debería poder leer restricciones_usuario');
  end if;
  if not has_function_privilege('authenticated',
       'public.moderar_restringir_usuario(uuid,text,integer,uuid)', 'EXECUTE') then
    perform pg_temp.fail('authenticated debería poder ejecutar moderar_restringir_usuario');
  end if;
  if has_function_privilege('anon',
       'public.moderar_ocultar_publicacion(uuid)', 'EXECUTE') then
    perform pg_temp.fail('anon no debería ejecutar moderar_ocultar_publicacion');
  end if;
end $$;

-- ============================================================
-- 12. Distintivos automáticos (Etapa 8)
-- ============================================================
do $$
declare
  v_canal uuid;
  v_pub uuid;
  v_primer_paso uuid;
begin
  select id into v_primer_paso from public.insignias where codigo = 'primer_paso';
  if v_primer_paso is null then
    perform pg_temp.fail('la insignia primer_paso debería existir');
  end if;

  select id into v_canal from public.canales where slug = 'canal-test';

  -- u1 publica: debe recibir primer_paso automáticamente.
  perform pg_temp.act_as('11111111-1111-1111-1111-111111111111');
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
  select v_canal, pg_temp.cat('tipo_publicacion','discusion'),
         pg_temp.cat('categoria_publicacion','general'), 'Primera de u1'
  returning id into v_pub;

  if not exists (
    select 1 from public.insignias_usuario
    where usuario_id = '11111111-1111-1111-1111-111111111111'
      and insignia_id = v_primer_paso
  ) then
    perform pg_temp.fail('u1 debería haber recibido primer_paso');
  end if;

  -- Un distintivo no verificable todavía no debe otorgarse automáticamente.
  -- (Se comprueba vendedor_activo porque la sección 4 inserta buen_samaritano
  -- para u1 al probar la restricción UNIQUE.)
  if exists (
    select 1 from public.insignias_usuario iu
    join public.insignias i on i.id = iu.insignia_id
    where iu.usuario_id = '11111111-1111-1111-1111-111111111111'
      and i.codigo = 'vendedor_activo'
  ) then
    perform pg_temp.fail('vendedor_activo no debería otorgarse aún');
  end if;

  -- Idempotencia: una segunda publicación no duplica el distintivo.
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
  select v_canal, pg_temp.cat('tipo_publicacion','discusion'),
         pg_temp.cat('categoria_publicacion','general'), 'Segunda de u1';
  if (select count(*) from public.insignias_usuario
      where usuario_id = '11111111-1111-1111-1111-111111111111'
        and insignia_id = v_primer_paso) <> 1 then
    perform pg_temp.fail('primer_paso no debería duplicarse');
  end if;
end $$;

select 'TODAS LAS PRUEBAS PASARON' as resultado;

rollback;
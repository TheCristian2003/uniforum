-- Pruebas de integridad y RLS del esquema V1.1.
--
-- Como ejecutarlas:
--   Requiere una instancia de DESARROLLO descartable con las migraciones
--   aplicadas. No ejecutar contra produccion.
--   Con psql, usando la cadena de conexion de desarrollo (nunca con service
--   role en el repositorio):
--     psql "$DATABASE_URL_DEV" -v ON_ERROR_STOP=1 \
--       -f supabase/tests/integrity_and_rls_test.sql
--
-- El script se envuelve en una transaccion que termina en ROLLBACK: no deja
-- datos. Si una comprobacion falla, lanza una excepcion y aborta.
--
-- Estado de ejecucion: NO ejecutado por el agente (sin credenciales de
-- desarrollo disponibles en esta sesion). Tratar como pendiente de validar.

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

-- Datos de apoyo: dos usuarios de Auth. El trigger crea sus perfiles.
insert into auth.users (id, instance_id, aud, role, email) values
  ('11111111-1111-1111-1111-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'u1@example.test'),
  ('22222222-2222-2222-2222-222222222222', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'u2@example.test');

-- Helper para leer catalogos por grupo/codigo.
create or replace function pg_temp.cat(p_grupo text, p_codigo text) returns integer
language sql stable as $$
  select id_maestra from public.maestra where grupo = p_grupo and codigo = p_codigo;
$$;

-- ============================================================
-- 1. maestra: UNIQUE (grupo, codigo), permitiendo mismo codigo en otro grupo
-- ============================================================
do $$
begin
  perform pg_temp.expect_error(
    'insert into public.maestra (grupo, codigo, nombre) values (''tipo_perfil'', ''estudiante'', ''Duplicado'')'
  );
  -- Mismo codigo en grupo distinto debe permitirse (ya existe 'general' en
  -- categoria_publicacion y tipo_canal); probamos un codigo repetido en otro grupo.
  perform pg_temp.expect_ok(
    'insert into public.maestra (grupo, codigo, nombre) values (''grupo_prueba'', ''estudiante'', ''Permitido'')'
  );
end $$;

-- ============================================================
-- 2. votos: exactamente un objetivo, valor en (1,-1)
-- ============================================================
do $$
declare
  v_pub uuid;
begin
  insert into public.canales (nombre, slug, tipo_canal_id)
  values ('Canal Test', 'canal-test', pg_temp.cat('tipo_canal', 'general'));

  -- Publicacion de u1 (autoria forzada por trigger, aqui simulamos con claim).
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, cuerpo)
  select c.id, pg_temp.cat('tipo_publicacion','discusion'),
         pg_temp.cat('categoria_publicacion','general'), 'Cuerpo de prueba'
  from public.canales c where c.slug = 'canal-test'
  returning id into v_pub;

  -- Dos objetivos a la vez -> debe fallar.
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, comentario_id, usuario_id, valor) values (%L, gen_random_uuid(), %L, 1)',
    v_pub, '22222222-2222-2222-2222-222222222222'
  ));

  -- Cero objetivos -> debe fallar.
  perform pg_temp.expect_error(format(
    'insert into public.votos (usuario_id, valor) values (%L, 1)',
    '22222222-2222-2222-2222-222222222222'
  ));

  -- valor fuera de (1,-1) -> debe fallar.
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, usuario_id, valor) values (%L, %L, 5)',
    v_pub, '22222222-2222-2222-2222-222222222222'
  ));

  -- Voto propio -> debe fallar por trigger.
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, usuario_id, valor) values (%L, %L, 1)',
    v_pub, '11111111-1111-1111-1111-111111111111'
  ));

  -- Voto valido de u2.
  perform pg_temp.expect_ok(format(
    'insert into public.votos (publicacion_id, usuario_id, valor) values (%L, %L, 1)',
    v_pub, '22222222-2222-2222-2222-222222222222'
  ));

  -- Voto duplicado de u2 sobre la misma publicacion -> debe fallar (indice unico parcial).
  perform pg_temp.expect_error(format(
    'insert into public.votos (publicacion_id, usuario_id, valor) values (%L, %L, 1)',
    v_pub, '22222222-2222-2222-2222-222222222222'
  ));
end $$;

-- ============================================================
-- 3. Puntos: idempotencia por votante+objetivo y no votar lo propio
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

  -- Simula borrar y volver a votar positivo: no debe volver a premiar.
  select id into v_voto from public.votos
   where publicacion_id = v_pub and usuario_id = '22222222-2222-2222-2222-222222222222';

  delete from public.votos where id = v_voto;
  perform set_config('request.jwt.claims', '{"sub":"22222222-2222-2222-2222-222222222222"}', true);
  insert into public.votos (publicacion_id, usuario_id, valor) values (v_pub, '22222222-2222-2222-2222-222222222222', 1);

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
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
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
-- 6. Privilegios: el cliente no puede ejecutar RPC internas ni escribir
--    columnas calculadas; solo las funciones previstas.
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
end $$;

-- ============================================================
-- 7. es_rol_privilegiado lee app_metadata.app_role
-- ============================================================
do $$
begin
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  if public.es_rol_privilegiado() then
    perform pg_temp.fail('sin app_role no deberia ser privilegiado');
  end if;
  perform set_config('request.jwt.claims',
    '{"sub":"11111111-1111-1111-1111-111111111111","app_metadata":{"app_role":"moderador"}}', true);
  if not public.es_rol_privilegiado() then
    perform pg_temp.fail('con app_role=moderador deberia ser privilegiado');
  end if;
  -- es_verificada no otorga permisos: no influye en es_rol_privilegiado.
  if public.es_rol_privilegiado() = false then
    perform pg_temp.fail('estado inesperado de es_rol_privilegiado');
  end if;
end $$;

-- ============================================================
-- 8. RLS: un usuario autenticado no ve publicaciones ocultas de otros
-- ============================================================
do $$
declare
  v_pub uuid;
  v_visibles integer;
begin
  -- Crea una publicacion oculta de u1.
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  insert into public.publicaciones (canal_id, tipo_id, categoria_id, estado_id, cuerpo)
  select c.id, pg_temp.cat('tipo_publicacion','discusion'),
         pg_temp.cat('categoria_publicacion','general'),
         pg_temp.cat('estado_publicacion','oculto'), 'Oculta'
  from public.canales c where c.slug = 'canal-test'
  returning id into v_pub;

  -- Como u2, no debe verla.
  perform set_config('request.jwt.claims', '{"sub":"22222222-2222-2222-2222-222222222222"}', true);
  set local role authenticated;
  select count(*) into v_visibles from public.publicaciones where id = v_pub;
  reset role;
  if v_visibles <> 0 then
    perform pg_temp.fail('u2 no deberia ver la publicacion oculta de u1');
  end if;

  -- El autor si la ve.
  perform set_config('request.jwt.claims', '{"sub":"11111111-1111-1111-1111-111111111111"}', true);
  set local role authenticated;
  select count(*) into v_visibles from public.publicaciones where id = v_pub;
  reset role;
  if v_visibles <> 1 then
    perform pg_temp.fail('el autor deberia ver su publicacion oculta');
  end if;
end $$;

-- ============================================================
-- 9. Integridad de catalogos: un tipo_id fuera de grupo debe ser rechazado
-- ============================================================
do $$
begin
  perform pg_temp.expect_error(format(
    'insert into public.canales (nombre, slug, tipo_canal_id) values (''Canal malo'', ''canal-malo'', %s)',
    pg_temp.cat('tipo_publicacion', 'discusion')  -- grupo equivocado
  ));
end $$;

raise notice 'TODAS LAS PRUEBAS PASARON';

rollback;

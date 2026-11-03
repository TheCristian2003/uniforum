-- Pruebas de la IA del Campus: contexto y cupo diario.
--
-- Como ejecutarlas:
--   Supabase -> SQL Editor -> New query -> pegar este archivo -> Run.
--   Debe salir "PRUEBAS DE IA PASARON".
--   Alternativa: psql "$DATABASE_URL_DEV" -v ON_ERROR_STOP=1 -f supabase/tests/ia_contexto_test.sql
--
--   Requiere una instancia de DESARROLLO con las migraciones aplicadas.
--   NUNCA ejecutar contra produccion.
--
-- El script se envuelve en una transaccion que termina en ROLLBACK: no deja
-- datos.

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

-- Simula la sesion de un usuario autenticado.
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

-- Datos de apoyo: dos usuarios (el trigger crea sus perfiles).
insert into auth.users (id, instance_id, aud, role, email) values
  ('33333333-3333-3333-3333-333333333333', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ia1@example.test'),
  ('44444444-4444-4444-4444-444444444444', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ia2@example.test');

insert into public.canales (nombre, slug, tipo_canal_id)
values ('Canal IA', 'canal-ia', public.id_maestra('tipo_canal', 'general'));

-- Baja el limite a 2 para probar el corte sin agotar el cupo real.
update public.ia_config set limite_diario = 2;

-- El trigger de publicaciones fuerza autor_id = auth.uid() y estado publicado.
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'discusion'),
  public.id_maestra('categoria_publicacion', 'academico'),
  'Examen de calculo',
  'El examen de calculo se aplazo al viernes en el auditorio.'
from public.canales c
where c.slug = 'canal-ia';

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'discusion'),
  public.id_maestra('categoria_publicacion', 'academico'),
  'Examen oculto',
  'Contenido retirado por moderacion sobre el examen de calculo.'
from public.canales c
where c.slug = 'canal-ia';

update public.publicaciones
   set estado_id = public.id_maestra('estado_publicacion', 'oculto')
 where titulo = 'Examen oculto';

insert into public.comentarios (publicacion_id, cuerpo)
select p.id, 'Confirmado: el examen quedo para el viernes.'
from public.publicaciones p
where p.titulo = 'Examen de calculo';

-- ============================================================
-- 1. El contexto incluye solo publicaciones publicadas
-- ============================================================
do $$
declare
  v jsonb;
  v_id uuid;
begin
  select id into v_id
  from public.publicaciones
  where titulo = 'Examen de calculo';

  perform pg_temp.act_as('44444444-4444-4444-4444-444444444444');
  set local role authenticated;

  v := public.buscar_contexto_ia('examen', null, 30, 12);

  reset role;

  if jsonb_array_length(v) <> 1 then
    perform pg_temp.fail(
      'se esperaba 1 publicacion visible y llegaron ' || jsonb_array_length(v)
    );
  end if;

  if (v -> 0 ->> 'id')::uuid <> v_id then
    perform pg_temp.fail('la publicacion devuelta no es la esperada');
  end if;

  if v -> 0 ->> 'canal' <> 'Canal IA' then
    perform pg_temp.fail('falta el nombre del canal en el contexto');
  end if;

  if jsonb_array_length(v -> 0 -> 'comentarios') <> 1 then
    perform pg_temp.fail('se esperaba 1 comentario en el contexto');
  end if;

  if jsonb_exists(v -> 0, 'autor_id') then
    perform pg_temp.fail('el contexto no debe exponer autor_id');
  end if;

  if v::text like '%Contenido retirado%' then
    perform pg_temp.fail('una publicacion oculta no debe aparecer');
  end if;
end $$;

-- ============================================================
-- 2. Filtros: sin terminos, por canal y por canal inexistente
-- ============================================================
do $$
declare
  v jsonb;
  v_canal uuid;
begin
  select id into v_canal from public.canales where slug = 'canal-ia';

  perform pg_temp.act_as('44444444-4444-4444-4444-444444444444');
  set local role authenticated;

  v := public.buscar_contexto_ia('', v_canal, 30, 12);

  reset role;

  if jsonb_array_length(v) <> 1 then
    perform pg_temp.fail('sin terminos debe devolver la publicacion del canal');
  end if;

  set local role authenticated;
  v := public.buscar_contexto_ia('examen', gen_random_uuid(), 30, 12);
  reset role;

  if jsonb_array_length(v) <> 0 then
    perform pg_temp.fail('un canal inexistente no debe devolver resultados');
  end if;
end $$;

-- ============================================================
-- 3. Cupo diario por usuario
-- ============================================================
do $$
declare
  restantes integer;
begin
  perform pg_temp.act_as('44444444-4444-4444-4444-444444444444');

  set local role authenticated;
  restantes := public.consumir_cupo_ia();
  reset role;

  if restantes <> 1 then
    perform pg_temp.fail('la primera consulta debe dejar 1 restante, no ' || restantes);
  end if;

  set local role authenticated;
  restantes := public.consumir_cupo_ia();
  reset role;

  if restantes <> 0 then
    perform pg_temp.fail('la segunda consulta debe dejar 0 restantes, no ' || restantes);
  end if;
end $$;

select pg_temp.expect_error('select public.consumir_cupo_ia()');

do $$
declare
  v_consultas integer;
begin
  select consultas into v_consultas
  from public.ia_uso
  where usuario_id = '44444444-4444-4444-4444-444444444444';

  if v_consultas is distinct from 2 then
    perform pg_temp.fail(
      'ia_uso debe registrar 2 consultas, no ' || coalesce(v_consultas::text, 'null')
    );
  end if;
end $$;

-- Otro usuario tiene su propio cupo.
do $$
begin
  perform pg_temp.act_as('33333333-3333-3333-3333-333333333333');
  set local role authenticated;
  perform public.consumir_cupo_ia();
  reset role;
end $$;

do $$
declare
  v_consultas integer;
begin
  select consultas into v_consultas
  from public.ia_uso
  where usuario_id = '33333333-3333-3333-3333-333333333333';

  if v_consultas is distinct from 1 then
    perform pg_temp.fail('el cupo debe ser independiente por usuario');
  end if;
end $$;

-- ============================================================
-- 4. Permisos
-- ============================================================
-- Sin sesion, la RPC de cupo rechaza la llamada.
select set_config('request.jwt.claim.sub', '', true);
select set_config('request.jwt.claims', '{}', true);

select pg_temp.expect_error('select public.consumir_cupo_ia()');

do $$
begin
  if has_function_privilege(
    'anon',
    'public.buscar_contexto_ia(text,uuid,integer,integer)',
    'execute'
  ) then
    perform pg_temp.fail('anon no debe poder ejecutar buscar_contexto_ia');
  end if;

  if has_function_privilege('anon', 'public.consumir_cupo_ia()', 'execute') then
    perform pg_temp.fail('anon no debe poder ejecutar consumir_cupo_ia');
  end if;

  if has_function_privilege(
    'anon',
    'public.resumen_objetos_ia(integer,uuid)',
    'execute'
  ) then
    perform pg_temp.fail('anon no debe poder ejecutar resumen_objetos_ia');
  end if;

  if not has_function_privilege(
    'authenticated',
    'public.resumen_objetos_ia(integer,uuid)',
    'execute'
  ) then
    perform pg_temp.fail('authenticated debe poder ejecutar resumen_objetos_ia');
  end if;

  if not has_function_privilege(
    'authenticated',
    'public.buscar_contexto_ia(text,uuid,integer,integer)',
    'execute'
  ) then
    perform pg_temp.fail('authenticated debe poder ejecutar buscar_contexto_ia');
  end if;

  if has_table_privilege('authenticated', 'public.ia_uso', 'select') then
    perform pg_temp.fail('authenticated no debe leer ia_uso directamente');
  end if;

  if has_table_privilege('authenticated', 'public.ia_config', 'update') then
    perform pg_temp.fail('el cliente no debe poder subir el limite de IA');
  end if;
end $$;

-- ============================================================
-- 5. Conteo de objetos perdidos/encontrados
-- ============================================================
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'encontrado'),
  public.id_maestra('categoria_publicacion', 'marketplace'),
  'Encontrado: prueba entregada',
  'Objeto de prueba entregado.',
  '{"entregado": true}'::jsonb
from public.canales c
where c.slug = 'canal-ia';

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'encontrado'),
  public.id_maestra('categoria_publicacion', 'marketplace'),
  'Encontrado: prueba pendiente',
  'Objeto de prueba sin entregar.',
  '{"entregado": false}'::jsonb
from public.canales c
where c.slug = 'canal-ia';

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'perdido'),
  public.id_maestra('categoria_publicacion', 'marketplace'),
  'Perdido: prueba',
  'Objeto de prueba perdido.'
from public.canales c
where c.slug = 'canal-ia';

do $$
declare
  v jsonb;
begin
  perform pg_temp.act_as('44444444-4444-4444-4444-444444444444');
  set local role authenticated;

  v := public.resumen_objetos_ia(30, (select id from public.canales where slug = 'canal-ia'));

  reset role;

  if (v ->> 'encontrados')::int <> 2 then
    perform pg_temp.fail('se esperaban 2 encontrados, llegaron ' || (v ->> 'encontrados'));
  end if;

  if (v ->> 'encontrados_entregados')::int <> 1 then
    perform pg_temp.fail(
      'se esperaba 1 encontrado entregado, llegaron ' || (v ->> 'encontrados_entregados')
    );
  end if;

  if (v ->> 'perdidos')::int <> 1 then
    perform pg_temp.fail('se esperaba 1 perdido, llegaron ' || (v ->> 'perdidos'));
  end if;

  if (v ->> 'entregados_total')::int <> 1 then
    perform pg_temp.fail(
      'se esperaba 1 entregado historico, llegaron ' || (v ->> 'entregados_total')
    );
  end if;
end $$;

do $$
declare
  v jsonb;
begin
  perform pg_temp.act_as('44444444-4444-4444-4444-444444444444');
  set local role authenticated;

  v := public.buscar_contexto_ia('prueba', (select id from public.canales where slug = 'canal-ia'), 30, 12);

  reset role;

  if not exists (
    select 1
    from jsonb_array_elements(v) elem
    where elem ->> 'titulo' = 'Encontrado: prueba entregada'
      and (elem -> 'metadatos' ->> 'entregado') = 'true'
  ) then
    perform pg_temp.fail('el contexto debe incluir metadatos.entregado');
  end if;
end $$;

-- ============================================================
-- 6. Una pregunta natural puede coincidir por cualquier termino
-- ============================================================
select pg_temp.act_as('33333333-3333-3333-3333-333333333333');

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'venta'),
  public.id_maestra('categoria_publicacion', 'marketplace'),
  'Venta: Mouse inalambrico',
  'Mouse en buen estado, disponible en la biblioteca.'
from public.canales c
where c.slug = 'canal-ia';

insert into public.publicaciones
  (canal_id, tipo_id, categoria_id, titulo, cuerpo)
select
  c.id,
  public.id_maestra('tipo_publicacion', 'venta'),
  public.id_maestra('categoria_publicacion', 'marketplace'),
  'Venta: Maleta para laptop',
  'Maleta acolchada en buen estado.'
from public.canales c
where c.slug = 'canal-ia';

do $$
declare
  v jsonb;
begin
  perform pg_temp.act_as('44444444-4444-4444-4444-444444444444');
  set local role authenticated;

  v := public.buscar_contexto_ia(
    'alguien vende mouse o maleta para laptop',
    (select id from public.canales where slug = 'canal-ia'),
    30,
    12
  );

  reset role;

  if jsonb_array_length(v) <> 2 then
    perform pg_temp.fail(
      'la busqueda OR debia encontrar mouse y maleta, llegaron ' || jsonb_array_length(v)
    );
  end if;
end $$;

select 'PRUEBAS DE IA PASARON' as resultado;

rollback;

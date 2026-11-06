-- Pruebas de validación de publicaciones y clasificación por tipo.
--
-- Ejecutar en el SQL Editor de DESARROLLO. Termina en ROLLBACK: no deja datos.
-- Requiere las migraciones aplicadas y un entorno descartable.

begin;

create function pg_temp.fail(msg text) returns void language plpgsql as $$
begin
  raise exception 'TEST FAIL: %', msg;
end $$;

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

create function pg_temp.expect_ok(cmd text) returns void language plpgsql as $$
begin
  begin
    execute cmd;
  exception when others then
    perform pg_temp.fail('comando inesperadamente falló (' || sqlerrm || '): ' || cmd);
  end;
end $$;

create function pg_temp.act_as(p_uid text)
returns void language plpgsql as $$
declare
  claims jsonb;
begin
  claims := jsonb_build_object('sub', p_uid);
  perform set_config('request.jwt.claim.sub', p_uid, true);
  perform set_config('request.jwt.claims', claims::text, true);
end $$;

insert into auth.users (id, instance_id, aud, role, email) values
  ('55555555-5555-5555-5555-555555555555',
   '00000000-0000-0000-0000-000000000000',
   'authenticated', 'authenticated', 'validacion@example.test');

insert into public.canales (nombre, slug, tipo_canal_id)
values (
  'Canal validación',
  'canal-validacion',
  public.id_maestra('tipo_canal', 'general')
);

select pg_temp.act_as('55555555-5555-5555-5555-555555555555');
set local role authenticated;

do $$
declare
  v_canal uuid;
  v_venta int;
  v_discusion int;
  v_evento int;
  v_encontrado int;
  v_general int;
  v_academico int;
  v_chisme int;
  v_marketplace int;
begin
  select id into v_canal from public.canales where slug = 'canal-validacion';
  v_venta := public.id_maestra('tipo_publicacion', 'venta');
  v_discusion := public.id_maestra('tipo_publicacion', 'discusion');
  v_evento := public.id_maestra('tipo_publicacion', 'evento');
  v_encontrado := public.id_maestra('tipo_publicacion', 'encontrado');
  v_general := public.id_maestra('categoria_publicacion', 'general');
  v_academico := public.id_maestra('categoria_publicacion', 'academico');
  v_chisme := public.id_maestra('categoria_publicacion', 'chisme');
  v_marketplace := public.id_maestra('categoria_publicacion', 'marketplace');

  perform pg_temp.expect_ok(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Venta válida', 'Prueba de venta', %L::jsonb)$q$,
    v_canal, v_venta, v_general,
    '{"precio": 10000, "moneda": "COP", "disponible": true}'
  ));

  perform pg_temp.expect_error(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Venta sin precio', 'Prueba', '{"moneda":"COP","disponible":true}'::jsonb)$q$,
    v_canal, v_venta, v_general
  ));

  perform pg_temp.expect_error(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Venta con categoría académica', 'Prueba', '{"precio": 1, "moneda":"COP","disponible":true}'::jsonb)$q$,
    v_canal, v_venta, v_academico
  ));

  perform pg_temp.expect_ok(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Discusión con tema', 'Prueba de discusión', '{}'::jsonb)$q$,
    v_canal, v_discusion, v_chisme
  ));

  perform pg_temp.expect_error(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Discusión marketplace', 'Prueba', '{}'::jsonb)$q$,
    v_canal, v_discusion, v_marketplace
  ));

  perform pg_temp.expect_error(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Evento sin inicio', 'Prueba', '{"lugar":"Auditorio"}'::jsonb)$q$,
    v_canal, v_evento, v_general
  ));

  perform pg_temp.expect_ok(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Evento válido', 'Prueba', '{"inicio":"2026-11-10T10:00:00","lugar":"Auditorio"}'::jsonb)$q$,
    v_canal, v_evento, v_general
  ));

  perform pg_temp.expect_error(format(
    $q$insert into public.publicaciones
      (canal_id, tipo_id, categoria_id, titulo, cuerpo, metadatos)
      values (%L, %s, %s, 'Hallazgo sin entregado', 'Prueba', '{"fecha":"2026-11-03","lugar":"Biblioteca"}'::jsonb)$q$,
    v_canal, v_encontrado, v_general
  ));
end $$;

reset role;

select 'PRUEBAS DE VALIDACIÓN PASARON' as resultado;

rollback;

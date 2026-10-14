-- Registro en una sola pantalla: el perfil se crea con los datos que envía
-- Flutter en `raw_user_meta_data` al hacer signUp (alias, tipo_perfil_id,
-- programa_id, sede_id). Si falta algún dato o no es válido, se usan los
-- valores por defecto (alias temporal y tipo de perfil "estudiante").
--
-- Reemplaza la versión de `20261011000000_initial_schema_v1_1.sql`. No es
-- destructiva: mantiene el trigger `auth_usuario_crear_perfil` existente.

create or replace function public.crear_perfil_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_alias text;
  v_tipo integer;
  v_programa integer;
  v_sede integer;
  v_tipo_meta text := v_meta->>'tipo_perfil_id';
  v_programa_meta text := v_meta->>'programa_id';
  v_sede_meta text := v_meta->>'sede_id';
begin
  v_alias := nullif(btrim(coalesce(v_meta->>'alias', '')), '');
  if v_alias is null or char_length(v_alias) < 3 then
    v_alias := 'usuario_' || replace(left(new.id::text, 8), '-', '');
  end if;
  v_alias := left(v_alias, 50);

  if v_tipo_meta ~ '^[0-9]+$' then
    select id_maestra into v_tipo
    from public.maestra
    where id_maestra = v_tipo_meta::integer and grupo = 'tipo_perfil' and activo;
  end if;
  v_tipo := coalesce(v_tipo, public.id_maestra('tipo_perfil', 'estudiante'));

  if v_programa_meta ~ '^[0-9]+$' then
    select id_maestra into v_programa
    from public.maestra
    where id_maestra = v_programa_meta::integer and grupo = 'programa' and activo;
  end if;

  if v_sede_meta ~ '^[0-9]+$' then
    select id_maestra into v_sede
    from public.maestra
    where id_maestra = v_sede_meta::integer and grupo = 'sede' and activo;
  end if;

  begin
    insert into public.perfiles (id, alias, tipo_perfil_id, programa_id, sede_id)
    values (new.id, v_alias, v_tipo, v_programa, v_sede);
  exception when unique_violation then
    -- Evita que un nombre repetido impida crear la cuenta.
    insert into public.perfiles (id, alias, tipo_perfil_id, programa_id, sede_id)
    values (
      new.id,
      left(v_alias, 44) || '_' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 5),
      v_tipo, v_programa, v_sede
    );
  end;

  return new;
end;
$$;

revoke execute on function public.crear_perfil_auth_user() from public;

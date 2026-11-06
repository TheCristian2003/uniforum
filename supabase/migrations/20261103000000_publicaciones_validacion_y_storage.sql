-- Endurecimiento de publicaciones: categorías coherentes, metadatos por tipo y
-- límites del bucket de imágenes.
--
-- Aditivo para el esquema existente. Normaliza las categorías redundantes de
-- registros anteriores antes de activar la validación; a partir de esta
-- migración, las nuevas escrituras deben cumplir las mismas reglas que el
-- formulario de Flutter.

-- 1) Normalizar categorías históricas.
do $$
begin
  if not exists (
    select 1
    from public.maestra
    where grupo = 'categoria_publicacion'
      and codigo = 'general'
      and activo
  ) then
    raise exception 'Falta la categoría general en maestra';
  end if;
end $$;

-- Los tipos que se explican por sí mismos usan la categoría general.
update public.publicaciones p
set categoria_id = general.id_maestra
from public.maestra tipo
cross join public.maestra general
where tipo.id_maestra = p.tipo_id
  and tipo.grupo = 'tipo_publicacion'
  and tipo.codigo not in ('discusion', 'aviso')
  and general.grupo = 'categoria_publicacion'
  and general.codigo = 'general'
  and p.categoria_id <> general.id_maestra;

-- Las categorías marketplace/eventos dejan de usarse: también se limpian en
-- discusiones y avisos antiguos para que coincidan con el selector actual.
update public.publicaciones p
set categoria_id = general.id_maestra
from public.maestra general
where general.grupo = 'categoria_publicacion'
  and general.codigo = 'general'
  and p.categoria_id in (
    select id_maestra
    from public.maestra
    where grupo = 'categoria_publicacion'
      and codigo in ('marketplace', 'eventos')
  );

-- 2) Tipo y categoría: el tipo define la estructura; la categoría solo aporta
-- tema en discusiones y avisos.
create or replace function public.validar_tipo_categoria_publicacion()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_tipo text;
  v_categoria text;
begin
  select codigo into v_tipo
  from public.maestra
  where id_maestra = new.tipo_id
    and grupo = 'tipo_publicacion'
    and activo;

  select codigo into v_categoria
  from public.maestra
  where id_maestra = new.categoria_id
    and grupo = 'categoria_publicacion'
    and activo;

  if v_tipo is null or v_categoria is null then
    raise exception 'La publicación necesita un tipo y una categoría válidos';
  end if;

  if v_tipo in ('discusion', 'aviso') then
    if v_categoria in ('marketplace', 'eventos') then
      raise exception 'La categoría % no aplica a una publicación de tipo %',
        v_categoria, v_tipo;
    end if;
  elsif v_categoria <> 'general' then
    raise exception 'El tipo % no admite categoría; usa la categoría general',
      v_tipo;
  end if;

  return new;
end;
$$;

drop trigger if exists publicaciones_validar_tipo_categoria
  on public.publicaciones;
create trigger publicaciones_validar_tipo_categoria
  before insert or update on public.publicaciones
  for each row execute function public.validar_tipo_categoria_publicacion();

-- 3) Metadatos obligatorios por tipo.
create or replace function public.es_fecha_hora_publicacion(p_valor text)
returns boolean
language plpgsql
stable
security invoker
set search_path = public
as $$
begin
  perform p_valor::timestamptz;
  return true;
exception when others then
  return false;
end;
$$;

create or replace function public.validar_metadatos_publicacion()
returns trigger
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_tipo text;
  v_meta jsonb := coalesce(new.metadatos, '{}'::jsonb);
  v_inicio timestamptz;
  v_fin timestamptz;
  v_lugar text;
begin
  select codigo into v_tipo
  from public.maestra
  where id_maestra = new.tipo_id
    and grupo = 'tipo_publicacion'
    and activo;

  if v_tipo is null then
    raise exception 'La publicación debe tener un tipo válido';
  end if;
  if jsonb_typeof(v_meta) <> 'object' then
    raise exception 'metadatos debe ser un objeto JSON';
  end if;

  if v_meta ? 'lugar' then
    if jsonb_typeof(v_meta -> 'lugar') <> 'string'
      or char_length(btrim(v_meta ->> 'lugar')) not between 1 and 200 then
      raise exception 'metadatos.lugar debe ser un texto de 1 a 200 caracteres';
    end if;
    v_lugar := btrim(v_meta ->> 'lugar');
  end if;

  if v_meta ? 'moneda' then
    if jsonb_typeof(v_meta -> 'moneda') <> 'string'
      or (v_meta ->> 'moneda') !~ '^[A-Z]{3}$' then
      raise exception 'metadatos.moneda debe ser un código de 3 letras mayúsculas';
    end if;
  end if;

  if v_tipo = 'venta' then
    if not (v_meta ? 'precio')
      or jsonb_typeof(v_meta -> 'precio') <> 'number'
      or (v_meta ->> 'precio')::numeric <= 0 then
      raise exception 'Una venta requiere metadatos.precio numérico mayor que 0';
    end if;
    if not (v_meta ? 'moneda') then
      raise exception 'Una venta requiere metadatos.moneda';
    end if;
    if not (v_meta ? 'disponible')
      or jsonb_typeof(v_meta -> 'disponible') <> 'boolean' then
      raise exception 'Una venta requiere metadatos.disponible booleano';
    end if;

  elsif v_tipo in ('perdido', 'encontrado') then
    if not (v_meta ? 'fecha')
      or jsonb_typeof(v_meta -> 'fecha') <> 'string'
      or not public.es_fecha_hora_publicacion(v_meta ->> 'fecha') then
      raise exception 'El tipo % requiere metadatos.fecha válida', v_tipo;
    end if;
    if not (v_meta ? 'lugar') then
      raise exception 'El tipo % requiere metadatos.lugar', v_tipo;
    end if;
    if v_tipo = 'perdido' and v_meta ? 'recompensa' then
      if jsonb_typeof(v_meta -> 'recompensa') <> 'number'
        or (v_meta ->> 'recompensa')::numeric < 0 then
        raise exception 'metadatos.recompensa debe ser un número mayor o igual a 0';
      end if;
      if not (v_meta ? 'moneda') then
        raise exception 'Una recompensa requiere metadatos.moneda';
      end if;
    end if;
    if v_tipo = 'encontrado'
      and (not (v_meta ? 'entregado')
        or jsonb_typeof(v_meta -> 'entregado') <> 'boolean') then
      raise exception 'Un hallazgo requiere metadatos.entregado booleano';
    end if;

  elsif v_tipo = 'evento' then
    if not (v_meta ? 'inicio')
      or jsonb_typeof(v_meta -> 'inicio') <> 'string'
      or not public.es_fecha_hora_publicacion(v_meta ->> 'inicio') then
      raise exception 'Un evento requiere metadatos.inicio válido';
    end if;
    if not (v_meta ? 'lugar') then
      raise exception 'Un evento requiere metadatos.lugar';
    end if;
    v_inicio := (v_meta ->> 'inicio')::timestamptz;
    if v_meta ? 'fin' then
      if jsonb_typeof(v_meta -> 'fin') <> 'string'
        or not public.es_fecha_hora_publicacion(v_meta ->> 'fin') then
        raise exception 'metadatos.fin debe ser una fecha válida';
      end if;
      v_fin := (v_meta ->> 'fin')::timestamptz;
      if v_fin < v_inicio then
        raise exception 'metadatos.fin no puede ser anterior a inicio';
      end if;
    end if;
    if v_meta ? 'enlace' then
      if jsonb_typeof(v_meta -> 'enlace') <> 'string'
        or (v_meta ->> 'enlace') !~ '^https?://' then
        raise exception 'metadatos.enlace debe ser una URL http(s)';
      end if;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists publicaciones_validar_metadatos
  on public.publicaciones;
create trigger publicaciones_validar_metadatos
  before insert or update on public.publicaciones
  for each row execute function public.validar_metadatos_publicacion();

-- Las funciones de trigger no se exponen como RPC.
revoke execute on function public.validar_tipo_categoria_publicacion()
  from public, anon, authenticated;
revoke execute on function public.validar_metadatos_publicacion()
  from public, anon, authenticated;

comment on function public.validar_tipo_categoria_publicacion() is
  'Impide categorías redundantes: solo discusión y aviso usan categoría temática; el resto usa general.';
comment on function public.validar_metadatos_publicacion() is
  'Valida los metadatos obligatorios de venta, perdido, encontrado y evento.';
comment on function public.es_fecha_hora_publicacion(text) is
  'Devuelve true si el texto se puede interpretar como fecha/hora ISO.';

-- 4) Límites del bucket de imágenes (5 MB, formatos que acepta el cliente).
update storage.buckets
set file_size_limit = 5 * 1024 * 1024,
    allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp']
where id = 'publicaciones';

-- Contexto y cupo para la IA del Campus.
--
-- La Edge Function `campus-ai` no consulta tablas directamente ni necesita la
-- service-role key: llama a estas dos RPC con el JWT del usuario, de modo que
-- las políticas RLS siguen aplicando.
--
--   * public.buscar_contexto_ia(...) recupera publicaciones visibles y sus
--     comentarios, ordenados por relevancia y recencia, como un único jsonb.
--   * public.consumir_cupo_ia(...) aplica el límite diario de consultas por
--     usuario y devuelve cuántas quedan.
--
-- No se guarda el texto de las preguntas ni las respuestas: solo el conteo
-- diario en `ia_uso`.

-- 1. Consumo diario de IA ---------------------------------------------------

-- Límite configurable solo desde backend: el cliente no puede subirlo.
create table public.ia_config (
  id boolean primary key default true check (id),
  limite_diario integer not null default 20 check (limite_diario between 1 and 200)
);

insert into public.ia_config (id, limite_diario) values (true, 20)
on conflict (id) do nothing;

alter table public.ia_config enable row level security;
revoke all on table public.ia_config from public, anon, authenticated;

create table public.ia_uso (
  usuario_id uuid not null references public.perfiles(id) on delete cascade,
  fecha date not null default ((now() at time zone 'America/Bogota')::date),
  consultas integer not null default 0 check (consultas >= 0),
  actualizado_en timestamptz not null default now(),
  primary key (usuario_id, fecha)
);

comment on table public.ia_uso is
  'Conteo de consultas de IA por usuario y día (America/Bogota). Solo lo escribe public.consumir_cupo_ia().';

alter table public.ia_uso enable row level security;

revoke all on table public.ia_uso from public, anon, authenticated;

-- Sin políticas: las filas propias se leen a través de la RPC, que devuelve el
-- cupo restante sin exponer el historial de otros usuarios.

create or replace function public.consumir_cupo_ia()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_usuario uuid := auth.uid();
  v_fecha date := (now() at time zone 'America/Bogota')::date;
  v_limite integer;
  v_consultas integer;
begin
  if v_usuario is null then
    raise exception 'Se requiere una sesión para usar la IA'
      using errcode = '28000';
  end if;

  select limite_diario into v_limite
  from public.ia_config
  where id = true;

  if v_limite is null then
    v_limite := 20;
  end if;

  -- Garantiza la fila del día y luego incrementa solo si hay cupo. Ambas
  -- sentencias comparten transacción, así que el conteo es atómico.
  insert into public.ia_uso (usuario_id, fecha, consultas)
  values (v_usuario, v_fecha, 0)
  on conflict (usuario_id, fecha) do nothing;

  update public.ia_uso
     set consultas = consultas + 1,
         actualizado_en = now()
   where usuario_id = v_usuario
     and fecha = v_fecha
     and consultas + 1 <= v_limite
  returning consultas into v_consultas;

  if v_consultas is null then
    raise exception 'Límite diario de consultas de IA alcanzado'
      using errcode = 'P0001';
  end if;

  return v_limite - v_consultas;
end $$;

comment on function public.consumir_cupo_ia() is
  'Registra una consulta de IA para auth.uid() y devuelve las consultas restantes del día. El límite se lee de public.ia_config.';

-- 2. Recuperación de contexto ----------------------------------------------

create index if not exists publicaciones_busqueda_ia_idx
  on public.publicaciones
  using gin (to_tsvector('spanish', coalesce(titulo, '') || ' ' || cuerpo));

create or replace function public.buscar_contexto_ia(
  p_consulta text,
  p_canal_id uuid default null,
  p_dias integer default 30,
  p_limite integer default 12
) returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  with parametros as (
    select
      websearch_to_tsquery('spanish', coalesce(btrim(p_consulta), '')) as tsq,
      now() - make_interval(days => greatest(least(coalesce(p_dias, 30), 180), 1)) as desde
  ),
  candidatas as (
    select
      p.id,
      p.titulo,
      p.cuerpo,
      p.puntaje,
      p.creado_en,
      p.anonimo,
      p.canal_id,
      p.tipo_id,
      p.categoria_id,
      ts_rank(
        to_tsvector('spanish', coalesce(p.titulo, '') || ' ' || p.cuerpo),
        par.tsq
      ) as rango
    from public.publicaciones p
    cross join parametros par
    where p.estado_id = public.id_maestra('estado_publicacion', 'publicado')
      and p.creado_en >= par.desde
      and (p_canal_id is null or p.canal_id = p_canal_id)
      and (
        numnode(par.tsq) = 0
        or to_tsvector('spanish', coalesce(p.titulo, '') || ' ' || p.cuerpo) @@ par.tsq
      )
    order by rango desc, p.creado_en desc
    limit greatest(least(coalesce(p_limite, 12), 20), 1)
  )
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'titulo', c.titulo,
        'cuerpo', left(c.cuerpo, 1000),
        'puntaje', c.puntaje,
        'creado_en', c.creado_en,
        'anonimo', c.anonimo,
        'canal', (select ca.nombre from public.canales ca where ca.id = c.canal_id),
        'tipo', (select m.nombre from public.maestra m where m.id_maestra = c.tipo_id),
        'categoria', (select m.nombre from public.maestra m where m.id_maestra = c.categoria_id),
        'comentarios', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'cuerpo', left(co.cuerpo, 400),
                'es_solucion', co.es_solucion
              )
              order by co.creado_en
            ),
            '[]'::jsonb
          )
          from public.comentarios co
          where co.publicacion_id = c.id
        )
      )
      order by c.rango desc, c.creado_en desc
    ),
    '[]'::jsonb
  )
  from candidatas c;
$$;

comment on function public.buscar_contexto_ia(text, uuid, integer, integer) is
  'Contexto para la IA del Campus: publicaciones publicadas y sus comentarios, filtrados por texto, canal y días. No devuelve la identidad del autor.';

-- 3. Privilegios ------------------------------------------------------------

revoke execute on function public.consumir_cupo_ia()
  from public, anon, authenticated;
grant execute on function public.consumir_cupo_ia()
  to authenticated;

revoke execute on function public.buscar_contexto_ia(text, uuid, integer, integer)
  from public, anon, authenticated;
grant execute on function public.buscar_contexto_ia(text, uuid, integer, integer)
  to authenticated;

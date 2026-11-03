-- Resumen de objetos perdidos/encontrados para la IA del Campus.
--
-- `buscar_contexto_ia` ahora incluye `metadatos` para que el modelo vea si un
-- objeto encontrado esta marcado como entregado. Para las preguntas de conteo
-- se agrega `resumen_objetos_ia`, que calcula las cifras en SQL (no en el
-- modelo) respetando RLS.
--
-- Limitacion del modelo actual: no existe una fecha de entrega. Los conteos se
-- basan en la fecha de creacion de la publicacion y en el campo
-- `metadatos.entregado` (solo aplica al tipo `encontrado`).

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
      p.metadatos,
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
        'metadatos', c.metadatos,
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
  'Contexto para la IA del Campus: publicaciones publicadas y sus comentarios, filtrados por texto, canal y dias. Incluye metadatos del tipo (por ejemplo entregado). No devuelve la identidad del autor.';

create or replace function public.resumen_objetos_ia(
  p_dias integer default 30,
  p_canal_id uuid default null
) returns jsonb
language sql
stable
security invoker
set search_path = public
as $$
  with parametros as (
    select
      greatest(least(coalesce(p_dias, 30), 180), 1) as dias,
      now() - make_interval(days => greatest(least(coalesce(p_dias, 30), 180), 1)) as desde
  ),
  filas as (
    select
      m.codigo as tipo,
      p.creado_en,
      coalesce((p.metadatos ->> 'entregado') = 'true', false) as entregado
    from public.publicaciones p
    join public.maestra m on m.id_maestra = p.tipo_id
    cross join parametros par
    where p.estado_id = public.id_maestra('estado_publicacion', 'publicado')
      and m.grupo = 'tipo_publicacion'
      and m.codigo in ('perdido', 'encontrado')
      and m.activo
      and (p_canal_id is null or p.canal_id = p_canal_id)
      and (
        p.creado_en >= par.desde
        or coalesce((p.metadatos ->> 'entregado') = 'true', false)
      )
  )
  select jsonb_build_object(
    'dias', par.dias,
    'encontrados', (
      select count(*)
      from filas f
      where f.tipo = 'encontrado' and f.creado_en >= par.desde
    ),
    'encontrados_entregados', (
      select count(*)
      from filas f
      where f.tipo = 'encontrado' and f.entregado and f.creado_en >= par.desde
    ),
    'perdidos', (
      select count(*)
      from filas f
      where f.tipo = 'perdido' and f.creado_en >= par.desde
    ),
    'entregados_total', (
      select count(*)
      from filas f
      where f.tipo = 'encontrado' and f.entregado
    )
  )
  from parametros par;
$$;

comment on function public.resumen_objetos_ia(integer, uuid) is
  'Conteo para la IA: encontrados y perdidos publicados en el periodo, encontrados marcados como entregados y total historico de entregados. Los conteos usan la fecha de creacion, no una fecha de entrega.';

revoke execute on function public.buscar_contexto_ia(text, uuid, integer, integer)
  from public, anon, authenticated;
grant execute on function public.buscar_contexto_ia(text, uuid, integer, integer)
  to authenticated;

revoke execute on function public.resumen_objetos_ia(integer, uuid)
  from public, anon, authenticated;
grant execute on function public.resumen_objetos_ia(integer, uuid)
  to authenticated;

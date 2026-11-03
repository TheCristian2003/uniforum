-- Busqueda por cualquier termino relevante para la IA del Campus.
--
-- `websearch_to_tsquery` une por defecto todas las palabras con AND. Eso hace
-- que una pregunta natural como "alguien vende mouse o maleta" no recupere una
-- publicacion que solo menciona mouse. Se convierte la consulta generada a OR,
-- conservando el ranking por relevancia para poner primero las coincidencias
-- con mas terminos.

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
      replace(
        websearch_to_tsquery('spanish', coalesce(btrim(p_consulta), ''))::text,
        ' & ',
        ' | '
      )::tsquery as tsq,
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
        to_tsvector(
          'spanish',
          coalesce(p.titulo, '') || ' ' || p.cuerpo || ' ' ||
          coalesce(tm.nombre, '') || ' ' || coalesce(cm.nombre, '') || ' ' ||
          coalesce(ca.nombre, '')
        ),
        par.tsq
      ) as rango
    from public.publicaciones p
    left join public.maestra tm on tm.id_maestra = p.tipo_id
    left join public.maestra cm on cm.id_maestra = p.categoria_id
    left join public.canales ca on ca.id = p.canal_id
    cross join parametros par
    where p.estado_id = public.id_maestra('estado_publicacion', 'publicado')
      and p.creado_en >= par.desde
      and (p_canal_id is null or p.canal_id = p_canal_id)
      and (
        numnode(par.tsq) = 0
        or to_tsvector(
          'spanish',
          coalesce(p.titulo, '') || ' ' || p.cuerpo || ' ' ||
          coalesce(tm.nombre, '') || ' ' || coalesce(cm.nombre, '') || ' ' ||
          coalesce(ca.nombre, '')
        ) @@ par.tsq
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
  'Contexto para la IA del Campus: publicaciones publicadas y comentarios. Los terminos se combinan con OR y se ordenan por relevancia; incluye metadatos. No devuelve la identidad del autor.';

revoke execute on function public.buscar_contexto_ia(text, uuid, integer, integer)
  from public, anon, authenticated;
grant execute on function public.buscar_contexto_ia(text, uuid, integer, integer)
  to authenticated;

-- Etapa 8: otorgamiento automático de distintivos verificables.
--
-- Los puntos por acción y su idempotencia ya existen en el esquema inicial
-- (eventos_puntos.clave_unica + otorgar_puntos). Las insignias están sembradas
-- en public.insignias, pero hasta ahora ninguna se concedía.
--
-- Alcance acordado: se otorgan solo los distintivos que se pueden verificar con
-- los datos actuales. buen_samaritano y vendedor_activo quedan pendientes porque
-- dependen de flujos de objetos perdidos/ventas que todavía no existen.

-- Concede una insignia concreta si está activa y el usuario aún no la tiene.
create or replace function public.otorgar_insignia(p_usuario_id uuid, p_codigo text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.insignias_usuario (usuario_id, insignia_id)
  select p_usuario_id, i.id
  from public.insignias i
  where i.codigo = p_codigo and i.activo
  on conflict (usuario_id, insignia_id) do nothing;
end;
$$;

-- Evalúa los distintivos verificables de un usuario y concede los que faltan.
-- Es idempotente: inserción con on conflict do nothing.
create or replace function public.evaluar_insignias(p_usuario_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_publicaciones integer;
  v_comentarios integer;
  v_soluciones integer;
  v_dias integer;
  v_votos_positivos integer;
  v_tendencia boolean;
begin
  select count(*) into v_publicaciones
  from public.publicaciones where autor_id = p_usuario_id;

  select count(*) into v_comentarios
  from public.comentarios where autor_id = p_usuario_id;

  select count(*) into v_soluciones
  from public.comentarios where autor_id = p_usuario_id and es_solucion;

  if v_publicaciones >= 1 then
    perform public.otorgar_insignia(p_usuario_id, 'primer_paso');
  end if;

  if v_soluciones >= 1 then
    perform public.otorgar_insignia(p_usuario_id, 'resuelve_dudas');
  end if;

  if (v_publicaciones + v_comentarios) >= 20 then
    perform public.otorgar_insignia(p_usuario_id, 'voz_del_campus');
  end if;

  select count(distinct (creado_en at time zone 'utc')::date) into v_dias
  from (
    select creado_en from public.publicaciones where autor_id = p_usuario_id
    union all
    select creado_en from public.comentarios where autor_id = p_usuario_id
  ) actividad;
  if v_dias >= 7 then
    perform public.otorgar_insignia(p_usuario_id, 'constante');
  end if;

  select count(*) into v_votos_positivos
  from public.eventos_puntos e
  join public.maestra m on m.id_maestra = e.motivo_id
  where e.usuario_id = p_usuario_id
    and m.grupo = 'motivo_puntos'
    and m.codigo in ('voto_positivo_publicacion', 'voto_positivo_comentario');
  if v_votos_positivos >= 10 then
    perform public.otorgar_insignia(p_usuario_id, 'gran_colaborador');
  end if;

  select exists(
    select 1 from public.publicaciones
    where autor_id = p_usuario_id and puntaje >= 10
  ) into v_tendencia;
  if v_tendencia then
    perform public.otorgar_insignia(p_usuario_id, 'tendencia');
  end if;
end;
$$;

-- Cada evento de puntos (publicación, comentario, voto positivo o solución)
-- evalúa los distintivos del usuario que los recibe.
create or replace function public.eventos_puntos_evaluar_insignias()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  perform public.evaluar_insignias(new.usuario_id);
  return new;
end;
$$;

create trigger eventos_puntos_evaluar_insignias
  after insert on public.eventos_puntos
  for each row execute function public.eventos_puntos_evaluar_insignias();

-- Estas funciones son internas (se disparan desde triggers), no endpoints RPC.
revoke execute on function public.otorgar_insignia(uuid, text) from public, anon, authenticated;
revoke execute on function public.evaluar_insignias(uuid) from public, anon, authenticated;
revoke execute on function public.eventos_puntos_evaluar_insignias() from public, anon, authenticated;

comment on function public.evaluar_insignias(uuid) is
  'Otorga distintivos verificables: primer_paso (1 publicación), resuelve_dudas (1 solución), voz_del_campus (20 aportes), constante (actividad en 7 días), gran_colaborador (10 votos positivos recibidos), tendencia (publicación con puntaje >= 10). Pendientes: buen_samaritano y vendedor_activo.';

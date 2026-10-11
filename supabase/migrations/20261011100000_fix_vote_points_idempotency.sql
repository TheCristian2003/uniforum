-- Corrige la idempotencia de puntos por voto.
--
-- La version anterior usaba la clave 'voto_publicacion:<voto_id>' (o
-- 'voto_comentario:<voto_id>'). Si el votante borraba su voto y volvia a
-- votar, se generaba un id nuevo y por tanto una clave nueva, lo que permitia
-- premiar repetidamente al mismo autor por el mismo votante y contenido.
--
-- El modelo exige un evento por votante y contenido (AGENTS.md seccion 5 y 8).
-- La clave pasa a combinar votante + objetivo. Es una migracion no destructiva:
-- reemplaza la funcion y deja los eventos historicos intactos.

create or replace function public.actualizar_puntaje_y_puntos_voto()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_delta integer;
  v_autor_id uuid;
  v_publicacion_id uuid;
  v_comentario_id uuid;
  v_clave text;
begin
  if tg_op = 'INSERT' then
    v_delta := new.valor;
    v_publicacion_id := new.publicacion_id;
    v_comentario_id := new.comentario_id;
  elsif tg_op = 'UPDATE' then
    v_delta := new.valor - old.valor;
    v_publicacion_id := new.publicacion_id;
    v_comentario_id := new.comentario_id;
  else
    v_delta := -old.valor;
    v_publicacion_id := old.publicacion_id;
    v_comentario_id := old.comentario_id;
  end if;

  if v_publicacion_id is not null then
    update public.publicaciones
    set puntaje = puntaje + v_delta
    where id = v_publicacion_id
    returning autor_id into v_autor_id;

    if tg_op <> 'DELETE' and new.valor = 1 then
      v_clave := format('voto_publicacion:%s:%s', new.usuario_id, v_publicacion_id);
      perform public.otorgar_puntos(
        v_autor_id, 'voto_positivo_publicacion', 3, v_clave, v_publicacion_id, null
      );
    end if;
  else
    select c.autor_id, c.publicacion_id
      into v_autor_id, v_publicacion_id
    from public.comentarios c
    where c.id = v_comentario_id;

    update public.comentarios
    set puntaje = puntaje + v_delta
    where id = v_comentario_id;

    if tg_op <> 'DELETE' and new.valor = 1 then
      v_clave := format('voto_comentario:%s:%s', new.usuario_id, v_comentario_id);
      perform public.otorgar_puntos(
        v_autor_id, 'voto_positivo_comentario', 2, v_clave, v_publicacion_id, null
      );
    end if;
  end if;

  if tg_op = 'DELETE' then
    return old;
  end if;
  return new;
end;
$$;

revoke execute on function public.actualizar_puntaje_y_puntos_voto() from public, anon, authenticated;

comment on function public.actualizar_puntaje_y_puntos_voto() is
  'Actualiza puntaje y otorga puntos de voto de forma idempotente por votante+objetivo.';

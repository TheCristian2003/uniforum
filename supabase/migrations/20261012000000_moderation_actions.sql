-- Acciones de moderación (Etapa 7b)
--
-- Hasta ahora moderación solo podía cambiar el estado de un reporte. Esta
-- migración añade:
--   1. Ocultar una publicación (estado 'oculto'), que el cliente no puede hacer
--      porque `publicaciones.estado_id` no tiene GRANT de escritura.
--   2. Restringir (sancionar) usuarios de forma temporal o permanente y
--      bloquear que publiquen o comenten mientras la restricción esté vigente.
--
-- El borrado duro de publicaciones y comentarios ya lo permite RLS para roles
-- privilegiados, así que no requiere funciones nuevas. No se activa ni se
-- modifica RLS de forma insegura: las escrituras nuevas pasan por funciones
-- SECURITY DEFINER que verifican `es_rol_privilegiado()`.

-- Catálogo del tipo de restricción.
insert into public.maestra (grupo, codigo, nombre, descripcion, orden) values
  ('tipo_restriccion', 'temporal', 'Temporal', 'Restricción con fecha de fin.', 10),
  ('tipo_restriccion', 'permanente', 'Permanente', 'Restricción sin fecha de fin.', 20)
on conflict (grupo, codigo) do nothing;

create table public.restricciones_usuario (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references public.perfiles(id) on delete cascade,
  tipo_id integer not null references public.maestra(id_maestra) on delete restrict,
  motivo varchar(300) not null,
  reporte_id uuid references public.reportes(id) on delete set null,
  creado_por uuid not null default auth.uid() references public.perfiles(id) on delete restrict,
  inicia_en timestamptz not null default now(),
  expira_en timestamptz,
  activa boolean not null default true,
  levantada_por uuid references public.perfiles(id) on delete set null,
  levantada_en timestamptz,
  creado_en timestamptz not null default now(),
  constraint restricciones_motivo_no_vacio
    check (char_length(btrim(motivo)) between 3 and 300),
  constraint restricciones_expiracion_coherente
    check (expira_en is null or expira_en > inicia_en)
);

create index restricciones_usuario_usuario_idx on public.restricciones_usuario(usuario_id);
create index restricciones_usuario_tipo_idx on public.restricciones_usuario(tipo_id);
create index restricciones_usuario_reporte_idx on public.restricciones_usuario(reporte_id);
create index restricciones_usuario_creado_por_idx on public.restricciones_usuario(creado_por);
create index restricciones_usuario_activa_idx
  on public.restricciones_usuario(usuario_id) where activa;

-- Valida que `tipo_id` pertenezca al grupo correcto (patrón de validar_catalogos).
create or replace function public.validar_tipo_restriccion()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1 from public.maestra
    where id_maestra = new.tipo_id and grupo = 'tipo_restriccion' and activo
  ) then
    raise exception 'tipo_id debe pertenecer al grupo tipo_restriccion';
  end if;
  return new;
end;
$$;

create trigger restricciones_validar_tipo before insert or update on public.restricciones_usuario
  for each row execute function public.validar_tipo_restriccion();

-- ¿El usuario de la sesión tiene una restricción vigente? Sin argumentos para
-- no exponer el estado de terceros (RLS solo deja leer tu propia restricción o
-- a moderación).
create or replace function public.usuario_restringido()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.restricciones_usuario r
    where r.usuario_id = auth.uid()
      and r.activa
      and (r.expira_en is null or r.expira_en > now())
  )
$$;

-- Ocultar una publicación reportada. El autor y moderación pueden ver las
-- publicaciones ocultas; el resto deja de verlas.
create or replace function public.moderar_ocultar_publicacion(p_publicacion_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.es_rol_privilegiado() then
    raise exception 'Solo el equipo de moderación puede ocultar publicaciones';
  end if;

  update public.publicaciones
     set estado_id = public.id_maestra('estado_publicacion', 'oculto')
   where id = p_publicacion_id
     and estado_id <> public.id_maestra('estado_publicacion', 'eliminado');

  if not found then
    raise exception 'La publicación no existe o ya estaba oculta';
  end if;
end;
$$;

-- Restringir a un usuario. `p_dias` null = permanente. Evita duplicar una
-- restricción vigente y no permite sancionarse a uno mismo.
create or replace function public.moderar_restringir_usuario(
  p_usuario_id uuid,
  p_motivo text,
  p_dias integer default null,
  p_reporte_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tipo_id integer;
  v_id uuid;
begin
  if not public.es_rol_privilegiado() then
    raise exception 'Solo el equipo de moderación puede restringir usuarios';
  end if;
  if p_usuario_id = auth.uid() then
    raise exception 'No puedes restringir tu propia cuenta';
  end if;
  if p_motivo is null or char_length(btrim(p_motivo)) < 3 then
    raise exception 'El motivo de la restricción es obligatorio';
  end if;
  if p_dias is not null and (p_dias < 1 or p_dias > 3650) then
    raise exception 'La duración debe estar entre 1 y 3650 días';
  end if;
  if exists (
    select 1 from public.restricciones_usuario r
    where r.usuario_id = p_usuario_id
      and r.activa
      and (r.expira_en is null or r.expira_en > now())
  ) then
    raise exception 'El usuario ya tiene una restricción vigente';
  end if;

  v_tipo_id := public.id_maestra(
    'tipo_restriccion',
    case when p_dias is null then 'permanente' else 'temporal' end
  );

  insert into public.restricciones_usuario (
    usuario_id, tipo_id, motivo, reporte_id, creado_por, expira_en
  )
  values (
    p_usuario_id, v_tipo_id, btrim(p_motivo), p_reporte_id, auth.uid(),
    case when p_dias is null then null else now() + make_interval(days => p_dias) end
  )
  returning id into v_id;

  return v_id;
end;
$$;

-- Levantar una restricción antes de su fecha de fin.
create or replace function public.moderar_levantar_restriccion(p_restriccion_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.es_rol_privilegiado() then
    raise exception 'Solo el equipo de moderación puede levantar restricciones';
  end if;

  update public.restricciones_usuario
     set activa = false,
         levantada_por = auth.uid(),
         levantada_en = now()
   where id = p_restriccion_id
     and activa;

  if not found then
    raise exception 'La restricción no existe o ya estaba inactiva';
  end if;
end;
$$;

-- Trigger de catálogo.
create trigger restricciones_usuario_validar_catalogos
  before insert or update on public.restricciones_usuario
  for each row execute function public.validar_tipo_restriccion();

-- Enforcement: bloquear publicar y comentar mientras la restricción esté vigente.
drop policy publicaciones_creacion_autorizada on public.publicaciones;
create policy publicaciones_creacion_autorizada on public.publicaciones
  for insert to authenticated
  with check (
    not public.usuario_restringido()
    and (
      (
        autor_id = (select auth.uid())
        and (select public.puede_publicar_tipo(tipo_id))
      )
      or (select public.es_rol_privilegiado())
    )
  );

drop policy comentarios_creacion_autorizada on public.comentarios;
create policy comentarios_creacion_autorizada on public.comentarios
  for insert to authenticated
  with check (
    not public.usuario_restringido()
    and (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()))
  );

-- RLS de la tabla de restricciones: cada persona ve solo la suya; moderación
-- ve todas. Las escrituras solo ocurren por las funciones SECURITY DEFINER.
alter table public.restricciones_usuario enable row level security;

create policy restricciones_usuario_lectura on public.restricciones_usuario
  for select to authenticated
  using (
    usuario_id = (select auth.uid())
    or (select public.es_rol_privilegiado())
  );

-- Privilegios: sin acceso directo de escritura; lectura para el propio usuario
-- y moderación.
revoke all on table public.restricciones_usuario from public, anon, authenticated;
grant select on table public.restricciones_usuario to authenticated;

revoke execute on function public.usuario_restringido() from public, anon, authenticated;
grant execute on function public.usuario_restringido() to authenticated;

revoke execute on function public.moderar_ocultar_publicacion(uuid) from public, anon, authenticated;
grant execute on function public.moderar_ocultar_publicacion(uuid) to authenticated;

revoke execute on function public.moderar_restringir_usuario(uuid, text, integer, uuid) from public, anon, authenticated;
grant execute on function public.moderar_restringir_usuario(uuid, text, integer, uuid) to authenticated;

revoke execute on function public.moderar_levantar_restriccion(uuid) from public, anon, authenticated;
grant execute on function public.moderar_levantar_restriccion(uuid) to authenticated;

revoke execute on function public.validar_tipo_restriccion() from public, anon, authenticated;

comment on table public.restricciones_usuario is
  'Sanciones temporales o permanentes. Solo moderación escribe (vía RPC); el usuario ve la propia.';

-- Imágenes adjuntas en publicaciones y comentarios.
--
-- Aditivo y reversible:
--   * agrega `imagenes` a `comentarios` (las publicaciones ya la tienen);
--   * limita la cantidad de imágenes por fila;
--   * crea el bucket público `publicaciones` en Supabase Storage y sus
--     políticas RLS para que cada persona solo escriba en su carpeta `{uid}/`.
--
-- La lectura de un bucket público se sirve por URL pública; las políticas de
-- escritura siguen exigiendo autenticación y propiedad de la carpeta.

alter table public.comentarios
  add column if not exists imagenes text[] not null default '{}';

grant insert (imagenes) on public.comentarios to authenticated;
grant update (imagenes) on public.comentarios to authenticated;

alter table public.publicaciones
  add constraint publicaciones_imagenes_max
  check (imagenes is null or array_length(imagenes, 1) <= 3);

alter table public.comentarios
  add constraint comentarios_imagenes_max
  check (imagenes is null or array_length(imagenes, 1) <= 1);

-- Bucket público de solo lectura para las imágenes adjuntas.
insert into storage.buckets (id, name, public)
values ('publicaciones', 'publicaciones', true)
on conflict (id) do update set public = true;

-- Lectura pública de los objetos del bucket.
drop policy if exists imagenes_lectura_publica on storage.objects;
create policy imagenes_lectura_publica on storage.objects
  for select
  using (bucket_id = 'publicaciones');

-- Cada persona solo escribe objetos dentro de su propia carpeta `{uid}/...`.
drop policy if exists imagenes_subida_propia on storage.objects;
create policy imagenes_subida_propia on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'publicaciones'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists imagenes_actualizacion_propia on storage.objects;
create policy imagenes_actualizacion_propia on storage.objects
  for update to authenticated
  using (
    bucket_id = 'publicaciones'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'publicaciones'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

drop policy if exists imagenes_eliminacion_propia on storage.objects;
create policy imagenes_eliminacion_propia on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'publicaciones'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

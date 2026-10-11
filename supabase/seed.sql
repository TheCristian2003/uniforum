-- Datos ficticios para desarrollo. Ejecutar despues de la migracion inicial.
-- No incluye usuarios ni contenido asociado a auth.users.

insert into public.maestra (grupo, codigo, nombre, descripcion, orden) values
  ('sede', 'riohacha', 'Sede Riohacha', 'Dato ficticio de desarrollo.', 10),
  ('facultad', 'ingenieria', 'Facultad de Ingeniería', 'Dato ficticio de desarrollo.', 10),
  ('facultad', 'salud', 'Facultad de Ciencias de la Salud', 'Dato ficticio de desarrollo.', 20),
  ('programa', 'ingenieria_sistemas', 'Ingeniería de Sistemas', 'Dato ficticio de desarrollo.', 10),
  ('programa', 'medicina', 'Medicina', 'Dato ficticio de desarrollo.', 20)
on conflict (grupo, codigo) do update
  set nombre = excluded.nombre,
      descripcion = excluded.descripcion,
      orden = excluded.orden,
      activo = true;

update public.maestra programa
set padre_id = facultad.id_maestra
from public.maestra facultad
where programa.grupo = 'programa'
  and facultad.grupo = 'facultad'
  and (
    (programa.codigo = 'ingenieria_sistemas' and facultad.codigo = 'ingenieria')
    or (programa.codigo = 'medicina' and facultad.codigo = 'salud')
  );

insert into public.canales (nombre, slug, descripcion, tipo_canal_id, unidad_id, icono)
select
  datos.nombre,
  datos.slug,
  datos.descripcion,
  public.id_maestra('tipo_canal', datos.tipo_canal),
  case when datos.unidad_grupo is null then null else public.id_maestra(datos.unidad_grupo, datos.unidad_codigo) end,
  datos.icono
from (
  values
    ('Comunidad general', 'comunidad-general', 'Espacio ficticio para conversaciones de la comunidad.', 'general', null::text, null::text, 'groups'),
    ('Ingeniería', 'ingenieria', 'Canal ficticio de la Facultad de Ingeniería.', 'unidad_academica', 'facultad', 'ingenieria', 'engineering'),
    ('Bienestar y vida universitaria', 'vida-universitaria', 'Canal ficticio para la vida en campus.', 'general', null::text, null::text, 'favorite')
) as datos(nombre, slug, descripcion, tipo_canal, unidad_grupo, unidad_codigo, icono)
on conflict (slug) do update
  set nombre = excluded.nombre,
      descripcion = excluded.descripcion,
      tipo_canal_id = excluded.tipo_canal_id,
      unidad_id = excluded.unidad_id,
      icono = excluded.icono,
      activo = true;

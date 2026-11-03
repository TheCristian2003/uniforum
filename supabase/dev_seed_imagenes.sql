-- Imágenes de DEMO para desarrollo (NO aplicar en producción).
--
-- Agrega avatares a los 12 perfiles y fotos adjuntas a varias publicaciones
-- del seed de demo. Es idempotente: usa UPDATE por alias/título, así que se
-- puede ejecutar varias veces sin duplicar nada.
--
-- Requiere haber ejecutado antes supabase/dev_seed_demo_data.sql (necesita que
-- existan esos perfiles y publicaciones).
--
-- Las URLs apuntan a servicios públicos de imágenes de prueba:
--   * avatares: https://i.pravatar.cc  (retratos ficticios, ?img=1..70)
--   * fotos:    https://picsum.photos (fotos aleatorias deterministas por seed)
-- Son imágenes remotas ficticias, sin datos personales reales; el dispositivo
-- necesita conexión a internet para verlas.

---------------------------------------------------------------------------
-- 1) Avatares de perfiles (retratos ficticios)
---------------------------------------------------------------------------
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=47' where alias = 'AliceR';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=12' where alias = 'BrunoT';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=32' where alias = 'CamiO';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=15' where alias = 'DiegoM';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=44' where alias = 'Elenita';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=8'  where alias = 'FabL';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=26' where alias = 'GabyR';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=60' where alias = 'HugoM';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=5'  where alias = 'IvanS';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=49' where alias = 'JuliH';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=18' where alias = 'KevinD';
update public.perfiles set avatar_url = 'https://i.pravatar.cc/300?img=23' where alias = 'LuciR';

---------------------------------------------------------------------------
-- 2) Imágenes adjuntas en publicaciones (máx. 3 por publicación)
---------------------------------------------------------------------------
update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-parcial/800/600'
] where titulo = 'Aviso: Parcial de Programación II';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-vscode-1/500/500',
  'https://picsum.photos/seed/vybe-vscode-2/500/500',
  'https://picsum.photos/seed/vybe-vscode-3/500/500'
] where titulo = 'VS Code + Flutter tips';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-git-1/500/500',
  'https://picsum.photos/seed/vybe-git-2/500/500'
] where titulo = 'Material de estudio Git';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-bd-1/500/500',
  'https://picsum.photos/seed/vybe-bd-2/500/500'
] where titulo = 'Apuntes de Base de Datos';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-cafetin/800/600'
] where titulo = 'El cafetín hoy estuvo brutal';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-libro/800/600'
] where titulo = 'Venta: Libro de Algoritmos';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-mouse/800/600'
] where titulo = 'Venta: Mouse inalámbrico';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-maleta/800/600'
] where titulo = 'Venta: Maleta para laptop';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-cartera/800/600'
] where titulo = 'Perdido: Cartera negra';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-audifonos/800/600'
] where titulo = 'Perdido: Audífonos';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-cartera-hallada/800/600'
] where titulo = 'Encontrado: Cartera';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-usb/800/600'
] where titulo = 'Encontrado: Llave USB';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-charla-ia/800/600'
] where titulo = 'Evento: Charla IA aplicada';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-taller-git/800/600'
] where titulo = 'Taller: Git y GitHub';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-donacion/800/600'
] where titulo = 'Jornada de donación de sangre';

update public.publicaciones set imagenes = array[
  'https://picsum.photos/seed/vybe-torta/800/600'
] where titulo = 'Se rumora que hay torta gratis hoy';

---------------------------------------------------------------------------
-- 3) Verificación: avisa si el seed de demo no estaba aplicado
---------------------------------------------------------------------------
do $$
declare
  v_aliases text[] := array['AliceR','BrunoT','CamiO','DiegoM','Elenita','FabL',
                            'GabyR','HugoM','IvanS','JuliH','KevinD','LuciR'];
  v_titulos text[] := array[
    'Aviso: Parcial de Programación II','VS Code + Flutter tips',
    'Material de estudio Git','Apuntes de Base de Datos',
    'El cafetín hoy estuvo brutal','Venta: Libro de Algoritmos',
    'Venta: Mouse inalámbrico','Venta: Maleta para laptop',
    'Perdido: Cartera negra','Perdido: Audífonos','Encontrado: Cartera',
    'Encontrado: Llave USB','Evento: Charla IA aplicada',
    'Taller: Git y GitHub','Jornada de donación de sangre',
    'Se rumora que hay torta gratis hoy'];
  n_avatares int;
  n_fotos    int;
  n_titulos  int;
begin
  select count(*) into n_avatares
  from public.perfiles
  where alias = any (v_aliases) and avatar_url is not null;

  select count(*), count(distinct titulo) into n_fotos, n_titulos
  from public.publicaciones
  where titulo = any (v_titulos) and imagenes is not null and array_length(imagenes, 1) > 0;

  if n_avatares = 0 and n_fotos = 0 then
    raise exception 'No se encontraron perfiles/publicaciones de demo. Ejecuta primero supabase/dev_seed_demo_data.sql.';
  end if;

  raise notice 'Imágenes de demo: % avatares de % perfiles y fotos en % de % publicaciones.',
    n_avatares, array_length(v_aliases, 1), n_titulos, array_length(v_titulos, 1);
end $$;

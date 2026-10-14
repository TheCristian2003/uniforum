-- Privacidad de los datos personales del perfil.
--
-- Hasta ahora cualquier usuario autenticado podia leer todas las columnas de
-- `perfiles`, incluidos `celular` y `fecha_nacimiento`. Esta migracion limita
-- esa lectura: los datos personales solo son accesibles para el propio usuario
-- a traves de la vista `mi_perfil`. El resto de columnas (alias, avatar,
-- puntos, etc.) siguen disponibles para los perfiles activos segun la politica
-- `perfiles_lectura_autenticada`.

-- 1. Revocar el SELECT a nivel de tabla, que implica todas las columnas.
revoke select on public.perfiles from authenticated;
revoke select on public.perfiles from anon;

-- 2. Conceder SELECT unicamente sobre las columnas no sensibles.
grant select (
  id,
  alias,
  tipo_perfil_id,
  programa_id,
  sede_id,
  biografia,
  avatar_url,
  es_verificada,
  nombre_oficial,
  puntos,
  activo,
  creado_en,
  actualizado_en
) on public.perfiles to authenticated;

-- 3. Vista con los datos personales del propio usuario.
--    `security_invoker = false` ejecuta la vista con los privilegios del
--    propietario (que si puede leer las columnas), pero el filtro
--    `id = auth.uid()` garantiza que solo se devuelve la fila propia.
create or replace view public.mi_perfil
with (security_invoker = false) as
select
  p.id,
  p.celular,
  p.fecha_nacimiento
from public.perfiles p
where p.id = auth.uid();

grant select on public.mi_perfil to authenticated;

comment on view public.mi_perfil is
  'Datos personales (celular, fecha_nacimiento) del usuario autenticado.';

-- Lectura pública de catálogos para el registro.
--
-- La pantalla de registro necesita los catálogos de `maestra` (tipo de perfil,
-- programa y sede) ANTES de que el usuario tenga sesión, es decir, con el rol
-- `anon`. El esquema inicial revocó todos los privilegios a `anon`
-- (`revoke all on all tables ... from anon, authenticated`) y solo volvió a
-- conceder SELECT a `authenticated`, por lo que el registro no podía cargar
-- el formulario ("permission denied for table maestra").
--
-- `maestra` son datos de referencia no sensibles, así que se concede lectura
-- mínima a `anon` limitada a los registros activos.

grant select on public.maestra to anon;

drop policy if exists maestra_lectura_publica on public.maestra;
create policy maestra_lectura_publica
  on public.maestra
  for select
  to anon
  using (activo);

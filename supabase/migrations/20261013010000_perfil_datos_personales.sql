-- Datos personales opcionales del perfil: celular y fecha de nacimiento.
-- Migracion no destructiva: solo agrega columnas, restricciones de formato y
-- el privilegio de actualizacion de los nuevos campos.

alter table public.perfiles
  add column if not exists celular varchar(20),
  add column if not exists fecha_nacimiento date;

-- Formato del celular: solo digitos, entre 7 y 15 (Colombia suele ser 10).
alter table public.perfiles
  drop constraint if exists perfiles_celular_formato;
alter table public.perfiles
  add constraint perfiles_celular_formato
  check (celular is null or celular ~ '^[0-9]{7,15}$');

-- Fecha de nacimiento dentro de un rango razonable (no futura, no absurda).
alter table public.perfiles
  drop constraint if exists perfiles_fecha_nacimiento_valida;
alter table public.perfiles
  add constraint perfiles_fecha_nacimiento_valida
  check (fecha_nacimiento is null or fecha_nacimiento >= date '1900-01-01');

-- El esquema inicial otorga UPDATE por columnas; se agregan las nuevas.
grant update (celular, fecha_nacimiento) on public.perfiles to authenticated;

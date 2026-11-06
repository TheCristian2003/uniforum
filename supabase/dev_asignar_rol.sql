-- Asignación manual de rol privilegiado para DESARROLLO.
--
-- Ejecutar solo en el SQL Editor del proyecto de desarrollo, nunca en
-- producción. Cambia el correo y el rol antes de ejecutar.
--
-- Roles válidos: administrador, moderador, institucional.
-- Después de ejecutarlo, el usuario debe cerrar y volver a iniciar sesión para
-- que el nuevo JWT incluya app_metadata.app_role.

do $$
declare
  v_email text := 'moderador@univ.test';
  v_rol text := 'moderador';
begin
  if v_rol not in ('administrador', 'moderador', 'institucional') then
    raise exception 'Rol inválido: %', v_rol;
  end if;

  update auth.users
  set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb)
      || jsonb_build_object('app_role', v_rol),
      updated_at = now()
  where lower(email) = lower(v_email);

  if not found then
    raise exception 'No existe un usuario con correo %', v_email;
  end if;

  raise notice 'Rol % asignado a %', v_rol, v_email;
end $$;

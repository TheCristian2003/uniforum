-- Supabase concede EXECUTE por defecto a anon/authenticated en este proyecto.
-- Revocamos esos endpoints implícitos y dejamos solo el RPC autenticado
-- explícitamente necesario para marcar una solución.

alter function public.id_maestra(text, text) security invoker;
alter function public.puede_publicar_tipo(integer) security invoker;

revoke execute on function public.id_maestra(text, text) from anon, authenticated;
revoke execute on function public.puede_publicar_tipo(integer) from anon, authenticated;
revoke execute on function public.es_rol_privilegiado() from anon, authenticated;
revoke execute on function public.marcar_comentario_solucion(uuid) from anon, authenticated;
revoke execute on function public.rls_auto_enable() from anon, authenticated;

grant execute on function public.id_maestra(text, text) to authenticated;
grant execute on function public.puede_publicar_tipo(integer) to authenticated;
grant execute on function public.es_rol_privilegiado() to authenticated;
grant execute on function public.marcar_comentario_solucion(uuid) to authenticated;

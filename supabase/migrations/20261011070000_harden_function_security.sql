-- Endurecimiento posterior a los asesores de Supabase.
-- Las funciones internas conservan el acceso necesario para RLS/triggers,
-- pero no quedan expuestas como RPC anónimo.

alter function public.actualizar_actualizado_en()
  set search_path = public;
alter function public.es_rol_privilegiado()
  set search_path = public;

revoke execute on function public.id_maestra(text, text) from public;
grant execute on function public.id_maestra(text, text) to authenticated;

revoke execute on function public.puede_publicar_tipo(integer) from public;
grant execute on function public.puede_publicar_tipo(integer) to authenticated;

revoke execute on function public.marcar_comentario_solucion(uuid) from public;
grant execute on function public.marcar_comentario_solucion(uuid) to authenticated;

revoke execute on function public.es_rol_privilegiado() from public;
grant execute on function public.es_rol_privilegiado() to authenticated;

revoke execute on function public.actualizar_actualizado_en() from public;

-- Es un event trigger interno de Supabase, no un endpoint de la aplicación.
revoke execute on function public.rls_auto_enable() from public;

-- Índices para las columnas que participan en claves foráneas.
create index canales_tipo_canal_idx on public.canales(tipo_canal_id);
create index canales_unidad_idx on public.canales(unidad_id);
create index eventos_puntos_motivo_idx on public.eventos_puntos(motivo_id);
create index eventos_puntos_publicacion_idx on public.eventos_puntos(publicacion_id);
create index insignias_usuario_insignia_idx on public.insignias_usuario(insignia_id);
create index maestra_padre_idx on public.maestra(padre_id);
create index perfiles_sede_idx on public.perfiles(sede_id);
create index publicaciones_categoria_idx on public.publicaciones(categoria_id);
create index publicaciones_estado_idx on public.publicaciones(estado_id);
create index publicaciones_tipo_idx on public.publicaciones(tipo_id);
create index reportes_comentario_idx on public.reportes(comentario_id);
create index reportes_motivo_idx on public.reportes(motivo_id);
create index reportes_publicacion_idx on public.reportes(publicacion_id);
create index reportes_reportante_idx on public.reportes(reportante_id);
create index votos_comentario_idx on public.votos(comentario_id);
create index votos_publicacion_idx on public.votos(publicacion_id);

-- Una política por operación evita evaluar varias políticas permisivas para la
-- misma fila y usa initplans para auth.uid()/JWT una sola vez por consulta.
drop policy canales_lectura_autenticada on public.canales;
drop policy canales_gestion_privilegiada on public.canales;
create policy canales_lectura_autenticada on public.canales for select to authenticated
  using (activo or (select public.es_rol_privilegiado()));
create policy canales_creacion_privilegiada on public.canales for insert to authenticated
  with check ((select public.es_rol_privilegiado()));
create policy canales_actualizacion_privilegiada on public.canales for update to authenticated
  using ((select public.es_rol_privilegiado()))
  with check ((select public.es_rol_privilegiado()));
create policy canales_eliminacion_privilegiada on public.canales for delete to authenticated
  using ((select public.es_rol_privilegiado()));

drop policy perfiles_lectura_autenticada on public.perfiles;
drop policy perfiles_actualizacion_propia on public.perfiles;
create policy perfiles_lectura_autenticada on public.perfiles for select to authenticated
  using (activo or id = (select auth.uid()));
create policy perfiles_actualizacion_propia on public.perfiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

drop policy publicaciones_lectura_autenticada on public.publicaciones;
drop policy publicaciones_creacion_propia on public.publicaciones;
drop policy publicaciones_actualizacion_propia on public.publicaciones;
drop policy publicaciones_eliminacion_propia on public.publicaciones;
drop policy publicaciones_moderacion on public.publicaciones;
create policy publicaciones_lectura_autenticada on public.publicaciones for select to authenticated
  using (
    estado_id = public.id_maestra('estado_publicacion', 'publicado')
    or autor_id = (select auth.uid())
    or (select public.es_rol_privilegiado())
  );
create policy publicaciones_creacion_autorizada on public.publicaciones for insert to authenticated
  with check (
    (
      autor_id = (select auth.uid())
      and (select public.puede_publicar_tipo(tipo_id))
    )
    or (select public.es_rol_privilegiado())
  );
create policy publicaciones_actualizacion_autorizada on public.publicaciones for update to authenticated
  using (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()))
  with check (
    (
      autor_id = (select auth.uid())
      and (select public.puede_publicar_tipo(tipo_id))
    )
    or (select public.es_rol_privilegiado())
  );
create policy publicaciones_eliminacion_autorizada on public.publicaciones for delete to authenticated
  using (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()));

drop policy comentarios_lectura_autenticada on public.comentarios;
drop policy comentarios_creacion_propia on public.comentarios;
drop policy comentarios_actualizacion_propia on public.comentarios;
drop policy comentarios_eliminacion_propia on public.comentarios;
drop policy comentarios_moderacion on public.comentarios;
create policy comentarios_lectura_autenticada on public.comentarios for select to authenticated
  using (true);
create policy comentarios_creacion_autorizada on public.comentarios for insert to authenticated
  with check (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()));
create policy comentarios_actualizacion_autorizada on public.comentarios for update to authenticated
  using (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()))
  with check (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()));
create policy comentarios_eliminacion_autorizada on public.comentarios for delete to authenticated
  using (autor_id = (select auth.uid()) or (select public.es_rol_privilegiado()));

drop policy votos_creacion_propia on public.votos;
drop policy votos_actualizacion_propia on public.votos;
drop policy votos_eliminacion_propia on public.votos;
create policy votos_creacion_propia on public.votos for insert to authenticated
  with check (usuario_id = (select auth.uid()));
create policy votos_actualizacion_propia on public.votos for update to authenticated
  using (usuario_id = (select auth.uid()))
  with check (usuario_id = (select auth.uid()));
create policy votos_eliminacion_propia on public.votos for delete to authenticated
  using (usuario_id = (select auth.uid()));

drop policy reportes_creacion_propia on public.reportes;
drop policy reportes_lectura_propia_o_moderacion on public.reportes;
create policy reportes_creacion_propia on public.reportes for insert to authenticated
  with check (reportante_id = (select auth.uid()));
create policy reportes_lectura_propia_o_moderacion on public.reportes for select to authenticated
  using (reportante_id = (select auth.uid()) or (select public.es_rol_privilegiado()));

drop policy eventos_puntos_lectura_propia on public.eventos_puntos;
create policy eventos_puntos_lectura_propia on public.eventos_puntos for select to authenticated
  using (usuario_id = (select auth.uid()) or (select public.es_rol_privilegiado()));

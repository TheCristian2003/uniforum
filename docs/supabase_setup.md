# Configuración de Supabase

## Estado al 11 de octubre de 2026

Existen dos proyectos en la misma organización (el plan gratuito permite dos y
no incluye ramas): uno de **desarrollo** y uno de **producción**. Todo el
trabajo del MVP (migraciones, pruebas y correcciones) se hizo en el de
**desarrollo**; el de producción quedó sin usar.

## Acciones realizadas

1. Se comprobó que el repositorio no tenía CLI de Supabase, PostgreSQL local ni
   una URL de proyecto configurada.
2. Se buscó una integración de Supabase disponible para crear proyectos,
   ejecutar SQL y administrar migraciones.
3. Se encontró una integración de Supabase disponible, pero aún no conectada.
   Se dejó sugerida en la aplicación; sugerirla no crea ni conecta el proyecto.
4. Tras conectar la integración, se verificó que la única organización visible
   es `TheCristian2003's Org` (su identificador interno no se copia aquí).
5. No se utilizó, copió ni guardó la clave enviada en el chat. Como quedó
   expuesta, debe revocarse y sustituirse antes de conectar cualquier cuenta.
6. Se preparó el esquema local en
   `supabase/migrations/20261011000000_initial_schema_v1_1.sql`.
7. Se preparó el seed ficticio en `supabase/seed.sql`.
8. `.env` y `.env.*` quedaron excluidos de Git para evitar publicar secretos.
9. Se documentaron las decisiones de seguridad y los pendientes en
   `docs/decisions.md`.
10. Se intentó consultar el costo de crear el proyecto en la organización
    confirmada, pero el endpoint de costos no estuvo disponible en esta sesión.
    Por seguridad, no se asumió que la región o el plan fueran gratuitos y no
    se creó ningún proyecto.
11. El usuario creó manualmente el proyecto `univibe` en `us-east-1` y se
    verificó que aparece como `ACTIVE_HEALTHY`.
12. Se aplicaron las migraciones `initial_schema_v1_1`,
    `harden_function_security`, `revoke_default_rpc_privileges` y
    `optimize_indexes_and_rls`.
13. Se ejecutó `supabase/seed.sql`: quedaron 44 registros de catálogo y tres
    canales ficticios; no se crearon usuarios.
14. Se creó `.env` local con la URL y la clave pública publishable. El archivo
    está ignorado por Git y no contiene una service-role key.

## Entornos

Organización `TheCristian2003's Org`, región `us-east-1`, PostgreSQL 17.11.

- **Desarrollo** (referencia `nreglugsyicwbaquexcp`)
  - URL: `https://nreglugsyicwbaquexcp.supabase.co`
  - Estado: esquema canónico aplicado (las cinco migraciones) y pruebas en
    verde. El seed demo (`supabase/seed.sql`) se ejecuta aquí.
  - `.env` local apunta a este proyecto. Todas las pruebas se hacen aquí.
- **Producción** (referencia `luxxhxjibycyuojqzryf`)
  - URL: `https://luxxhxjibycyuojqzryf.supabase.co`
  - Estado: congelado durante el MVP. Conserva un esquema antiguo con errores
    (RLS sin políticas, sin `UNIQUE (grupo, codigo)`), pero sin datos reales.
  - No aplicar nada hasta un release; entonces reconstruir con las migraciones
    canónicas (nunca con el reset destructivo usado para reparar dev).

La contraseña de base de datos y las claves se mantienen únicamente en Supabase,
fuera de este archivo y de Git.

No enviar aquí contraseñas, service-role keys ni tokens de acceso.

## Siguientes pasos después del esquema inicial

1. Añadir `supabase_flutter` al cliente Flutter y leer `.env` en desarrollo.
   _(Hecho: ver `lib/core/config/app_config.dart` y `lib/main.dart`.)_
2. Comprobar el registro/inicio de sesión y la restauración de sesión.
   _(Implementado en `lib/features/auth`; pendiente de probar contra el proyecto
   remoto con usuarios reales de desarrollo.)_
3. Verificar las diez tablas, claves foráneas, `CHECK`, índices parciales y
   RLS con pruebas de usuario autenticado, propietario y rol privilegiado.
   _(Hecho: `supabase/tests/integrity_and_rls_test.sql` ejecutado en dev el
   2026-10-11, resultado "TODAS LAS PRUEBAS PASARON".)_
4. Mantener `supabase/seed.sql` reproducible y comprobar que solo contiene
   catálogos, unidades y canales ficticios cuando se use en otra instancia.
5. Configurar Auth (registro, confirmación de correo, recuperación de cuenta)
   según la decisión del producto.
6. Registrar en este archivo la referencia del proyecto, la fecha de conexión
   y las comprobaciones ejecutadas, sin incluir secretos.

### Cambios pendientes de aplicar en el proyecto remoto

- La migración `20261011100000_fix_vote_points_idempotency.sql` ya está aplicada
  en la instancia de desarrollo. No tocar producción sin autorización.
- Pruebas `supabase/tests/integrity_and_rls_test.sql`: ejecutadas y en verde en
  desarrollo. Repetir si se cambia el esquema.

## Restricciones de seguridad

- Flutter solo puede usar la URL del proyecto y la clave pública.
- La service-role key y cualquier clave de proveedor de IA permanecen en
  secretos del backend o Edge Functions.
- `es_verificada` no concede permisos administrativos.
- Los roles privilegiados se asignan mediante `app_metadata.app_role` desde
  backend, nunca desde el cliente.
- No se aplicará la migración contra producción sin confirmar explícitamente el
  proyecto de destino.

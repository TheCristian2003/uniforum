# Decisiones técnicas

## Esquema inicial V1.1

La migración `20261011000000_initial_schema_v1_1.sql` crea las diez tablas
propias del modelo V1.1, sus catálogos técnicos mínimos, restricciones,
políticas RLS y funciones de integridad.

`auth.users` sigue siendo propiedad de Supabase. Un trigger crea un perfil con
un alias temporal no sensible (`usuario_<uuid corto>`) y tipo Estudiante; el
onboarding de Flutter deberá exigir que la persona elija su alias definitivo.

Los permisos privilegiados no dependen de `perfiles.es_verificada` ni de
`tipo_perfil_id`. Las políticas leen exclusivamente
`auth.jwt()->app_metadata.app_role`; dicho valor debe ser asignado por una
operación administrativa de backend con service role, nunca desde Flutter.
Mientras no se asigne ese rol, nadie puede crear publicaciones de tipo `aviso`
ni gestionar canales o reportes como moderador.

La migración protege los puntajes y puntos contra escrituras del cliente. Los
eventos de publicación, comentario, voto positivo y solución se registran de
forma idempotente. Los límites diarios ya aplican a publicaciones (3) y
comentarios (10). Las recompensas por objetos encontrados/devueltos se añadirán
cuando se acuerde el contrato de estados y metadatos para esos tipos.

## Idempotencia de puntos por voto (2026-10-11)

La migración `20261011100000_fix_vote_points_idempotency.sql` corrige la clave
de idempotencia de los puntos por voto. Antes se usaba el id del voto
(`voto_publicacion:<voto_id>`), por lo que borrar y volver a votar generaba una
clave nueva y permitía premiar repetidamente al mismo autor. Ahora la clave
combina votante y objetivo (`voto_publicacion:<usuario_id>:<publicacion_id>` y
`voto_comentario:<usuario_id>:<comentario_id>`), cumpliendo la regla de un
evento por votante y contenido. Los eventos históricos quedan intactos.

## Pruebas SQL/RLS

`supabase/tests/integrity_and_rls_test.sql` contiene pruebas de constraints,
triggers, idempotencia de puntos, privilegios y RLS. Se envuelven en una
transacción que termina en `ROLLBACK`. Deben ejecutarse sobre una instancia de
desarrollo descartable; **aún no se han ejecutado en el proyecto remoto**.

## Autenticación y onboarding (etapa 2)

- El cliente usa `supabase_flutter`; `flutter_dotenv` lee `.env` (ignorado por
  Git) y también admite `--dart-define`. `.env.example` documenta las claves.
- Solo se admiten la URL y la clave pública. No hay service-role en el cliente.
- El onboarding detecta el alias temporal del trigger con el patrón
  `usuario_<8 hex>` (`Perfil.needsOnboarding`) y obliga a reemplazarlo. Es una
  heurística de MVP: si el producto lo requiere, convendrá una columna explícita
  de "onboarding completado" en una migración futura.
- En el onboarding solo se ofrecen tipos auto-seleccionables (estudiante,
  docente, egresado, visitante). Administrador e institucional se asignan en
  backend, no desde el cliente.

## Sistema visual

Se adopta `docs/design.md` (colores institucionales Uniguajira) como referencia
visual **inicial**, a petición del producto. El nombre comercial y la identidad
final siguen pendientes. La tipografía Plus Jakarta Sans y las pantallas
completas (feed, canales, IA) se implementarán en la etapa de base Flutter.

## Decisiones pendientes

- Definir los campos obligatorios de `metadatos` para venta, perdido,
  encontrado y evento, antes de imponer validaciones SQL específicas.
- Definir el flujo de revisión y cierre de reportes y el operador que asignará
  roles privilegiados.
- Definir la política de imágenes de Storage: cantidad, tamaño, MIME y rutas.
- Confirmar la identidad visual/nombre final. El archivo `design.md` se trata
  como referencia visual y no establece nombre comercial ni identidad final.
- Confirmar el mecanismo de confirmación de correo en Supabase Auth para el
  entorno de desarrollo.

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
transacción que termina en `ROLLBACK`. Se ejecutaron sobre la instancia de
desarrollo el 2026-10-11 y terminaron en verde ("TODAS LAS PRUEBAS PASARON").

Detalle operativo: la base de desarrollo se había creado con una versión
antigua del esquema (RLS activado pero sin políticas, sin `UNIQUE (grupo,
codigo)` en `maestra`). Se reconstruyó aplicando las migraciones canónicas en
orden y luego `seed.sql`. Si hay que reconstruir de nuevo en dev: borrar el
trigger `auth_usuario_crear_perfil` en `auth.users`, hacer `DROP TABLE ...
CASCADE` de las diez tablas públicas y reaplicar las migraciones en orden.

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

Se adopta la identidad visual de `docs/design/DESIGN.md` (colores
institucionales Uniguajira) como referencia visual **inicial**, a petición del
producto. El nombre comercial y la identidad final siguen pendientes. El tema
Flutter ya aplica los colores institucionales; la tipografía Plus Jakarta Sans
queda pendiente para el pulido visual.

## Entornos Supabase (2026-10-11)

El plan gratuito permite dos proyectos y no incluye ramas, así que se usan dos
proyectos de la misma organización:

- **Desarrollo** `nreglugsyicwbaquexcp`: aquí se aplican migraciones, seed y
  pruebas. El `.env` local apunta aquí.
- **Producción** `luxxhxjibycyuojqzryf`: congelado durante el MVP.

Reglas para no repetir errores:

- Verificar siempre el Reference ID del proyecto antes de ejecutar SQL
  destructivo. El reset `DROP TABLE ... CASCADE` es **solo** para reparar dev.
- Producción se actualiza al sacar versión, aplicando solo las migraciones en
  orden (aditivas), tras backup y prueba en una copia.
- El seed contiene canales/datos ficticios: no debe sembrarse tal cual en
  producción.

## Navegación (Etapa 3, 2026-10-11)

- Se implementa `MainShell` con `IndexedStack` y barra inferior de cuatro
  destinos (Inicio, Canales, IA, Perfil) más un FAB central para publicar.
- El FAB todavía no abre el formulario de publicación; muestra un aviso
  "próximamente" hasta la etapa de publicaciones.
- El diseño (`docs/design/DESIGN.md`) alterna el estilo del destino activo entre
  amarillo (`primary-container`) y azul (`ug-blue`) según la pantalla. Se
  unifica al **pill amarillo** en las cuatro pestañas por coherencia; el uso del
  azul institucional queda para componentes internos (badges, enlaces).
- Se añaden widgets de estado reutilizables (`LoadingView`, `EmptyView`,
  `ErrorView`) para no duplicar estados de carga/vacío/error entre pantallas.
- Los niveles de gamificación se centralizan en `core/gamification/niveles.dart`
  (Novato, Activo, Referente, Leyenda) para no repetir umbrales en la UI.

## Canales y feed (Etapa 4, 2026-10-11)

- La lista de canales activos, el detalle de canal y el feed de Inicio leen de
  Supabase bajo RLS mediante `CanalesRepository` y `PublicacionesRepository`.
- Los nombres de tipo y categoría se resuelven con los catálogos de `maestra` en
  el cliente (mapas `id_maestra -> nombre`) para evitar desambiguar dos claves
  foráneas hacia la misma tabla en una consulta embebida.
- El repositorio filtra explícitamente por estado `publicado`, además del filtro
  de RLS, para no mezclar borradores/ocultos.
- Se reutilizan `PublicacionCard`, `LoadingView`, `EmptyView` y `ErrorView`, con
  `RefreshIndicator` para recargar, en el feed y en el detalle de canal.
- La fecha relativa se centraliza en `core/utils/fecha_relativa.dart` y el mapeo
  de iconos de canal en `core/utils/icono_canal.dart`.

## Crear publicación (Etapa 5, 2026-10-11)

- Alcance de esta etapa: formulario base (canal, tipo, categoría, título
  opcional, cuerpo y anónimo). Los campos específicos por tipo (venta, perdido,
  encontrado, evento) y las imágenes se difieren a una etapa posterior, ya que
  su esquema figura como decisión pendiente.
- La inserción no envía `autor_id`, `estado_id` ni `puntaje`: los fija el
  trigger `proteger_estado_inicial` en el backend y RLS valida el tipo según el
  rol (`puede_publicar_tipo`). El cliente nunca escribe esos valores.
- La opción de tipo `aviso` solo se muestra a roles privilegiados, leídos de
  `app_metadata.app_role` (`core/auth/roles.dart`). Esto es solo de interfaz: la
  autorización real sigue en RLS.
- Tras crear una publicación se invalidan `feedRecientesProvider` y
  `publicacionesDeCanalProvider(canal)` para refrescar el feed.
- El formulario se abre desde el FAB central de `MainShell`.

## Comentarios y votos (Etapa 6, 2026-10-11)

- El detalle de publicación vive en `PublicacionDetalleScreen`; no existe esa
  pantalla en `docs/design/DESIGN.md`, así que reutiliza la tarjeta de feed, el
  control de voto y los widgets de estado. Se registra la ausencia de diseño.
- Los votos se leen una sola vez con `misVotosProvider` (una consulta por
  usuario), en lugar de consultar el voto de cada tarjeta. `accionVoto` decide
  insertar, actualizar o eliminar según el voto actual, de modo que tocar el
  mismo valor quita el voto.
- El cliente nunca envía `usuario_id` ni `autor_id`: los fija el trigger,
  y RLS limita los votos y comentarios a los del propio usuario. No se puede
  votar el contenido propio (el trigger `validar_voto` lo impide y la interfaz
  deshabilita los botones).
- Marcar una solución usa el RPC `marcar_comentario_solucion`; el backend valida
  que solo el autor de la publicación pueda hacerlo. La columna `es_solucion`
  no tiene `GRANT` de escritura para el cliente.
- Para no exponer el alias de las publicaciones anónimas, el repositorio ya no
  embebe `autor` en la consulta: pide `autor_id` y resuelve los perfiles solo de
  las publicaciones no anónimas. El `autor_id` sigue siendo legible (necesario
  para detectar contenido propio); considerar una vista si se requiere anonimato
  estricto.
- Presentación mejorada reutilizando el lenguaje de `docs/design/DESIGN.md`: la
  publicación se muestra dentro de una tarjeta, `ControlVoto` adopta la píldora
  con borde y resalta el voto activo (azul a favor, rojo en contra) y los avatares
  anónimos usan un icono de persona en el feed y en el detalle.

## Reportes y moderación mínima (Etapa 7, 2026-10-12)

- Cualquier usuario autenticado puede reportar una publicación o un comentario
  desde el detalle (`Reportar` en el menú de la publicación y bandera en los
  comentarios ajenos). Los motivos salen del catálogo `motivo_reporte` de
  `maestra`; el cliente nunca envía `reportante_id` ni `estado_id`, los fija el
  trigger. El backend rechaza reportes pendientes duplicados con el error
  "reporte pendiente", que la hoja de reporte traduce a un mensaje amable.
- La moderación (`ModeracionScreen`) solo se muestra a roles privilegiados
  (`esRolPrivilegiado`): si el usuario no lo es, se muestra un estado de acceso
  restringido y no se consultan los reportes. El acceso se abre desde una
  tarjeta "Moderación" en el perfil, visible solo para esos roles.
- Solo se gestiona el estado del reporte (`pendiente` → `revisado`/`cerrado`).
  Ocultar o eliminar el contenido reportado no es posible desde el cliente
  (no hay `GRANT` de `estado_id` en `publicaciones`); queda fuera del MVP.
- La pantalla de moderación no existe en `docs/design/DESIGN.md`; reutiliza el
  lenguaje visual existente (tarjetas blancas, chips y widgets de estado). Se
  registra la ausencia de diseño.

## Acciones de moderación y restricciones (Etapa 7b, 2026-10-12)

- La moderación deja de ser solo "cambiar el estado del reporte": ahora la
  tarjeta de cada reporte permite **ocultar** o **eliminar** el contenido y
  **restringir al autor**, además de marcar revisado/cerrado.
- Ocultar una publicación es una operación de columna que el cliente no puede
  hacer (no hay `GRANT` de `estado_id` en `publicaciones`), así que se expone el
  RPC `moderar_ocultar_publicacion`, que verifica `es_rol_privilegiado()` y
  cambia `estado_id` a `oculto`. El resto de RLS ya oculta esas publicaciones al
  resto de usuarios y las deja visibles para el autor y moderación.
- El borrado es duro y reutiliza el `DELETE` REST que RLS ya permite a roles
  privilegiados (`publicaciones_eliminacion_autorizada`,
  `comentarios_eliminacion_autorizada`); la app pide confirmación porque borra en
  cascada comentarios y votos. Los comentarios no tienen columna de estado, así
  que solo se pueden eliminar, no ocultar.
- Nuevas restricciones (`public.restricciones_usuario`, tipo
  `temporal`/`permanente`) con RPCs `moderar_restringir_usuario` y
  `moderar_levantar_restriccion`. La escritura queda solo en funciones
  `SECURITY DEFINER` (la tabla no tiene `INSERT`/`UPDATE` para `authenticated`);
  el usuario afectado solo puede leer su propia restricción.
- Enforcement: la política de inserción de `publicaciones` y `comentarios` llama
  a `public.usuario_restringido()`, que bloquea crear contenido mientras la
  restricción esté vigente (no se bloquea votar, por decisión de producto). El
  cliente refleja lo mismo con `miRestriccionActivaProvider`: un banner en
  `MainShell` y mensajes al intentar publicar o comentar.
- Decisión de producto: moderadores y administradores pueden ocultar/eliminar y
  restringir; la restricción puede ser temporal (1/7/30 días) o permanente. La
  asignación de `app_role` sigue siendo responsabilidad del backend.

## Niveles y distintivos (Etapa 8, 2026-10-12)

- Los puntos por acción ya se calculaban en SQL desde la migración inicial
  (`eventos_puntos` con `clave_unica` para idempotencia y topes diarios).
- Niveles (umbrales acordados en `AGENTS.md`, implementados en
  `lib/core/gamification/niveles.dart`): Novato 0–49, Activo 50–149,
  Referente 150–399, Leyenda 400+. El nivel se deriva en la app a partir de
  `perfiles.puntos`, que es un valor controlado por el backend.
- Distintivos: la migración `20261012010000_otorgar_insignias.sql` añade
  `evaluar_insignias`, que se dispara tras cada evento de puntos y concede los
  logros verificables de forma idempotente (`on conflict do nothing`):
  - `primer_paso`: 1 publicación.
  - `resuelve_dudas`: 1 comentario marcado como solución.
  - `voz_del_campus`: 20 aportes (publicaciones + comentarios).
  - `constante`: actividad en 7 días distintos.
  - `gran_colaborador`: 10 votos positivos recibidos.
  - `tendencia`: una publicación con puntaje >= 10.
- Umbrales provisionales (ajustables en la migración). Los conteos se hacen
  sobre las tablas reales, no sobre `eventos_puntos`, salvo los votos positivos.
- Quedan sin otorgar `buen_samaritano` y `vendedor_activo` porque dependen de
  flujos de objetos perdidos/ventas que aún no existen.
- El perfil muestra puntos, nivel, progreso, estadísticas reales (publicaciones,
  comentarios, soluciones, votos recibidos) y la cuadrícula de distintivos.

## Metadatos de publicación por tipo (2026-10-12)

- Los metadatos específicos se guardan en `publicaciones.metadatos` (jsonb, ya
  existente en el esquema V1.1) como objeto, sin incluir datos personales.
- Esquema acordado por tipo (implementado en `MetadatosPublicacion` y en el
  formulario; validado solo en Flutter por ahora):
  - `venta`: `precio` (num ≥ 0, obligatorio), `moneda` (`COP`), `lugar`
    (opcional), `disponible` (bool, por defecto `true`).
  - `perdido`: `fecha` (obligatoria), `lugar` (obligatorio), `recompensa`
    (num opcional).
  - `encontrado`: `fecha` (obligatoria), `lugar` (obligatorio), `entregado`
    (bool, por defecto `false`).
  - `evento`: `inicio` (obligatorio), `fin` (opcional, no anterior al inicio),
    `lugar` (obligatorio), `enlace` (opcional, http/https).
  - `discusion` y `aviso`: sin metadatos.
- Las fechas se serializan como texto ISO-8601 dentro del JSON. El repositorio
  omite la columna `metadatos` del `insert` cuando queda vacía.
- El detalle de la publicación muestra los metadatos y el feed resalta el precio
  en las ventas; la validación en SQL queda pendiente.

## Decisiones pendientes

- Imponer validaciones SQL de `metadatos` (hoy solo en Flutter) una vez
  estabilizado el formato por tipo.
- Definir el operador que asignará roles privilegiados (`app_role`).
- Definir si el contenido oculto debe ser visible para su autor (hoy sí lo es).
- Definir la política de imágenes de Storage: cantidad, tamaño, MIME y rutas.
- Confirmar la identidad visual/nombre final. El archivo `docs/design/DESIGN.md` se trata
  como referencia visual y no establece nombre comercial ni identidad final.
- Confirmar el mecanismo de confirmación de correo en Supabase Auth para el
  entorno de desarrollo.

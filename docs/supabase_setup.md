# Configuración de Supabase

## Estado al 29 de octubre de 2026

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
15. Se añadieron migraciones aditivas para moderación
    (`20261012000000_moderation_actions.sql`), insignias
    (`20261012010000_otorgar_insignias.sql`), imágenes
    (`20261012020000_publication_images.sql`), perfil desde el registro
    (`20261013000000_perfil_desde_registro.sql`), datos personales
    (`20261013010000_perfil_datos_personales.sql`), privacidad del perfil
    (`20261013020000_perfil_privacidad_datos.sql`) y lectura anónima de catálogos
    (`20261014000000_maestra_lectura_anon.sql`). En total, 12 archivos en
    `supabase/migrations/`.
16. La migración de imágenes creó el bucket público `publicaciones` y sus cuatro
    políticas de Storage: lectura pública y escritura, actualización y borrado
    solo dentro de la carpeta `{uid}/`.
17. Se añadieron los seeds de desarrollo `supabase/dev_seed_demo_data.sql` y
    `supabase/dev_seed_imagenes.sql` (datos e imágenes ficticias, idempotentes).
18. Las últimas verificaciones registradas son `flutter analyze` sin errores,
    `flutter test` en verde y la prueba SQL de integridad y RLS en desarrollo.

## Entornos

Organización `TheCristian2003's Org`, región `us-east-1`, PostgreSQL 17.11.

- **Desarrollo** (referencia `nreglugsyicwbaquexcp`)
  - URL: `https://nreglugsyicwbaquexcp.supabase.co`
  - Estado: esquema canónico aplicado (14 migraciones) y pruebas en verde. La
  migración `20261031000000_ia_busqueda_or.sql` está pendiente de aplicar en el
  proyecto de desarrollo. `20261014000000_maestra_lectura_anon.sql` ya está
  aplicada (confirmado por el equipo el 2026-10-29).
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

## Storage

- Bucket público `publicaciones` (lectura por URL pública).
- Ruta obligatoria `{uid}/archivo`; las políticas de Storage exigen que la
  primera carpeta coincida con `auth.uid()`, así que cada usuario solo escribe,
  actualiza o borra sus propios objetos.
- Cantidad máxima por fila: 3 imágenes en `publicaciones` y 1 en `comentarios`
  (`CHECK` en la base). Formatos aceptados en el cliente: jpg, jpeg, png y webp.
- Pendiente: límite de tamaño y validación de MIME en el backend, y limpieza de
  archivos huérfanos al borrar contenido.

## Seeds de desarrollo

Todos son solo para desarrollo; nunca se ejecutan tal cual en producción.

| Archivo | Contenido | Requisito |
|---|---|---|
| `supabase/seed.sql` | Catálogos, sedes, unidades y canales ficticios | Después de las migraciones |
| `supabase/dev_seed_demo_data.sql` | 12 perfiles ficticios con publicaciones, comentarios, votos y reportes | Después de `seed.sql` |
| `supabase/dev_seed_imagenes.sql` | Avatares y fotos de demo por URL pública | Después de `dev_seed_demo_data.sql` |

Los seeds de demo son idempotentes: usan `UPDATE` por alias o título y no crean
usuarios de Auth ni datos personales reales.

## IA del Campus (`campus-ai`)

Código: `supabase/functions/campus-ai/index.ts`. Depende de las migraciones
`20261029000000_ia_contexto_y_cupo.sql` (crea `buscar_contexto_ia`,
`consumir_cupo_ia`, `ia_uso` e `ia_config`) y
`20261030000000_ia_objetos_resumen.sql` (añade `metadatos` al contexto y crea
`resumen_objetos_ia` para conteos de objetos) y
`20261031000000_ia_busqueda_or.sql` (combina los términos de búsqueda con OR).
La función usa el JWT del usuario y las RPC `security invoker`, así que RLS sigue
aplicando y **no necesita la service-role key**. Si `resumen_objetos_ia` no
existe, la función lo registra en los logs y usa consultas directas bajo RLS.

Del lado del cliente, `lib/data/repositories/ia_repository.dart` invoca la
función y la pestaña IA (`lib/features/ia/presentation/ia_screen.dart`) muestra
la respuesta con sus fuentes. Por eso, tras desplegar y aplicar las migraciones,
la pestaña queda operativa sin cambios de código.

Secretos (Dashboard > Edge Functions > Secrets, o `supabase secrets set`):

| Secreto | Obligatorio | Valor |
|---|---|---|
| `GEMINI_API_KEY` | Sí | Clave de Google AI Studio |
| `MODELO_IA` | No | `gemini-3.1-flash-lite` por defecto |
| `IA_CUPO_HABILITADO` | No | `false` desactiva el cupo diario (solo pruebas) |

`SUPABASE_URL` y `SUPABASE_ANON_KEY` los inyecta la plataforma.

Los modelos de Gemini se retiran con el tiempo (el 2.5 Flash ya rechaza cuentas
nuevas con `404`). Si aparece ese código en los logs, ajusta `MODELO_IA` o el
valor por defecto en `index.ts` al modelo vigente que indique el error.

El cupo diario (20 por usuario, zona `America/Bogota`) se cambia en la tabla
`public.ia_config` desde el SQL Editor; el cliente no tiene permisos para
modificarla ni para pasar un límite propio a la RPC.

Para cambiar el límite general (máximo 200 por la validación de la tabla):

```sql
update public.ia_config set limite_diario = 100 where id = 1;
```

Para reponer el cupo de un usuario en el día actual:

```sql
delete from public.ia_uso
where usuario_id = '<uuid-del-usuario>'
  and fecha = (now() at time zone 'America/Bogota')::date;
```

Para desactivar el cupo temporalmente durante pruebas, define el secreto
`IA_CUPO_HABILITADO=false` y vuelve a desplegar la función. Con el cupo
desactivado la respuesta devuelve `restantes: null`; para reactivarlo elimina el
secreto o ponlo en `true`.

Despliegue:

1. Dashboard > Edge Functions > *Deploy a new function* > nombre `campus-ai` >
   pegar `index.ts` > Deploy. Si hay CLI:
   `npx supabase functions deploy campus-ai --project-ref nreglugsyicwbaquexcp`.
2. Definir `GEMINI_API_KEY` en Secrets (y redesplegar si se añade después).
3. Verificar con el JWT de un usuario real:

   ```bash
   curl -X POST "https://nreglugsyicwbaquexcp.supabase.co/functions/v1/campus-ai" \
     -H "Authorization: Bearer <JWT>" \
     -H "Content-Type: application/json" \
     -d '{"pregunta":"¿Qué pasó con el examen de cálculo?"}'
   ```

   Debe responder `{respuesta, fuentes, restantes, modo}`.
4. Ejecutar `supabase/tests/ia_contexto_test.sql` en el SQL Editor: debe imprimir
   "PRUEBAS DE IA PASARON".

Límites implementados: pregunta de 3–500 caracteres, 12 publicaciones y ~7000
caracteres de contexto, ~700 tokens de salida y cupo diario por usuario
(America/Bogotá) definido en `ia_config`. El cliente puede enviar hasta 6 turnos
previos de la conversación (máximo 800 caracteres cada uno) en `historial` para
responder seguimientos; no se almacenan en la base. No se guarda el texto de las
preguntas ni de las respuestas: solo el conteo diario. Para bajar la latencia se
envía `thinkingLevel: "low"` en Gemini 3.x (`thinkingBudget: 0` en 2.5); si el
modelo rechaza el campo, la función reintenta sin él y lo recuerda mientras la
instancia siga viva. Gemini 3.8 Flash no permite apagar del todo el
razonamiento.

La pestaña IA permite adjuntar hasta 3 archivos por consulta (máximo 6 MB por
archivo y 8 MB en total): PDF, imágenes JPEG/PNG/WebP/HEIC, audio
M4A/MP3/WAV/OGG/FLAC/AAC y texto TXT/MD/CSV/JSON, con un solo audio por
consulta. El micrófono graba hasta 2
minutos en M4A y el audio se adjunta a la consulta. La Edge Function valida tipo
y tamaño, envía PDF/imágenes/audio a Gemini como contenido multimodal y extrae
el texto de los archivos de texto; los adjuntos no se guardan en Storage ni en la
base. En Android se requiere `RECORD_AUDIO` y en iOS
`NSMicrophoneUsageDescription` (ya configurados). Hay ejemplos para probar en
`docs/ejemplos_ia/silabo.pdf` y `docs/ejemplos_ia/notas.csv`. Un seguimiento
conversacional puede usar la respuesta anterior, pero no vuelve a enviar
automáticamente el archivo.

La llamada al modelo espera 30 s. El modelo por defecto es el ligero; si no
responde, no existe para la clave o Google devuelve `429`/`5xx`, se reintenta con
`gemini-3-flash-preview` (45 s). Los logs indican qué modelo respondió y cuánto
tardó (`Gemini ok`, `Respondió el modelo de respaldo`, `Fallo al llamar a
Gemini`). Si el modelo sigue sin responder pero la pregunta era de objetos, la
función devuelve las cifras calculadas en SQL con una nota de que la IA está
ocupada.

La búsqueda combina los términos con OR (migración `20261031000000`), de modo
que "alguien vende mouse o maleta" recupera publicaciones que mencionen
cualquiera de las dos palabras, ordenadas por relevancia. Una pregunta concreta
se busca primero en el periodo pedido y luego en todo el historial; las
preguntas de actividad general ("qué se publicó en los últimos 7 días", "qué
pasó", "resumen", "eventos", "populares") usan directamente las publicaciones más
recientes y no las sustituyen por coincidencias antiguas. Así una pregunta
específica no recibe siempre las mismas doce publicaciones y una consulta por
periodo no responde que no hubo actividad si hay publicaciones dentro de él. Si
la pregunta es de votos o popularidad, el contexto se ordena por `puntaje`.

El contexto incluye el puntaje y los detalles de `metadatos` (`inicio`, `fin`,
`lugar`, `precio`, `disponible`, `entregado`) para que el modelo distinga ventas
de objetos encontrados y descarte eventos pasados usando la fecha actual. Las
fuentes que devuelve la función son solo las que el modelo citó con `[P#]`
(máximo 4); si respondió con conocimiento general, `fuentes` queda vacío. En la
app, las respuestas usan `SelectableText.rich` para seleccionar y copiar, renderizan
negritas y código sin comillas invertidas, y los enlaces piden confirmación antes de
abrirse fuera de la app con `url_launcher`. En los
resúmenes la respuesta empieza con una nota determinista si se usaron
publicaciones fuera del periodo pedido. Para preguntas generales (definiciones,
explicaciones, cómo hacer algo) el modelo responde con conocimiento general y
avisa de que no proviene del campus; si no hay publicaciones relacionadas, sigue
respondiendo en vez de devolver un error. Solo un resumen sin publicaciones
devuelve el mensaje de "todavía no hay publicaciones". Los errores del proveedor
se registran en los logs de la función con su código HTTP: `400/401/403` clave o
permisos, `404` modelo inexistente, `429` límite de cuota de Google y `0` bloqueo
por filtros de contenido.

## Siguientes pasos después del esquema inicial

1. Añadir `supabase_flutter` al cliente Flutter y leer `.env` en desarrollo.
   _(Hecho: ver `lib/core/config/app_config.dart` y `lib/main.dart`.)_
2. Comprobar el registro/inicio de sesión y la restauración de sesión.
   _(Implementado en `lib/features/auth`; pendiente de probar contra el proyecto
   remoto con usuarios reales de desarrollo.)_
3. Verificar las once tablas (diez del V1.1 más `restricciones_usuario`),
   claves foráneas, `CHECK`, índices parciales y
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

- Aplicar la migración `20261031000000_ia_busqueda_or.sql` (15.ª) si aún no está
  aplicada; sin ella la búsqueda de la IA exige todas las palabras. Las
  migraciones de contexto y objetos ya están aplicadas.
- Ejecutar `supabase/dev_seed_imagenes.sql` si aún no se hizo (requiere
  `dev_seed_demo_data.sql` ya ejecutado).
- Desplegar `campus-ai` y definir el secreto `GEMINI_API_KEY` (ver la sección de
  IA). El cliente ya invoca la función; sin el despliegue la pestaña IA muestra
  un error de configuración.
- La migración `20261011100000_fix_vote_points_idempotency.sql` ya está aplicada
  en la instancia de desarrollo. No tocar producción sin autorización.
- Pruebas `supabase/tests/integrity_and_rls_test.sql` e
  `supabase/tests/ia_contexto_test.sql`: ejecutar y confirmar el mensaje final
  tras aplicar la nueva migración.
- Pendiente de diseño de datos: validación SQL de `metadatos` y límites de
  tamaño/MIME de las imágenes en Storage.

## Restricciones de seguridad

- Flutter solo puede usar la URL del proyecto y la clave pública.
- La service-role key y cualquier clave de proveedor de IA permanecen en
  secretos del backend o Edge Functions.
- `es_verificada` no concede permisos administrativos.
- Los roles privilegiados se asignan mediante `app_metadata.app_role` desde
  backend, nunca desde el cliente.
- No se aplicará la migración contra producción sin confirmar explícitamente el
  proyecto de destino.

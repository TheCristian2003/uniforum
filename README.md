# Plataforma Social Universitaria Inteligente

> **Nombre del producto:** pendiente de definir. `UniForum` fue un nombre de trabajo y no debe tratarse como definitivo.

Aplicación móvil desarrollada con **Flutter y Dart** para conectar a estudiantes, docentes, personal administrativo, egresados y, cuando corresponda, visitantes. Combina conversación social, información útil, vida universitaria, publicaciones institucionales, compra y venta, objetos perdidos/encontrados, eventos, inteligencia artificial y gamificación.

No es únicamente un foro académico: busca convertirse en un espacio digital donde ocurre la vida universitaria, desde dudas y avisos hasta conversaciones sociales, tendencias y actividades del campus.

## Pilares del producto

1. **Comunidad:** publicaciones, comentarios, canales, likes y dislikes.
2. **Vida universitaria:** avisos, conversaciones sociales, eventos, compra/venta y objetos perdidos/encontrados.
3. **Inteligencia artificial:** asistente contextual, resúmenes “¿Qué me perdí?”, búsqueda asistida y ayuda para redactar publicaciones.
4. **Gamificación:** puntos, niveles, distintivos y, si el tiempo lo permite, ranking semanal.
5. **Confianza y moderación:** perfiles verificados, reportes, privacidad y controles para cuentas institucionales.

## Tipos de publicación

La aplicación utiliza una sola entidad `publicaciones` para mantener el feed y las interacciones reutilizables. Los tipos estructurales son:

- `discusion`
- `aviso`
- `venta`
- `perdido`
- `encontrado`
- `evento`

La **categoría** es independiente del tipo. Por ejemplo, una publicación de tipo `discusion` puede tener categoría `chisme`, `deportes`, `vida universitaria`, `tecnología` o `académico`. “Chisme” no es un tipo estructural adicional; debe respetar las reglas de privacidad y convivencia.

Los campos específicos de cada tipo pueden almacenarse en `metadatos` (`jsonb`) con validación en la aplicación y, cuando sea apropiado, en la base de datos.

## Usuarios y perfiles

Supabase Auth gestiona la autenticación. `perfiles.id` referencia `auth.users.id`; no se debe crear una segunda tabla propia de contraseñas.

Los perfiles pueden representar estudiantes, docentes, administradores, egresados, visitantes o perfiles institucionales. La verificación se registra en `perfiles.es_verificada`; `nombre_oficial` permite identificar una dependencia cuando aplique.

**Verificación no equivale a autorización:** un perfil verificado no se convierte automáticamente en administrador. Las acciones privilegiadas deben comprobarse mediante políticas RLS y permisos del backend, no solamente ocultando botones en Flutter.

## Stack tecnológico propuesto

| Área | Tecnología | Uso |
|---|---|---|
| Aplicación | Flutter + Dart | Cliente móvil |
| Autenticación | Supabase Auth | Registro, inicio y sesión |
| Base de datos | PostgreSQL en Supabase | Datos relacionales y restricciones |
| Archivos | Supabase Storage | Imágenes de publicaciones y perfiles |
| Actualizaciones en vivo | Supabase Realtime, solo donde aporte valor | Actualizaciones de feed/comentarios |
| Backend de IA | Supabase Edge Function | Mantener la clave de IA fuera del cliente |
| Modelo de IA | Gemini a través de backend | Respuestas y resúmenes contextualizados |
| Estado | Riverpod como opción recomendada | Estado de vistas y repositorios |

No se debe incluir ninguna clave privada de Supabase o de Gemini en el código cliente, en `README.md`, ni en el repositorio. Usar variables/secrets y un archivo `.env` local excluido por Git cuando corresponda.

## Modelo de datos V1.0

El diagrama de Lucidchart es la referencia visual. Las tablas previstas son:

| Tabla | Propósito |
|---|---|
| `maestra` | Catálogos de tipos, categorías, estados, sedes, motivos y valores de referencia. |
| `perfiles` | Perfil del usuario enlazado con `auth.users`; incluye verificación y puntos. |
| `canales` | Comunidades generales o asociadas a una unidad académica/sede. |
| `publicaciones` | Discusiones, avisos, ventas, objetos perdidos/encontrados y eventos. |
| `comentarios` | Respuestas a publicaciones; incluye marcar solución. |
| `votos` | Likes/dislikes a una publicación o comentario. |
| `reportes` | Reportes de una publicación o comentario. |
| `eventos_puntos` | Registro auditable de puntos ganados. |
| `insignias` | Catálogo de distintivos. |
| `insignias_usuario` | Distintivos obtenidos por cada perfil. |

### Implementación inicial del esquema

La migración `supabase/migrations/20261011000000_initial_schema_v1_1.sql`
contiene el primer esquema SQL no destructivo: tablas, catálogos técnicos,
claves foráneas, restricciones, índices, RLS y lógica protegida para puntos,
votos y solución de comentarios. Debe aplicarse primero en un proyecto de
desarrollo de Supabase; no incluye ni requiere secretos.

`supabase/seed.sql` agrega únicamente sedes, unidades y canales ficticios de
desarrollo, después de aplicar la migración. No crea usuarios de Auth ni datos
personales reales.

La migración `supabase/migrations/20261011100000_fix_vote_points_idempotency.sql`
corrige la idempotencia de los puntos por voto para que un evento dependa del
votante y el contenido, no del id del voto. Las pruebas de integridad y RLS
están en `supabase/tests/integrity_and_rls_test.sql` y se ejecutan contra una
instancia de desarrollo.

Las credenciales se mantienen fuera del repositorio en archivos `.env` locales.
El alias inicial creado para una cuenta de Auth es temporal y el cliente deberá
reemplazarlo durante el onboarding. La explicación de permisos y decisiones
pendientes está en `docs/decisions.md`.

### Reglas importantes del esquema

- `maestra`: usar `UNIQUE (grupo, codigo)`, no unicidad individual de `grupo` ni de `codigo`.
- `perfiles.id`: UUID compatible con `auth.users.id`.
- `votos`: `publicacion_id` y `comentario_id` son anulables, pero **exactamente uno** debe tener valor. `valor` solo admite `1` (like) o `-1` (dislike).
- `votos`: índices únicos parciales para impedir más de un voto por usuario y publicación/comentario. El usuario puede cambiar el valor de su voto existente.
- `reportes`: `publicacion_id` y `comentario_id` son anulables, pero exactamente uno debe tener valor.
- `insignias_usuario`: `UNIQUE (usuario_id, insignia_id)`.
- Un usuario no debe votar su propio contenido.
- `puntaje` y `puntos` no deben poder manipularse directamente desde el cliente. Actualizarlos de forma consistente mediante lógica confiable de backend/SQL.
- Las políticas RLS son obligatorias para tablas expuestas a clientes.
- `maestra.grupo` determina el significado del catálogo. La aplicación debe validar que el valor elegido pertenece al grupo esperado; considerar restricciones adicionales en SQL si es necesario.
- No almacenar contraseñas en `perfiles`.

## Funcionamiento general

1. El usuario se registra o inicia sesión con Supabase Auth y completa alias, tipo de perfil y datos opcionales de programa/sede.
2. En Inicio consulta publicaciones recientes, avisos y tendencias.
3. En Canales explora comunidades generales o asociadas a facultades, programas y sedes.
4. Puede crear una publicación de uno de los seis tipos, agregar imágenes y seleccionar una categoría.
5. Otros usuarios pueden comentar y votar publicaciones o comentarios.
6. Las acciones válidas generan eventos de puntos sujetos a límites antiabuso.
7. El perfil muestra puntos, nivel, publicaciones y distintivos.
8. Los usuarios pueden reportar contenido. La IA puede ayudar a detectar posibles riesgos, pero la decisión de moderación debe seguir reglas definidas y permitir revisión humana.

## Inteligencia artificial

La IA debe ser una función central de la experiencia, no solamente una caja de chat decorativa.

### Funciones planificadas

- **IA del Campus:** preguntas en lenguaje natural sobre información disponible en la aplicación.
- **“¿Qué me perdí?”:** resumen de publicaciones recientes y destacadas de un canal o periodo.
- **Búsqueda asistida:** ayuda a localizar publicaciones relacionadas.
- **Asistente de publicación:** sugerencias de título, claridad, ortografía y categoría; el usuario revisa antes de publicar.
- **Apoyo a moderación (opcional):** marcar contenido que podría requerir revisión. No aplicar sanciones automáticamente en el MVP.

### Flujo técnico

1. Flutter envía la pregunta y el contexto mínimo necesario a una Supabase Edge Function autenticada.
2. La función valida sesión, límites de uso y parámetros.
3. Recupera contenido permitido de PostgreSQL (por ejemplo, publicaciones y comentarios recientes del canal elegido).
4. Envía al proveedor de IA solo el contexto necesario.
5. La respuesta debe diferenciar datos recuperados de inferencias, incluir referencias a publicaciones cuando sea posible y reconocer cuando no hay información suficiente.
6. Flutter muestra la respuesta y enlaces a las fuentes utilizadas.

La clave de Gemini se guarda como secreto del backend. No enviar datos privados, correos, tokens ni información de moderación innecesaria al modelo. Aplicar límites de longitud, uso y costo. La IA no debe inventar avisos oficiales ni presentar rumores como hechos confirmados.

## Puntos, niveles y distintivos

Los puntos deben premiar contribuciones útiles, no solo volumen.

| Acción | Puntos de referencia | Control |
|---|---:|---|
| Publicación válida | +2 | Máximo 3 al día |
| Comentario válido | +1 | Máximo 10 al día |
| Voto positivo recibido en publicación | +3 | Un evento por votante y contenido |
| Voto positivo recibido en comentario | +2 | Un evento por votante y contenido |
| Comentario marcado como solución | +15 | Solo el autor de la publicación puede marcarlo |
| Entregar objeto encontrado | +10 | Requiere validación de estado |
| Objeto marcado como devuelto | +20 | Evitar duplicados |

Niveles de referencia:
- **Novato:** 0–49 puntos
- **Activo:** 50–149 puntos
- **Referente:** 150–399 puntos
- **Leyenda:** 400 puntos o más

Distintivos iniciales sugeridos:
- **Primer paso:** primera publicación válida.
- **Buen samaritano:** ayudar a devolver un objeto.
- **Resuelve-dudas:** alcanzar cinco respuestas marcadas como solución.
- **Vendedor activo:** completar varias ventas legítimas.
- **Voz del campus:** alcanzar un umbral de comentarios válidos.
- **Constante:** participar en varios días distintos.
- **Gran colaborador:** recibir valoraciones positivas por aportes útiles.
- **Tendencia:** publicación con interacción destacada, con reglas antiabuso.

Los umbrales deben estar configurados de forma clara y no premiar spam. Los distintivos se asignan una sola vez por usuario salvo que el diseño futuro indique lo contrario.

## Seguridad, privacidad y convivencia

- Aplicar RLS a las tablas accesibles desde el cliente.
- Derivar la identidad del usuario de la sesión autenticada, no confiar en `autor_id` enviado por el cliente.
- Proteger operaciones de administración y verificación en backend.
- El anonimato de una publicación oculta la identidad públicamente, pero no debe eliminar la trazabilidad privada para moderación.
- No permitir doxxing, amenazas, acoso, publicación de datos personales ni acusaciones que presenten rumores como hechos.
- Las publicaciones tipo aviso institucional solo deben poder ser creadas por perfiles autorizados.
- La IA puede asistir a moderadores, no reemplazarlos automáticamente.
- Limitar intentos de voto, reportes y generación de puntos.

## Navegación y pantallas

Navegación inferior propuesta: **Inicio · Canales · IA · Perfil**, con un botón `+` para crear publicaciones.

Pantallas MVP:
1. Inicio de sesión y registro.
2. Inicio/feed.
3. Lista y detalle de canales.
4. Crear publicación.
5. Detalle de publicación y comentarios.
6. IA del Campus y “¿Qué me perdí?”.
7. Perfil, niveles y distintivos.
8. Reportar contenido.
9. Gestión mínima de avisos institucionales, si se implementa en el MVP.

Marketplace, eventos y objetos perdidos reutilizan la misma entidad y componentes, con formularios y metadatos específicos.

## Alcance sugerido para seis semanas

1. **Semana 1:** base Flutter, navegación, tema, Supabase y migración inicial.
2. **Semana 2:** autenticación y perfiles.
3. **Semana 3:** canales, feed y creación de publicaciones.
4. **Semana 4:** comentarios, votos, reportes y puntos.
5. **Semana 5:** IA contextual mediante Edge Function y referencias.
6. **Semana 6:** distintivos, pruebas, pulido y demo.

Si el tiempo se reduce, posponer ranking avanzado, notificaciones push y funciones opcionales antes que la seguridad, las interacciones principales o la IA central.

## Estructura sugerida

```text
lib/
  app/
  core/
    config/
    errors/
    theme/
    utils/
  features/
    auth/
    home/
    channels/
    posts/
    comments/
    votes/
    assistant/
    profile/
    reputation/
    reports/
  data/
    models/
    repositories/
    services/
supabase/
  migrations/
  seed.sql
  functions/
    campus-ai/
docs/
  schema.dbml
  decisions.md
  demo.md
```

Adaptar esta estructura a los archivos existentes antes de moverlos. Evitar reorganizaciones masivas sin necesidad.

## Comandos

Los comandos exactos dependen del entorno. Como mínimo, antes de entregar cambios:

```bash
flutter pub get
flutter analyze
flutter test
```

Si se modifican migraciones, revisar que sean coherentes con el esquema y probarlas en un proyecto de desarrollo, nunca contra producción sin autorización.

## Estado del proyecto

Este README describe el diseño y alcance previstos. No afirma que todas las funciones estén implementadas. Marcar como implementada una función solo después de comprobar el código y sus pruebas.

### Implementación actual

Implementado y comprobado con `flutter analyze` y `flutter test`:

- Esquema SQL V1.1 en `supabase/migrations/` (tablas, constraints, RLS, puntos).
- Autenticación con `supabase_flutter`: registro, inicio y cierre de sesión, y
  restauración de sesión.
- Perfiles y onboarding: alias, tipo de perfil y programa/sede opcionales,
  sujetos a los catálogos permitidos.
- Tema Flutter con los colores institucionales de `docs/design.md`.

Pendiente:

- Aplicar la migración de idempotencia de votos y ejecutar las pruebas SQL en
  el proyecto de desarrollo.
- Confirmar el mecanismo de confirmación de correo en Supabase Auth.
- Base Flutter completa (navegación Inicio/Canales/IA/Perfil, feed, canales,
  publicaciones, comentarios, votos, reportes), gamificación e IA.
- Asignación de `app_metadata.app_role` desde backend y tipografía Plus Jakarta
  Sans.

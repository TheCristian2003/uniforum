# Vybe — Plataforma Social Universitaria Inteligente

> Documento base para presentación y pitch público.
> Nombre de trabajo actual: **Vybe** (identidad final aún por confirmar).

---

## 1. Elevator pitch (30 segundos)

**Vybe es el espacio digital donde ocurre la vida universitaria.** En una sola
app móvil se combinan lo académico y lo social: avisos oficiales, conversaciones,
eventos, compra/venta, objetos perdidos y encontrados, una asistente de IA
contextual y un sistema de reputación que premia a quienes realmente aportan.

No es “otro foro”: es la comunidad del campus, con la confianza y la seguridad de
una plataforma moderna.

**Frase de cierre:** *“Todo lo que pasa en tu universidad, en una sola app.”*

---

## 2. El problema

- La información universitaria está **fragmentada**: grupos de WhatsApp, correos,
  carteleras, redes sociales y rumores sin fuente.
- Los **avisos oficiales** se pierden entre el ruido; los estudiantes no saben qué
  se perdieron.
- La vida social y la vida académica viven separadas, en herramientas distintas.
- Vender, comprar, reportar un objeto perdido o difundir un evento **no tiene un
  lugar común ni confiable**.
- La mayoría de los foros castigan con spam y no distinguen a quien ayuda de quien
  solo publica por volumen.

---

## 3. La solución

Una **plataforma social universitaria inteligente** con cinco pilares:

| Pilar | Qué incluye |
|---|---|
| **Comunidad** | Publicaciones, comentarios, votos (a favor/en contra) y canales. |
| **Vida universitaria** | Avisos, conversaciones, eventos, compra/venta y objetos perdidos/encontrados. |
| **IA contextual** | Asistente del campus, resúmenes “¿Qué me perdí?” y ayuda para redactar. |
| **Gamificación** | Puntos, niveles y distintivos que reconocen el aporte real. |
| **Confianza y moderación** | Perfiles verificados, reportes, privacidad y control institucional. |

### Un solo feed, seis tipos de publicación

La app reutiliza **una sola entidad de publicación** para mantener todo el feed
unificado e interactivo:

`discusión` · `aviso` · `venta` · `perdido` · `encontrado` · `evento`

La **categoría es independiente del tipo** (académico, vida universitaria, chisme,
deportes, eventos, marketplace, tecnología, general). Así, un chisme es una
*categoría* de discusión, no un módulo aparte: menos ruido, más comunidad.

---

## 4. Qué hace hoy (implementado y verificado)

Estado comprobado con `flutter analyze` (sin errores) y `flutter test`
(**55 pruebas en verde**):

- **Registro, inicio y cierre de sesión** con Supabase Auth y restauración de
  sesión.
- **Onboarding y perfiles**: alias, tipo de perfil, programa y sede; edición de
  perfil con avatar.
- **Navegación principal**: Inicio, Canales, IA y Perfil, con botón flotante para
  publicar.
- **Canales y feed**: canales por unidad académica/sede, detalle de canal y feed de
  publicaciones recientes, con estados de carga, vacío y error.
- **Crear publicación**: canal, tipo, categoría, título, cuerpo, anonimato e
  **imágenes adjuntas**. Campos específicos por tipo:
  - `venta` → precio (COP), lugar, disponibilidad.
  - `perdido` → fecha, lugar, recompensa.
  - `encontrado` → fecha, lugar, entregado.
  - `evento` → inicio, fin, lugar, enlace.
  - Los `aviso` institucionales solo se ofrecen a roles autorizados.
- **Detalle y comentarios**: comentar, **votar a favor/en contra** (sin poder votar
  el propio contenido) y **marcar comentarios como solución**.
- **Imágenes** en publicaciones, comentarios y perfil mediante Supabase Storage,
  con políticas de acceso por usuario.
- **Reportes y moderación**: cualquier usuario reporta contenido; los roles
  privilegiados pueden **ocultar** o **eliminar** contenido y **restringir
  temporal o permanentemente** al autor.
- **Gamificación real**: puntos por acción, **niveles** (Novato, Activo, Referente,
  Leyenda), estadísticas de participación y **distintivos otorgados
  automáticamente** para logros verificables.
- **Ajustes**: preferencias persistidas y **modo claro/oscuro/sistema** completo.

> La pestaña **IA** está hoy como *prototipo visual*; su conexión al modelo se
> realiza en la siguiente etapa (Edge Function de Supabase).

---

## 5. Qué la hace especial (diferenciadores)

1. **No es solo un foro.** Unifica comunidad, avisos, eventos, marketplace y
   objetos perdidos en un mismo feed.
2. **Una entidad, seis experiencias.** Menos complejidad, más coherencia: el mismo
   motor de publicaciones sirve para todos los casos.
3. **IA contextual del campus.** Pregunta en lenguaje natural y resume “¿Qué me
   perdí?”, con referencias a las publicaciones reales — no rumores inventados.
4. **Reputación que no se puede hacer trampa.** Los puntos se calculan en el
   servidor, con límites diarios e idempotencia: **votos propios y duplicados no
   premian**.
5. **Confianza por diseño.** Verificación institucional, anonimato *trazable* para
   moderación y perfiles oficiales identificados visualmente.
6. **Seguridad y privacidad de base.** La identidad sale de la sesión, no de datos
   que envía el cliente.
7. **Moderación con dientes.** Ocultar, eliminar y restringir, siempre con revisión
   humana.
8. **Experiencia joven y moderna.** Diseño propio, tema claro/oscuro, consistencia
   visual en cada pantalla.

---

## 6. Por qué es buena (calidad técnica)

- **Seguridad por diseño:** *Row Level Security* en cada tabla expuesta; el
  cliente nunca fija autoría, rol, puntajes ni identidad. Los privilegios se
  validan en el backend, no ocultando botones.
- **Integridad de datos:** restricciones SQL (una publicación o comentario por
  voto/reporte, un solo voto por usuario y contenido) e índices que evitan abusos.
- **Anti-abuso:** límites diarios de puntos y **idempotencia** para no premiar dos
  veces la misma acción.
- **Arquitectura limpia:** separación entre presentación, lógica y acceso a datos
  (Riverpod + repositorios), modelos tipados y componentes reutilizables.
- **Código confiable:** 55 pruebas automatizadas y análisis estático limpio.
- **Sin secretos en el cliente:** ninguna clave privada de IA o *service-role* vive
  en la app.

| Número | Dato |
|---|---|
| 10 | tablas del modelo V1.0 (+ restricciones de moderación) |
| 12 | migraciones SQL versionadas y aditivas |
| 6 | tipos de publicación sobre una sola entidad |
| 8 | categorías independientes del tipo |
| 4 | niveles de reputación y 8 distintivos en catálogo |
| 55 | pruebas automatizadas en verde |

---

## 7. Por qué deberías usarla

**Estudiantes**
- Entérate de todo lo que pasa en el campus, en un solo lugar.
- Resuelve dudas, ayuda y **gana reputación** que se ve en tu perfil.
- Compra, vende, encuentra lo que perdiste y no te pierdas los eventos.
- Modo anónimo cuando quieres opinar sin exponerte (con moderación responsable).

**Docentes y personal administrativo**
- Publica **avisos oficiales** con identidad institucional verificada.
- Responde dudas y gana visibilidad como referencia del campus.

**Instituciones (facultades, sedes, bienestar)**
- Canal oficial identificado, con control de quién puede publicar avisos.
- Moderación y trazabilidad para proteger a la comunidad.

**Emprendedores y comercio local**
- Un **marketplace** dentro de la comunidad universitaria, sin fricción.

**Egresados y comunidad**
- Mantente conectado con la vida de la universidad.

---

## 8. Estado actual y hoja de ruta

**Hoy**
- MVP funcional: comunidad, publicaciones e imágenes, comentarios, votos,
  reportes, moderación, gamificación, canales y perfiles.
- Base de datos con RLS, migraciones y pruebas de integridad/seguridad.

**Siguiente**
- **IA del Campus** conectada por Edge Function (respuestas con referencias).
- Validaciones de metadatos en SQL.
- Notificaciones, ranking semanal y pulido visual (tipografía).
- Definición del operador de roles y del nombre/identidad final.

---

## 9. Frases clave para la presentación

- *“Vybe no es un foro: es la vida universitaria en una app.”*
- *“Todo lo que pasa en tu universidad, en un solo lugar.”*
- *“La IA que sí te dice qué te perdiste — y de dónde lo sacó.”*
- *“Aquí se premia a quien ayuda, no a quien hace spam.”*
- *“Privacidad cuando quieres, responsabilidad cuando importa.”*
- *“Seguro desde el primer clic: la confianza se valida en el servidor.”*
- *“Seis formas de participar, una sola comunidad.”*
- *“Gana reputación siendo el que resuelve, no el que opina más.”*

---

## 10. Preguntas que te pueden hacer (y respuesta corta)

- **¿En qué se diferencia de un grupo de WhatsApp?** Estructura, búsqueda,
  reputación, moderación y canales oficiales; nada se pierde en el ruido.
- **¿Es seguro?** Identidad basada en sesión, RLS en todas las tablas,
  moderación con restricciones y sin claves privadas en la app.
- **¿Se puede abusar de los puntos?** No: límites diarios, idempotencia, sin votos
  propios ni duplicados.
- **¿La IA reemplaza a los moderadores?** No; asiste y prioriza, la decisión es
  humana.
- **¿Sirve para vender o encontrar cosas?** Sí, marketplace y objetos
  perdidos/encontrados usan el mismo feed con campos propios.
- **¿Qué tan maduro está?** MVP funcional y probado (55 pruebas); la IA es el
  siguiente gran paso.

---

## 11. Resumen técnico

| Área | Tecnología |
|---|---|
| Cliente | Flutter + Dart (Riverpod) |
| Autenticación | Supabase Auth |
| Base de datos | PostgreSQL en Supabase con RLS |
| Archivos | Supabase Storage |
| IA (próxima) | Supabase Edge Function + modelo Gemini (clave en el backend) |
| Diseño | Sistema visual propio, tema claro/oscuro, identidad Vybe |

Documentación relacionada: `README.md`, `docs/decisions.md`,
`docs/supabase_setup.md` y `docs/design/DESIGN.md`.

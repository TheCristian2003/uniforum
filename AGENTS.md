# AGENTS.md — Guía para Codex y OpenCode

## 1. Misión del agente

Construir y mantener una aplicación móvil Flutter/Dart que funcione como **plataforma social universitaria inteligente**. No reducir el producto a un foro académico: debe contemplar comunidad, vida universitaria, avisos, conversaciones sociales, compra/venta, objetos perdidos/encontrados, eventos, IA y gamificación.

El nombre comercial sigue pendiente. No renombrar todo el proyecto ni inventar una marca definitiva sin pedir confirmación.

## 2. Forma de trabajar

1. Antes de editar, inspecciona el repositorio, el `README.md`, `pubspec.yaml`, las migraciones existentes y el código relacionado.
2. Resume brevemente qué entendiste, qué archivos planeas cambiar y cualquier incertidumbre relevante.
3. Divide tareas grandes en cambios pequeños y comprobables.
4. Respeta la arquitectura y convenciones existentes si funcionan. No reestructures todo el proyecto por preferencia personal.
5. No sobrescribas trabajo del usuario, diseños ni datos existentes sin revisar su contenido.
6. Implementa la tarea solicitada; no agregues funcionalidades no pedidas.
7. Tras editar, ejecuta las comprobaciones disponibles (`flutter analyze`, `flutter test` y pruebas específicas). Informa con honestidad qué ejecutaste y qué no.
8. No afirmes que algo funciona si no lo has comprobado.
9. Si falta una decisión importante, pregunta antes de asumir. Para detalles menores, elige la solución más simple y documenta la decisión.
10. Mantén `README.md`, documentación, migraciones y código sincronizados.

## 3. Stack y convenciones

- Cliente: Flutter + Dart.
- Backend de datos y autenticación: Supabase.
- Base de datos: PostgreSQL.
- Archivos: Supabase Storage.
- IA: Supabase Edge Function que llama al proveedor de modelo (previsto: Gemini).
- Gestión de estado: usar la solución que ya esté instalada; si el proyecto está vacío, Riverpod es la opción preferida.
- Nombres de clases, archivos y variables Dart en inglés, salvo que el proyecto existente use otra convención consistente.
- Los nombres de tablas y columnas de base de datos permanecen en español para respetar el ER actual.
- UI en español.
- Código null-safe, componentes reutilizables y separación entre presentación, lógica y acceso a datos.
- Evitar dependencias innecesarias y APIs obsoletas.

## 4. Producto y alcance

### Pilares
1. Comunidad.
2. Vida universitaria.
3. IA contextual.
4. Puntos, niveles y distintivos.
5. Seguridad, privacidad y moderación.

### Tipos de publicación obligatorios
- `discusion`
- `aviso`
- `venta`
- `perdido`
- `encontrado`
- `evento`

La categoría es independiente del tipo. Ejemplos de categorías: académico, vida universitaria, chisme, deportes, eventos, marketplace, tecnología y general. No crear un tipo estructural `chisme`: debe ser una categoría de discusión.

### Pantallas principales
- Login/registro.
- Inicio/feed.
- Canales y detalle de canal.
- Crear publicación.
- Detalle de publicación y comentarios.
- IA del Campus / “¿Qué me perdí?”.
- Perfil, nivel y distintivos.
- Reportes/moderación mínima.
- Las pantallas de venta, objetos perdidos y eventos deben reutilizar publicaciones cuando sea posible.

### Fuera del MVP salvo petición expresa
- Chat privado entre usuarios.
- Notificaciones push.
- Banco completo de PDF/apuntes.
- Sistema de pagos.
- Recomendaciones complejas basadas en ML.
- Panel administrativo grande.
- Integraciones externas adicionales.
- No construir módulos separados si basta una variación de formulario y metadatos.

## 5. Modelo de datos V1.0

El modelo visual de Lucidchart es la referencia acordada. Tablas:
- `maestra`
- `perfiles`
- `canales`
- `publicaciones`
- `comentarios`
- `votos`
- `reportes`
- `eventos_puntos`
- `insignias`
- `insignias_usuario`

Supabase ya administra `auth.users`. `perfiles.id` debe ser UUID y FK a `auth.users.id`. No almacenar contraseñas ni duplicar la autenticación en una tabla propia.

### Reglas de integridad obligatorias

**`maestra`**
- `UNIQUE (grupo, codigo)`.
- No hacer `grupo` único por sí solo ni `codigo` único por sí solo.
- `padre_id` puede modelar jerarquías, por ejemplo facultad → programa.
- Cada uso debe validar que el registro pertenezca al grupo esperado.

**`perfiles`**
- Contiene `es_verificada` y opcionalmente `nombre_oficial` para perfiles institucionales.
- Verificación no concede automáticamente rol de administrador.
- Los permisos reales deben validarse en backend/RLS.

**`votos`**
- Un único registro puede referirse a una publicación o a un comentario.
- `publicacion_id` y `comentario_id` admiten NULL.
- Añadir `CHECK` para exigir exactamente uno:
  `(publicacion_id IS NOT NULL AND comentario_id IS NULL) OR (publicacion_id IS NULL AND comentario_id IS NOT NULL)`.
- `valor` solo puede ser `1` o `-1`.
- Crear índices únicos parciales para `(usuario_id, publicacion_id)` cuando `publicacion_id IS NOT NULL` y `(usuario_id, comentario_id)` cuando `comentario_id IS NOT NULL`.
- Permitir cambiar un voto actualizando el mismo registro.
- Impedir que una persona vote su propio contenido.
- No restar puntos de reputación al autor por recibir dislikes.

**`reportes`**
- Un reporte apunta a exactamente una publicación o un comentario mediante `CHECK` equivalente al de votos.
- `reportante_id` es obligatorio.
- Prevenir reportes duplicados abusivos cuando sea pertinente sin bloquear reportes legítimos posteriores.

**`insignias_usuario`**
- `UNIQUE (usuario_id, insignia_id)`.

**Puntos y puntajes**
- No confiar en valores de `puntos` o `puntaje` enviados por Flutter.
- Calcular/actualizar desde SQL confiable o backend con protección contra duplicados.
- Mantener `eventos_puntos` como registro auditable y usar una `clave_unica`/idempotencia para impedir premiar repetidamente la misma acción.
- Aplicar topes diarios de puntos.

No generar migraciones destructivas ni ejecutar cambios en producción sin autorización expresa. Preferir migraciones nuevas y reversibles cuando sea posible.

## 6. Seguridad y Supabase

- Activar y probar Row Level Security (RLS) en tablas expuestas al cliente.
- La identidad del usuario debe derivarse de la sesión (`auth.uid()`), nunca confiar ciegamente en `autor_id`, `usuario_id` o `reportante_id` enviados desde el cliente.
- Los usuarios pueden editar/eliminar su propio contenido según reglas definidas; administradores/moderadores tienen permisos separados.
- Restringir creación de avisos institucionales a perfiles autorizados.
- No tratar `es_verificada = true` como prueba suficiente de permiso para todas las operaciones.
- Validar tamaño, tipo y cantidad de imágenes.
- Nunca exponer service-role key, claves de proveedor de IA ni secretos en Flutter, commits, logs o documentos.
- No desactivar RLS como atajo.
- No usar datos reales sensibles en seed/demo. Usar contenido ficticio.

## 7. Reglas para la IA

La IA es parte central del producto. La primera versión debe priorizar una función útil y demostrable, no múltiples sistemas independientes.

### Casos de uso
1. **IA del Campus:** responder usando publicaciones y comentarios recuperados de la base.
2. **“¿Qué me perdí?”:** resumir publicaciones de un canal/periodo.
3. **Búsqueda asistida:** ayudar a encontrar contenido relacionado.
4. **Asistente de publicación:** sugerir título, claridad, ortografía y categoría; el usuario decide si aplica cambios.
5. **Moderación asistida (opcional):** señalar contenido para revisión humana, sin sancionar automáticamente.

### Arquitectura
- Flutter llama a una Supabase Edge Function autenticada.
- La función valida usuario, parámetros, límites de uso y contexto permitido.
- Recupera solo los datos necesarios para la pregunta.
- La función llama al proveedor de IA usando una clave almacenada como secreto.
- Devuelve respuesta, fuentes/IDs de publicaciones y, si aplica, una indicación de falta de información.
- La clave del proveedor nunca se envía al cliente.
- No presentar rumores o contenido de usuarios como información institucional verificada.
- No inventar citas ni URLs. Si no hay datos suficientes, la IA debe decirlo.
- Limitar contexto, longitud de respuesta, frecuencia y costo.
- Evitar enviar correos, tokens, información privada o datos de moderación innecesarios al modelo.
- No agregar embeddings/vector database salvo que se solicite y el MVP lo justifique.

## 8. Gamificación

Puntos de referencia:
- Publicación válida: +2, máximo 3/día.
- Comentario válido: +1, máximo 10/día.
- Voto positivo recibido en publicación: +3, sin duplicar evento por votante/contenido.
- Voto positivo recibido en comentario: +2, sin duplicar evento por votante/contenido.
- Comentario marcado solución: +15, solo autor de la publicación.
- Entrega de objeto encontrado: +10 si se valida.
- Objeto devuelto: +20, evitar duplicidad.

Niveles de referencia:
- Novato: 0–49.
- Activo: 50–149.
- Referente: 150–399.
- Leyenda: 400+.

Distintivos iniciales:
- Primer paso.
- Buen samaritano.
- Resuelve-dudas.
- Vendedor activo.
- Voz del campus.
- Constante.
- Gran colaborador.
- Tendencia.

Implementar solo los distintivos que puedan verificarse de forma clara dentro del alcance. No premiar spam, votos propios ni duplicados. Los umbrales deben ser configurables o documentados.

## 9. Moderación y publicaciones sociales

- Permitir conversación informal, incluida la categoría `chisme`, pero establecer límites claros.
- No diseñar funciones para doxxing, acoso, amenazas, difamación ni difusión de datos personales.
- El anonimato, si se habilita, solo oculta al autor públicamente; la aplicación conserva autoría privada para seguridad/moderación.
- Los reportes se revisan con reglas explícitas. La IA puede priorizar, no tomar decisiones irreversibles sin revisión.
- Las cuentas institucionales deben identificarse visualmente y estar sujetas a permisos de publicación.

## 10. Diseño y experiencia de usuario

- Diseño juvenil, moderno, legible y consistente; no parecer un panel académico anticuado.
- Navegación inferior propuesta: Inicio, Canales, IA, Perfil; botón flotante para publicar.
- Mantener estados loading, empty, error y success.
- Formularios con validación clara.
- Accesibilidad básica: contraste, tamaños legibles, labels, targets táctiles adecuados.
- Diseñar para pantallas móviles y soportar tema claro/oscuro si no compromete el MVP.
- No inventar el nombre ni la identidad final del producto.

## 11. Estándar de implementación

Antes de agregar un paquete:
1. Revisar si el proyecto ya resuelve esa necesidad.
2. Preferir paquetes mantenidos y compatibles con la versión actual.
3. Explicar por qué es necesario.

Para cada función:
1. Modelo/DTO si aplica.
2. Repositorio o servicio de datos.
3. Estado/controlador.
4. UI con estados de carga/error/vacío.
5. Validación y permisos.
6. Pruebas mínimas.
7. Documentación breve cuando cambie el comportamiento.

No poner consultas SQL complejas, secretos ni lógica de autorización únicamente en widgets.

## 12. Verificación de cambios

Ejecutar cuando estén disponibles:
```bash
flutter pub get
flutter analyze
flutter test
```

Para Edge Functions, usar el método de validación disponible en el repo y comprobar manejo de errores. Para SQL:
- Revisar sintaxis y dependencias.
- Probar constraints con casos válidos e inválidos.
- Probar políticas RLS con distintos roles.
- Verificar que un usuario no pueda votar su propio contenido ni duplicar votos/puntos.

Si no puedes ejecutar una prueba por falta de configuración/credenciales, indícalo; no inventes un resultado.

## 13. Git y entrega

- No hacer `git reset --hard`, `git clean -fd`, borrados masivos ni reescritura de historial.
- No descartar cambios del usuario.
- No hacer commit ni push salvo petición explícita.
- No cambiar archivos ajenos a la tarea.
- Al terminar, resumir:
  - qué cambió;
  - archivos afectados;
  - pruebas ejecutadas y resultados;
  - pasos manuales pendientes;
  - decisiones o limitaciones.

## 14. Orden sugerido de desarrollo

1. Inspeccionar repositorio y confirmar estructura real.
2. Configuración Flutter, tema y navegación.
3. Supabase Auth y perfiles.
4. Migración SQL V1.0 con constraints, índices y RLS.
5. Canales y feed.
6. Publicaciones y metadatos por tipo.
7. Comentarios y votos unificados.
8. Reportes.
9. Puntos, niveles y distintivos.
10. Edge Function de IA y referencias.
11. Pruebas, datos demo, accesibilidad y documentación.

No implementar todo de una sola vez. Trabajar por entregables pequeños y funcionales.

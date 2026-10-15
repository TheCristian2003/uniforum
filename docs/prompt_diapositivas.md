# Prompt para generar diapositivas de Vybe

Copia y pega el bloque de abajo en tu IA generadora de presentaciones
(Gamma, Canva, PowerPoint Copilot, ChatGPT/Claude con export a PPTX, etc.).

---

## Prompt

Actúa como un diseñador de presentaciones y copywriter de producto. Genera una
presentación **en español**, de **13 diapositivas**, formato **16:9**, lista para
exportar a **PPTX** (o formato equivalente). El objetivo es **presentar una app
móvil y convencer al público de usarla**.

### Contexto del producto

- **Proyecto:** Vybe — Plataforma Social Universitaria Inteligente (app móvil).
  "Vybe" es el nombre de trabajo; **no lo presentes como nombre final cerrado**.
- **Qué es:** el espacio digital donde ocurre la vida universitaria. Combina lo
  académico y lo social en una sola app: avisos, conversaciones, eventos,
  compra/venta, objetos perdidos/encontrados, asistente de IA contextual y
  reputación.
- **Stack:** Flutter + Dart (cliente), Supabase (auth, PostgreSQL con Row Level
  Security, Storage), IA mediante Edge Function (próxima etapa).
- **Público de la presentación:** estudiantes, docentes, personal administrativo,
  instituciones y emprendedores/comercio local.

### Tono

Joven, moderno, claro y seguro. Cercano pero profesional. Nada de tecnicismos
innecesarios. Frases cortas y memorables.

### Contenido por diapositiva

1. **Portada.** Título: "Vybe" + subtítulo "La vida universitaria en una sola
   app". Una imagen mental de campus/comunidad. Frase: "Todo lo que pasa en tu
   universidad, en un solo lugar."
2. **El problema.** Cinco viñetas: información fragmentada (WhatsApp, correos,
   carteleras, rumores), avisos oficiales que se pierden, lo social y lo académico
   separados, no hay lugar común para vender/perder cosas/eventos, y foros que no
   premian a quien ayuda.
3. **La solución.** Un título fuerte y los **5 pilares** en tarjetas: Comunidad,
   Vida universitaria, IA contextual, Gamificación, Confianza y moderación.
4. **Un feed, seis experiencias.** "6 tipos de publicación sobre una sola entidad":
   discusión, aviso, venta, perdido, encontrado, evento. Aclara que la **categoría
   es independiente del tipo** (académico, vida universitaria, chisme, deportes,
   eventos, marketplace, tecnología, general).
5. **Qué hace hoy.** Funcionalidades reales: registro/login/onboarding; canales por
   facultad y sede + feed; crear publicación con imágenes y campos por tipo;
   comentarios, votos a favor/en contra y marcar solución; reportes y moderación
   (ocultar, eliminar, restringir); gamificación (puntos, niveles, distintivos);
   ajustes y modo claro/oscuro.
6. **Qué la hace especial.** Diferenciadores en íconos: no es solo un foro; una
   entidad y seis experiencias; IA que dice de dónde saca la información;
   reputación que no se puede hacer trampa (sin votos propios ni duplicados);
   verificación institucional y anonimato trazable; seguridad de base.
7. **Seguridad y confianza.** Row Level Security en cada tabla, identidad derivada
   de la sesión (nunca de datos del cliente), límites anti-abuso, moderación con
   revisión humana y sin claves privadas en la app.
8. **Números.** Tabla de métricas: 10 tablas, 12 migraciones SQL, 6 tipos de
   publicación, 8 categorías, 4 niveles, 8 distintivos, 55 pruebas automatizadas en
   verde.
9. **Para estudiantes.** Entérate de todo, resuelve dudas y gana reputación,
   compra/vende, encuentra lo que perdiste, no te pierdas los eventos.
10. **Para docentes e instituciones.** Publica avisos oficiales con identidad
    verificada; canal oficial con control de publicación; moderación y
    trazabilidad. (Puedes sumar comercio local/emprendedores con el marketplace.)
11. **¿Cómo se ve?** Describe 3 pantallas clave (feed/inicio, detalle con
    comentarios y votos, perfil con nivel y distintivos). Sugiere marcadores de
    posición de mockups de celular.
12. **Hoja de ruta.** Próximo gran paso: **IA del Campus** conectada por Edge
    Function (resúmenes "¿Qué me perdí?" con referencias). Luego: notificaciones,
    ranking semanal, pulido visual.
13. **Cierre.** Frase de impacto y llamado a la acción: "Vybe no es un foro: es la
    vida universitaria en una app. Gana reputación siendo el que resuelve, no el
    que opina más."

### Diseño visual

- **Estilo:** juvenil, moderno, limpio, con buen contraste y mucho aire.
- **Paleta de marca:** amarillo desierto `#C99A2E` (principal, tema claro), azul mar
  `#0F4C81`, rojo institucional `#C81D25`, agua marina `#0E8F9E`, neutros claros
  `#FBF8F5`/`#1E1E1E`. Ofrece **variante de tema oscuro** con acento blanco/gris
  (`#F2F2F2`) y fondos neutros (`#141414`).
- **Tipografía:** Plus Jakarta Sans (o una sans moderna equivalente), títulos en
  negrita.
- **Bordes:** tarjetas e imágenes con radios de 16 px; pills para etiquetas.
- **Máximo 5–6 líneas de texto por diapositiva.** Prefiere íconos, métricas
  grandes y bloques cortos sobre párrafos.
- Usa íconos consistentes (estilo Material Symbols) y deja marcadores de posición
  para capturas de la app.

### Restricciones (importante)

- **No inventes datos, métricas, usuarios, premios ni alianzas.** Usa solo los
  números y funciones del contenido anterior.
- **No afirmes que la IA ya funciona:** la pestaña de IA es hoy un **prototipo
  visual**; se presenta como próximo paso.
- **No presentes "Vybe" como nombre definitivo**; descríbelo como nombre de
  trabajo.
- No menciones ni expongas claves, secretos ni información privada.
- Mantén todo en español neutro.

### Entregable

- 13 diapositivas **16:9** en **PPTX** (o Slides/Canva), con notas del presentador
  de 1–3 frases por diapositiva.
- Incluye la paleta y la tipografía aplicadas de forma consistente.
- Al final, agrega una diapositiva extra opcional de **preguntas frecuentes** con
  respuestas de una línea.

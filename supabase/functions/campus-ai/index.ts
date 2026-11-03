// Edge Function: IA del Campus.
//
// Recibe una pregunta (o una petición de resumen), recupera el contexto visible
// para el usuario mediante `buscar_contexto_ia`, aplica el cupo diario con
// `consumir_cupo_ia` y llama a Gemini con una clave que solo existe como
// secreto de la función. Nunca recibe ni devuelve la service-role key.
//
// Secretos necesarios (Supabase > Edge Functions > Secrets):
//   GEMINI_API_KEY    obligatorio
//   MODELO_IA         opcional, por defecto `gemini-3.1-flash-lite`
//   IA_CUPO_HABILITADO opcional, `false` desactiva el cupo diario (pruebas)
//
// El modelo ligero es el predeterminado porque `gemini-3.8-flash` agotaba el
// tiempo de espera. Si no responde a tiempo, no existe para la clave o el
// proveedor está saturado (429/5xx), se reintenta con `gemini-3-flash-preview`.
//
// El cupo diario (20 por defecto) se configura en la tabla `ia_config` desde
// SQL, nunca desde el cliente.
//
// El cliente puede enviar los últimos turnos de la conversación (`historial`,
// máximo 6 mensajes de 800 caracteres) para responder preguntas de seguimiento.
//
// Despliegue: ver docs/supabase_setup.md.

import { createClient } from "jsr:@supabase/supabase-js@2";

const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const MAX_PREGUNTA = 500;
const MAX_CONTEXTO = 7000;
const MAX_PUBLICACIONES = 12;
const MAX_HISTORIAL = 6;
const MAX_TEXTO_HISTORIAL = 800;
const MODELO_POR_DEFECTO = "gemini-3.1-flash-lite";
const MODELO_RESPALDO = "gemini-3-flash-preview";

type Modo = "pregunta" | "resumen";

interface CuerpoSolicitud {
  pregunta?: string;
  canalId?: string | null;
  dias?: number;
  modo?: Modo;
  historial?: unknown;
}

interface ContenidoGemini {
  role: "user" | "model";
  parts: { text: string }[];
}

interface TurnoHistorial {
  rol: "user" | "model";
  texto: string;
}

interface ComentarioContexto {
  cuerpo: string;
  es_solucion: boolean;
}

interface PublicacionContexto {
  id: string;
  titulo: string | null;
  cuerpo: string;
  puntaje: number;
  creado_en: string;
  anonimo: boolean;
  canal: string | null;
  tipo: string | null;
  categoria: string | null;
  metadatos: Record<string, unknown> | null;
  comentarios: ComentarioContexto[] | null;
}

interface ResumenObjetos {
  dias: number;
  encontrados: number;
  encontrados_entregados: number;
  perdidos: number;
  entregados_total: number;
}

interface Fuente {
  id: string;
  titulo: string;
  canal: string | null;
  tipo: string | null;
  creadoEn: string;
}

class ErrorGemini extends Error {
  constructor(readonly estado: number, readonly detalle: string) {
    super("gemini");
  }
}

const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const SISTEMA_PREGUNTA = [
  "Eres el asistente de IA de una plataforma social universitaria.",
  "Respondes en español, de forma clara, breve y útil (máximo 220 palabras).",
  "Si la pregunta trata sobre el campus o sus publicaciones, usa el CONTEXTO y cita [P1], [P2].",
  "Si la pregunta es general (definiciones, explicaciones, cómo hacer algo), responde con conocimiento general y aclara en una frase que no proviene de publicaciones del campus.",
  "Si usas publicaciones fuera del periodo indicado, dilo al inicio de la respuesta.",
  "Si el contexto incluye 'Datos verificados de objetos', úsalos para responder conteos; esas cifras son la fuente de verdad y no debes decir que no hay registro.",
  "El campo Puntaje es el número neto de votos de cada publicación; úsalo para ordenar por popularidad.",
  "Para ventas usa solo publicaciones con Tipo: Venta y para objetos encontrados solo Tipo: Encontrado. La categoría Marketplace no equivale al tipo de publicación.",
  "Para eventos próximos compara Detalles.inicio (o Detalles.fecha) con la Fecha de hoy: excluye los eventos pasados y, si no hay futuros, dilo claramente.",
  "Cita [P#] solo las publicaciones que realmente uses; si respondes con conocimiento general, no cites fuentes.",
  "No inventes avisos, fechas, nombres, enlaces ni información institucional.",
  "No reveles datos personales ni información de moderación.",
  "Distingue entre opiniones o rumores de usuarios e información institucional verificada.",
].join(" ");

const SISTEMA_RESUMEN = [
  "Eres el asistente de IA de una plataforma social universitaria.",
  "Resumes en español lo más importante del periodo usando solo el CONTEXTO.",
  "Máximo 200 palabras, en viñetas cortas agrupadas por tema.",
  "Cita las publicaciones con su número entre corchetes, por ejemplo [P1].",
  "No inventes hechos ni presentes rumores como información confirmada.",
  "Si no hay suficiente información, dilo en una sola frase.",
].join(" ");

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, "Content-Type": "application/json; charset=utf-8" },
  });
}

function error(mensaje: string, status: number): Response {
  return json({ error: mensaje }, status);
}

function recortarContexto(
  publicaciones: PublicacionContexto[],
): PublicacionContexto[] {
  const elegidas: PublicacionContexto[] = [];
  let caracteres = 0;
  for (const publicacion of publicaciones) {
    const tamano =
      (publicacion.titulo?.length ?? 0) +
      publicacion.cuerpo.length +
      (publicacion.comentarios ?? []).reduce(
        (total, comentario) => total + comentario.cuerpo.length,
        0,
      );
    if (elegidas.length > 0 && caracteres + tamano > MAX_CONTEXTO) break;
    elegidas.push(publicacion);
    caracteres += tamano;
  }
  return elegidas;
}

function textoContexto(publicaciones: PublicacionContexto[]): string {
  return publicaciones
    .map((publicacion, indice) => {
      const lineas = [
        `[P${indice + 1}] Canal: ${publicacion.canal ?? "General"} | ` +
        `Tipo: ${publicacion.tipo ?? "publicación"} | ` +
        `Categoría: ${publicacion.categoria ?? "general"} | ` +
        `Fecha: ${(publicacion.creado_en ?? "").slice(0, 10)} | ` +
        `Puntaje (votos): ${publicacion.puntaje}`,
      ];
      if (publicacion.titulo) lineas.push(`Título: ${publicacion.titulo}`);
      lineas.push(`Texto: ${publicacion.cuerpo}`);
      const metadatos = publicacion.metadatos ?? {};
      const detalles: string[] = [];
      for (const campo of ["fecha", "inicio", "fin", "lugar", "precio", "moneda"] as const) {
        const valor = metadatos[campo];
        if (typeof valor === "string" || typeof valor === "number") {
          detalles.push(`${campo}: ${valor}`);
        }
      }
      for (const campo of ["disponible", "entregado"] as const) {
        const valor = metadatos[campo];
        if (typeof valor === "boolean") {
          detalles.push(`${campo}: ${valor ? "sí" : "no"}`);
        }
      }
      if (detalles.length > 0) {
        lineas.push(`Detalles: ${detalles.join(" | ")}`);
      }
      const comentarios = (publicacion.comentarios ?? []).slice(0, 5);
      if (comentarios.length > 0) {
        lineas.push("Comentarios:");
        for (const comentario of comentarios) {
          const marca = comentario.es_solucion ? "(solución) " : "";
          lineas.push(`- ${marca}${comentario.cuerpo}`);
        }
      }
      return lineas.join("\n");
    })
    .join("\n\n");
}

function normalizarHistorial(entrada: unknown): TurnoHistorial[] {
  if (!Array.isArray(entrada)) return [];
  const turnos: TurnoHistorial[] = [];
  for (const item of entrada.slice(-MAX_HISTORIAL)) {
    if (!item || typeof item !== "object") continue;
    const registro = item as { rol?: unknown; texto?: unknown };
    const rol = registro.rol === "ia" || registro.rol === "model"
      ? "model"
      : "user";
    const texto = typeof registro.texto === "string"
      ? registro.texto.trim()
      : "";
    if (!texto) continue;
    turnos.push({ rol, texto: texto.slice(0, MAX_TEXTO_HISTORIAL) });
  }
  return turnos;
}

function contarObjetosDesdeContexto(
  publicaciones: PublicacionContexto[],
  dias: number,
): ResumenObjetos {
  const encontrados = publicaciones.filter((publicacion) =>
    /encontrado/i.test(publicacion.tipo ?? "")
  );
  const perdidos = publicaciones.filter((publicacion) =>
    /perdido/i.test(publicacion.tipo ?? "")
  );
  const entregados = encontrados.filter(
    (publicacion) => publicacion.metadatos?.["entregado"] === true,
  );
  return {
    dias,
    encontrados: encontrados.length,
    encontrados_entregados: entregados.length,
    perdidos: perdidos.length,
    entregados_total: entregados.length,
  };
}

function contenidoConHistorial(
  historial: TurnoHistorial[],
  introduccion: string,
): ContenidoGemini[] {
  const turnos = [...historial];
  while (turnos.length > 0 && turnos[turnos.length - 1].rol !== "model") {
    turnos.pop();
  }
  while (turnos.length > 0 && turnos[0].rol !== "user") {
    turnos.shift();
  }
  const fusionados: TurnoHistorial[] = [];
  for (const turno of turnos) {
    const previo = fusionados[fusionados.length - 1];
    if (previo && previo.rol === turno.rol) {
      previo.texto = `${previo.texto}\n\n${turno.texto}`;
    } else {
      fusionados.push({ ...turno });
    }
  }
  const mensajeActual: ContenidoGemini = {
    role: "user",
    parts: [{ text: introduccion }],
  };
  return [
    ...fusionados.map((turno) => ({
      role: turno.rol,
      parts: [{ text: turno.texto }],
    })),
    mensajeActual,
  ];
}

// Gemini 3.x usa `thinkingLevel` (low/medium/high) y no permite apagar del todo
// el razonamiento; Gemini 2.5 usa `thinkingBudget`. `low` reduce la latencia.
// Si el modelo rechaza el campo, se reintenta sin él y se recuerda en la
// instancia para no repetir el error.
let pensamientoNoSoportado = false;

function configuracionPensamiento(
  modelo: string,
): Record<string, unknown> | null {
  if (/^gemini-(3|4)/i.test(modelo)) return { thinkingLevel: "low" };
  if (/^gemini-2\.5/i.test(modelo)) return { thinkingBudget: 0 };
  return null;
}

async function llamarGemini(
  apiKey: string,
  modelo: string,
  sistema: string,
  contents: ContenidoGemini[],
  timeoutMs: number,
): Promise<string> {
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(modelo)}:generateContent`;
  const controlador = new AbortController();
  const temporizador = setTimeout(() => controlador.abort(), timeoutMs);
  const inicio = Date.now();

  const generationConfig: Record<string, unknown> = {
    temperature: 0.2,
    topP: 0.9,
    maxOutputTokens: 700,
  };
  const pensamiento = configuracionPensamiento(modelo);
  if (pensamiento && !pensamientoNoSoportado) {
    generationConfig.thinkingConfig = pensamiento;
  }

  try {
    const respuesta = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      signal: controlador.signal,
      body: JSON.stringify({
        system_instruction: { parts: [{ text: sistema }] },
        contents,
        generationConfig,
        safetySettings: [
          { category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_ONLY_HIGH" },
          { category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_ONLY_HIGH" },
          { category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_ONLY_HIGH" },
          { category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_ONLY_HIGH" },
        ],
      }),
    });

    if (!respuesta.ok) {
      const detalle = await respuesta.text();
      const transcurrido = Date.now() - inicio;
      console.error("Gemini respondió", respuesta.status, `${transcurrido}ms`, detalle.slice(0, 300));

      if (
        respuesta.status === 400 &&
        !pensamientoNoSoportado &&
        /thinking/i.test(detalle)
      ) {
        pensamientoNoSoportado = true;
        console.error("El modelo no acepta thinkingConfig; se reintenta sin él");
        return await llamarGemini(apiKey, modelo, sistema, contents, timeoutMs);
      }

      throw new ErrorGemini(respuesta.status, detalle.slice(0, 300));
    }

    const datos = await respuesta.json();
    console.log("Gemini ok", `${Date.now() - inicio}ms`, modelo);

    if (datos?.promptFeedback?.blockReason) {
      throw new ErrorGemini(0, `blockReason: ${datos.promptFeedback.blockReason}`);
    }

    const candidato = datos?.candidates?.[0];
    const partes = candidato?.content?.parts ?? [];
    const texto = partes
      .map((parte: { text?: string }) => parte.text ?? "")
      .join("")
      .trim();

    if (!texto && candidato?.finishReason) {
      throw new ErrorGemini(0, `finishReason: ${candidato.finishReason}`);
    }

    return texto;
  } finally {
    clearTimeout(temporizador);
  }
}

function esTimeout(fallo: unknown): boolean {
  return (fallo as { name?: string } | null)?.name === "AbortError";
}

function fuentesDeRespuesta(
  respuesta: string,
  publicaciones: PublicacionContexto[],
): Fuente[] {
  const citadas = new Set<number>();
  for (const coincidencia of respuesta.matchAll(/\[P(\d+)\]/gi)) {
    const numero = Number(coincidencia[1]);
    if (Number.isInteger(numero)) citadas.add(numero);
  }
  if (citadas.size === 0) return [];

  return publicaciones
    .filter((_, indice) => citadas.has(indice + 1))
    .slice(0, 4)
    .map((publicacion) => ({
      id: publicacion.id,
      titulo: publicacion.titulo?.trim() || publicacion.cuerpo.slice(0, 80),
      canal: publicacion.canal,
      tipo: publicacion.tipo,
      creadoEn: publicacion.creado_en,
    }));
}

function respuestaDeFallo(fallo: unknown): Response {
  const estado = fallo instanceof ErrorGemini ? fallo.estado : -1;

  if (esTimeout(fallo)) {
    return error("La IA tardó demasiado en responder. Inténtalo de nuevo.", 504);
  }
  if (estado === 0) {
    return error(
      "La IA no pudo responder por sus filtros de contenido. Intenta reformular la pregunta.",
      400,
    );
  }
  if (estado === 400 || estado === 401 || estado === 403) {
    return error(
      "La IA está mal configurada en el servidor (clave o permisos). Avisa al administrador.",
      503,
    );
  }
  if (estado === 404) {
    return error("El modelo de IA configurado no está disponible.", 503);
  }
  if (estado === 503) {
    return error(
      "El proveedor de IA está ocupado en este momento. Espera un minuto e inténtalo de nuevo.",
      503,
    );
  }
  if (estado === 429) {
    return error(
      "El proveedor de IA está saturado. Espera un minuto e inténtalo de nuevo.",
      429,
    );
  }
  return error("La IA no pudo responder en este momento. Inténtalo de nuevo.", 502);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }
  if (req.method !== "POST") return error("Método no permitido", 405);

  const encabezado = req.headers.get("Authorization") ?? "";
  const token = encabezado.replace(/^Bearer\s+/i, "").trim();
  if (!token) return error("Falta la sesión del usuario", 401);

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  if (!supabaseUrl || !anonKey) {
    console.error("Faltan SUPABASE_URL o SUPABASE_ANON_KEY en la función");
    return error("Servicio no configurado", 500);
  }

  const apiKey = Deno.env.get("GEMINI_API_KEY");
  if (!apiKey) return error("La IA todavía no está configurada", 503);

  let cuerpo: CuerpoSolicitud;
  try {
    cuerpo = await req.json();
  } catch {
    return error("Cuerpo de la solicitud inválido", 400);
  }

  const modo: Modo = cuerpo.modo === "resumen" ? "resumen" : "pregunta";
  const pregunta = (cuerpo.pregunta ?? "").trim();
  const historial = normalizarHistorial(cuerpo.historial);

  if (pregunta.length > MAX_PREGUNTA) {
    return error(`La pregunta no puede superar ${MAX_PREGUNTA} caracteres`, 400);
  }
  if (modo === "pregunta" && pregunta.length < 3) {
    return error("Escribe una pregunta de al menos 3 caracteres", 400);
  }

  let canalId: string | null = null;
  if (cuerpo.canalId != null) {
    if (typeof cuerpo.canalId !== "string" || !UUID_RE.test(cuerpo.canalId)) {
      return error("Canal inválido", 400);
    }
    canalId = cuerpo.canalId;
  }

  const diasPedidos = typeof cuerpo.dias === "number" && Number.isFinite(cuerpo.dias)
    ? Math.trunc(cuerpo.dias)
    : 30;
  const dias = Math.min(Math.max(diasPedidos, 1), 90);

  const supabase = createClient(supabaseUrl, anonKey, {
    auth: { persistSession: false, autoRefreshToken: false },
    global: { headers: { Authorization: `Bearer ${token}` } },
  });

  const { data: usuario, error: errorUsuario } = await supabase.auth.getUser(token);
  if (errorUsuario || !usuario?.user) {
    return error("Sesión inválida o expirada", 401);
  }

  const consulta = modo === "resumen" ? "" : pregunta;

  async function contexto(
    texto: string,
    diasBusqueda: number,
  ): Promise<PublicacionContexto[] | null> {
    const { data, error: errorContexto } = await supabase.rpc(
      "buscar_contexto_ia",
      {
        p_consulta: texto,
        p_canal_id: canalId,
        p_dias: diasBusqueda,
        p_limite: MAX_PUBLICACIONES,
      },
    );
    if (errorContexto) {
      console.error("buscar_contexto_ia falló", errorContexto.message);
      return null;
    }
    return ((data ?? []) as PublicacionContexto[]).filter(
      (publicacion) => publicacion && typeof publicacion.cuerpo === "string",
    );
  }

  async function resumenDirecto(): Promise<ResumenObjetos | null> {
    const { data: filasMaestra, error: errorMaestra } = await supabase
      .from("maestra")
      .select("id_maestra, grupo, codigo")
      .in("codigo", ["publicado", "perdido", "encontrado"])
      .eq("activo", true);
    if (errorMaestra || !filasMaestra) {
      console.error("Conteo directo: maestra falló", errorMaestra?.message);
      return null;
    }
    const estado = filasMaestra.find(
      (fila) => fila.grupo === "estado_publicacion" && fila.codigo === "publicado",
    );
    const encontrado = filasMaestra.find(
      (fila) => fila.grupo === "tipo_publicacion" && fila.codigo === "encontrado",
    );
    const perdido = filasMaestra.find(
      (fila) => fila.grupo === "tipo_publicacion" && fila.codigo === "perdido",
    );
    if (!estado || !encontrado || !perdido) {
      console.error("Conteo directo: faltan catálogos");
      return null;
    }

    const desde = new Date(Date.now() - dias * 86_400_000).toISOString();
    const contar = async (
      tipoId: number,
      opciones: { desde?: string; entregados?: boolean } = {},
    ): Promise<number | null> => {
      let consulta = supabase
        .from("publicaciones")
        .select("id", { count: "exact", head: true })
        .eq("estado_id", estado.id_maestra)
        .eq("tipo_id", tipoId);
      if (canalId) consulta = consulta.eq("canal_id", canalId);
      if (opciones.desde) consulta = consulta.gte("creado_en", opciones.desde);
      if (opciones.entregados) {
        consulta = consulta.contains("metadatos", { entregado: true });
      }
      const { count, error } = await consulta;
      if (error) {
        console.error("Conteo directo falló", error.message);
        return null;
      }
      return count ?? 0;
    };

    const [enc, ent, per, total] = await Promise.all([
      contar(encontrado.id_maestra, { desde }),
      contar(encontrado.id_maestra, { desde, entregados: true }),
      contar(perdido.id_maestra, { desde }),
      contar(encontrado.id_maestra, { entregados: true }),
    ]);
    if (enc === null || ent === null || per === null || total === null) {
      return null;
    }
    return {
      dias,
      encontrados: enc,
      encontrados_entregados: ent,
      perdidos: per,
      entregados_total: total,
    };
  }

  const pidePopular = /votos?|popular|puntaje/i.test(pregunta);
  const popularGeneral = pidePopular &&
    /m[aá]s votos|m[aá]s popular|mejor(es)? votad|top\b/i.test(pregunta);
  const esResumen = modo === "resumen";
  const textoInicial = esResumen || popularGeneral ? "" : consulta;
  let publicaciones = await contexto(textoInicial, dias);
  let notaPeriodo = `Periodo: últimos ${dias} días.`;
  let avisoPeriodo = "";

  if (publicaciones === null) {
    return error("No se pudo recuperar el contexto del campus", 500);
  }

  // Las preguntas concretas se buscan primero en el periodo y luego en todo el
  // historial. Los resúmenes y las preguntas de actividad general usan lo más
  // reciente: así no dependen de que las palabras aparezcan literalmente.
  const necesitaActividad = esResumen ||
    /resumen|perd[ií]|pas[oó]|novedad|actualidad|[uú]ltim|semana|mes|hoy|evento|actividad|pr[oó]xim|votos?|popular/i
      .test(pregunta);

  if (!esResumen && publicaciones.length === 0 && consulta !== "") {
    publicaciones = await contexto(consulta, 3650);
    if (publicaciones === null) {
      return error("No se pudo recuperar el contexto del campus", 500);
    }
    if (publicaciones.length > 0) {
      notaPeriodo =
        `No hubo coincidencias en los últimos ${dias} días; ` +
        "se amplió la búsqueda a publicaciones más antiguas.";
    }
  }

  if (!esResumen && publicaciones.length === 0 && necesitaActividad &&
    consulta !== "") {
    publicaciones = await contexto("", dias);
    if (publicaciones === null) {
      return error("No se pudo recuperar el contexto del campus", 500);
    }
    if (publicaciones.length > 0) {
      notaPeriodo =
        `No hubo coincidencias exactas con la consulta en los últimos ${dias} días; ` +
        "se usan las publicaciones más recientes del periodo.";
    }
  }

  if (publicaciones.length === 0 && necesitaActividad) {
    publicaciones = await contexto("", 3650);
    if (publicaciones === null) {
      return error("No se pudo recuperar el contexto del campus", 500);
    }
    if (publicaciones.length > 0) {
      notaPeriodo =
        `No hay publicaciones en los últimos ${dias} días; ` +
        "se usan las publicaciones más recientes del campus.";
      avisoPeriodo = modo === "resumen"
        ? `No hay publicaciones de los últimos ${dias} días; esta respuesta usa ` +
          "las últimas publicaciones disponibles del campus."
        : `No hay publicaciones de los últimos ${dias} días; se usaron las ` +
          "últimas disponibles del campus como referencia.";
    }
  }

  if (/votos?|popular|puntaje/i.test(pregunta)) {
    publicaciones = [...publicaciones].sort((a, b) =>
      b.puntaje - a.puntaje ||
      Date.parse(b.creado_en) - Date.parse(a.creado_en)
    );
  }

  if (publicaciones.length === 0 && modo === "resumen") {
    return json({
      respuesta: "Todavía no hay publicaciones para resumir en ese periodo.",
      fuentes: [],
      restantes: null,
      modo,
    });
  }

  if (publicaciones.length === 0) {
    notaPeriodo = "No hay publicaciones del campus relacionadas con la pregunta.";
  }

  const usadas = recortarContexto(publicaciones);
  const contextoTexto = usadas.length > 0
    ? textoContexto(usadas)
    : "(sin publicaciones relacionadas en el campus)";

  let datosObjetos = "";
  let resumenObjetosUsuario = "";
  if (/objet|perd|encontr|entreg|devolv/i.test(pregunta)) {
    let resumen: ResumenObjetos | null = null;
    let exacto = false;
    const { data, error: errorResumen } = await supabase.rpc(
      "resumen_objetos_ia",
      { p_dias: dias, p_canal_id: canalId },
    );
    if (errorResumen) {
      console.error(
        "resumen_objetos_ia falló",
        errorResumen.message,
        "¿migración aplicada?",
      );
    } else if (data && typeof (data as ResumenObjetos).encontrados === "number") {
      resumen = data as ResumenObjetos;
      exacto = true;
      console.log("Resumen de objetos", JSON.stringify(resumen));
    }
    if (!resumen) {
      resumen = await resumenDirecto();
      if (resumen) {
        exacto = true;
        console.log("Resumen de objetos (directo)", JSON.stringify(resumen));
      }
    }
    if (!resumen) {
      const metadatosDisponibles = usadas.some(
        (publicacion) => publicacion.metadatos !== undefined,
      );
      if (metadatosDisponibles) {
        resumen = contarObjetosDesdeContexto(usadas, dias);
        console.warn(
          "Conteos aproximados desde el contexto",
          JSON.stringify(resumen),
        );
      } else {
        console.error(
          "El contexto no incluye metadatos; aplica la migración de objetos",
        );
      }
    }
    if (resumen) {
      const r = resumen;
      const etiqueta = exacto
        ? `Datos verificados de objetos (publicaciones creadas en los últimos ${r.dias} días)`
        : `Datos aproximados de objetos (según las ${usadas.length} publicaciones recuperadas)`;
      datosObjetos =
        `${etiqueta}: ${r.encontrados} encontrados publicados, de los cuales ${r.encontrados_entregados} están marcados como entregados; ` +
        `${r.perdidos} perdidos publicados. ` +
        `${exacto ? "Total histórico" : "Total en el contexto"} de encontrados entregados: ${r.entregados_total}. ` +
        "Solo las publicaciones de tipo encontrado tienen el campo entregado.";
      resumenObjetosUsuario =
        `${exacto ? "Según los registros del campus" : "Según las publicaciones recuperadas"} (últimos ${r.dias} días): ` +
        `${r.encontrados} objetos encontrados publicados, ` +
        `${r.encontrados_entregados} marcados como entregados y ` +
        `${r.perdidos} objetos perdidos publicados. ` +
        `${exacto ? "Total histórico" : "Total en el contexto"} de encontrados entregados: ${r.entregados_total}.`;
    }
  }

  const contextoCompleto = datosObjetos
    ? `${datosObjetos}\n\n${contextoTexto}`
    : contextoTexto;

  let restantes: number | null = null;
  const cupoHabilitado =
    (Deno.env.get("IA_CUPO_HABILITADO") ?? "true").toLowerCase() !== "false";

  if (cupoHabilitado) {
    const { data: restantesData, error: errorCupo } = await supabase.rpc(
      "consumir_cupo_ia",
    );

    if (errorCupo) {
      if (errorCupo.code === "P0001") {
        return error(
          "Alcanzaste el límite diario de consultas de IA. Vuelve a intentarlo mañana.",
          429,
        );
      }
      console.error("consumir_cupo_ia falló", errorCupo.message);
      return error("No se pudo validar el cupo de IA", 500);
    }

    restantes = typeof restantesData === "number" ? restantesData : null;
  }
  const modeloPrincipal = Deno.env.get("MODELO_IA")?.trim() ||
    MODELO_POR_DEFECTO;
  const modelos = modeloPrincipal === MODELO_RESPALDO
    ? [modeloPrincipal]
    : [modeloPrincipal, MODELO_RESPALDO];

  const hoy = new Intl.DateTimeFormat("en-CA", { timeZone: "America/Bogota" })
    .format(new Date());
  const introduccion = modo === "resumen"
    ? `${notaPeriodo}\nFecha de hoy: ${hoy}.\nCanal: ${canalId ? "el canal seleccionado" : "todos los canales"}.\n\nCONTEXTO:\n${contextoCompleto}\n\nTarea: resume lo más importante del periodo y señala los temas abiertos.`
    : `Pregunta del usuario: ${pregunta}\n${notaPeriodo}\nFecha de hoy: ${hoy}.\n\nCONTEXTO:\n${contextoCompleto}\n\nResponde la pregunta. Usa el contexto cuando sea relevante y, si es una pregunta general, responde con conocimiento general aclarando que no proviene de publicaciones del campus.`;
  const sistema = modo === "resumen" ? SISTEMA_RESUMEN : SISTEMA_PREGUNTA;
  const contents = contenidoConHistorial(historial, introduccion);

  let respuesta = "";
  let ultimoFallo: unknown = null;

  for (let indice = 0; indice < modelos.length; indice++) {
    const modelo = modelos[indice];
    // El modelo principal puede estar lento o retirado; el respaldo es un
    // modelo ligero con capa gratuita que suele responder en pocos segundos.
    const limite = indice === 0 ? 30000 : 45000;
    const inicioIa = Date.now();
    try {
      respuesta = await llamarGemini(
        apiKey,
        modelo,
        sistema,
        contents,
        limite,
      );
      if (respuesta) {
        if (indice > 0) console.log("Respondió el modelo de respaldo", modelo);
        break;
      }
    } catch (fallo) {
      ultimoFallo = fallo;
      const estado = fallo instanceof ErrorGemini ? fallo.estado : -1;
      console.error(
        "Fallo al llamar a Gemini",
        modelo,
        estado,
        `${Date.now() - inicioIa}ms`,
        esTimeout(fallo)
          ? "timeout"
          : fallo instanceof ErrorGemini
          ? fallo.detalle
          : fallo instanceof Error
          ? fallo.message
          : String(fallo),
      );
      if (
        indice < modelos.length - 1 &&
        (esTimeout(fallo) || estado === 404 || estado === 429 ||
          estado === 500 || estado === 503)
      ) {
        console.warn("Se reintenta con el modelo de respaldo", modelos[indice + 1]);
        continue;
      }
    }
    break;
  }

  if (!respuesta && resumenObjetosUsuario) {
    return json({
      respuesta:
        `${resumenObjetosUsuario}\n\nLa IA está ocupada ahora, pero estas cifras vienen directamente de la base.`,
      fuentes: fuentesDeRespuesta("", usadas),
      restantes,
      modo,
    });
  }

  if (!respuesta && ultimoFallo) return respuestaDeFallo(ultimoFallo);
  if (!respuesta) {
    return error("La IA no pudo responder a esa solicitud. Intenta reformularla.", 502);
  }

  const fuentes = fuentesDeRespuesta(respuesta, usadas);

  const nota = avisoPeriodo ? `${avisoPeriodo}\n\n` : "";
  const notaObjetos = resumenObjetosUsuario
    ? `${resumenObjetosUsuario}\n\n`
    : "";
  return json({
    respuesta: `${nota}${notaObjetos}${respuesta}`,
    fuentes,
    restantes,
    modo,
  });
});

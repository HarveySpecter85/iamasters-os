---
name: marketing-brand-voice
description: Genera el voice profile completo del operador con 3 registros (A formal, B divulgativo, C cercano). Combina interview directa + Firecrawl scraping de URLs públicas (web, LinkedIn, YouTube). Output a brand-context/voice/ con voice-profile.md, samples.md y register-{a,b,c}.md. Lo invoca el onboarding wizard tras la identidad.
---

# marketing-brand-voice

## Cuándo se invoca

- `meta-onboarding-wizard` lo llama tras configurar identidad básica
- Usuario invoca: "configura mi brand voice", "extrae mi voz", "rehaz el voice profile"
- Cuando se detecta drift en outputs (humanizer baja consistentemente) y se sugiere refinar voice

## Process

### Paso 1 · Detectar inputs disponibles

Pregunta al operador (usa AskUserQuestion):

1. **Web propia / blog**: URL (opcional)
2. **LinkedIn personal**: URL (opcional)
3. **YouTube canal**: URL (opcional, con 5+ vídeos)
4. **Twitter/X**: URL (opcional)
5. **Documentos propios**: ¿tienes copy ya escrito que represente tu voz? (newsletter, post anclado, etc.) Pega o ruta a archivo
6. **Voice profile previo**: ¿tienes ya un voice profile de otro lado (Hatem framework, etc.)? Pega lo que quieras integrar

Si no da nada → modo "interview only" (Paso 3 más extenso).

### Paso 2 · Scrapear URLs (si las hay)

Invoca `tool-firecrawl-scraper`:
```json
{
  "urls": [...],
  "format": "markdown",
  "extract_assets": true
}
```

Output esperado: contenido markdown + assets en `brand-context/assets/`.

### Paso 3 · Interview directa

Independientemente de URLs, hacer 6 preguntas de calibración:

**Pregunta 1 · Tono dominante** (multi-select):
- (a) Formal y autoridad — propuesta corporativa
- (b) Divulgativo profesional — explicas con claridad sin ser corporate
- (c) Cercano y directo — como hablas con un amigo
- (d) Provocador — opiniones fuertes, sin miedo a ofender
- (e) Cálido y empático — humano, vulnerable
- (f) Técnico y específico — datos, números, precisión

**Pregunta 2 · Vocabulario del que huyes** (texto libre):
- "¿Qué palabras nunca usas porque suenan a corporate / a vendehumos / a AI?"

**Pregunta 3 · Frases-firma** (texto libre):
- "¿Hay frases que repites mucho y son tuyas? Dame 2-3"

**Pregunta 4 · Jerga propia** (texto libre):
- "¿Tienes términos propios o de tu nicho que uses constantemente? (ej. 'operador IA', 'aterrizar el sistema', 'no-fluff')"

**Pregunta 5 · Anti-modelos** (texto libre):
- "Dime una cuenta de LinkedIn / un creador / un autor cuyo tono ODIES. (Para evitarlo)"

**Pregunta 6 · Modelo a aspirar** (texto libre):
- "Dime una cuenta / autor / podcaster con un tono parecido al que quieres tener"

### Paso 4 · Análisis combinado

Combinar:
- Texto scrapeado de URLs (si hubo)
- Respuestas de interview
- Voice profile previo (si proporcionó)

Extraer:

**Personalidad** (3-5 traits):
- ¿Es seguro / inseguro? ¿Optimista / cauto? ¿Concreto / abstracto? ¿Cálido / frío?

**Tono spectrum** (cuantificado 0-10):
- Formality: 0 (cercano) — 10 (formal)
- Directness: 0 (rodeos) — 10 (sin rodeos)
- Humor: 0 (serio) — 10 (mucho humor)
- Authority: 0 (humilde) — 10 (afirmativo)
- Warmth: 0 (distante) — 10 (cercano)

**Vocabulario**:
- Palabras-firma (las que aparecen ≥3 veces en samples scrapeados)
- Palabras prohibidas (de pregunta 2 + AI tells del humanizer)
- Jerga propia (de pregunta 4)

**Estructura típica**:
- Longitud media de frase
- Uso de listas vs prosa
- Posición de la opinión (al inicio? al final? entrelazada?)

### Paso 5 · Generar `voice-profile.md`

```markdown
# Voice Profile — [Nombre operador]

> Generado: YYYY-MM-DD
> Fuentes: web + LinkedIn + interview (o lo que aplique)

## Personalidad
- Trait 1
- Trait 2
- Trait 3

## Tono spectrum
- Formality: X/10
- Directness: X/10
- Humor: X/10
- Authority: X/10
- Warmth: X/10

## Palabras-firma (uso frecuente, marcan voz)
- ...

## Vocabulario prohibido (nunca usar)
- ...

## Jerga propia (términos del nicho que uso natural)
- ...

## Estructura típica
- Longitud media de frase: X palabras
- Listas vs prosa: 60/40 prosa
- Opinión: al inicio del bloque
- Cierre: pregunta abierta o llamada concreta

## Anti-modelo
- "No quiero sonar como [creador X], cuyo tono es [Y]"

## Modelo a aspirar
- "Tono parecido a [creador Z], cuya virtud es [W]"
```

### Paso 6 · Generar samples.md

Lista de 10-15 frases representativas:
- 5 de inputs scrapeados (extraídas con criterio: frases con personalidad, no genéricas)
- 5 de interview (las frases-firma de Pregunta 3 + reformulaciones)
- 5 sintéticas siguiendo el voice profile (para validar internamente)

### Paso 7 · Generar 3 registers

#### `register-a-formal.md` (formal)

Para: emails cliente premium, propuestas comerciales, contratos, deliverables corporate.

```markdown
# Registro A · Formal

## Cuándo usarlo
- Email a cliente premium o C-level
- Propuesta comercial
- Contrato o documento legal
- Pitch a inversor

## Reglas
- Frases largas y bien construidas (15-25 palabras)
- Vocabulario preciso, sin jerga
- Cero emojis
- Sin abreviaturas
- Tutear/usted según contexto cliente

## Vocabulario permitido (ejemplos)
- "tras nuestra reunión", "en cuanto a", "respecto a", "considerando que"
- "le adjunto", "agradezco su tiempo", "quedo a disposición"

## Vocabulario prohibido en este registro
- (lista de palabras del voice-profile que NO aplican aquí, ej. "vamos a darle caña")
- Slang, anglicismos innecesarios, emojis

## Plantilla email cliente
[Plantilla rellena según voice-profile + reglas formales]

## Ejemplo (extraído del voice-profile)
[Frase del operador adaptada a tono formal]
```

#### `register-b-divulgativo.md` (divulgativo)

Para: LinkedIn post, blog, video script, newsletter, podcast intro.

```markdown
# Registro B · Divulgativo

## Cuándo usarlo
- LinkedIn post / artículo
- Blog post
- Video script (YouTube, talk)
- Newsletter (cuerpo)
- Twitter thread (largos)

## Reglas
- Frases mixtas (10-20 palabras), variar ritmo
- Lenguaje claro, sin jerga innecesaria pero con jerga propia OK
- Contar historia o experiencia personal frecuentemente
- 0-2 emojis intencionales máximo
- Apoyarse en números concretos

## Vocabulario permitido
[Las palabras-firma del voice-profile aplicadas aquí]

## Estructura típica para LinkedIn post
1. Hook (1-2 frases con afirmación contundente o pregunta)
2. Contexto personal ("Llevo X meses...", "He visto...")
3. Insight (la lección)
4. Detalle concreto (números, ejemplos)
5. Pregunta o llamada al final

## Ejemplo (rebuild de samples del operador)
[Sample del voice-profile reescrito en B]
```

#### `register-c-cercano.md` (cercano)

Para: WhatsApp comunidad, DMs, comentarios en redes, chats internos.

```markdown
# Registro C · Cercano

## Cuándo usarlo
- WhatsApp grupo comunidad
- Respuestas a comentarios en LinkedIn/Instagram
- DMs a leads cálidos
- Mensajes Slack a equipo
- Captions cortas en stories

## Reglas
- Frases cortas (5-12 palabras)
- Tono coloquial, contracciones permitidas
- 1-3 emojis OK si son relevantes
- Abreviaturas comunes OK ("xq", "tb", "nada")
- Tuteo siempre

## Vocabulario permitido
[Palabras-firma + slang propio + casual]

## Reglas adicionales
- Está OK empezar frase con conjunción (Y, Pero, Porque)
- Está OK puntos suspensivos para tono...
- Cero formalidades de saludo/despedida (no "Estimado", no "Saludos cordiales")

## Ejemplo
"oye una cosa rápida — la última versión del flow de leads ya quedó?
me dijo Marta que estaba pendiente de tu OK 😊"
```

### Paso 8 · Validación

Mostrar al operador el voice-profile + samples + 3 registers.

Pregunta: "¿Suena a ti? Te genero 3 ejemplos rápidos en cada registro para que valides:"

Generar:
- 1 email formal de propuesta (registro A)
- 1 LinkedIn post sobre tu nicho (registro B)
- 1 mensaje WhatsApp a comunidad (registro C)

Si el operador valida → guardar.
Si dice "no es así" → preguntar qué falla específicamente y refinar (Paso 4 con feedback).

### Paso 9 · Cierre

- Output guardado en `brand-context/voice/`:
  - `voice-profile.md`
  - `samples.md`
  - `register-a-formal.md`
  - `register-b-divulgativo.md`
  - `register-c-cercano.md`
- Append en `context/learnings.md`:
  ```
  ## marketing-brand-voice
  - YYYY-MM-DD: voice profile generado. Reto principal: <X>. Aprender: <Y>.
  ```
- Update `~/.claude/skills/_operator-state.json` con flag `brandVoiceConfigured: true`

## Outputs

5 archivos en `brand-context/voice/`:
- voice-profile.md
- samples.md
- register-a-formal.md
- register-b-divulgativo.md
- register-c-cercano.md

Plus assets en `brand-context/assets/` (si Firecrawl extrajo).

## Skills que llama

- `tool-firecrawl-scraper` — para scrapear URLs públicas (paso 2)

## Edge cases

- **Operador no quiere dar URLs y no quiere interview larga**: hacer interview mínima (3 preguntas) y generar voice profile con disclaimers ("low confidence, refine cuando tengas más datos").
- **URLs no scrapeables (login required)**: pedir al operador que copie/pegue 3-5 posts representativos.
- **Operador en idioma no castellano/inglés**: detectar y avisar — el flujo funciona pero la calidad de detección de patrones es menor.
- **Voice cambia mucho entre canales** (LinkedIn formal vs Instagram casual): generar 2 voice-profiles separados (`voice-profile-pro.md`, `voice-profile-personal.md`) y advertir al operador que las skills marketing-* preguntarán cuál usar.

## Examples

Ver `references/examples.md` para 2 casos:
1. Operador con LinkedIn pro + blog → voice profile robusto con 3 registers diferenciados
2. Operador sin presencia online → interview-only voice profile, low confidence flagged

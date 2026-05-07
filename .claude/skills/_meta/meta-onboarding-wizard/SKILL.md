---
name: meta-onboarding-wizard
description: Lanza el onboarding inicial cuando un operador instala iAmasters OS por primera vez. Entrevista por bloques temáticos (no todo de golpe) y llena los archivos sectorizados context/me.md, work.md, team.md, current-priorities.md, goals.md + configura defaults inteligentes en settings + ofrece modo cognito guiado/completo + lanza welcome-quick-win al cerrar para garantizar primer wow. Solo se ejecuta UNA vez por instalación.
---

# meta-onboarding-wizard

> Inspirado en el patrón "interview-by-section" de [`Luispitik/claude-code-second-brain`](https://github.com/Luispitik/claude-code-second-brain). En lugar de bombardear con 18 preguntas seguidas, vamos por bloques temáticos con resúmenes intermedios — sensación humana, no formulario burocrático.

## Cuándo se invoca

- Sinapsis lee `~/.claude/skills/_operator-state.json` y tiene `needsOnboarding: true`
- O bien: existe operator-state pero `context/me.md` no existe (en plantilla)
- El usuario explícitamente pide reconfigurar: "vuelve a hacerme el onboarding"

NO se invoca:
- Cuando hay `context/me.md` rellenado (pasa al flujo `meta-start-here` normal)
- Cuando hay daily summary del día anterior (continuidad)

## Process

### Paso 1 · Bienvenida y confirmación

Mensaje exacto al usuario:

```
👋 Bienvenido a iAmasters OS.

Voy a hacerte una entrevista guiada para que el sistema sepa quién
eres, qué haces, y cómo quieres trabajar conmigo. Tarda ~10 minutos
y solo se hace UNA vez.

Vamos por bloques cortos para que no se haga pesado. Después te
genero tu primer entregable real (5 min más). Total: ~15 min.

¿Empezamos?
```

Espera "sí", "vamos", "ok" antes de seguir.

### Paso 2 · Bloque A · Identidad (→ `context/me.md`)

3 preguntas seguidas (sin pausar entre ellas, son rápidas):

1. ¿Cómo te llamas?
2. ¿Dónde vives? (ciudad / país, para timezone y contexto cultural)
3. ¿Cómo te describes profesionalmente en 1 frase?

Tras recibir las 3 respuestas, escribe `context/me.md`:

```markdown
# Me · <nombre>

## Identidad
- **Nombre**: <nombre>
- **Ubicación**: <ciudad, país>
- **Timezone**: <calculado de ubicación>
- **Idioma**: <inferido, default castellano>

## Cómo me describo profesionalmente
> <respuesta literal a pregunta 3>

## Cómo quiero que Claude me hable

(Se llena en el Bloque F sobre estilo)

---
*Última actualización: <fecha>*
```

Confirma al usuario:

```
Listo bloque 1. Vamos a tu negocio.
```

### Paso 3 · Bloque B · Negocio (→ `context/work.md`)

4 preguntas, una por una con micro-feedback entre cada:

1. ¿Cuál es tu negocio principal? (nombre + 1 frase de qué hace)
2. ¿Cómo ganas dinero hoy? (servicios, productos, suscripciones, ads, mix)
3. ¿Quién es tu cliente ideal? (descripción concreta — si no lo tienes claro, OK, lo trabajamos después)
4. ¿Qué herramientas usas a diario? (lista corta — Notion, GHL, Google Workspace, etc.)

Tras las 4 respuestas, escribe `context/work.md`:

```markdown
# Work · <negocio principal>

## Qué hago
> <respuesta 1>

## Cómo gano dinero
<respuesta 2 estructurada como bullets si tiene varios streams>

## Cliente ideal (ICP)
> <respuesta 3>
> 
> *Nota: este ICP se refinará con la skill `marketing-icp` cuando estés listo.*

## Stack actual
<respuesta 4 como tabla o lista>

## Otros negocios / proyectos paralelos

(añadir aquí si el usuario los menciona)

---
*Última actualización: <fecha>*
```

Micro-feedback al usuario:

```
✓ Bloque 2 (negocio) anotado.
```

### Paso 4 · Bloque C · Equipo (→ `context/team.md`)

Pregunta 1: "¿Trabajas solo o con un equipo? (solo / 1-3 personas / 4-10 / más de 10)"

**Si trabaja solo**: 
- Crea `context/team.md` con header + nota "Trabajas solo. Cuando contrates a alguien, ejecuta este wizard de nuevo o edita este archivo manualmente."
- Salta al Bloque D.

**Si tiene equipo** (cualquier tamaño): pregunta 2: "Cuéntame quién es cada uno con rol en 1 línea (ej: Ana — diseñadora, lleva contenido). Si son muchos, los principales 3-5."

Tras respuesta, escribe `context/team.md`:

```markdown
# Team

## Estructura
- **Tamaño**: <solo | 1-3 | 4-10 | 10+>

## Personas

| Nombre | Rol | Notas |
|---|---|---|
| <Ana> | <Diseñadora> | <lleva contenido> |
| ... | ... | ... |

## Cómo nos comunicamos
(rellena el usuario después si quiere — Slack, WhatsApp, reuniones semanales, etc.)

---
*Última actualización: <fecha>*
```

### Paso 5 · Bloque D · Foco actual (→ `context/current-priorities.md`)

2 preguntas:

1. ¿En qué estás focalizado ESTE mes? (1-3 prioridades)
2. ¿Qué cuello de botella te frena ahora mismo?

Tras respuestas, escribe `context/current-priorities.md`:

```markdown
# Current priorities

> **Nota**: este archivo cambia mensualmente. Ejecuta el comando
> `/update-priorities` o edítalo cuando tu foco cambie.

## Foco del mes (<mes año>)

1. <prioridad 1>
2. <prioridad 2>
3. <prioridad 3>

## Cuello de botella actual

> <respuesta 2>

## Decisiones abiertas

(las skills `six-hats` y `decisions-log` llenarán esta sección con
el tiempo)

---
*Última actualización: <fecha>*
```

Micro-feedback:

```
✓ Bloque 4 (foco actual) anotado.
```

### Paso 6 · Bloque E · Objetivos (→ `context/goals.md`)

1 pregunta abierta: "¿Cuál es el objetivo grande que quieres conseguir en los próximos 12 meses? Algo concreto si puedes (€X de revenue, lanzar Y producto, contratar Z personas)."

Tras respuesta, escribe `context/goals.md`:

```markdown
# Goals

## Objetivo 12 meses

> <respuesta literal del usuario>

## Hitos trimestrales

(no preguntados todavía. Cuando estés listo, ejecuta la skill
`strategy-quarterly-planning` o edítalo manual.)

| Trimestre | Hito objetivo | Estado |
|---|---|---|
| Q3 | (por definir) | — |
| Q4 | (por definir) | — |
| Q1+ | (por definir) | — |

## Norte estratégico

(qué decisión tomar cuando dudes — añadir cuando tengas claridad)

---
*Última actualización: <fecha>*
```

### Paso 7 · Bloque F · Configuración técnica

3 preguntas seguidas:

1. **Nivel técnico**: ¿cero / intermedio / avanzado? (cero = nunca abriste terminal antes)
2. **Idioma de outputs hacia tus clientes**: castellano / inglés / bilingüe / otro
3. **Firecrawl API key**: ¿tienes una? Si no, ofrécela: "https://www.firecrawl.dev tiene 500 créditos free. Sin esto algunas skills piden contenido manual." Ofrece pegarla ahora.

Construye/actualiza `~/.claude/skills/_operator-state.json` con todas las respuestas hasta ahora más:
- `needsOnboarding: false`
- `onboardingDate: <fecha actual>`
- `welcomeCompleted: false` (se pone true tras Paso 9)
- `firecrawlAvailable: true|false`
- `cognitoMode: pending` (se elige en Paso 8)
- `technicalLevel: <respuesta>`
- `clientOutputLanguage: <respuesta>`

Si nivel técnico = cero, ajusta `.claude/settings.json` para activar plan-mode por defecto y permisos más conservadores (no `Bash(npm install)` etc.).

### Paso 8 · Bloque G · Modo cognito

Pregunta exacta:

```
Una skill que vas a usar bastante es `cognito` — un sistema operativo
de pensamiento con varios modos cognitivos (divergente, crítico,
ejecutor, etc.) que se aplican según la fase del proyecto.

Te ofrezco dos modos:

  [1] Guiado — yo elijo automáticamente el modo cognitivo según el
      contexto (4 modos esenciales: divergente, crítico, ejecutor,
      sintetizador). Recomendado si empiezas.

  [2] Completo — accedes a los 7 modos cognitivos con las 5 fases de
      proyecto (35 combinaciones posibles). Más potente, más curva
      de aprendizaje.

Puedes cambiarlo después con `/cognito-mode <guiado|completo>`.
¿Cuál prefieres?
```

Default si no responde: [1] Guiado.

Guarda en operator-state como `cognitoMode: "guiado" | "completo"`.

### Paso 9 · Inicialización archivos sistema

Crea archivos faltantes con headers canónicos:

1. **`context/decisions-log.md`** (si no existe):
```markdown
# Decisions log

Diario append-only de decisiones del operador.
Patrón inspirado en [claude-code-second-brain](https://github.com/Luispitik/claude-code-second-brain) de Luis Pitik.

> Esta skill (`decisions-log`) se invoca automáticamente cuando
> tomas una decisión estratégica. También puedes invocarla
> manualmente: "registra esta decisión".

---
```

2. **`context/learnings.md`** (si no existe):
```markdown
# Learnings

Feedback consolidado de skills, append-only.
Cada sección corresponde a una skill que registró algo aprendido.

---
```

3. **`context/soul.md`** (si no existe):
```markdown
# Soul · personalidad del agente

> Cómo respondes al usuario. Esto es estático (cambia poco).

## Tono
- Directo, sin rodeos
- Cálido pero no efusivo
- 2-3 opciones máx con recomendación, no listas exhaustivas

## Idioma
- Castellano siempre con el operador
- Outputs cliente en el idioma configurado en `me.md`

## Lo que NO haces
- Vender humo
- Inflar palabras vacías
- Ejecutar acciones destructivas sin confirmar

---
```

4. **`projects/welcome/`** (directorio vacío, listo para welcome-quick-win)

### Paso 10 · Bloque H · Lanzamiento welcome quick-win

Mensaje al usuario:

```
🎉 Setup completo. He creado tu contexto:

  ✓ context/me.md — tu identidad
  ✓ context/work.md — tu negocio
  ✓ context/team.md — tu equipo
  ✓ context/current-priorities.md — tu foco
  ✓ context/goals.md — tu objetivo 12 meses
  ✓ Sinapsis configurado
  ✓ Cognito en modo <guiado|completo>

Última cosa: voy a generarte tu PRIMER ENTREGABLE para que veas el
sistema funcionando. Tarda ~5 min y te queda un HTML compartible.

¿Vamos?
```

Si "sí": invoca skill `welcome-quick-win`.
Si "no" o "después": cierra wizard, marca `welcomeCompleted: false` (se disparará automáticamente la siguiente sesión).

### Paso 11 · Cierre y aprendizaje

- Append en `~/.claude/skills/_daily-summaries/<TODAY>.md`:
  ```
  ## Sesión 1 · Onboarding completado
  - Operador: <nombre>, ubicación: <ubicación>
  - Avatar inferido: <calculado de respuestas>
  - Foco actual: <prioridad 1>
  - Cognito mode: <guiado|completo>
  - Welcome quick-win: <completado|pendiente>
  ```
- NO appends en `context/learnings.md` para esta primera sesión (queda limpio para skills reales)

## Outputs

- `~/.claude/skills/_operator-state.json` — actualizado con perfil completo
- `context/me.md`, `work.md`, `team.md`, `current-priorities.md`, `goals.md` — sectorizados
- `context/decisions-log.md`, `learnings.md`, `soul.md` — inicializados con header
- `projects/welcome/` — directorio creado
- `.env` — Firecrawl API key si se proporcionó
- `.claude/settings.json` — ajustes de permisos según nivel técnico
- `~/.claude/skills/_daily-summaries/<TODAY>.md` — entrada inicial

## Skills que llama

- **`welcome-quick-win`** — al final del onboarding para generar primer entregable (Paso 10)

## Edge cases

- **Usuario abandona a mitad**: guardar progreso parcial en operator-state con `onboardingProgress: <bloque>` (A-H). Al volver, retomar desde el bloque siguiente al último completado.
- **Usuario dice "no tengo equipo, no tengo ICP, no tengo objetivo claro"**: aceptar "todavía no" sin presionar. Llenar archivos con "(por definir)" y propón skills concretas para definirlos después (`marketing-icp`, `strategy-trending-research`, etc.)
- **Usuario es solo curioso, sin negocio**: marcar `avatar: "curioso"` en operator-state y saltar Bloque B → "OK, sin negocio activo. Cuando lo tengas, vuelve a ejecutar este wizard."
- **Respuestas contradictorias**: pedir clarificación corta (1 pregunta), no debate. Ej: nivel cero pero dominio = desarrollo → "¿seguro? Para empezar te sugiero plan-mode activado, lo desactivamos cuando estés cómodo. ¿OK?"
- **Firecrawl no proporcionada y no quiere obtenerla**: marca `firecrawlAvailable: false` y degrada gracefully (welcome-quick-win pedirá párrafo manual).

## Examples

```
Operador: (clone fresh + abre Claude Code)
Wizard: "👋 Bienvenido a iAmasters OS. Voy a hacerte una entrevista..."
Operador: "vamos"

[Bloque A]
Wizard: "¿Cómo te llamas?"
Operador: "Marta"
Wizard: "¿Dónde vives?"
Operador: "Madrid"
Wizard: "¿Cómo te describes profesionalmente en 1 frase?"
Operador: "Diseñadora UX freelance especializada en SaaS B2B"
Wizard: ✓ context/me.md creado.

[Bloque B]
Wizard: "¿Cuál es tu negocio principal?"
Operador: "Estudio de diseño UX, trabajo sola con 4-5 clientes simultáneos"
... [continúa]

[Bloque H, final]
Wizard: "🎉 Setup completo. He creado tu contexto:..."
Operador: "vamos"
Wizard: → invoca welcome-quick-win
```

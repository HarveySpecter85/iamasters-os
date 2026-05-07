# iAmasters OS — CLAUDE.md (project root)

> Sistema operativo agéntico para operadores de IA.
> Sinapsis v4.5 (engine) + capa OS (brand context, agent context, skills curadas, multi-cliente).

## Session Entry — EXECUTE ON FIRST MESSAGE OF EVERY SESSION

### Paths absolutos (relativos a este repo)
- **Skills del OS**: `.claude/skills/`
- **Commands del OS**: `.claude/commands/`
- **Brand context**: `brand-context/` (voice, positioning, ICP, assets)
- **Agent context**: `context/` (soul.md, user.md, learnings.md)
- **Proyectos**: `projects/` (por skill o `projects/briefs/<nombre>/`)
- **Clientes**: `clients/<nombre>/` (con `clients/_templates/` para nuevos)
- **Docs operativos**: `docs/`

### Paths Sinapsis (engine global del operador)
- **Skills root global**: `~/.claude/skills/` (Sinapsis instalado por install.sh)
- **Operator state**: `~/.claude/skills/_operator-state.json` (perfil del operador)
- **Instincts**: `~/.claude/skills/_instincts-index.json` (lo aprendido)
- **Daily summaries**: `~/.claude/skills/_daily-summaries/`
- **Catalog**: `~/.claude/skills/_catalog.json`

### MANDATORY first action
Antes de responder al primer mensaje del usuario, debes:

1. Leer `~/.claude/skills/_operator-state.json` (Sinapsis: perfil del operador, decisiones, lecciones).
2. Leer `context/user.md` (capa OS: usuario en el contexto de este repo).
3. Comprobar `synapsis-bridge` siguiente:

### Detección de primer arranque (onboarding)
Si `~/.claude/skills/_operator-state.json` NO existe o tiene `needsOnboarding: true`:
- → invoca la skill `meta-onboarding-wizard` que está en `.claude/skills/_meta/meta-onboarding-wizard/`.

Si existe pero `brand-context/voice/voice-profile.md` NO existe:
- → invoca `meta-start-here` para arrancar el flujo de brand context.

Si todo está creado:
- → ejecuta el ritual normal de `/start-here` (resumen del día anterior + propuesta de tarea).

### Session continuity (operativa diaria)
Cuando todo está configurado:
1. Lee `synapsis/daily-summaries/<TODAY>.md` o `<YESTERDAY>.md` (Sinapsis daily summary multi-proyecto)
2. Lee `context/learnings.md` (capa OS: feedback consolidado de skills)
3. Comprueba si hay proyectos abiertos en `projects/briefs/*/brief.md` con `status: active`
4. Saluda con: "Ayer dejaste X. Sigues con Y o cambias?"

## Sobre el sistema

### Sinapsis (engine de memoria)
Sinapsis es el sistema que hace que Claude Code aprenda de ti. Vive instalado en `~/.claude/` (no en este repo). El repo lo trae vendored en `vendor/sinapsis/` para instalación.

Sinapsis te da:
- **Operator state**: tu identidad, stack, decisiones — persiste en TODOS los proyectos que abras
- **Instincts**: patrones aprendidos que se inyectan automáticamente cuando aplican
- **Passive rules**: guardrails técnicos (seguridad, calidad, workflow)
- **Skills on-demand**: solo carga las skills relevantes (~2.800 tokens vs ~25.000)
- **Dream cycle**: limpieza periódica de memoria (duplicados, stale, contradicciones)
- **Dashboard** (`/dashboard-sinapsis`): métricas reales del sistema

Comandos Sinapsis útiles (instalados global):
- `/system-status` — estado general
- `/evolve` — graduar instinct draft → confirmed → permanent
- `/instinct-status` — instincts activos por dominio
- `/passive-status` — reglas pasivas
- `/eod` — resumen end-of-day multi-proyecto
- `/dream` — ciclo de hygiene de memoria
- `/analyze-session` — review de propuestas aprendidas

### Capa OS (este repo)
Lo que aporta este repo encima de Sinapsis:

**Brand Context (`brand-context/`)** — estática, una sola vez:
- Voice profile + 3 registros (A formal / B divulgativo / C cercano)
- Positioning (ángulo, mercado, diferencial)
- ICP (cliente ideal, lenguaje, buying triggers)
- Brand assets (logos, colores, fuentes — Firecrawl scraping)

**Agent Context (`context/`)** — dinámica, evoluciona:
- `soul.md` — personalidad del agente (cómo respondes)
- `user.md` — el operador en contexto del repo (preferencias visuales en docs, ejemplos del día a día)
- `learnings.md` — feedback consolidado de skills

**Skills curadas (`.claude/skills/`)** — 18-22 skills por categoría:
- `_meta/` — sistema (skill-creator, onboarding-wizard, output-verifier)
- `marketing/` — brand-voice, positioning, ICP, copywriting, repurposing, UGC, email-sequence
- `operations/` — meeting-notes, task-priority
- `strategy/` — trending-research, competitor-monitor
- `tools/` — humanizer, firecrawl-scraper, youtube-transcript, output-verifier
- `visualization/` — excalidraw-diagram

**Niveles de proyecto**:
1. **Single task** — pregunta directa. Output a `projects/<skill-name>/<fecha>-<titulo>/`.
2. **Planned project** — scoping conversation. Output a `projects/briefs/<nombre>/` con `brief.md`.
3. **GSD project** — multi-fase. `.planning/` en el cliente o raíz. Una a la vez.

**Multi-cliente**:
- `clients/<nombre>/` con su propio brand-context, context, projects
- Skills se copian del root al cliente en cada update (no se heredan, sí se sincronizan)
- `CLAUDE.md` se hereda del repo raíz; cliente puede añadir override en `clients/<nombre>/CLAUDE.md`
- Templates en `clients/_templates/` para cuatro verticales

## Skills registry (auto-mantenido)

Lista canónica de skills instaladas en este repo:

<!-- skills-registry-start -->
*(este bloque lo auto-mantiene el comando `/wrap-up` después de cada sesión donde se añadan/quiten skills)*
<!-- skills-registry-end -->

## Niveles de proyecto — heartbeat

Al iniciar cada sesión, comprueba `projects/briefs/*/brief.md`:
- Si hay `status: active`, recuérdale al usuario qué dejó abierto.
- Si hay un `.planning/` en raíz o en algún cliente, indica que hay un GSD project en marcha.
- Si terminó algo (`status: done`), pregunta si lo archivamos.

## Cómo registrar skills nuevas (auto)

Cuando se añade una skill nueva en `.claude/skills/<categoria>/<nombre>/`:
- `/start-here` la detecta y registra en `synapsis/skills-catalog.json`
- `/wrap-up` actualiza el registry de este CLAUDE.md
- El comando `/install-skill <github-url>` la valida antes de añadirla

Si una skill se elimina:
- `/start-here` lo detecta y propone limpiar referencias en CLAUDE.md, README, etc.

## Permisos (recordatorio)

`.claude/settings.json` viene con permisos seguros por defecto:
- ✅ Read files, run dev server, git operations, edit files dentro del repo
- ❌ Install packages globalmente, delete files, send to internet, leer .env

Si necesitas más permisos: `claude` con `--dangerously-skip-permissions` (solo para tareas isoladas) o edita `settings.json`.

## Idioma

- **Operativa con el usuario**: castellano por defecto
- **Comentarios técnicos en código**: inglés (estándar dev)
- **Commits**: conventional commits en inglés
- **Outputs entregables al cliente**: en el idioma del cliente (detectar de su brand-context)

## Convenciones del repo

- Carpetas en kebab-case (`brand-context`, `clients`, `projects`)
- Archivos markdown en kebab-case con extensión `.md`
- Skills en kebab-case con prefijo de categoría: `marketing-brand-voice`, `tool-humanizer`, `meta-skill-creator`
- Outputs por fecha: `YYYY-MM-DD-titulo-corto/`
- Variables de entorno en `.env` (nunca commitear; ver `.env.example`)

## Cuándo NO usar el OS

Casos donde es mejor abrir Claude Code en otro lado y no en este repo:
- Editar el código de tu propia app (abre la app)
- Resolver un bug puntual sin necesidad de brand context
- Una sesión exploratoria que no quieres que ensucie tu memory

Para casos donde sí lo usas:
- Crear contenido (LinkedIn, X, blog, email, video script)
- Trabajar con un cliente (entras en `clients/<nombre>/`)
- Análisis estratégico (positioning, competidores, trending)
- Generar deliverables que requieran brand voice consistente

## Soporte y comunidad

- Issues: https://github.com/iamasters/iamasters-os/issues *(privado en v0)*
- Sinapsis upstream: https://github.com/Luispitik/sinapsis

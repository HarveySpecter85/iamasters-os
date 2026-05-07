---
name: meta-onboarding-wizard
description: Lanza el onboarding inicial cuando un operador instala iAmasters OS por primera vez. Detecta primer arranque (no hay operator-state.json o user.md vacío), pregunta avatar/nivel/dominio/stack en 5-7 preguntas, configura defaults inteligentes, y propone qué skills activar/desactivar. Solo se ejecuta UNA vez por instalación; después se desactiva.
---

# meta-onboarding-wizard

## Cuándo se invoca

- Sinapsis lee `_operator-state.json` y tiene `needsOnboarding: true` (primer arranque)
- O bien: existe `_operator-state.json` pero `context/user.md` está vacío (en plantilla)
- El usuario explícitamente pide reconfigurar: "vuelve a hacerme el onboarding"

NO se invoca:
- Cuando hay `context/user.md` rellenado (pasa al flujo `meta-start-here` normal)
- Cuando hay daily summary del día anterior (continuidad)

## Process

### Paso 1 · Confirmar primer arranque
- Lee `~/.claude/skills/_operator-state.json`
- Lee `context/user.md`
- Si ambos rellenados → cancelar onboarding, derivar a `meta-start-here`

### Paso 2 · Pregunta secuencial (usa AskUserQuestion si disponible)

**Pregunta 1 · Avatar:**
- (a) Single business — soy mi propio cliente
- (b) Freelance multi-cliente — tengo varios clientes
- (c) Agencia pequeña — equipo de 2-10 personas
- (d) Formador/educador — enseño esto a otros

**Pregunta 2 · Nivel técnico:**
- (a) Cero — nunca abrí terminal antes de Claude Code
- (b) Intermedio — toco código a veces, conozco git, npm
- (c) Avanzado — desarrollo, sysadmin, full stack

**Pregunta 3 · Dominio principal:**
- (a) Marketing & contenido (LinkedIn, blog, copy, ads)
- (b) Operaciones (procesos, productividad, gestión)
- (c) Estrategia & análisis (research, competidores, dashboards)
- (d) Mixto / múltiples
- (e) Desarrollo (código, deploy, ingeniería)

**Pregunta 4 · Stack actual** (multi-select):
- Notion, Airtable, Google Workspace
- HubSpot, GoHighLevel, otro CRM
- Slack, Discord, Telegram, WhatsApp
- Supabase, Vercel, GitHub
- N8n, Zapier, Make
- Otro (texto libre)

**Pregunta 5 · Idioma de outputs cliente** (si el avatar es freelance/agencia):
- (a) Castellano
- (b) Inglés
- (c) Bilingüe (castellano + inglés)
- (d) Otro

**Pregunta 6 · Firecrawl API key** (opcional):
- "¿Tienes API key de Firecrawl? Sin esto, el onboarding del brand voice no podrá auto-extraer tu voz desde tu web pública."
- Si sí → guardar en `.env`. Si no → ofrecer link `https://www.firecrawl.dev` (500 créditos free).

**Pregunta 7 · Identidad básica:**
- Nombre / handle público
- Email contacto principal
- Web/LinkedIn (opcional, se usará en brand voice extraction)

### Paso 3 · Configurar defaults según respuestas

Construir `_operator-state.json` global (Sinapsis) y `context/user.md` (repo) con las respuestas.

**Si avatar = freelance/agencia:**
- Activar capa multi-cliente
- Crear estructura `clients/` lista (vacía pero presente)
- Sugerir templates verticales en `clients/_templates/`

**Si avatar = single-business:**
- Sugerir desactivar `clients/` (queda en `.gitignore` extendido)
- Trabajar siempre en raíz del repo

**Si nivel técnico = cero:**
- Activar plan-mode por defecto en `.claude/settings.json`
- Restringir más permisos (no `Bash(npm install)`)
- Activar hook de notificación al completar tareas largas

**Si dominio = marketing:**
- Skills auto-activadas: marketing-* (todas), tool-humanizer, tool-output-verifier
- Skills desactivadas: operations-task-priority si no aplica

**Si dominio = operations:**
- Skills auto-activadas: operations-*, strategy-*, tool-output-verifier
- Reordenar settings.json para priorizar estas categorías

### Paso 4 · Propuesta de primer brand-voice

Tras configurar identidad:
- Si dio web/LinkedIn → "¿Lanzamos ahora `marketing-brand-voice` para extraer tu voz desde estas URLs? (~5 min)"
- Si dijo sí → invoca skill `marketing-brand-voice` (cuando exista) y pasa los URLs como input
- Si no → "OK, lo haces después con `/start-here` cuando estés listo"

### Paso 5 · Marca onboarding completado

- Update `~/.claude/skills/_operator-state.json` → `needsOnboarding: false`
- Add timestamp `onboardingDate` con fecha actual
- Append en `synapsis/daily-summaries/<TODAY>.md`:
  ```
  ## Session 1 - Onboarding completado
  - Avatar: <X>, Nivel: <Y>, Dominio: <Z>
  - Brand voice: <pendiente | iniciado | completado>
  - Primera tarea sugerida: <Q>
  ```

### Paso 6 · Bienvenida y primera tarea sugerida

Cierre con mensaje:

> "Listo, {{nombre}}. iAmasters OS configurado para tu perfil.
>
> Lo que puedes hacer ahora:
> 1. **Brand voice** (si no lo hiciste): `/start-here` y elige opción brand voice
> 2. **Crear primer cliente** (si freelance/agencia): `/add-client`
> 3. **Tarea concreta**: dime qué necesitas y te recomiendo qué skill usar
>
> Cuando cierres, recuerda `/wrap-up` para que mañana retome el hilo."

## Outputs

- `~/.claude/skills/_operator-state.json` — actualizado con perfil
- `context/user.md` — rellenado en el repo
- `.env` — API keys si se proporcionaron
- `synapsis/daily-summaries/<TODAY>.md` — entrada inicial
- `.claude/settings.json` — ajustes de permisos según nivel técnico

## Skills que llama

- **`marketing-brand-voice`** — opcionalmente en paso 4, si el usuario quiere arrancar voice profile

## Edge cases

- **Usuario abandona a mitad**: guardar progreso parcial en `_operator-state.json` con `onboardingProgress: 3` (de 7). Al volver, retomar desde la última pregunta.
- **No tiene Firecrawl key y no quiere obtenerla**: continuar, marcar `firecrawlAvailable: false` y degradar gracefully el brand-voice flow.
- **Respuestas contradictorias**: pedir clarificación. Ej: nivel cero pero dominio = desarrollo → "¿seguro? sugerencia: empieza por marketing/operations".

## Examples

```
Operador: (abre Claude Code en repo recién clonado)
Wizard: "Bienvenido a iAmasters OS. 7 preguntas rápidas para configurarlo a tu medida..."
[Pregunta 1-7]
Wizard: "Perfecto, Marta. He configurado el OS para freelance multi-cliente con dominio marketing.
        He activado 7 skills marketing y desactivado el módulo de operaciones (lo activamos cuando lo necesites).
        ¿Lanzamos ahora la extracción de tu brand voice desde linkedin.com/in/marta-x? Tarda 5 min."
Operador: "Sí"
Wizard: → invoca marketing-brand-voice
```

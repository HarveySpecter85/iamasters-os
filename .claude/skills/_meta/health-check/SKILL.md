---
name: health-check
description: Diagnóstico completo del estado de iAmasters OS. Verifica entorno (CLI, OS, paths), Sinapsis instalada, brand-context inicializado, context sectorizado, skills curadas presentes, settings válidos, decisions-log existente y API keys. Devuelve reporte estructurado 🟢🟡🔴 con acciones concretas para cada problema. Soporta auto-fix para problemas comunes (decisions-log faltante, brand-context vacío, context sin sectorizar). Se invoca vía slash command `/doctor` o cuando otra skill detecta inconsistencia.
---

# health-check

## Cuándo se invoca

- Usuario ejecuta `/doctor`
- `meta-start-here` detecta inconsistencia al arrancar sesión
- `meta-onboarding-wizard` lo invoca al final del setup para validar
- Tras `update.sh` para verificar que la actualización no rompió nada
- Usuario reporta que "algo no funciona" sin saber qué

## Process

### Paso 1 · Verificación entorno

Comprueba en este orden, marca cada item con 🟢/🟡/🔴:

| Check | Comando / Validación | Severidad si falla |
|---|---|---|
| Claude Code CLI presente | `which claude` o reconocer entorno actual | 🔴 |
| Repo raíz correcto | Existe `CLAUDE.md` + `.claude/` + `vendor/sinapsis/` en `pwd` | 🔴 |
| Git inicializado | Existe `.git/` | 🟡 |
| `.env` existe | Existe `.env` (no `.env.example`) | 🟡 si Firecrawl está documentado, 🟢 si no |
| Node.js presente | `which node && node --version` ≥ 18 | 🟡 (solo crítico si hay scripts JS) |

### Paso 2 · Verificación Sinapsis

| Check | Validación | Severidad |
|---|---|---|
| Sinapsis instalada | `~/.claude/skills/` existe y tiene contenido | 🔴 |
| Operator state | `~/.claude/skills/_operator-state.json` existe y es JSON válido | 🔴 |
| Catalog | `~/.claude/skills/_catalog.json` existe | 🟡 |
| Daily summaries dir | `~/.claude/skills/_daily-summaries/` existe | 🟡 |
| Hooks Sinapsis | `~/.claude/settings.json` tiene la sección `hooks` con SessionStart | 🟡 |
| Vendored upstream | `vendor/sinapsis/` existe con archivos esperados | 🟡 |

### Paso 3 · Verificación capa OS — brand-context

| Check | Validación | Severidad |
|---|---|---|
| `brand-context/` directorio | Existe | 🔴 |
| Voice profile | `brand-context/voice/voice-profile.md` existe y no está vacío | 🟡 (skill sugerida: `marketing-brand-voice`) |
| Voice samples | `brand-context/voice/samples.md` existe | 🟡 |
| Registros A/B/C | `brand-context/voice/register-a-formal.md`, `register-b-divulgativo.md`, `register-c-cercano.md` | 🟡 |
| Positioning | `brand-context/positioning/positioning.md` existe | 🟡 (skill sugerida: `marketing-positioning`) |
| ICP | `brand-context/icp/icp.md` existe | 🟡 (skill sugerida: `marketing-icp`) |

### Paso 4 · Verificación capa OS — context (sectorizado)

| Check | Validación | Severidad |
|---|---|---|
| `context/me.md` | Existe + no vacío | 🟡 (skill sugerida: `meta-onboarding-wizard`) |
| `context/work.md` | Existe + no vacío | 🟡 |
| `context/team.md` | Existe (puede estar vacío si trabajas solo) | 🟢 |
| `context/current-priorities.md` | Existe + no vacío | 🟡 |
| `context/goals.md` | Existe + no vacío | 🟡 |
| `context/decisions-log.md` | Existe (puede estar solo con header) | 🟡 (auto-fix disponible) |
| `context/learnings.md` | Existe (puede estar vacío) | 🟢 |
| `context/soul.md` | Existe + no vacío | 🟡 |

### Paso 5 · Verificación skills curadas

Lista skills mínimas que deben estar en el repo (Capa 1 v0.4.3 = 18 skills):

```
.claude/skills/_meta/meta-skill-creator/SKILL.md
.claude/skills/_meta/meta-onboarding-wizard/SKILL.md
.claude/skills/_meta/meta-start-here/SKILL.md
.claude/skills/_meta/meta-wrap-up/SKILL.md
.claude/skills/_meta/welcome-quick-win/SKILL.md
.claude/skills/_meta/six-hats/SKILL.md
.claude/skills/_meta/decisions-log/SKILL.md
.claude/skills/_meta/health-check/SKILL.md
.claude/skills/_meta/cognito/SKILL.md
.claude/skills/_meta/find-skills/SKILL.md
.claude/skills/marketing/marketing-brand-voice/SKILL.md
.claude/skills/marketing/marketing-positioning/SKILL.md
.claude/skills/marketing/marketing-icp/SKILL.md
.claude/skills/marketing/marketing-copywriting/SKILL.md
.claude/skills/marketing/marketing-content-repurposing/SKILL.md
.claude/skills/tools/tool-firecrawl-scraper/SKILL.md
.claude/skills/tools/tool-humanizer/SKILL.md
.claude/skills/tools/tool-output-verifier/SKILL.md
.claude/skills/tools/tool-visual-explainer/SKILL.md
```

Por cada faltante: 🟡 con sugerencia "ejecuta `bash scripts/update.sh` para sincronizar con upstream".

### Paso 6 · Verificación settings

| Check | Validación | Severidad |
|---|---|---|
| `.claude/settings.json` parseable | JSON válido | 🔴 |
| Permissions seguras | Tiene `permissions` con allow/deny adecuados | 🟡 |
| No secrets en settings | No hay API keys hardcoded | 🔴 |

### Paso 7 · Verificación API keys (opcionales)

| Check | Validación | Severidad |
|---|---|---|
| `ANTHROPIC_API_KEY` | Set en env o `.env` | 🟢 (no requerida con Pro/Max) |
| `FIRECRAWL_API_KEY` | Set en env o `.env` | 🟡 (sin esto, scraping manual) |

### Paso 8 · Compilar reporte

Genera reporte en chat con esta estructura:

```
# 🩺 iAmasters OS · Health Check

📅 <fecha y hora>
📂 Repo: <ruta absoluta>
👤 Operador: <nombre desde operator-state.json>
🎯 Versión OS: <leer de CHANGELOG o package>

## Resumen

🟢 OK: <N> componentes
🟡 AVISO: <N> componentes
🔴 ERROR: <N> componentes

## Detalle

### Entorno
🟢 Claude Code CLI presente
🟢 Repo raíz correcto
...

### Sinapsis
🟢 ...
🟡 ...

### Brand Context
🟡 voice-profile.md no existe
   → Acción: ejecuta `marketing-brand-voice` para generarlo (10 min)
...

### Context sectorizado
🟡 context/me.md vacío
   → Acción: ejecuta `meta-onboarding-wizard` (sección "Quién eres")
...

### Skills curadas
🟢 18/18 skills core presentes

### Settings
🟢 ...

### API keys
🟡 FIRECRAWL_API_KEY no encontrada
   → Sin esto, las skills que scrapean piden contenido manualmente.
     Si quieres automatizar: añade clave en `.env` (firecrawl.com → free tier)

## Próximas acciones recomendadas

(orden por impacto):
1. <acción 1>
2. <acción 2>
3. <acción 3>
```

### Paso 9 · Auto-fix opcional

Para problemas con auto-fix disponible, ofrece ejecutar:

```
Detecté <N> problemas con fix automático:
  • Crear context/decisions-log.md con header canónico
  • Inicializar brand-context/ subfolders vacíos
  • Crear .env desde .env.example

¿Aplico los fixes? (s/n)
```

Si "s", aplícalos uno a uno mostrando qué hace cada uno. Si "n", continúa sin tocar.

### Paso 10 · Cierre

- Si todo 🟢: muestra al usuario qué proyectos tiene abiertos (lee `projects/briefs/*/brief.md` con `status: active`) y propón continuar con uno
- Si hay 🟡 o 🔴: muestra plan de acción priorizado
- Append en `context/learnings.md` bajo `## health-check` solo si descubriste algo recurrente (no por cada ejecución)

## Outputs

- Reporte en chat con estructura del Paso 8
- Opcional: archivo `projects/health-check/<YYYY-MM-DD>-report.md` (solo si el usuario lo pide explícitamente)
- Opcional: archivos creados/inicializados por auto-fix

## Skills que llama

- Ninguna directamente. Esta skill es defensiva — diagnostica pero no ejecuta más que auto-fixes muy concretos.

## Edge cases

- **Repo abierto pero no es iamasters-os**: detecta ausencia de `vendor/sinapsis/` y archivos clave → reporta "no estás en un repo iamasters-os" + sugiere `cd ~/iamasters-os` o instalación.
- **Sinapsis instalada PERO con versión distinta a la vendoreada**: avisa de drift, propón `bash scripts/update.sh` que re-vendoree.
- **`.env` con sintaxis rota**: detecta y reporta línea problemática.
- **Permisos rotos** (settings.json no parseable): NO intentes arreglar, deriva al usuario a backup en `.claude/settings.json.bak` si existe.
- **Cliente activo en `clients/<X>/`**: validar también el sub-context de ese cliente.

## Auto-fixes disponibles

Lista exacta de fixes que esta skill puede ejecutar sin preguntar más allá del "¿aplico?":

1. **Crear `context/decisions-log.md` con header canónico** (si no existe)
2. **Crear `context/learnings.md` con header** (si no existe)
3. **Inicializar `brand-context/voice/`, `positioning/`, `icp/`, `assets/` con `.gitkeep`** (si faltan los dirs)
4. **Crear `.env` desde `.env.example`** (si `.env` no existe)
5. **Crear `projects/welcome/` directorio** (si no existe)
6. **Añadir entradas faltantes al skills-registry de CLAUDE.md** (si hay skills nuevas no registradas)

Fixes que NO son automáticos (requieren skill o flujo de usuario):
- Generar voice-profile (requiere `marketing-brand-voice`)
- Llenar `context/me.md, work.md, team.md` (requiere `meta-onboarding-wizard`)
- Sincronizar skills upstream (requiere `bash scripts/update.sh`)
- Cualquier fix de Sinapsis instalación (deriva a `vendor/sinapsis/install.sh`)

## Notas operativas

- Esta skill NO debe pedir información personal ni cambiar configuración. Solo diagnostica y aplica fixes muy concretos.
- Output debe ser **rápido de leer** — usuario debe poder en 30s saber el estado general del OS.
- 🟡 NO bloquea uso, 🔴 SÍ bloquea uso — sé estricto con esta clasificación.
- Si el reporte tiene >5 🟡, considera generar HTML compartible vía `tool-visual-explainer` para que el usuario lo lea más cómodo.

# `_install-state.json` — schema y contrato

> State machine persistente que garantiza que iAmasters OS se instala completo, por fases, sin "instalaciones fantasma".
>
> Vive en `~/.claude/skills/_install-state.json`. Lo escriben varios componentes, lo leen otros tantos. Este documento es el contrato.

## Por qué existe

Antes (v0.5.x): la instalación era un script bash de un solo disparo + un wizard conversacional. Si algo fallaba a mitad (Python en Windows, compresión de contexto, usuario que se cansaba), el sistema no sabía qué fase había completado realmente. Resultado: el agente reportaba "todo instalado" cuando solo había creado archivos vacíos.

Desde v0.6: cada fase de instalación tiene un estado persistente verificable. Un hook `SessionStart` lee este estado y bloquea respuestas al usuario hasta que la instalación esté completa. La instalación es **reentrante**: si se rompe, `/install --resume` continúa desde la última fase exitosa.

## Ubicación

```
~/.claude/skills/_install-state.json
```

Lo crea `scripts/install.sh` al arrancar. Lo escriben varios componentes a lo largo del flujo. Lo lee el hook `_install-gate.sh` antes de cada sesión.

## Fases

| # | Fase | `required` | Lo escribe | Validación de "done" |
|---|---|---|---|---|
| 1 | `prereqs` | sí | `install.sh` | git ≥2.0 + claude code + node ≥18 |
| 2 | `sinapsis-engine` | sí | `install.sh` | operator-state.json válido + hooks ejecutables + ≥1 skill real |
| 3 | `context-files` | sí | `meta-onboarding-wizard` | 4 archivos creados en `context/` con contenido real |
| 4 | `operator-state` | sí | `meta-onboarding-wizard` | `needsOnboarding: false` + campos mínimos |
| 5 | `welcome-completed` | sí | `welcome-quick-win` | 1 deliverable en `projects/welcome/` |
| 6 | `deep-dive-completed` | no (deferrable) | `meta-deep-dive` | 22 dimensiones cubiertas en context/ |

**Regla:** la instalación se considera completa cuando todas las fases `required: true` están en `done`. La fase 6 es deferrable — el sistema funciona sin ella, solo te conoce más superficialmente.

## Estados por fase

| Estado | Significado |
|---|---|
| `pending` | No iniciada todavía |
| `in-progress` | Iniciada, no completada (puede tener checkpoint parcial) |
| `done` | Completada y validada externamente (no por declaración del agente) |
| `failed` | Intentada y falló (con detalle en `errors[]`) |
| `skipped` | Saltada por decisión explícita del usuario (solo válido en fases con `deferrable: true`) |

## Validación de "done" — no se fía del agente

Cada fase tiene una validación que NO consiste en "el agente dice que lo hizo". Son checks mecánicos:

**Fase 2 (`sinapsis-engine`)**:
```bash
# El validador comprueba TODO esto:
[ -f ~/.claude/skills/_operator-state.json ] && \
  jq empty ~/.claude/skills/_operator-state.json && \
  [ -x ~/.claude/skills/_passive-activator.sh ] && \
  [ -x ~/.claude/skills/_session-learner.sh ] && \
  [ -f ~/.claude/skills/_catalog.json ] && \
  jq empty ~/.claude/skills/_catalog.json && \
  [ "$(find ~/.claude/skills -name SKILL.md -maxdepth 3 | wc -l)" -gt 0 ]
```

Si falla alguno, la fase queda `failed` con detalle en `errors[]`. El hook `SessionStart` la detecta y guía recuperación.

**Fase 3 (`context-files`)**:
- Los 4 archivos existen
- Cada uno tiene ≥100 caracteres de contenido (no es plantilla vacía)
- El archivo `me.md` tiene `## Nombre` con valor real

**Fase 4 (`operator-state`)**:
- `_operator-state.json` parseable
- `needsOnboarding: false`
- `operator.name` no es null ni vacío
- `operator.language` está set

**Fase 5 (`welcome-completed`)**:
- Existe `projects/welcome/<fecha>-*/` con al menos un archivo

## Quién escribe qué (contrato)

**`install.sh`** (al ejecutar `bash scripts/install.sh`):
1. Crea el archivo si no existe (desde `scripts/_install-state.template.json`)
2. Setea `repoPath`, `startedAt`
3. Tras validar prereqs → `phases.prereqs.status = "done"`
4. Tras instalar Sinapsis y validar profundo → `phases.sinapsis-engine.status = "done"` con checksum
5. Si cualquiera falla → `failed` con detalle en `errors[]` y `exit 1`

**`meta-onboarding-wizard`** (skill):
- Después de la **fase 1 interna** (identidad+ubicación capturadas): escribe `context/me.md` y marca `filesCreated += ["context/me.md"]`
- Después de la **fase 2 interna** (negocio): escribe `context/work.md` y marca progreso
- Idem fase 3 y 4
- Al terminar las 4: `phases.context-files.status = "done"` + `phases.operator-state.status = "done"`
- Si el usuario abandona a mitad: marca `pausedBy: "user"`, `pausedAtPhase: <fase actual>`, deja `status: "in-progress"` con el `filesCreated` parcial

**`welcome-quick-win`** (skill):
- Tras generar el deliverable: `phases.welcome-completed.status = "done"` + `deliverablePath`

**`meta-deep-dive`** (skill):
- Tras cubrir las 22 dimensiones: `phases.deep-dive-completed.status = "done"`
- Si el usuario lo aplaza explícitamente: `status = "skipped"`

## Quién lee qué

**Hook `_install-gate.sh`** (SessionStart, ejecuta antes de que el modelo vea el primer mensaje):
- Lee el state
- Si alguna fase `required: true` no está en `done`, inyecta `additionalContext` al modelo:
  ```
  [INSTALL GATE] iAmasters OS installation incomplete: <N>/5 required phases done.
  Current phase: <currentPhase> (<status>).
  Before responding to the user, you MUST run /install --resume.
  Do not engage with other requests until installation is complete.
  ```

**Comando `/install`** y `/install --resume`:
- Lee state
- Si todo `done`: dice "ya instalado, no hago nada" y aborta
- Si hay fase en progreso: continúa donde se quedó
- Si hay fase fallida: muestra el error + sugiere fix

**Comando `/install-status`**:
- Lee state y muestra dashboard:
  ```
  📦 iAmasters OS · Installation status

  ✅ prereqs · done · 2026-05-15 10:00
  ✅ sinapsis-engine · done · checksum sha256:abc...
  🟡 context-files · in-progress · 1/4 files
  ⏳ operator-state · pending
  ⏳ welcome-completed · pending
  ⏭️  deep-dive-completed · deferrable

  Próximo paso: ejecuta /install --resume
  ```

**Skill `health-check`** (`/doctor`):
- Lee state como fuente de verdad sobre qué está instalado
- Si todo está `done` pero hay archivos faltantes en disco → drift detectado
- Si state dice `pending` pero archivos existen → re-validación profunda + actualizar state

**Skill `meta-start-here`**:
- Lee state al inicio
- Si incompleto: deriva a `/install --resume` (redundancia con el hook, por si el hook fallara)

## Edge cases

**Usuario reinstala desde cero**:
- Si `~/.claude/skills/_install-state.json` ya existe y todas las fases están `done`:
  - `install.sh` pregunta: ¿reinstalar? (`--force-reinstall` flag o prompt interactivo)
  - Si sí: hace backup del state actual a `_install-state.<timestamp>.json` y arranca fresco

**Usuario abre Claude Code en un repo iamasters-os distinto del que instaló**:
- El state tiene `repoPath`. Si no coincide con el actual:
  - El hook muestra: "Has cambiado de repo iAmasters OS. El anterior estaba en X. ¿Es intencionado? (`/install` para reconfigurar)"

**Compresión de contexto a mitad de wizard**:
- El state tiene el detalle del progreso parcial. La nueva sesión:
  1. Lee state
  2. Detecta `currentPhase: "context-files"` con `filesCreated: ["me.md"]`
  3. El hook inyecta: "Estabas en context-files, ya tienes me.md, te faltan work.md/current-priorities.md/goals.md. Retoma con /install --resume"

**Instalación corrupta** (archivos eliminados manualmente tras state `done`):
- `health-check` detecta drift (state dice done, archivos faltan)
- Marca la fase como `failed` con motivo y propone re-ejecutar

## Versionado del schema

`schemaVersion: 1` (v0.6.0). Si en el futuro cambia el contrato, se sube `schemaVersion` y `install.sh` migra estados antiguos al nuevo formato (función `migrate_state_v1_to_v2()`).

## Ejemplo completo de state (instalación a medias)

```json
{
  "version": "0.6.0",
  "schemaVersion": 1,
  "repoPath": "/home/user/iamasters-os",
  "startedAt": "2026-05-15T10:00:00Z",
  "lastUpdatedAt": "2026-05-15T10:08:42Z",
  "currentPhase": "context-files",
  "completedPhases": ["prereqs", "sinapsis-engine"],
  "phases": {
    "prereqs": {
      "status": "done",
      "required": true,
      "validatedAt": "2026-05-15T10:00:30Z",
      "checks": {
        "git": "2.43.0",
        "node": "v20.10.0",
        "python": "Python 3.11.7",
        "claude_code": "env-detected"
      },
      "warnings": [],
      "owner": "install.sh"
    },
    "sinapsis-engine": {
      "status": "done",
      "required": true,
      "validatedAt": "2026-05-15T10:01:15Z",
      "validation": {
        "operator_state_json_valid": true,
        "catalog_json_valid": true,
        "hooks_executable": true,
        "skills_count": 23
      },
      "checksum": "sha256:9a8b7c6d5e4f...",
      "owner": "install.sh"
    },
    "context-files": {
      "status": "in-progress",
      "required": true,
      "startedAt": "2026-05-15T10:05:12Z",
      "filesCreated": ["context/me.md"],
      "filesPending": [
        "context/work.md",
        "context/current-priorities.md",
        "context/goals.md"
      ],
      "owner": "meta-onboarding-wizard"
    },
    "operator-state": {
      "status": "pending",
      "required": true,
      "validatedAt": null,
      "fields": {},
      "owner": "meta-onboarding-wizard"
    },
    "welcome-completed": {
      "status": "pending",
      "required": true,
      "deliverablePath": null,
      "owner": "welcome-quick-win"
    },
    "deep-dive-completed": {
      "status": "pending",
      "required": false,
      "deferrable": true,
      "owner": "meta-deep-dive"
    }
  },
  "pausedBy": "user",
  "pausedAt": "2026-05-15T10:08:42Z",
  "pausedAtPhase": "context-files",
  "errors": []
}
```

Lectura: el usuario empezó la instalación, terminó prereqs y Sinapsis, abrió Claude Code, el wizard arrancó context-files, escribió `me.md`, el usuario dijo "para, vuelvo luego". La siguiente sesión, el hook leerá esto y forzará `/install --resume` que retoma desde `work.md`.

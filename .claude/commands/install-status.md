---
description: Dashboard del estado de instalación iAmasters OS. Lee ~/.claude/skills/_install-state.json y muestra qué fases están done, in-progress, failed o pending. Solo lectura — no modifica nada. Útil cuando el usuario duda de si la instalación está bien o quiere saber por qué algo no funciona.
---

# /install-status

Muestra el estado actual de la instalación. Read-only.

## Process

### Paso 1 · Leer state

Lee `~/.claude/skills/_install-state.json`. Si no existe:
> "iAmasters OS no está instalado en este sistema. Ejecuta desde terminal:
>
> ```bash
> bash scripts/install.sh
> ```"

Para.

### Paso 2 · Mostrar dashboard

Formato exacto:

```
📦 iAmasters OS · Installation status

Repo:        <repoPath>
Started:     <startedAt>
Last update: <lastUpdatedAt>
Schema:      v<schemaVersion>

Fases:
  <icon> prereqs            · <status>  <detail>
  <icon> sinapsis-engine    · <status>  <detail>
  <icon> context-files      · <status>  <detail>
  <icon> operator-state     · <status>  <detail>
  <icon> welcome-completed  · <status>  <detail>
  <icon> deep-dive-completed · <status>  <detail>  [opcional]

Required progress: <X>/5 done
```

Iconos por estado:
- `done` → ✅
- `in-progress` → 🟡
- `failed` → ❌
- `pending` → ⏳
- `skipped` → ⏭️

Detalles por fase:
- `prereqs`: muestra `checks` (versiones detectadas)
- `sinapsis-engine`: muestra `validation.skills_count` y los primeros 12 chars de checksum si lo hay
- `context-files`: muestra `filesCreated.length`/4 + lista breve si hay menos de 4
- `operator-state`: muestra si hay nombre y nivel técnico capturados
- `welcome-completed`: muestra `deliverablePath` si hay
- `deep-dive-completed`: muestra `(opcional, no bloqueante)`

### Paso 3 · Mostrar errores recientes

Si `errors[]` tiene contenido, lista los últimos 3:
```
⚠️  Últimos errores:
  - [<phase>] <message>  (<at>)
```

### Paso 4 · Acción recomendada

Al final, una línea con qué hacer ahora:

- Si todo `done` (5/5): "Todo en orden. Ejecuta `/start-here` para empezar el día."
- Si hay alguna `in-progress`: "Continúa con `/install --resume`."
- Si hay `failed`: "Resuelve el error y luego ejecuta `bash scripts/install.sh --resume`."
- Si hay solo `pending` después de `prereqs/sinapsis-engine` done: "Continúa el onboarding con `/install`."
- Si solo `deep-dive-completed` queda: "Las 5 fases obligatorias están hechas. Opcional: `/deep-dive` para profundizar."

### Paso 5 · Si el usuario pide HTML compartible

Si dice "házmelo en HTML" o "compártemelo", invoca `tool-visual-explainer` con el dashboard de arriba.

## Lo que NO haces

- ❌ Modificar el state file
- ❌ Ejecutar `install.sh`
- ❌ Invocar wizard ni otras skills
- ❌ Tomar acciones — solo informas

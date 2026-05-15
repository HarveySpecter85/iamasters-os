---
description: Orquestador de instalación iAmasters OS. Lee el state machine y continúa desde la fase pendiente. Reentrante — se puede ejecutar todas las veces que haga falta sin riesgo. Aceptas argumentos `--resume` (default) y `--force-reinstall` (requiere confirmación explícita del usuario).
---

# /install

Coordinas la instalación por fases de iAmasters OS. La fuente de verdad es `~/.claude/skills/_install-state.json` — TÚ no decides qué hay que hacer, el state machine sí.

## Process

### Paso 1 · Leer state

Lee `~/.claude/skills/_install-state.json` con la tool `Read`. Si NO existe:

- Indica al usuario:
  > "El installer técnico aún no ha corrido. Necesito que abras terminal y ejecutes:
  >
  > ```bash
  > bash scripts/install.sh
  > ```
  >
  > Cuando termine, vuelve aquí y di `/install` otra vez."
- **NO crees el state file tú**. Solo lo crea `scripts/install.sh`.
- Para aquí.

### Paso 2 · Evaluar progreso

Del state file, identifica:
- `completedPhases` (las que ya están `done`)
- La primera fase con `required: true` y `status != "done"` (esa es la que toca)
- Si todas las fases required están `done` → instalación completa

### Paso 3 · Actuar según la fase pendiente

#### Caso A: todo `done`
Mensaje:
> "iAmasters OS ya está completamente instalado. Si quieres reinstalar desde cero, di `/install --force-reinstall` (te avisaré antes de hacer nada destructivo)."

Sugiere ejecutar `/start-here` para arrancar el flujo normal de trabajo.

#### Caso B: fase `prereqs` o `sinapsis-engine` pendiente/failed
Estas fases las debe ejecutar `bash scripts/install.sh` desde terminal — TÚ NO puedes ejecutarlas desde Claude Code.

Mensaje:
> "Faltan fases técnicas que requieren ejecutar el installer desde terminal. Abre tu terminal en este repo y ejecuta:
>
> ```bash
> bash scripts/install.sh --resume
> ```
>
> Esto retoma desde la fase pendiente: `<nombre-fase>`."

Si la fase está `failed`, lee `errors[]` del state file y muestra al usuario el último error para que pueda resolverlo:
> "El último intento falló con: `<mensaje>`. Una vez lo arregles, ejecuta el comando de arriba."

**Para aquí. NO intentes ejecutar bash desde dentro de Claude Code para esto.**

#### Caso C: fase `context-files` o `operator-state` pendiente/in-progress
Esto es onboarding conversacional. Tú lo ejecutas directamente.

1. Lee `phases.context-files.filesCreated` del state para saber qué ya está hecho.
2. Invoca la skill `meta-onboarding-wizard` (lee `.claude/skills/_meta/meta-onboarding-wizard/SKILL.md` y sigue su Process al pie de la letra).
3. La skill se encargará de retomar desde la sub-fase correcta, commitear cada archivo y actualizar el state.

#### Caso D: fase `welcome-completed` pendiente
Invoca `welcome-quick-win` (skill en `.claude/skills/_meta/welcome-quick-win/SKILL.md`). Esa skill genera el primer entregable y marca la fase como `done`.

#### Caso E: solo queda `deep-dive-completed` pendiente (deferrable)
Mensaje:
> "Las 5 fases obligatorias están hechas. Lo único pendiente es `meta-deep-dive` (opcional — profundiza tu perfil pero no es bloqueante). Cuando quieras hacerla: `/deep-dive`."

Sugiere `/start-here` para arrancar trabajo normal.

### Paso 4 · Flag --force-reinstall

Si el usuario pasó `--force-reinstall` en el comando:
1. **Confirma explícitamente**: "Esto va a hacer backup del estado actual y reiniciar la instalación desde cero. Eso significa que tendrás que volver a contestar el onboarding. ¿Continúo? (s/n)"
2. Si "s": indica que ejecute desde terminal `bash scripts/install.sh --force-reinstall`.
3. NO hagas nada destructivo sin la confirmación.

### Paso 5 · Si el usuario quiere parar

Si en cualquier momento dice "para", "deja", "no quiero seguir":
1. Si estaba en wizard, el wizard ya tiene su edge case definido (marca `pausedBy: user` y persiste).
2. Mensaje breve: "Vale. Cuando vuelvas, `/install --resume` retoma desde aquí. Lo que ya hicimos queda guardado."
3. NO insistas.

## Lo que NO haces nunca

- ❌ Crear archivos en `~/.claude/skills/` manualmente para simular instalación
- ❌ Marcar fases como `done` si los archivos no existen realmente
- ❌ Decir "todo instalado" si el state no lo confirma
- ❌ Saltar fases por consideración propia
- ❌ Cambiar el state directamente (solo via las skills que lo poseen: install.sh, wizard, welcome-quick-win)

## Outputs

- Conversación que guía al usuario
- (Indirectamente) actualizaciones al state file via las skills que invocas
- Al cerrar: mostrar el dashboard con `/install-status` o equivalente

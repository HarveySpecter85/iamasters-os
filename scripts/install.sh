#!/bin/bash
# ============================================================
#  iAmasters OS — Installer for macOS / Linux
#  Sistema operativo agéntico para operadores de IA
#  https://github.com/iamasters/iamasters-os
# ============================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SINAPSIS_VENDOR="$REPO_ROOT/vendor/sinapsis"
CLAUDE_HOME="$HOME/.claude"

echo ""
echo -e "${PURPLE}${BOLD}============================================================${NC}"
echo -e "${PURPLE}${BOLD}  iAmasters OS — Sistema Operativo Agéntico${NC}"
echo -e "${PURPLE}${BOLD}  Sinapsis (engine) + capa OS (skills, brand context)${NC}"
echo -e "${PURPLE}${BOLD}============================================================${NC}"
echo ""

# ── Step 1: Prerequisites ──
echo -e "${BLUE}[1/6]${NC} Comprobando prerequisitos..."

if ! command -v claude &> /dev/null; then
    echo -e "${RED}  ERROR${NC} Claude Code no encontrado en PATH"
    echo -e "${RED}         Instálalo primero: https://claude.ai/code${NC}"
    exit 1
else
    echo -e "${GREEN}  OK${NC} Claude Code detectado"
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}  ERROR${NC} Node.js no encontrado. Instálalo: https://nodejs.org${NC}"
    exit 1
else
    echo -e "${GREEN}  OK${NC} Node.js $(node --version) detectado"
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}  ! Python 3 no encontrado — algunos hooks Sinapsis se desactivarán${NC}"
else
    echo -e "${GREEN}  OK${NC} $(python3 --version) detectado"
fi

if ! command -v git &> /dev/null; then
    echo -e "${RED}  ERROR${NC} Git no encontrado. Es imprescindible.${NC}"
    exit 1
else
    echo -e "${GREEN}  OK${NC} $(git --version) detectado"
fi

# ── Step 2: Detect Sinapsis state ──
echo -e "${BLUE}[2/6]${NC} Comprobando Sinapsis (engine de memoria)..."

SINAPSIS_INSTALLED=false
if [ -f "$CLAUDE_HOME/skills/_catalog.json" ]; then
    SINAPSIS_INSTALLED=true
    echo -e "${GREEN}  OK${NC} Sinapsis ya instalado en $CLAUDE_HOME/skills/"
else
    echo -e "${CYAN}  ->  Sinapsis no detectado — se instalará desde vendor/${NC}"
fi

# ── Step 3: Install Sinapsis if needed ──
echo -e "${BLUE}[3/6]${NC} Instalando Sinapsis..."

if $SINAPSIS_INSTALLED; then
    echo -e "${YELLOW}  ! Sinapsis ya estaba instalado. Saltando instalación de engine.${NC}"
    echo -e "${YELLOW}    Si quieres actualizar: cd vendor/sinapsis && bash install.sh${NC}"
else
    if [ ! -f "$SINAPSIS_VENDOR/install.sh" ]; then
        echo -e "${RED}  ERROR${NC} vendor/sinapsis/install.sh no encontrado."
        echo -e "${RED}         El repo no está completo — clónalo de nuevo.${NC}"
        exit 1
    fi
    echo -e "${CYAN}  ->  Ejecutando vendor/sinapsis/install.sh${NC}"
    cd "$SINAPSIS_VENDOR"
    bash install.sh
    cd "$REPO_ROOT"
    echo -e "${GREEN}  OK${NC} Sinapsis instalado"
fi

# ── Step 4: Initialize OS layer ──
echo -e "${BLUE}[4/6]${NC} Inicializando capa OS..."

# Crear placeholders en carpetas vacías para que git las trackee
for empty_dir in "projects" "projects/briefs" "context" "brand-context/voice" "brand-context/positioning" "brand-context/icp" "brand-context/assets"; do
    touch "$REPO_ROOT/$empty_dir/.gitkeep" 2>/dev/null || true
done

# Soul.md y user.md base si no existen
if [ ! -f "$REPO_ROOT/context/soul.md" ]; then
    cat > "$REPO_ROOT/context/soul.md" <<'EOF'
# Soul — personalidad del agente

> Esta es la personalidad base del agente. La modificas tú a tu gusto.
> Se complementa con tu operator-state.json (Sinapsis) y tu user.md.

## Cómo respondes
- Directo y sin rodeos. Si algo no tiene sentido, lo dices.
- 2-3 opciones máximo con recomendación. El usuario tiene la última palabra.
- No complaciente. Honesto sobre limitaciones y riesgos.
- Tono cálido, no corporativo.

## Cómo razonas
- Antes de actuar, planificas. Plan mode por defecto en proyectos > 10 min.
- Validación humana antes de acciones destructivas (delete, push, send).
- Si pierdes contexto, pides aclaración en lugar de inventar.

## Boundaries
- Nunca commiteas .env ni credenciales.
- Nunca envías mensajes externos (email, WhatsApp, Slack) sin aprobación explícita.
- Nunca borras archivos: archivar siempre.

## Continuidad
- Siempre lees brand-context/ antes de generar contenido entregable.
- Siempre lees context/learnings.md antes de invocar una skill ya conocida.
- Siempre cierras sesión con /wrap-up para que mañana retomes el hilo.
EOF
    echo -e "${GREEN}  OK${NC} context/soul.md creado"
fi

if [ ! -f "$REPO_ROOT/context/user.md" ]; then
    cat > "$REPO_ROOT/context/user.md" <<'EOF'
# User — perfil del operador en este repo

> Este archivo se rellena durante el onboarding (skill meta-onboarding-wizard).
> Sinapsis mantiene el perfil global en ~/.claude/skills/_operator-state.json;
> este es solo el contexto específico del repo (preferencias visuales, ejemplos,
> conexiones a apps, etc).

## Identidad básica (rellenar en onboarding)
- Nombre:
- Rol:
- Avatar: (single business / freelance multi-cliente / agencia)
- Idioma operativo: castellano
- Email contacto:

## Stack que uso a menudo
- Frontend:
- Backend:
- Deploy:
- CRM/automatización:
- Apps de productividad:

## Mis valores innegociables
-
-
-

## Mis cuellos de botella habituales
-
-

## Apps externas conectadas (MCPs activos)
-

## Notas adicionales
EOF
    echo -e "${GREEN}  OK${NC} context/user.md creado"
fi

if [ ! -f "$REPO_ROOT/context/learnings.md" ]; then
    cat > "$REPO_ROOT/context/learnings.md" <<'EOF'
# Learnings — feedback consolidado de skills

> Este archivo lo auto-mantiene la skill meta-wrap-up al cerrar sesión.
> Es el resumen humano-legible de lo que vive en synapsis instincts (estructurado).

## General
*(vacío hasta que ejecutes skills y cierres sesiones)*

## Por skill

<!-- Las entradas se añaden por skill en formato:
## skill-name
- 2026-MM-DD: lección aprendida
-->
EOF
    echo -e "${GREEN}  OK${NC} context/learnings.md creado"
fi

echo -e "${GREEN}  OK${NC} Capa OS inicializada"

# ── Step 5: Hook script for skill change detection ──
echo -e "${BLUE}[5/6]${NC} Instalando hook local del OS..."

cat > "$REPO_ROOT/scripts/skill-change-detector.sh" <<'HOOKSCRIPT'
#!/bin/bash
# Detecta cambios en .claude/skills/ y los flagea en synapsis-pending.json
# para que /wrap-up actualice el registry del CLAUDE.md.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PENDING_FILE="$REPO_ROOT/.claude/.skills-pending.json"

# Lee tool input via stdin
INPUT=$(cat 2>/dev/null || echo "{}")

# Solo actuamos si la edición fue en .claude/skills/
if echo "$INPUT" | grep -q '"file_path".*\.claude/skills/'; then
    mkdir -p "$REPO_ROOT/.claude"
    echo "{\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"changed\":true}" > "$PENDING_FILE"
fi
exit 0
HOOKSCRIPT

chmod +x "$REPO_ROOT/scripts/skill-change-detector.sh"
echo -e "${GREEN}  OK${NC} Hook scripts/skill-change-detector.sh instalado"

# ── Step 6: Final check ──
echo -e "${BLUE}[6/6]${NC} Verificando instalación..."

ISSUES=0
[ ! -d "$CLAUDE_HOME/skills" ] && ISSUES=$((ISSUES+1)) && echo -e "${RED}  ! Sinapsis no se instaló correctamente${NC}"
[ ! -f "$REPO_ROOT/CLAUDE.md" ] && ISSUES=$((ISSUES+1)) && echo -e "${RED}  ! CLAUDE.md no existe${NC}"
[ ! -f "$REPO_ROOT/.claude/settings.json" ] && ISSUES=$((ISSUES+1)) && echo -e "${RED}  ! settings.json no existe${NC}"

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}  OK${NC} Todo en orden"
fi

# ── Done ──
echo ""
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo -e "${GREEN}${BOLD}  iAmasters OS instalado correctamente${NC}"
echo -e "${GREEN}${BOLD}============================================================${NC}"
echo ""
echo -e "  ${BOLD}Siguiente paso:${NC}"
echo -e "  1. Asegúrate de estar en este repo: ${CYAN}cd $REPO_ROOT${NC}"
echo -e "  2. Arranca Claude Code: ${CYAN}claude${NC}"
echo -e "  3. La primera vez se ejecutará el onboarding wizard automáticamente"
echo ""
echo -e "  ${BOLD}Comandos útiles:${NC}"
echo -e "  ${CYAN}/start-here${NC}      — Ritual de inicio de sesión"
echo -e "  ${CYAN}/wrap-up${NC}         — Cierre de sesión + commit"
echo -e "  ${CYAN}/system-status${NC}   — Dashboard Sinapsis (engine)"
echo -e "  ${CYAN}/add-client${NC}      — Crear cliente nuevo"
echo ""
echo -e "  ${BOLD}Documentación:${NC}"
echo -e "  - README.md         — Visión general"
echo -e "  - CLAUDE.md         — Instrucciones para Claude (núcleo del repo)"
echo -e "  - docs/             — Guías de operación"
echo ""
echo -e "${PURPLE}  El OS aprende de ti. Cada sesión alimenta la siguiente.${NC}"
echo ""

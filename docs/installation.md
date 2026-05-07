# Instalación de iAmasters OS

## Prerequisitos

- **Claude Code CLI** instalado y autenticado con plan Pro o Max → https://claude.ai/code
- **Node.js 18+** → https://nodejs.org
- **Python 3.9+** → https://python.org (para hooks Sinapsis)
- **Git** → https://git-scm.com

## Instalación rápida

```bash
git clone <url-repo> iamasters-os
cd iamasters-os
bash scripts/install.sh
```

El instalador:

1. Comprueba prerequisitos
2. Detecta si Sinapsis está instalado en `~/.claude/`. Si no → instala desde `vendor/sinapsis/`
3. Configura hooks de Sinapsis en `~/.claude/settings.json` (4 PreToolUse + 1 PostToolUse + 1 Stop + 1 PreCompact)
4. Inicializa la capa OS dentro del repo: crea `context/soul.md`, `context/user.md`, `context/learnings.md` con plantillas
5. Instala el hook local del OS: `scripts/skill-change-detector.sh`

Tiempo total: ~30 segundos.

## Primer arranque

```bash
cd iamasters-os
claude
```

La primera vez, Claude Code:

1. Lee `CLAUDE.md` raíz del repo
2. Detecta que es primer arranque (operator-state vacío)
3. Invoca automáticamente la skill `meta-onboarding-wizard`
4. Te pregunta avatar/nivel/dominio/stack en 7 preguntas (~3 min)
5. Configura defaults inteligentes
6. Te propone hacer el brand-voice setup (~5-10 min con tu web/LinkedIn)

Tras esto, ya puedes trabajar normalmente.

## Verificación

Para confirmar que todo está bien:

```bash
ls ~/.claude/skills/         # Sinapsis instalado: deberías ver _catalog.json, etc.
ls -la                        # Repo: CLAUDE.md, .claude/, brand-context/, etc.
```

Dentro de Claude Code:

```
/system-status     # dashboard Sinapsis (engine)
/start-here        # ritual de inicio del OS
```

## Troubleshooting

### "Sinapsis no se instaló correctamente"
- Comprueba que `vendor/sinapsis/` existe y no está vacío
- Ejecuta manualmente: `cd vendor/sinapsis && bash install.sh`

### "Claude Code no encontrado"
- Asegúrate de que `claude` está en tu `$PATH`
- Reinstalar: https://claude.ai/code

### "Permission denied" en scripts
- `chmod +x scripts/*.sh`

### Onboarding no se lanza al abrir Claude Code
- Comprueba `~/.claude/skills/_operator-state.json` — si tiene `needsOnboarding: true` y aun así no se lanza, lee CLAUDE.md raíz para verificar que la sección "MANDATORY first action" está intacta.

## Update a versión nueva

```bash
cd iamasters-os
git pull
bash scripts/update.sh    # (en v0.3.0+)
```

`update.sh` maneja conflictos cuando upstream e local han modificado los mismos archivos. Lo verás detallado en v0.3.0.

## Desinstalación

```bash
# Backup primero
cp -r ~/.claude ~/.claude.backup

# Eliminar Sinapsis (opcional - puede que lo uses en otros repos)
rm -rf ~/.claude/skills/_*
rm -rf ~/.claude/skills/sinapsis-*
rm -rf ~/.claude/skills/skill-router

# Eliminar el repo (¡cuidado: borra brand-context y projects!)
# Mejor: simplemente no lo uses más
rm -rf iamasters-os
```

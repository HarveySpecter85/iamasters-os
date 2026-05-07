# AGENTS.md — Compatibilidad cross-tool

> Este archivo permite que herramientas distintas a Claude Code (Codex, Cursor, etc.) lean las mismas instrucciones.

Para Claude Code, el archivo principal es [`CLAUDE.md`](CLAUDE.md). Léelo primero.

## Resumen para agentes no-Claude

Este repositorio es **iAmasters OS**, un sistema operativo agéntico que combina:
- **Sinapsis v4.5** (memoria persistente entre sesiones) — vendored en `vendor/sinapsis/`
- **Capa OS** (brand-context, agent-context, skills curadas, multi-cliente)

### Si tu agente NO es Claude Code

1. **No ejecutes los hooks de Sinapsis** — están en `~/.claude/settings.json` y son específicos de Claude Code
2. **Sí puedes usar las skills** que viven en `.claude/skills/<categoria>/<nombre>/SKILL.md` — son markdown estándar
3. **Sí puedes leer brand-context y context** — son markdown plain
4. **Skills format**: cada skill tiene `SKILL.md` con YAML frontmatter (name, description) seguido de instrucciones
5. **Comandos**: viven en `.claude/commands/<nombre>.md` y son slash commands de Claude Code; otros agentes los pueden leer como referencia

### Variables clave

- Idioma operativo: castellano
- Estilo: directo, sin rodeos, 2-3 opciones máx con recomendación
- Validación humana siempre antes de acciones destructivas
- Nunca commitear `.env`, credentials, secretos

### Estructura mínima a respetar

```
.claude/skills/<categoria>/<nombre>/SKILL.md
brand-context/voice/voice-profile.md
brand-context/positioning/positioning.md
brand-context/icp/icp.md
context/soul.md
context/user.md
context/learnings.md
projects/briefs/<nombre>/brief.md
clients/<nombre>/{brand-context,context,projects}
```

### Cómo invocar una skill (genérico)

1. Lee `.claude/skills/<categoria>/<nombre>/SKILL.md`
2. Sigue las instrucciones del bloque "Process" o "Steps"
3. Si la skill referencia archivos en `references/`, léelos solo cuando los pidan los pasos
4. Si la skill referencia otra skill (skill-to-skill), invoca esa skill y luego continúa

### Compatibilidad probada

- ✅ **Claude Code** (entorno principal, todos los hooks Sinapsis activos)
- 🟡 **Codex (OpenAI)** — skills funcionan, hooks Sinapsis no aplican
- 🟡 **Cursor** — skills funcionan como prompts, no hay integración directa
- ❌ **Antigravity / Other** — no probado

Para soporte cross-tool más profundo, abre un issue en el repo.

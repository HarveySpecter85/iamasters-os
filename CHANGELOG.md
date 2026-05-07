# Changelog

Todos los cambios notables a iAmasters OS se documentan aquí.

Formato basado en [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [Unreleased]

### En construcción para v0.1.0
- Esqueleto del repo con Sinapsis vendored
- 4 meta-skills: skill-creator, onboarding-wizard, start-here, wrap-up
- Estructura brand-context, context, projects, clients
- 4 templates de cliente vertical (vacíos en v0.1.0, llenos en v0.3.0)
- install.sh inicial

---

## v0.1.0 — esqueleto + Sinapsis (planeado)

**Objetivo**: repo clonable que instale Sinapsis y deje preparada la capa OS para construir encima.

### Added
- Estructura completa de carpetas
- Sinapsis v4.5 vendored en `vendor/sinapsis/`
- `install.sh` que delega a Sinapsis y luego inicializa capa OS
- README, CLAUDE.md, AGENTS.md, LICENSE, .gitignore, .env.example
- Meta-skills v0: `meta-skill-creator`, `meta-onboarding-wizard`, `meta-start-here`, `meta-wrap-up`
- Plantillas vacías de brand-context y context

---

## Versionado de Sinapsis vendored

| iAmasters OS | Sinapsis vendored |
|---|---|
| v0.1.0 | v4.5.0 |

Cuando Sinapsis publique nueva versión upstream, se actualiza vendor con un commit dedicado.

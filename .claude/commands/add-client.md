---
description: Crea cliente nuevo desde template vertical o vacío. Multi-cliente del OS.
---

# /add-client

Crea un nuevo cliente en `clients/<nombre>/` con su propio brand-context, context y projects.

## Process

1. Pregunta nombre del cliente (kebab-case): ej. `acme-corp`
2. Pregunta vertical (si quieres template):
   - `freelance-ia` — operador IA solo
   - `agencia-marketing` — pequeña agencia
   - `formador-online` — coach/educador
   - `consultoria-b2b` — consultor B2B
   - `vacio` — empezar desde cero
3. Ejecuta: `bash scripts/add-client.sh <nombre> <vertical>`
4. Output: estructura creada en `clients/<nombre>/`

## Notas

- El cliente hereda `CLAUDE.md` raíz del repo (aplica a todos por defecto)
- Puedes añadir `clients/<nombre>/CLAUDE.md` con overrides específicos
- Las skills se copian del root al cliente; no se heredan, sí se sincronizan en `bash scripts/update.sh`
- `cd clients/<nombre> && claude` para trabajar dentro del workspace del cliente

## Implementación

> En v0.1.0 este comando es un wrapper a `bash scripts/add-client.sh`.
> En v0.3.0 se integra con templates rellenos de los 4 verticales.

```
bash scripts/add-client.sh
```

Si `scripts/add-client.sh` no existe aún, créalo con plantilla mínima (solo crea estructura de carpetas + `.gitkeep`).

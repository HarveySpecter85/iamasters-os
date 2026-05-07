# Templates de cliente vertical

> En v0.1.0 los templates están vacíos (solo .gitkeep). Se rellenan en v0.3.0.

## Verticales planificados

1. **freelance-ia** — operador IA solo, sirve a múltiples clientes desde su laptop
2. **agencia-marketing** — agencia pequeña 2-10 personas, especializada en marketing/contenido
3. **formador-online** — coach o educador que vende cursos/comunidad
4. **consultoria-b2b** — consultor B2B (estrategia, ops, transformación)

## Qué traerá cada template

```
clients/_templates/<vertical>/
├── brand-context/
│   ├── voice/voice-profile.md          # Tono típico del vertical
│   ├── positioning/positioning.md      # Ángulos comunes
│   └── icp/icp.md                      # Cliente ideal del vertical
├── context/
│   ├── soul.md                         # Personalidad ajustada
│   └── user.md                         # Plantilla con campos típicos
└── projects/
    └── (vacío)
```

## Cómo se usa

```bash
bash scripts/add-client.sh <nombre-cliente> <vertical>
```

Esto clona el template del vertical seleccionado a `clients/<nombre-cliente>/` y deja al operador rellenar lo específico (nombre del cliente, web, etc.).

## Contribuir nuevos verticales

1. Crear `clients/_templates/<nombre-vertical>/`
2. Seguir la estructura estándar
3. Pull request con la justificación del vertical (qué tipo de operador lo necesita)

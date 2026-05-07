# Brand Context

Capa estática de la marca del operador. Se rellena durante el onboarding (skill `marketing-brand-voice`).

## Estructura

- `voice/voice-profile.md` — descripción de la voz (tono, vocabulario, no-go)
- `voice/samples.md` — frases representativas extraídas
- `voice/register-a-formal.md` — registro formal (email cliente premium)
- `voice/register-b-divulgativo.md` — registro divulgativo (LinkedIn, blog)
- `voice/register-c-cercano.md` — registro cercano (WhatsApp, comunidad)
- `positioning/positioning.md` — ángulo, mercado, diferencial
- `icp/icp.md` — perfil cliente ideal: dolor, lenguaje, buying triggers
- `assets/` — logos, colores, fuentes (auto-extraído por Firecrawl si está disponible)

## Cuándo se actualiza

- En el onboarding inicial → genera todo desde cero con interview + Firecrawl
- Cuando cambia tu posicionamiento → re-ejecuta `marketing-positioning`
- Cuando refinas voice tras feedback → edita `voice-profile.md` directamente o re-ejecuta `marketing-brand-voice` con flag `refine: true`

## Importante

Este folder está en `.gitignore` por defecto (sus archivos rellenados son privados del operador). Los archivos `.gitkeep` y este README sí se commitean.

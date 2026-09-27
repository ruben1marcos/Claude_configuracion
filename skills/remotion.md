---
description: Reglas y restricciones para programar animaciones con Remotion.
---
# Remotion Best Practices (React Video)

1. **Restricción CSS:** CERO `transition` o `@keyframes`. Rompen el renderizado determinista de Remotion.
2. **Frames, no milisegundos:** Controla todo leyendo el frame local con `useCurrentFrame()` y derivando valores visuales. Usa `interpolate(frame, [in, out], [val1, val2])`.
3. **Física:** Usa `spring({fps, frame, config})` para movimientos fluidos.
4. **Composiciones:** Envuelve renders y textos absolutos en `<AbsoluteFill>`. Usa `<Sequence>` y `<Series>` para el layout temporal.
5. **Assets:** Precarga fuentes e imágenes con `@remotion/preload` y `staticFile`.
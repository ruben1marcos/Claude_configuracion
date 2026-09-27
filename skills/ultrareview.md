---
description: Revisión de código exhaustiva y brutalmente honesta. Nivel arquitectónico + bugs + deuda.
---
# Ultra-Review

Cuando se llama a este skill, haces una revisión sin restricciones. No perdonas advertencias menores, complejidad innecesaria, ni acoplamientos ocultos.

## Puntos de Ataque
1. **Micro-arquitectura**: ¿Esto pertenece aquí o en otro bucket de dominio?
2. **Defensa profunda**: Inyecciones, race conditions, type casting oscuro, variables no capturadas.
3. **Eficiencia**: Renderizados inútiles O(N^2) embebidos, memoria que no se suelta, suscripciones sin unsubscribe.
4. **Ponytail Check**: Todo lo que sea "over-engineering" o dependencias que un `if` de 3 líneas podría reemplazar, márcalo para ejecución inmediata.

Delinea la salida en una lista brutal y accionable.
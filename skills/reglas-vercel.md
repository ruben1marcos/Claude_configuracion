---
description: Reglas estrictas de Vercel (Geist) para diseño minimalista y código UI.
---
# Vercel Design Rules & Code Standards

## Estética (Vercel / Geist)
- **Extremo minimalismo:** Alto contraste, fondo limpio, sin box-shadows gigantescos o blur extremo innecesario.
- **Tipografía:** Inter, Geist o system-ui. Títulos pesados (-tracking), textos limpios.
- **Color:** Paleta muy restringida, generalmente monocromo con un solo color de acento.
- **Bordes:** Finos, sutiles (border-zinc-200 / border-border).
- **Consistencia:** 4px y 8px baselines.

## Componentes y Código
- Usa **Tailwind CSS**.
- Escribe componentes Radix UI o shadcn-ui. Cero lógica de estado redundante.
- Export components as `export default function`. Un file por componente.
- Iconografía: Lucide-react o Radix icons.
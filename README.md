# 🚀 Configuración y Sincronización de Claude Code

Este repositorio contiene la suite completa de personalización, automatización, skills personalizadas y herramientas para **Claude Code** y **OmniRoute**.

Permite sincronizar y configurar cualquier PC nuevo en menos de **2 minutos**.

---

## 📁 Estructura del Repositorio

```text
Configuracion_claude/
├── README.md
├── skills/                      # Archivos .md de las skills de Claude Code
│   ├── agent-browser.md         # Navegación y pruebas web autónomas
│   ├── humanized.md             # Respuestas naturales y sin tono corporativo
│   ├── mcp-builder.md           # Creación de servidores Model Context Protocol
│   ├── prompt-designer.md       # Ingeniería y diseño de prompts
│   ├── reglas-vercel.md         # Estándares y optimizaciones para Vercel/Next.js
│   ├── remotion.md              # Creación de videos con React y Remotion
│   ├── skill-creator.md         # Generador de nuevas habilidades para Claude
│   ├── stop-slop.md             # Filtro anti-código redundante y explicaciones innecesarias
│   └── ultrareview.md           # Revisión implacable de código y arquitectura
├── scripts/                     # Scripts de automatización en PowerShell y VBS
│   ├── instalar-skills-en-claude.ps1            # Copia las skills a ~/.claude/skills
│   ├── instalar-automatizacion-powershell.ps1   # Inyecta la función 'claude' en $PROFILE
│   └── iniciar-omniroute-silencioso.vbs         # Lanza OmniRoute en segundo plano sin consola
└── plugins-and-mcp/             # Configuración y guía de plugins
    └── plugins.md               # Resumen de Superpowers, GSD, Context-Mode, Claude-Mem
```

---

## ⚡ Instalación Rápida en una Nueva PC

### Paso 1: Clonar el repositorio
Abre una terminal PowerShell y clona el proyecto en tu carpeta de documentos:
```powershell
mkdir -p "$HOME\Documents\Claude"
cd "$HOME\Documents\Claude"
git clone <URL-DE-TU-REPOSITORIO> Configuracion_claude
cd Configuracion_claude
```

### Paso 2: Instalar herramientas base
Asegúrate de tener instalados Node.js, Claude Code y OmniRoute:
```powershell
npm install -g @anthropic-ai/claude-code
npm install -g omniroute
npm install -g context-mode
```

### Paso 3: Instalar las Skills
Ejecuta el script para copiar todas las skills a la ubicación oficial de Claude Code (`~/.claude/skills`):
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\instalar-skills-en-claude.ps1
```

### Paso 4: Configurar la Automatización "Cero Fricción"
Para que al escribir `claude` en cualquier terminal se inicie OmniRoute automáticamente si está apagado:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\instalar-automatizacion-powershell.ps1
```

*(Opcional - Inicio automático con Windows):*
Copia el archivo `scripts\iniciar-omniroute-silencioso.vbs` a tu carpeta de inicio (`Win + R` -> `shell:startup`).

---

## 🛠️ Skills y Funciones Incluidas

| Skill / Herramienta | Comando / Activación | Propósito |
| :--- | :--- | :--- |
| **Skill Creator** | `/skill-creator` | Diseña y empaqueta nuevas skills con formato estándar |
| **Superpowers** | `/superpowers` | Flujos de TDD, brainstorming y debugging sistemático |
| **GSD (Get Stuff Done)** | `/gsd` | Planificación y ejecución ágil por fases |
| **Ultra-Review** | `/ultrareview` | Auditoría de arquitectura, seguridad y rendimiento |
| **Context-Mode** | Integrado / MCP | Optimización extrema del contexto |
| **Claude-Mem** | `localhost:37777` | Memoria persistente a largo plazo entre sesiones |
| **Agent Browser** | `/agent-browser` | Automatización de navegador y pruebas E2E |
| **MCP Builder** | `/mcp-builder` | Generación rápida de servidores MCP |
| **Prompt Designer** | `/prompt-designer` | Arquitectura de prompts con variables y XML tags |
| **Reglas Vercel** | `/reglas-vercel` | Buenas prácticas de Next.js, Edge Runtime y Vercel |
| **Humanized** | `/humanized` | Redacción natural sin clichés de IA |
| **Stop Slop** | `/stop-slop` | Elimina código defensivo innecesario y sobre-ingeniería |
| **Remotion** | `/remotion` | Creación de video programático con React |

---

## 🔐 Manejo de Claves API
OmniRoute administra tus credenciales de forma local y centralizada en `~/.omniroute`. Ya no es necesario ingresar la clave API en cada sesión ni exportar variables de entorno manualmente.

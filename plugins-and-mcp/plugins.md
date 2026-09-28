# Plugins y Extensiones de Claude Code

Este documento contiene la lista y comandos de instalación de todos los plugins y MCPs configurados en este entorno.

---

## 1. Context-Mode
Optimiza el uso de la ventana de contexto de Claude ejecutando búsquedas y comandos en un sandbox local.
- **Instalación:**
  ```powershell
  npm install -g context-mode
  ```

---

## 2. Claude-Mem
Sistema de memoria persistente a largo plazo que aprende decisiones, patrones y arquitectura de proyectos.
- **Dashboard web:** `http://localhost:37777`
- **Comandos útiles:**
  - `/learn-codebase`: Indexa el proyecto completo en memoria.

---

## 3. Superpowers
Framework de habilidades y flujos de trabajo avanzados para Claude Code (brainstorming, debugging sistemático, TDD).
- Ubicado e integrado directamente en el sistema de skills.

---

## 4. GSD (Get Stuff Done)
Herramientas avanzadas de ejecución por fases, planificación de arquitectura, revisión de código y testing automatizado.

---

## 5. OmniRoute
Enrutador inteligente local con fallback automático y soporte multi-modelo para Claude Code.
- **Instalación global:**
  ```powershell
  npm install -g omniroute
  ```
- **Panel Web / Dashboard:** `http://localhost:20128`
- **Configuración de autenticación local (`~/.omniroute/.env`):**
  ```dotenv
  REQUIRE_API_KEY=false
  ```
  *(Permite compatibilidad con las cabeceras `x-api-key` del SDK nativo de Anthropic).*
- **Comandos clave:**
  - `omniroute serve`: Inicia el servidor proxy local.
  - `claude`: Inicia Claude Code directamente mediante la función automatizada de PowerShell (evita los problemas del wrapper `omniroute launch`).
- **Selección de modelos con prefijo de enrutador:**
  - En la terminal de Claude: `/model auto/claude-sonnet` (o `dva/claude-sonnet-5`). Evita el error *400 Ambiguous model*.

# 📋 Reporte de Integración: Claude Code + OmniRoute

Este documento recopila los problemas conocidos, causas raíz técnicas, soluciones temporales (*workarounds*) y la automatización implementada en este repositorio para integrar **Claude Code** con el proxy local **OmniRoute**.

---

## 🐛 Problemas Identificados y Soluciones

### Bug 1: Incompatibilidad de Cabeceras de Autenticación (Error 401)
* **Descripción:** Claude Code utiliza internamente el SDK oficial de Anthropic, inyectando la API Key en la cabecera HTTP `x-api-key`. Sin embargo, OmniRoute (al operar como un proxy compatible con la especificación de OpenAI) valida por defecto la cabecera `Authorization: Bearer <token>`.
* **Consecuencia:** Al no encontrar la cabecera `Authorization: Bearer`, OmniRoute rechaza las peticiones devolviendo `401 Invalid API key`, aun cuando `$env:ANTHROPIC_API_KEY` esté configurada.
* **Solución / Workaround:** 
  Configurar `REQUIRE_API_KEY=false` en el archivo `~/.omniroute/.env`.
* **Automatización en este repo:**
  El script `scripts/instalar-automatizacion-powershell.ps1` detecta y configura automáticamente `REQUIRE_API_KEY=false` en `~/.omniroute/.env`.
* **Recomendación para upstream:** OmniRoute debería aceptar o mapear la cabecera `x-api-key` cuando reciba peticiones dirigidas a endpoints compatibles con Anthropic.

---

### Bug 2: Conflicto con el Wrapper `omniroute launch`
* **Descripción:** El comando empaquetador `omniroute launch -- claude` intercepta y manipula el entorno de ejecución del subproceso de Claude Code.
* **Consecuencia:** Sobrescribe o ignora variables de entorno inyectadas manualmente (como `$env:ANTHROPIC_API_KEY`), causando fallos de autenticación si se utilizan llaves personalizadas. Adicionalmente, genera conflictos si existen instalaciones nativas independientes (`~/.local/bin/claude.exe`) frente a instalaciones globales de npm (`%APPDATA%\npm\claude.cmd`).
* **Solución / Workaround:**
  Invocar directamente el ejecutable nativo de Claude Code mediante la función de PowerShell en `$PROFILE`, evitando el uso de `omniroute launch`.
* **Automatización en este repo:**
  La función `claude` inyectada en PowerShell localiza dinámicamente el binario real (`claude.exe` / `claude.cmd`), inicializa el servidor en segundo plano si no está corriendo y ejecuta directamente el proceso con todas las variables de entorno intactas.

---

### Bug 3: Ambigüedad en los Nombres de Modelos (Error 400)
* **Descripción:** El selector interactivo `/model` de Claude Code envía nombres de modelos genéricos o estándares (por ejemplo, `claude-sonnet-5` o `claude-sonnet`).
* **Consecuencia:** OmniRoute rechaza la petición con `400 Ambiguous model 'claude-sonnet-5'` porque requiere un prefijo de proveedor (como `dva/` o `auto/`) para resolver la ruta de enrutamiento adecuada.
* **Solución / Workaround:**
  Especificar el modelo directamente con su prefijo en la terminal:
  ```text
  /model auto/claude-sonnet
  ```
  O definir la variable de entorno `$env:ANTHROPIC_MODEL = "auto/claude-sonnet"`.
* **Automatización en este repo:**
  El perfil de PowerShell inyecta `$env:ANTHROPIC_MODEL = "auto/claude-sonnet"` por defecto si no ha sido personalizada, garantizando funcionamiento inmediato.
* **Recomendación para upstream:** Permitir alias globales en OmniRoute para que nombres genéricos como `claude-sonnet-5` se resuelvan por defecto hacia la ruta `auto/`.

---

## 🚀 Resumen de Comandos de Inicialización

1. **Configurar automatización y perfiles:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\instalar-automatizacion-powershell.ps1
   ```
2. **Instalar skills:**
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\scripts\instalar-skills-en-claude.ps1
   ```
3. **Ejecutar Claude Code:**
   ```powershell
   claude
   ```
   *(Si necesitas cambiar de modelo dentro de la sesión, escribe `/model auto/claude-sonnet` o el prefijo correspondiente).*

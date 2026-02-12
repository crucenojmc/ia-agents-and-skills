---
name: web-screenshot
description: >
  Captures high-quality screenshots of web pages or local HTML files using Puppeteer.
  Supports responsive viewports, full-page capture, and PDF export.
license: MIT
metadata:
  version: "1.0.0"
  author: mapplics
  dependencies:
    - puppeteer
---

# Web Screenshot

Herramienta de captura automatizada basada en Puppeteer (Chrome Headless).
Diseñada para funcionar en Docker o nativamente si Node.js está disponible.

## 🚀 Uso

### Capturar URL o Archivo
Crea una imagen PNG de una URL pública o un archivo HTML local.

```bash
# Uso directo del script
./skills/web-screenshot/bin/snap.sh <input_url_or_file> <output_path> [options]

# Ejemplo
./skills/web-screenshot/bin/snap.sh https://google.com screenshot.png
./skills/web-screenshot/bin/snap.sh docs/output.html docs/preview.png
```

## ⚙️ Opciones

No hay flags complejos expuestos en `snap.sh` actualmente, pero el script subyacente `snap.js` soporta:
- Detección automática de tamaño de contenido (full page).
- Viewport estándar 1920x1080.
- Espera a `networkidle0` para asegurar carga completa.

## 📦 Docker vs Local

El script `bin/snap.sh` gestiona automáticamente el entorno:
1. **Local**: Si `node` y `node_modules` existen, usa el host (más rápido).
2. **Docker**: Si no, usa la imagen `web-screenshot:1.0` (aislado, portable).

## 🛠️ Instalación (Local)

Para habilitar ejecución local (más rápida):

```bash
cd skills/web-screenshot
npm install
```

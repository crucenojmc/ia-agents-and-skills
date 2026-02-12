---
name: knowledge-structure
description: >
  Enforces structure, scaffolding, and validation (linting) for documentation vaults.
  Ensures broken links are detected and file naming conventions are followed.
license: MIT
metadata:
  version: "1.0.0"
  author: mapplics
  dependencies:
    - minimist
---

# Knowledge Structure

El guardián de la integridad de la documentación. Se encarga de crear estructuras base y validar que los vínculos entre documentos sean correctos.

## 🚀 Capacidades

### 1. Scaffolding (Crear Estructura)
Inicializa una nueva carpeta de documentación con la estructura estándar recomendada.

```bash
./skills/knowledge-structure/bin/scaffold.sh <target_directory>

# Ejemplo
./skills/knowledge-structure/bin/scaffold.sh docs/mi-proyecto
```

**Estructura Generada:**
- `index.md`: Home page.
- `guides/`: Guías de usuario.
- `reference/`: API y referencia técnica.
- `diagrams/`: Fuentes de diagramas.
- `assets/`: Imágenes y estáticos.

### 2. Linting (Validación)
Escanea todos los archivos Markdown (`.md`) buscando WikiLinks rotos (`[[Página]]`).
Soporta resolución inteligente de rutas (nombre base o ruta relativa).

```bash
./skills/knowledge-structure/bin/lint.sh <target_directory>

# Ejemplo
./skills/knowledge-structure/bin/lint.sh docs/mi-proyecto
```

**Salida:**
- ✅ Lista de archivos escaneados.
- ❌ Errores detallados si un link apunta a un archivo inexistente.
- Código de salida 1 si hay errores (útil para CI/CD).

## 📦 Docker vs Local

Ambos scripts soportan ejecución híbrida:
- **Local**: Preferido si `npm install` se ejecutó en el skill directory.
- **Docker**: Fallback automático a `knowledge-structure:1.0`.

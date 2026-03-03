---
name: universal-skill-creator
description: >
  The Master Skill. Creates, audits, normalizes, and maintains AI agent skills.
  Trigger: Use when user asks to create, audit, normalize, delete, clean, configure, or install skills.
license: MIT
metadata:
  author: mapplics
  version: "4.1"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
---

# Universal Skill Creator (Orchestrator)

> "The metaskill that builds other skills."

Este skill actúa como el sistema operativo para la gestión de Agent Skills. Sus funciones se dividen en módulos de Ciclo de Vida.

## Cuándo Usar

Activa este skill cuando:
- El usuario quiere **crear** una nueva capacidad o skill.
- El usuario pide **auditar** o **revisar** los skills existentes.
- Se necesita **instalar** o **configurar** el entorno de agentes.
- Se requiere **eliminar** o **limpiar** skills en desuso.

**No usar cuando:**
- El usuario pide código de aplicación normal.
- El usuario ya está dentro de un flujo específico de otro skill (ej: `demand-analysis`).

---

## Patrones Críticos

### Patrón 1: Discovery First (OBLIGATORIO)

**Descripción**: Antes de crear NADA, busca si ya existe. Dos registries, en orden:

```bash
# Paso 0a: Buscar en SundialHub (registry oficial agentskills.io, 52k+ skills)
./skills/universal-skill-creator/scripts/search_sundial_skills.sh "<keywords>"

# Paso 0b: Buscar en skills.sh (si SundialHub no tiene resultados relevantes)
./skills/universal-skill-creator/scripts/search_community_skills.sh "<keywords>"
```

*Si existe algo similar: evaluar señales de confianza (installs, safety, version) antes de instalar.
Solo crear si no hay alternativa adecuada en ninguno de los dos.*

### Patrón 2: Revelación Progresiva

**Descripción**: No intentes hacer todo de una vez. Lee las guías específicas según el módulo activo.

```python
# Ejemplo: Si estás en creación, lee la guía de flujo
view_file("skills/universal-skill-creator/guides/creation-workflow.md")
```

### Patrón 3: Estructura Estándar

**Descripción**: Todos los skills creados DEBEN seguir el template `SKILL-GENERIC.md`.
- `SKILL.md` en raíz.
- `assets/templates/` para recursos.
- `scripts/` para automatización.

---

## Árbol de Decisiones (Módulos)

```
¿Qué desea hacer el usuario?
├── CREAR un nuevo skill
│   ├── ¿Busqué en SundialHub Y skills.sh? (Módulo 0 — OBLIGATORIO)
│   │   ├── NO → Ejecutar búsqueda en ambos registries.
│   │   └── SÍ, no hay alternativa → Iniciar Módulo 1 (Creación).
│
├── AUDITAR o Arreglar skills
│   └── Iniciar Módulo 2 (Auditoría).
│
├── MANTENER (Borrar/Listar)
│   └── Iniciar Módulo 3 (CMS).
│
├── CONFIGURAR agentes
│   └── Iniciar Módulo 4 (Setup).
│
├── PUBLICAR skill al registry
│   ├── ¿Scan de seguridad pasado? (Módulo 6 — OBLIGATORIO)
│   │   ├── NO → Ejecutar scan, corregir, re-escanear.
│   │   └── SÍ → Iniciar Módulo 5 (Publishing).
│
└── CONSULTAR API de SundialHub
    └── Iniciar Módulo 7 (API Directa).
```

---

## Comandos Comunes (Por Módulo)

### Módulo 0: Discovery
```bash
# Paso 0a — SundialHub (registry oficial, PRIMERO)
./skills/universal-skill-creator/scripts/search_sundial_skills.sh "query"

# Paso 0b — skills.sh (alternativo, si 0a no tiene resultados)
./skills/universal-skill-creator/scripts/search_community_skills.sh "query"
```

### Módulo 0: Instalar desde Registry
```bash
# Desde SundialHub (multi-agente)
./skills/universal-skill-creator/scripts/install_sundial_skill.sh <author>/<skill> --claude

# Desde skills.sh (Antigravity)
./skills/universal-skill-creator/scripts/install_community_skill.sh <repo> <skill>
```

### Módulo 2: Auditoría
```bash
./skills/universal-skill-creator/scripts/audit_workspace.sh
```

### Módulo 3: Mantenimiento
```bash
# Listar
./skills/universal-skill-creator/scripts/manage_skills.sh list
# Eliminar
./skills/universal-skill-creator/scripts/manage_skills.sh delete <nombre>
```

### Módulo 4: Configuración
```bash
./setup.sh --all --global
```

### Módulo 5: Publishing a SundialHub
```bash
# Publicar skill local al registry (scan de seguridad + validación previa automática)
./skills/universal-skill-creator/scripts/publish_to_sundial.sh ./skills/<nombre> \
  --changelog "Descripción" --visibility public --categories coding

# Ver mis skills publicados
npx sundial-hub mine
```

### Módulo 6: Seguridad Pre-Publicación (OBLIGATORIO)
```bash
# 🔒 Scan obligatorio ANTES de publicar (tokens, passwords, IPs, claves)
./skills/universal-skill-creator/scripts/scan_sensitive_data.sh ./skills/<nombre>

# Modo estricto (bloquea también warnings medios/bajos)
./skills/universal-skill-creator/scripts/scan_sensitive_data.sh ./skills/<nombre> --strict

# Modo JSON para uso programático
./skills/universal-skill-creator/scripts/scan_sensitive_data.sh ./skills/<nombre> --json
```

**⚠ IMPORTANTE**: El scan de seguridad se ejecuta automáticamente dentro de
`publish_to_sundial.sh` y `sundial_api.sh publish`. No se puede saltear.
Detecta: API tokens, passwords, connection strings, claves privadas, IPs privadas,
archivos .env, credenciales de cloud, y datos personales.

### Módulo 7: API Directa de SundialHub
```bash
# Cliente HTTP directo (sin Node.js/npx). Usa curl + token Bearer.
# Token: se lee de $SUNDIAL_TOKEN o ~/.sundial/auth.json

# Buscar skills
./skills/universal-skill-creator/scripts/sundial_api.sh search "query" --limit 5

# Ver detalle de un skill
./skills/universal-skill-creator/scripts/sundial_api.sh show author/name

# Verificar disponibilidad de nombre
./skills/universal-skill-creator/scripts/sundial_api.sh check-name my-skill

# Listar mis skills publicados
./skills/universal-skill-creator/scripts/sundial_api.sh mine

# Publicar via API directa (incluye scan de seguridad obligatorio)
./skills/universal-skill-creator/scripts/sundial_api.sh publish ./skills/<nombre> \
  --version 2 --categories coding --changelog "New feature"

# Verificar autenticación
./skills/universal-skill-creator/scripts/sundial_api.sh verify-auth

# Usar token específico (sin auth.json)
SUNDIAL_TOKEN=sd_xxx ./skills/universal-skill-creator/scripts/sundial_api.sh search "pdf"
```

**Endpoints HTTP descubiertos** (base: `https://www.sundialhub.com`):
- `GET /api/hub/skills?q={query}&limit={n}` — Buscar
- `GET /api/hub/skills/by-author-name/{author}/{name}` — Detalle
- `GET /api/hub/skills?mine=true` — Mis skills (auth obligatoria)
- `POST /api/hub/skills` — Crear nuevo (auth obligatoria)
- `POST /api/hub/skills/{id}/versions` — Nueva versión (auth obligatoria)

---

## � Autenticación y Provisión de Token Seguro

Para interactuar con las características avanzadas de SundialHub (como publicación de skills o consulta de endpoints privados), el sistema requerirá autenticación. TÚ, como agente, debes guiar al usuario de forma segura.

**Instrucciones que debes proveer al usuario (SIEMPRE que falte autenticación):**
1. **NO le pidas que pegue el token en el chat.** Eso comprometería sus credenciales en los historiales del LLM.
2. Indícale que genere un token desde: `https://www.sundialhub.com/settings/tokens`.
3. Dale estas **tres opciones** seguras para que provea el Token al entorno:
   - **Opción A (Recomendada):** Crear manualmente el archivo `~/.sundial/auth.json` e incluir `{"token": "sd_..."}` en su entorno local.
   - **Opción B:** Ejecutar en su propia terminal `npx sundial-hub auth login` y seguir el prompt.
   - **Opción C:** Añadir y exportar `SUNDIAL_TOKEN="sd_..."` en sus variables de entorno o archivo perfiles del sistema (`.zshrc` o `.bashrc`).

---

## �🚨 Reglas Críticas para Automatización (IA & CI/CD)

Si eres un agente de IA interactuando con las herramientas de este skill o del SundialHub, **memoriza estas trampas** derivadas de automatizaciones fallidas pasadas:

1. **Bloqueo Interactivo en Publish (Hang):** Cuando publiques un skill usando `publish_to_sundial.sh`, si agregas `-y` (desasistido) pero omites banderas como `--categories` o `--changelog`, el comando subyacente `npx sundial-hub push` abrirá un prompt interactivo en la terminal que se quedará esperando input eternamente (ej. `? Category:` o `? Changelog:` ante un auto-bumping de versión). **Solución:** `publish_to_sundial.sh` a partir de la v4.1 tiene auto-fallbacks (`other` y `"Auto-publish via ai-agent"`), pero la buena práctica es SIEMPRE pasar explícitamente `--categories <tu-categoria>` y `--changelog "Tu mensaje"` junto con `-y` para evitar comportamientos imprevistos.
2. **Avalancha de Embeddings en Terminal:** El comando `sundial_api.sh show` o cualquier response directo de la API de Sundial devuelve un array denso de 1536 floats (`embedding`). Esto inunda los buffers del shell y **rompe el límite de tokens de tu contexto** sumando más de 16KB de texto basura. **Solución:** Cuando llames a la API directamente con curl para traer detalles o buscar, usa siempre algo análogo a `| jq 'del(.skill.embedding)'` o usa `grep -v 'embedding'`.
3. **Parseo Estricto de `mine=true`:** El endpoint HTTP `/api/hub/skills?mine=true` NO devuelve un array de skills en la raíz. Devuelve un objeto JSON wrapeado `{"skills": [...]}`. Intentar iterar la raíz con herramientas HTTP estáticas causará errores de llaves/índices (`KeyError: 0`). **Solución:** Parsear conscientemente la propiedad `skills`. 

---

## Comportamiento del Agente

1.  **Identifica la intención**: Clasifica la solicitud en uno de los módulos de creación, auditoría o publicación.
2.  **Validar**: Si es Creación, ejecuta el Checklist de Discovery.
3.  **Delegación Estratégica (Uso de Subagentes para Validaciones y Publicación)**: 
    - **NUNCA** ejecutes `publish_to_sundial.sh` u otros comandos de validación o escaneo pesados directamente en el shell del agente principal.
    - **SIEMPRE** delega estas tareas de adquisición de información y validación a un **Subagente** (ej. 'Explore' o 'Plan'). Tu (el agente principal) sólo debes quedarte con los **resultados finales limpios** (sin saturar tu contexto con logs).
4.  **Mitigación Interactiva de Seguridad**:
    - Si el Subagente retorna que la publicación arrojó hallazgos de seguridad (MEDIUM, HIGH) desde SundialHub, **notifica al usuario de los hallazgos** que retornó el subagente.
    - Sugiere un plan de mitigación.
    - Ofrécele al usuario estas opciones y espera su respuesta:
      * *Opción A:* Dejar registrado en el skill como tareas (`TODO` / issues) a resolver en el futuro.
      * *Opción B:* Implementar las soluciones en este instante en un proceso iterativo de corrección.
    - Si el usuario elige *Opción B* (iterar), pregúntale: ¿Deseas que solicite tu **confirmación para cada cambio** que haga, o prefieres que lo resuelva **100% de forma autónoma** y delegada iterando hasta que pase el escaneo (LOW)?
5.  **Reportar**: Confirma la acción y actualiza `AGENTS.md` si es necesario.

### Referencia de Archivos
- **Guía de Creación**: [guides/creation-workflow.md](guides/creation-workflow.md)
- **SundialHub Registry**: [guides/sundial-registry.md](guides/sundial-registry.md)
- **API Directa & Seguridad**: [guides/api-and-security.md](guides/api-and-security.md)
- **Templates**: [assets/templates/](assets/templates/)
- **Checklists**: [assets/checklists/](assets/checklists/)
- **Fuente de Verdad**: `AGENTS.md`
- **Documentación SundialHub**: [recursos/sundialhub.md](../../recursos/sundialhub.md)

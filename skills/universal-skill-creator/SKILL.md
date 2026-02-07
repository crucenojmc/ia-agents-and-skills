---
name: universal-skill-creator
description: >
  The Master Skill. Creates, audits, normalizes, and maintains AI agent skills.
  Trigger: Use when user asks to create, audit, normalize, delete, clean, configure, or install skills.
license: MIT
metadata:
  author: mapplics
  version: "3.1"
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

**Descripción**: Antes de crear NADA, busca si ya existe.

```bash
# Paso 0: Buscar en la comunidad
./skills/universal-skill-creator/scripts/search_community_skills.sh "<keywords>"
```
*Si existe algo similar: Ofrece instalarlo (`npx skills add...`). Solo crea si no hay alternativa.*

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
│   ├── ¿Ya busqué en la comunidad? (Paso 0)
│   │   ├── NO → Ejecutar búsqueda.
│   │   └── SÍ → Iniciar Módulo 1 (Creación).
│
├── AUDITAR o Arreglar skills
│   └── Iniciar Módulo 2 (Auditoría).
│
├── MANTENER (Borrar/Listar)
│   └── Iniciar Módulo 3 (CMS).
│
└── CONFIGURAR agentes
    └── Iniciar Módulo 4 (Setup).
```

---

## Comandos Comunes (Por Módulo)

### Módulo 0: Discovery
```bash
./skills/universal-skill-creator/scripts/search_community_skills.sh "query"
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

---

## Comportamiento del Agente

1.  **Identifica la intención**: Clasifica la solicitud en uno de los 4 módulos.
2.  **Validar**: Si es Creación, ejecuta el Checklist de Discovery.
3.  **Aplicar**: Usa los scripts de automatización correspondientes.
4.  **Reportar**: Confirma la acción y actualiza `AGENTS.md` si es necesario.

### Referencia de Archivos
- **Guía de Creación**: [guides/creation-workflow.md](guides/creation-workflow.md)
- **Templates**: [assets/templates/](assets/templates/)
- **Fuente de Verdad**: `AGENTS.md`

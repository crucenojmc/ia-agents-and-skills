---
name: universal-skill-creator
description: >
  The Master Skill. Creates, audits, normalizes, and maintains AI agent skills.
  Trigger: Use when user asks to create, audit, normalize, delete, clean, 
  configure, or install skills.
license: MIT
metadata:
  author: mapplics
  version: "3.0"
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, WebFetch, WebSearch, Task
---

# Universal Skill Creator (Orchestrator)

> "The metaskill that builds other skills."

Este skill actúa como el sistema operativo para la gestión de Agent Skills. Sus funciones se dividen en 4 módulos principales.

---

## 🔍 Módulo 0: Discovery de Skills (skills.sh)

**Trigger:** Usuario solicita crear un skill o capacidad nueva.

**Acción PREVIA a la creación:**

1. **Identificar keywords** del skill solicitado por el usuario.
2. **Buscar en skills.sh:**
   ```bash
   # Buscar en todo el ecosistema (inteligente)
   ./skills/universal-skill-creator/scripts/search_community_skills.sh "<keywords>"
   ```
3. **Analizar resultados:** El script filtra y limpia la salida de `npx skills find`.
4. **Decisión del usuario:**
   - ✅ **Instalar existente** → Ejecutar instalación con `npx skills add`
   - ❌ **Ninguno aplica** → Continuar con Módulo 1 (Creación)

**Comandos de Instalación:**
```bash
# Instalar skill específico para Antigravity
npx -y skills add <repo> --skill <nombre> -a antigravity -y

# Instalación global
npx -y skills add <repo> --skill <nombre> -a antigravity -g -y
```

> 📚 Referencia: [skills_sh_ecosystem.md](../../../recursos/skills_sh_ecosystem.md)

---

## 🏗️ Módulo 1: Creación de Skills

**Trigger:** Cuando el usuario quiere crear un nuevo skill.

**Acción:**
El agente NO debe adivinar. Sigue el flujo detallado en:
👉 **[Guía de Flujo de Creación](guides/creation-workflow.md)**

**Resumen del Proceso:**
1. **Descubrimiento**: Ejecutar cuestionario (Propósito, Ámbito, Referencias).
2. **Análisis**: Decidir si se justifica un skill o es documentación trivial.
3. **Diseño**: Proponer estructura (`skills/{nombre}/SKILL.md`).
4. **Implementación**: Usar templates en `assets/templates/`.
   - Ver referencia de formato: **[Estructura de Referencia](guides/skill-structure-template.md)**

---

## 🕵️ Módulo 2: Auditoría y Normalización

**Trigger:** Cuando el usuario pide auditar el workspace o arreglar skills legacy.

**Acciones:**

1. **Auditar Workspace:**
   ```bash
   ./skills/universal-skill-creator/scripts/audit_workspace.sh
   ```

2. **Normalizar:**
   Si se detectan errores, sigue paso a paso la:
   � **[Guía de Normalización](guides/normalization.md)**

---

## 🔧 Módulo 3: Mantenimiento (CMS)

**Trigger:** Eliminar skills, limpiar huérfanos o listar instalados.

**Herramienta:** `scripts/manage_skills.sh`

| Acción | Comando |
|--------|---------|
| **Eliminar** | `./skills/universal-skill-creator/scripts/manage_skills.sh delete {nombre}` |
| **Limpiar (Prune)** | `./skills/universal-skill-creator/scripts/manage_skills.sh prune` |
| **Listar** | `./skills/universal-skill-creator/scripts/manage_skills.sh list` |

> ⚠️ Nunca elimines el skill `universal-skill-creator`.

---

## � Módulo 4: Configuración y Despliegue

**Trigger:** Instalar skills en los agentes (Claude, Gemini, Copilot), configurar entorno global.

**Herramienta:** `scripts/setup_agents.sh`

**Acciones:**
- **Instalar todo (local)**: `./setup.sh --all`
- **Instalación Global Avanzada**: `./setup.sh` (Seleccionar Opción 5)
  - Permite elegir qué skills copiar y a qué proveedor (`~/.claude`, etc).

---

## 🤖 Comportamiento General del Agente

1. **Identifica la intención**: ¿Crear, Auditar, Mantener o Configurar?
2. **Usa la herramienta especializada**: No intentes hacerlo manual si hay script.
3. **Revelación Progresiva**: Lee las guías enlazadas (`view_file`) solo cuando entres en ese módulo específico.
4. **Fuente de Verdad**: Recuerda que `AGENTS.md` gestiona la configuración central.

## � Índice de Recursos

- **Guías**: [guides/](guides/)
- **Scripts**: [scripts/](scripts/)
- **Templates**: [assets/templates/](assets/templates/)

# AI Agents Configuration

> Configuración central para agentes de IA en este repositorio.
> Este archivo es la fuente de verdad y se copia/enlaza a las configuraciones específicas de cada herramienta.

## 📋 Descripción del Proyecto

Este repositorio centraliza **metodologías, formatos, templates y flujos de trabajo** para construir un compendio reutilizable de asistentes virtuales y skills para agentes de IA.

---

## 🛠️ Skills Disponibles

| Skill | Descripción | Trigger | Archivo |
|-------|-------------|---------|---------|
| `universal-skill-creator` | Crea skills para agentes de IA siguiendo el estándar Agent Skills | Cuando el usuario pide crear un skill, documentar patrones para IA, o necesita guía sobre diseño de skills | [SKILL.md](skills/universal-skill-creator/SKILL.md) |
| `meta-skill-creator` | (Legacy) Creador de skills original | Cuando se necesite referencia del formato anterior | [SKILL.md](skills/meta-skill-creator/SKILL.md) |
| `pdf-processing` | Procesamiento de archivos PDF | Cuando se trabaje con PDFs | [SKILL.md](skills/pdf-processing/SKILL.md) |
| `local-time` | Obtiene hora/fecha del sistema | Preguntas sobre hora, fecha o timestamps | [SKILL.md](skills/local-time/SKILL.md) |
| `demand-analysis-expert` | Experto en estadística y forecast | "analisis de demanda", "forecast", "estacionalidad" | [SKILL.md](skills/demand-analysis-expert/SKILL.md) |
| `os-awareness` | Verifica el SO antes de comandos de sistema | "instalar", "update", "apt", "brew", "comando" | [SKILL.md](skills/os-awareness/SKILL.md) |
| `documentation-orchestrator` | Orquestador de documentación Docs-as-Code | "generate docs", "document project", "validate docs" | [SKILL.md](skills/documentation-orchestrator/SKILL.md) |
| `docs-renderer` | Renderizado avanzado Markdown a HTML/PDF con temas | "render pdf", "export html", "generate output" | [SKILL.md](skills/docs-renderer/SKILL.md) |
| `mermaid-expert` | Experto en diagramas Mermaid, C4 y Estilos | "create diagram", "mermaid help", "c4 model" | [SKILL.md](skills/mermaid-expert/SKILL.md) |
| `knowledge-structure` | Linter y validador de estructura y WikiLinks | "validate structure", "fix links", "lint docs" | [SKILL.md](skills/knowledge-structure/SKILL.md) |
| `web-screenshot` | Capturas de pantalla automatizadas (local/web) | "take screenshot", "capture url" | [SKILL.md](skills/web-screenshot/SKILL.md) |

---

## 🤖 Instrucciones para el Agente

### Comportamiento General

1. **Antes de crear cualquier skill nuevo**, carga primero:
   ```
   skills/universal-skill-creator/SKILL.md
   ```

2. **🚨 CHECKLIST OBLIGATORIO** (Antes de crear NADA):
   El agente DEBE validar explícitamente estos pasos en su pensamiento o output:
   - [ ] ¿Ejecuté `npx skills find` o `search_community_skills.sh`?
   - [ ] ¿Busqué skills.sh por palabras clave similares?
   - [ ] ¿Es realmente necesario un nuevo skill o basta con el existente?
   
   *Si se salta este paso, el agente está violando el protocolo.*

3. **🚨 CHECKLIST DE CALIDAD** (Antes de finalizar):
   - [ ] ¿Ejecuté `audit_workspace.sh`?
   - [ ] ¿Corregí todos los warnings?

3. **Sigue el proceso interactivo** del skill-creator:
   - Pregunta siempre el tipo de skill (genérico/específico/orquestador)
   - Consulta si hay código de referencia
   - Verifica si se desea auto-invocación

4. **Usa los templates apropiados**:
   - `assets/templates/SKILL-GENERIC.md` para skills universales
   - `assets/templates/SKILL-PROJECT.md` para skills de proyecto
   - `assets/templates/SKILL-ORCHESTRATOR.md` para skills coordinadores

### Triggers Automáticos

El agente debe cargar skills automáticamente según el contexto:

| Contexto | Skill a Cargar | Acción |
|----------|----------------|--------|
| Crear/modificar skills | `universal-skill-creator` | Leer SKILL.md antes de actuar |
| Documentar patrones de IA | `universal-skill-creator` | Usar proceso interactivo |
| Obtener hora/fecha | `local-time` | Ejecutar script para obtener dato preciso |

### Cómo Cargar un Skill

Para cargar un skill, el agente debe ejecutar:

```
view_file("skills/{nombre-skill}/SKILL.md")
```

---

## 📂 Estructura del Repositorio

```
.
├── AGENTS.md                 # Este archivo (fuente de verdad)
├── setup.sh                  # Script de configuración
├── skills/                   # Skills para agentes
│   ├── universal-skill-creator/
│       ├── SKILL.md
│       ├── assets/
│       │   ├── templates/
│       │   ├── checklists/
│       │   └── examples/
│       ├── guides/
│       └── scripts/
├── templates/                # Templates generales
├── workflows/                # Flujos de trabajo
├── agentes/                  # Configuraciones de agentes
└── recursos/                 # Material de referencia
```

---

## ⚙️ Configuración por Herramienta

### Claude Code

| Ubicación | Archivo |
|-----------|---------|
| Proyecto | `.claude/skills/` → `skills/` |
| Instrucciones | `.claude/CLAUDE.md` (copia de AGENTS.md) |
| Global | `~/.claude/skills/` |

### Gemini CLI / Antigravity

| Ubicación | Archivo |
|-----------|---------|
| Proyecto | `.gemini/skills/` → `skills/` |
| Antigravity | `.agent/skills/` → `skills/` |
| Instrucciones | `.gemini/GEMINI.md` (copia de AGENTS.md) |
| Global | `~/.gemini/antigravity/skills/` |

**Nota**: Para Gemini CLI, habilitar `experimental.skills` en configuración.

### Codex (OpenAI)

| Ubicación | Archivo |
|-----------|---------|
| Proyecto | `.codex/skills/` → `skills/` |
| Instrucciones | `AGENTS.md` (nativo) |

### GitHub Copilot

| Ubicación | Archivo |
|-----------|---------|
| Proyecto Skills | `.github/skills/` → `skills/` |
| Custom Instructions | `.github/copilot-instructions.md` |
| Global | `~/.copilot/skills/` |

**Referencia**: [GitHub Copilot Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)

---

## 🚀 Instalación Rápida

```bash
# Modo interactivo
./setup.sh

# Configurar todas las herramientas
./setup.sh --all

# Solo Claude y Gemini
./setup.sh --claude --gemini

# Con instalación global
./setup.sh --all --global

# Ver ayuda
./setup.sh --help
```

---

## 📝 Convenciones

### Naming de Skills

| Tipo | Patrón | Ejemplo |
|------|--------|---------|
| Tecnología | `{technology}` | `pytest`, `react-19` |
| Principio | `{concept}` | `clean-code`, `tdd` |
| Proyecto | `{project}-{component}` | `myapp-api` |
| Workflow | `{action}-{target}` | `skill-creator` |
| Orquestador | `{domain}-orchestrator` | `quality-orchestrator` |

### Estructura de Skill

```
skill-name/
├── SKILL.md              # Obligatorio
├── assets/               # Templates, schemas, ejemplos
├── scripts/              # Scripts ejecutables
├── guides/               # Documentación extendida
└── references/           # Referencias a docs locales
```

---

## 🔄 Actualización de Skills

Cuando se modifique o agregue un skill:

1. Actualizar este archivo `AGENTS.md`
2. Re-ejecutar `./setup.sh` para propagar cambios
3. Reiniciar los asistentes de IA

---

## 📚 Recursos Adicionales

- [Agent Skills Standard](https://agentskills.io)
- [Antigravity Skills Guide](https://antigravity.google/docs/skills)
- [Claude Code Agent Skills](https://platform.claude.com/docs/agents-and-tools/agent-skills)

---

## 📋 Changelog

| Fecha | Cambio |
|-------|--------|
| 2026-01-27 | Agregado `universal-skill-creator` v2.0 |
| 2026-01-27 | Creado script `setup.sh` para configuración multi-herramienta |

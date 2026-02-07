# skills.sh - Open Agent Skills Ecosystem

> **Fuente**: [skills.sh](https://skills.sh/) | [GitHub](https://github.com/vercel-labs/skills)  
> **Análisis realizado**: 2026-02-06

## 📋 Resumen

**skills.sh** es un directorio/ecosistema abierto de skills para agentes de IA, mantenido por Vercel Labs. Proporciona:

- **CLI unificado**: `npx skills add <owner/repo>` para instalar skills
- **+37 agentes soportados**: Incluyendo Antigravity, Claude Code, Cursor, Codex, etc.
- **Leaderboard**: Ranking de skills basado en telemetría anónima de instalaciones
- **Estándar SKILL.md**: Formato unificado con YAML frontmatter
- **Búsqueda Inteligente**: `npx skills find` para buscar en todo el ecosistema

---

## 🛠️ CLI - Comandos Principales

### Búsqueda de Skills (Smart Search)
```bash
# Buscar interactivamente
npx skills find <keywords>

# Buscar en scripts (no-interactivo)
echo "q" | npx skills find <keywords>
```

### Instalación de Skills
```bash
# Formato básico
npx skills add <owner/repo>

# Ejemplos
npx skills add vercel-labs/agent-skills
npx skills add anthropics/skills

# Listar skills en un repo
npx skills add vercel-labs/agent-skills --list

# Instalar skills específicos
npx skills add vercel-labs/agent-skills --skill frontend-design --skill skill-creator

# Instalar para agentes específicos
npx skills add vercel-labs/agent-skills -a claude-code -a antigravity

# Instalación global
npx skills add vercel-labs/agent-skills -g

# Modo no-interactivo (CI/CD)
npx skills add vercel-labs/agent-skills --skill frontend-design -g -a claude-code -y
```

### Otros Comandos
```bash
skills list      # Listar skills instalados
skills find      # Buscar skills
skills check     # Verificar skills
skills update    # Actualizar skills
skills init      # Inicializar repo de skills
skills remove    # Eliminar skills
```

---

## 📁 Formato SKILL.md

### Plantilla Básica
```markdown
---
name: my-skill-name
description: A clear description of what this skill does and when to use it
---

# My Skill Name

[Instrucciones que seguirá el agente cuando este skill esté activo]

## When to Use
Describe los escenarios donde este skill debe usarse.

## Steps
1. Primero, hacer esto
2. Luego, hacer aquello

## Examples
- Ejemplo de uso 1
- Ejemplo de uso 2

## Guidelines
- Pauta 1
- Pauta 2
```

### Campos del Frontmatter

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `name` | ✅ | Identificador único (lowercase, guiones permitidos) |
| `description` | ✅ | Descripción breve del skill y cuándo usarlo |
| `metadata.internal` | ❌ | `true` para ocultar de discovery normal |

---

## 📂 Ubicaciones de Skills por Agente

| Agente | Local | Global |
|--------|-------|--------|
| **antigravity** | `.agent/skills/` | `~/.gemini/antigravity/skills/` |
| **claude-code** | `.claude/skills/` | `~/.claude/skills/` |
| **codex** | `.agents/skills/` | `~/.codex/skills/` |
| **cursor** | `.cursor/skills/` | `~/.cursor/skills/` |
| **gemini-cli** | `.agents/skills/` | `~/.gemini/skills/` |
| **github-copilot** | `.agents/skills/` | `~/.copilot/skills/` |
| **windsurf** | `.windsurf/skills/` | `~/.codeium/windsurf/skills/` |
| **cline** | `.cline/skills/` | `~/.cline/skills/` |

> Ver [lista completa de 37+ agentes](https://github.com/vercel-labs/skills#supported-agents)

---

## 🔍 Skill Discovery

El CLI busca skills en estas ubicaciones dentro de un repositorio:

```
./                          # Raíz (si contiene SKILL.md)
./skills/
./skills/.curated/
./skills/.experimental/
./skills/.system/
./.agents/skills/
./.agent/skills/
./.claude/skills/
```

### Plugin Manifest Discovery
Si existe `.claude-plugin/marketplace.json`:

```json
{
  "metadata": { "pluginRoot": "./plugins" },
  "plugins": [{
    "name": "my-plugin",
    "source": "my-plugin",
    "skills": ["./skills/review", "./skills/test"]
  }]
}
```

---

## 🏆 Top Skills (Leaderboard All-Time)

| # | Skill | Repo | Installs |
|---|-------|------|----------|
| 1 | `find-skills` | vercel-labs/skills | 133.5K |
| 2 | `vercel-react-best-practices` | vercel-labs/agent-skills | 101.3K |
| 3 | `web-design-guidelines` | vercel-labs/agent-skills | 76.6K |
| 4 | `remotion-best-practices` | remotion-dev/skills | 71.1K |
| 5 | `frontend-design` | anthropics/skills | 45.9K |
| 6 | `vercel-composition-patterns` | vercel-labs/agent-skills | 25.7K |
| 7 | `agent-browser` | vercel-labs/agent-browser | 24.3K |
| 8 | `skill-creator` | anthropics/skills | 22.6K |
| 9 | `browser-use` | browser-use/browser-use | 19.0K |
| 10 | `ui-ux-pro-max` | nextlevelbuilder/ui-ux-pro-max-skill | 15.4K |

---

## 🗂️ Categorías de Skills Populares

### Desarrollo & Technical
- `vercel-react-best-practices`, `supabase-postgres-best-practices`, `next-best-practices`
- `mcp-builder`, `webapp-testing`, `test-driven-development`, `systematic-debugging`

### Design & Frontend
- `web-design-guidelines`, `frontend-design`, `ui-ux-pro-max`, `canvas-design`

### Documents & Files
- `pdf`, `docx`, `xlsx`, `pptx`

### Marketing & Content
- `seo-audit`, `copywriting`, `marketing-psychology`, `brainstorming`

---

## 🔗 Repositorios de Referencia

| Repo | Descripción |
|------|-------------|
| [vercel-labs/skills](https://github.com/vercel-labs/skills) | CLI y documentación principal |
| [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | Skills oficiales de Vercel |
| [anthropics/skills](https://github.com/anthropics/skills) | Skills oficiales de Anthropic |
| [obra/superpowers](https://github.com/obra/superpowers) | Superpowers (TDD, debugging, etc.) |

---

## 💡 Ideas de Inspiración

### Oportunidades de Mejora para Este Proyecto

1. **Subcarpetas de categorización**: `skills/.curated/`, `skills/.experimental/`, `skills/.system/`
2. **Campo `metadata.internal`**: Para skills privados/WIP
3. **CLI mejorado**: Considerar compatibilidad con `npx skills`
4. **Plugin Manifest**: Soporte para `marketplace.json`

---

## 📚 Recursos Adicionales

- [skills.sh](https://skills.sh/) - Directorio principal
- [Documentación](https://skills.sh/docs) - Docs oficiales
- [FAQ](https://skills.sh/docs/faq) - Preguntas frecuentes
- [Trending](https://skills.sh/trending) - Skills en tendencia

# GitHub Copilot Agent Skills

**Fuente:** [GitHub Docs - About Agent Skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
**Fecha:** Enero 2026

## 📋 Resumen

Agent Skills es un estándar abierto ([agentskills.io](https://agentskills.io)) que permite a los agentes de IA cargar instrucciones, scripts y recursos cuando son relevantes para mejorar su rendimiento en tareas especializadas.

## 🔧 Compatibilidad

GitHub Copilot Agent Skills funciona con:
- **Copilot coding agent** (agente de codificación)
- **GitHub Copilot CLI**
- **Agent mode en VS Code Insiders** (soporte en versión estable próximamente)

## 📂 Ubicaciones de Skills

### Project Skills (Específicos del repositorio)
```
.github/skills/skill-name/SKILL.md
.claude/skills/skill-name/SKILL.md  # También soportado
```

### Personal Skills (Compartidos entre proyectos)
```
~/.copilot/skills/skill-name/SKILL.md
~/.claude/skills/skill-name/SKILL.md  # También soportado
```

## 📝 Estructura de un Skill

Cada skill debe estar en su propio directorio con un archivo `SKILL.md`:

```
.github/skills/
└── mi-skill/
    ├── SKILL.md          # Obligatorio
    ├── scripts/          # Opcional - scripts ejecutables
    └── examples/         # Opcional - ejemplos de código
```

## 📄 Formato del SKILL.md

El archivo debe contener YAML frontmatter seguido de instrucciones en Markdown:

```markdown
---
name: github-actions-failure-debugging
description: Guide for debugging failing GitHub Actions workflows. 
  Use this when asked to debug failing GitHub Actions workflows.
license: MIT
---

# Instructions

Your detailed instructions here...

## Steps

1. Step one
2. Step two
3. Step three
```

### Campos del Frontmatter

| Campo | Requerido | Descripción |
|-------|-----------|-------------|
| `name` | ✅ Sí | Identificador único, lowercase con guiones |
| `description` | ✅ Sí | Qué hace el skill y CUÁNDO debe usarse |
| `license` | ❌ No | Licencia del skill |

## ⚙️ Cómo Funciona

1. **Descubrimiento**: Copilot lee los nombres y descripciones de todos los skills disponibles
2. **Activación**: Basándose en el prompt del usuario, Copilot decide cuándo usar un skill
3. **Inyección**: El contenido de `SKILL.md` se inyecta en el contexto del agente
4. **Ejecución**: Copilot sigue las instrucciones y puede usar scripts incluidos

## 🔀 Skills vs Custom Instructions

| Aspecto | Custom Instructions | Skills |
|---------|---------------------|--------|
| Ubicación | `.github/copilot-instructions.md` | `.github/skills/` |
| Cuándo usar | Instrucciones simples, siempre relevantes | Instrucciones detalladas, contextuales |
| Carga | Siempre activas | Bajo demanda |
| Ejemplo | Estándares de código del proyecto | Debugging de GitHub Actions |

## 📚 Recursos Adicionales

- **Estándar oficial**: [agentskills.io](https://agentskills.io)
- **Skills de Anthropic**: [github.com/anthropics/skills](https://github.com/anthropics/skills)
- **Colección comunitaria**: [github.com/github/awesome-copilot](https://github.com/github/awesome-copilot)
- **Custom Instructions**: [Docs GitHub](https://docs.github.com/en/copilot/how-tos/configure-custom-instructions/add-repository-instructions)

## 🔮 Próximamente

- Soporte en versión estable de VS Code
- Skills a nivel de organización
- Skills a nivel empresarial

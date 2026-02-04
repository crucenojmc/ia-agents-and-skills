# Repositorio de Skills (Gentleman Programming)

**Fuente Original:** [GitHub - Gentleman-Skills](https://github.com/Gentleman-Programming/Gentleman-Skills)
**Clonado en Local:** `recursos/external_repos/gentleman_skills`

## 📂 Organización del Repositorio
Este repositorio es un modelo de referencia para organizar el conocimiento de los agentes.

*   `curated/`: Skills de alta calidad, testeados y mantenidos por el autos.
*   `community/`: Contribuciones de la comunidad.

## 🛠️ Ejemplos Destacados
Hemos identificado varios patrones útiles en la carpeta `curated` que podemos adaptar:

1.  **skill-creator**: Un "Meta-Skill". Es un skill diseñado para enseñar al agente a crear nuevos skills.
    *   *Ubicación:* `curated/skill-creator/SKILL.md`
    *   *Utilidad:* Automatiza la expansión del repositorio.

2.  **Tech Stacks (React 19, NextJS 15, Tailwind 4)**: 
    *   Estos skills no son imperativos, sino informativos. Contienen "Best Practices" y "Avoid these patterns".
    *   *Patrón:* Usan secciones como `## Critical Rules` y `## Common Pipfalls`.

## 🧩 Estructura de un Skill (Formato Gentleman)
El formato observado en este repo es ligeramente más detallado que el de Anthropic básico.

```markdown
---
name: [identificador-kebab-case]
description: [Trigger claro para el agente]
liceense: Apache-2.0
metadata:
  author: [autor]
  version: "1.0"
allowed-tools: [lista explícita de herramientas permitidas]
---

## When to use this skill
Criterios claros de activación.

## The Skill Content
Reglas, guías, ejemplos de código.
```

# Estructura de Skill (Estilo Anthropic)

Esta metodología propone encapsular una habilidad en un **directorio** en lugar de un solo archivo. Utiliza "progressive disclosure" para no saturar el contexto del agente.

## Estructura de Carpetas
Crea una carpeta con el nombre del skill (ej. `analisis-datos-sql`) y dentro coloca los siguientes archivos:

```text
nombre-skill/
├── SKILL.md            # Archivo maestro
├── guides/             # (Opcional) Guías detalladas referenciadas
│   ├── best_practices.md
│   └── troubleshooting.md
└── tools/              # (Opcional) Scripts ejecutables
    ├── query_runner.py
    └── visualizer.py
```

## Contenido de `SKILL.md`

El archivo `SKILL.md` DEBE comenzar con YAML Frontmatter.

\`\`\`markdown
---
name: [Nombre Único del Skill]
description: [Descripción corta y precisa ( 1-2 oraciones). Esto es lo ÚNICO que ve el agente inicialmente.]
author: [Tu Nombre]
version: 1.0
---

# Insturcciones para [Nombre del Skill]

Esta habilidad te permite realizar [Tarea Principal].

## Cuándo usar esta habilidad
Describe situaciones gatillo.
- Cuando el usuario pide X.
- Cuando detectas un error de tipo Y.

## Cómo usar las herramientas
Si este skill incluye scripts en la carpeta \`tools/\`, explica cómo y cuándo ejecutarlos.

> Ejecuta \`tools/query_runner.py\` con el argumento \`--sql "SELECT..."\` para obtener datos crudos.

## Referencias Adicionales
Si necesitas más detalles sobre casos borde, lee el archivo \`guides/troubleshooting.md\`.
\`\`\`

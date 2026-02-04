# Equipping Agents for the Real World with Agent Skills

**Fuente:** [Anthropic Engineering Blog](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)
**Fecha:** Oct 16, 2025

## 💡 Concepto Clave: Agent Skills
Los "Skills" son carpetas organizadas con instrucciones, scripts y recursos que los agentes pueden descubrir y cargar dinámicamente. Permiten transformar un agente generalista en uno especializado mediante la "revelación progresiva" (progressive disclosure).

## 📂 Anatomía de un Skill
Un Skill no es solo un prompt, es un directorio que sigue esta estructura:

```text
nombre-del-skill/
├── SKILL.md          # Punto de entrada obligatorio
├── scripts/          # Código ejecutable (Python, Bash)
└── docs/             # Documentación adicional (referencias, guias)
```

### El archivo `SKILL.md`
Debe comenzar con **YAML Frontmatter** que define los metadatos que el agente ve inicialmente (sin cargar todo el contenido):

```markdown
---
name: PDF Form Filler
description: Extracts form fields from PDF files and aids in filling them out.
---
# PDF Form Filler Instructions
... (resto del prompt detallado) ...
```

## 🧠 Principios de Diseño

1.  **Revelación Progresiva:**
    *   **Nivel 1:** El agente solo ve el `name` y `description` en su System Prompt inicial.
    *   **Nivel 2:** Si el agente decide usar el skill, lee el `SKILL.md` completo.
    *   **Nivel 3:** El `SKILL.md` puede referenciar otros archivos (`forms.md`, `reference.md`) que solo se leen si son estrictamente necesarios.

2.  **Ejecución de Código:**
    *   Los skills pueden contener scripts (ej. Python) que el agente ejecuta en lugar de simular la tarea.
    *   *Ejemplo:* En lugar de intentar parsear un PDF "leyéndolo", el agente ejecuta un script Python que extrae los campos de formulario de forma determinística.

## 🛡️ Seguridad
*   Los skills pueden introducir vulnerabilidades.
*   Se recomienda auditar el código y las instrucciones antes de usar skills de terceros.

## 📝 Best Practices para Crear Skills
1.  **Identificar brechas:** Ver dónde falla el agente actualmente.
2.  **Estructurar para escalar:** Dividir prompts gigantes en archivos más pequeños referenciados.
3.  **Iterar con el Agente:** Pedirle al mismo agente que reflexione sobre qué información le faltó y agregarla al skill.

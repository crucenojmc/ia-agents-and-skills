# El Sistema de Skills que Cambió Cómo Trabajo con IA

**Fuente:** [Gentleman Programming (YouTube)](https://www.youtube.com/watch?v=Nvn6s3r9ZAw)
**Autor:** Gentleman Programming (Alan Buscaglia)
**Formato:** Video Tutorial

## 🔑 Conceptos Clave

1.  **Polución de Contexto:** El problema principal que resuelve este método es evitar los "God Prompts" (prompts gigantes que contienen todas las reglas posibles). Esto confunde al modelo y gasta tokens innecesarios.
2.  **Skills como Herramientas de "Lectura":** En lugar de tener el conocimiento "en memoria", el agente tiene la *capacidad* de ir a buscarlo.
3.  **Modularidad Extrema:** Cada habilidad (ej. "Crear Componente React", "Analizar Base de Datos") es una carpeta aislada.

## 🛠️ Metodología Práctica

### Estructura de Proyecto Propuesta
El autor sugiere mantener una carpeta `.cursor/skills` o `.copilot/skills` (o genérica `skills/` en la raíz) con subcarpetas para cada capacidad.

### El Flujo de "Carga Bajo Demanda" (Lazy Loading)
1.  **System Global:** El agente solo conoce la lista de skills disponibles (Nombre + Descripción breve).
2.  **Trigger:** El usuario pide algo que coincide con la descripción de un skill.
3.  **Acción:** El agente usa su herramienta de `read_file` para leer el archivo `SKILL.md` correspondiente.
4.  **Ejecución:** Ahora el agente tiene el contexto específico para esa tarea (y solo para esa).

### Componentes de un Skill Robusto
*   **Frontmatter:** Fundamental para que el agente sepa *de qué trata* antes de abrirlo.
*   **Scripts Determinísticos:** El video enfatiza el uso de scripts (Python/Node) para tareas donde el LLM falla (matemáticas, parseo estricto, análisis de archivos grandes).
*   **Ejemplos Few-Shot:** Incluir ejemplos de input/output dentro del `SKILL.md` para guiar el estilo de respuesta.

## 💡 Diferencias con otros enfoques
A diferencia de simplemente pegar instrucciones en el chat, este enfoque requiere un agente con capacidad de **uso de herramientas** (File System Access y Terminal), como Cline, Roo Code o GitHub Copilot.

## 📝 Cita Destacada
> "No le des al agente el pescado (la respuesta), dale una caña de pescar (el skill) y enséñale en qué río usarla (instrucciones claras)."

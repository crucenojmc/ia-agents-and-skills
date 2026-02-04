# Guía de Incorporación de Datos para Agentes y Skills

Este documento describe el proceso para recopilar, analizar y estructurar información desde fuentes externas (artículos, videos, documentación) con el fin de crear configuraciones reutilizables de Agentes de IA y Skills.

## Flujo de Trabajo

### 1. Identificación y Recopilación
El primer paso es encontrar fuentes de alta calidad que describan metodologías de trabajo efectivas con IA.
*   **Fuentes:** Artículos de investigación, blogs de ingeniería (OpenAI, Anthropic, Microsoft), tutoriales en YouTube, documentación técnica.
*   **Qué buscar:**
    *   Descriptions de roles específicos (ej. "Arquitecto de Soluciones", "Reviewer de Código").
    *   Prompts efectivos y estructuras de prompts (System Prompts).
    *   Flujos de iteración (ej. Chain of Thought, ReAct).
    *   Formatos de salida esperados (JSON, Markdown, Código).

### 2. Extracción y Abstracción
Una vez identificado el contenido, extraer los componentes clave para independizarlos del contexto original.
*   **Rol:** ¿Quién actúa? (Persona).
*   **Objetivo:** ¿Qué se quiere lograr? (Task).
*   **Contexto/Restricciones:** ¿Qué reglas se deben seguir? (Constraints).
*   **Herramientas Necesarias:** ¿Necesita acceso a internet, shell, sistema de archivos? (Skills).

### 3. Estandarización (Templates)
Utilizar los templates ubicados en la carpeta `/templates` para estructurar la información.
*   **Agentes:** Definir `system_prompt`, `user_prompt_examples`, y configuración de temperatura/modelo.
*   **Skills:** Definir inputs, outputs, y lógica de la herramienta.
*   **Workflows:** Definir la secuencia de interacciones entre usuario-agente o agente-agente.

### 4. Clasificación y Almacenamiento
Guardar los archivos generados en las carpetas correspondientes:
*   `/agentes`: Definiciones de personalidades y roles.
*   `/skills`: Capacidades técnicas específicas (ej. "Consultar base de datos", "Generar diagrama").
*   `/workflows`: Guías paso a paso de procesos complejos (ej. "Refactorización de Legacy Code").
*   `/recursos`: Enlaces originales, transcripciones crudas o notas de investigación.

### 5. Validación
Probar el agente o skill creado en un entorno controlado para asegurar que cumple el objetivo extraído de la fuente original. Ajustar los prompts según los resultados.

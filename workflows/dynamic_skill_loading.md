# Workflow: Carga Dinámica de Skills (Lazy Loading)

## 🎯 Objetivo Global
Optimizar el uso de tokens y reducir la confusión del agente ("alucinaciones") manteniendo el contexto limpio. El agente solo carga las instrucciones detalladas cuando son estrictamente necesarias.

## 👥 Agentes Involucrados
*   **Agente General (Orquestador):** El asistente principal (Copilot/Cline) que interactúa con el usuario.

## 🔄 Pasos del Workflow

### Paso 1: Detección de Intención
*   **Input:** Mensaje del usuario (ej. "Necesito analizar este PDF").
*   **Proceso:** El agente escanea su lista de skills disponibles (cargados en el System Prompt inicial solo como metadatos).
*   **Decisión:** Identifica que el skill `pdf-processing` es relevante.

### Paso 2: Adquisición de Contexto (Tool Use)
*   **Acción:** El agente ejecuta `read_file("skills/pdf-processing/SKILL.md")`.
*   **Resultado:** El contenido detallado del skill se inyecta en el contexto de la conversación actual.

### Paso 3: Ejecución Especializada
*   **Contexto Actual:** Ahora el agente tiene las reglas específicas del skill (ej. "Usa el script inspect_pdf.py").
*   **Acción:** El agente sigue las instrucciones recién leídas (ej. Ejecuta el comando de terminal).

### Paso 4: Limpieza (Implícita)
*   En futuras sesiones o si el contexto se reinicia, el skill "desaparece", manteniendo el agente ligero nuevamente.

## ⚠️ Requisitos Técnicos
El agente DEBE tener permiso para:
1.  Leer archivos del sistema de archivos local (`read_file`).
2.  (Opcional) Ejecutar comandos de terminal si el skill lo requiere (`run_in_terminal`).

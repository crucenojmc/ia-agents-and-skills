# [Nombre del Skill] - Template

## ℹ️ Descripción
¿Qué tarea específica resuelve esta habilidad?
*Ejemplo: "Genera un diagrama de secuencia en formato Mermaid basado en una descripción de texto."*

## 📥 Input Schema
¿Qué datos necesita la herramienta para funcionar? (Formato JSON preferido)

\`\`\`json
{
  "description": "Texto descriptivo del flujo",
  "theme": "Opcional. default: 'dark'"
}
\`\`\`

## 📤 Output Schema
¿Qué devuelve la herramienta?

\`\`\`json
{
  "diagram_code": "Código mermaid...",
  "format": "mermaid"
}
\`\`\`

## 💻 Lógica / Pseudocódigo
Describe cómo funciona la skill internamente.

1.  Analizar el texto de entrada.
2.  Identificar actores y mensajes.
3.  Formatear en sintaxis Mermaid.
4.  Retornar el string.

## 🔗 Dependencias
¿Requiere librerías externas o APIs?

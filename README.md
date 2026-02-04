# Configuración de Agentes y Skills para Desarrollo Colaborativo con IA

Este repositorio sirve como base de conocimiento y configuración para **Agentes de IA** y **Skills** especializados en el desarrollo de software.

## 🎯 Objetivo
Centralizar metodologías, formatos, templates y flujos de trabajo recopilados de diversas fuentes (documentación técnica, videos, artículos) para construir un compendio reutilizable de asistentes virtuales. Estos recursos están diseñados para potenciar el trabajo colaborativo entre humanos e IA.

## 📂 Estructura del Repositorio

*   **Agentes (`agentes/`)**: Definiciones de roles especializados (ej. Arquitecto, QA, Developer Frontend). Configuración de prompts de sistema y personalidades.
*   **Skills (`skills/`)**: Habilidades modulares que los agentes pueden utilizar (ej. Lectura de archivos, Análisis de logs, Creación de diagramas).
*   **Flujos de Trabajo (`workflows/`)**: Definiciones de procesos paso a paso para tareas complejas (ej. 'Ciclo de TDD', 'Análisis de Seguridad').
*   **Templates (`templates/`)**: Plantillas base para crear nuevos agentes, skills y workflows estandarizados.
*   **Recursos (`recursos/`)**: Material de referencia crudo, notas y bibliografía extraída de investigaciones externas.

## 🚀 Cómo Empezar

### Instalación

```bash
# Clonar el repositorio
git clone https://github.com/crucenojmc/ia-agents-and-skills.git
cd ia-agents-and-skills

# Inicializar repositorios externos (submódulos git)
./init-submodules.sh
# o alternativamente:
git submodule update --init --recursive
```

### Contribuir

1.  Lee la **[Guía de Incorporación de Datos](GUIA_PASOS.md)** para entender cómo extraer y formatear el conocimiento.
2.  Utiliza los templates disponibles en directorio `templates/` para estructurar tu contribución.
3.  Guarda tu configuración en la carpeta correspondiente.

---

## 🌟 Fuentes de Inspiración

Este repositorio se nutre de las mejores prácticas y patrones de la comunidad. Los siguientes repositorios externos están incluidos como submódulos en `recursos/external_repos/` para referencia y estudio:

| Repositorio | Descripción | Inspiración |
|-------------|-------------|-------------|
| **[awesome-copilot](https://github.com/github/awesome-copilot)** | Colección curada de recursos de GitHub Copilot | Patrones de prompting y extensiones para agentes |
| **[Gentleman-Skills](https://github.com/Gentleman-Programming/Gentleman-Skills)** | Skills del canal Gentleman Programming | Estructura de skills y metodologías de desarrollo |
| **[clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills)** | Skills enfocados en código limpio | Principios de calidad y buenas prácticas |
| **[skills (Anthropic)](https://github.com/anthropics/skills)** | Skills oficiales de Anthropic para Claude | Estándar de formato y estructura de skills |
| **[prowler](https://github.com/prowler-cloud/prowler)** | Herramienta de seguridad cloud | Ejemplo de proyecto bien estructurado con skills |

> 💡 **Nota**: Estos repositorios son submódulos git. Al clonar, ejecuta `./init-submodules.sh` para descargarlos.

---

## 🤝 Colaboración
Este proyecto busca adaptar las mejores prácticas de la industria. Si encuentras un flujo de trabajo interesante o una técnica de prompting efectiva, ¡agrégala siguiendo la guía!

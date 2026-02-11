# Configuración de Agentes y Skills para Desarrollo Colaborativo con IA

Este repositorio sirve como base de conocimiento y configuración para **Agentes de IA** y **Skills** especializados en el desarrollo de software.

## 🎯 Objetivo
Centralizar metodologías, formatos, templates y flujos de trabajo recopilados de diversas fuentes (documentación técnica, videos, artículos) para construir un compendio reutilizable de asistentes virtuales. Estos recursos están diseñados para potenciar el trabajo colaborativo entre humanos e IA.

## 📂 Estructura del Repositorio

*   **Agentes (`agentes/`)**: Equipo de IA especializado para el mantenimiento del proyecto.
    *   **Orchestrator**: Gerente del proyecto y despachador.
    *   **Skill Architect**: Experto en creación y auditoría de skills.
    *   **Docs Specialist**: Encargado de la documentación viva.
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

Este repositorio se nutre de las mejores prácticas y patrones de la comunidad.

### 🚀 Ecosistema skills.sh

[![skills.sh](https://img.shields.io/badge/Powered%20by-skills.sh-blue)](https://skills.sh/)

Este proyecto está integrado con **[skills.sh](https://skills.sh/)**, el ecosistema abierto de skills para agentes de IA mantenido por Vercel Labs. 

```bash
# Buscar skills disponibles
npx skills add vercel-labs/agent-skills --list

# Instalar un skill para Antigravity
npx skills add anthropics/skills --skill pdf -a antigravity -y
```

> 📖 Ver [recursos/skills_sh_ecosystem.md](recursos/skills_sh_ecosystem.md) para documentación completa.

### 📚 Repositorios de Referencia

Los siguientes repositorios están incluidos como submódulos en `recursos/external_repos/`:

| Repositorio | Descripción | Inspiración |
|-------------|-------------|-------------|
| **[skills.sh](https://skills.sh/)** | Directorio de skills para agentes de IA | CLI, formato SKILL.md, ecosistema abierto |
| **[skills (Anthropic)](https://github.com/anthropics/skills)** | Skills oficiales de Anthropic para Claude | Estándar de formato y estructura de skills |
| **[awesome-copilot](https://github.com/github/awesome-copilot)** | Colección curada de recursos de GitHub Copilot | Patrones de prompting y extensiones |
| **[Gentleman-Skills](https://github.com/Gentleman-Programming/Gentleman-Skills)** | Skills del canal Gentleman Programming | Estructura y metodologías de desarrollo |
| **[clean-code-skills](https://github.com/ertugrul-dmr/clean-code-skills)** | Skills enfocados en código limpio | Principios de calidad y buenas prácticas |
| **[prowler](https://github.com/prowler-cloud/prowler)** | Herramienta de seguridad cloud | Ejemplo de proyecto bien estructurado |

> 💡 **Nota**: Ejecuta `./init-submodules.sh` para descargar los submódulos git.

---

## 🤝 Colaboración
Este proyecto busca adaptar las mejores prácticas de la industria. Si encuentras un flujo de trabajo interesante o una técnica de prompting efectiva, ¡agrégala siguiendo la guía!

---

## 📜 Créditos y Atribuciones

- **[skills.sh](https://skills.sh/)** - Vercel Labs - Ecosistema abierto de agent skills
- **[Anthropic](https://github.com/anthropics/skills)** - Especificación y skills de referencia
- **[Agent Skills Standard](https://agentskills.io)** - Estándar de la comunidad


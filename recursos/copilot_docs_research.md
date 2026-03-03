# Resumen de Investigación: GitHub Copilot Multi-Agent Orchestration & Ecosystem

De acuerdo con la documentación de GitHub Copilot y los patrones de implementación actuales sobre la creación de agentes personalizados (`.agent.md`), Copilot permite diseñar ecosistemas de agentes descentralizados y especializados en responsabilidades reducidas. Esto se logra configurando distintos niveles de alcance, herramientas limitadas, y definiendo handoffs (transferencias) hacia otros agentes.

A continuación, se detalla la configuración de la orquestación, las transferencias, y el uso de servidores MCP para los agentes.

## 1. Creación de Agentes Personalizados (Custom Agents)

Los agentes personalizados de Copilot asisten en labores de codificación mediante archivos Markdown (`.agent.md`) que contienen *YAML frontmatter*. Pueden configurarse a distintos niveles:
- **Workspace/Repository**: Útiles para guiar un proyecto específico (`.github/agents/mi-agente.agent.md`).
- **User Profile**: Útiles en cualquier espacio de trabajo vinculados a un usuario específico.
- **Organization/Enterprise**: Creados en repositorios como `.github-private/agents/` para aplicarlos a escala global.

Estos diferentes niveles de resolución permiten evitar conflictos, con el nivel de repositorio tomando precedencia organizativa si hubiera solapamiento. 

### Propiedades Clave de Configuración
- `name`: Identificador del agente.
- `description`: Su propósito principal (requerido).
- `tools`: Selección de herramientas a las que el agente tiene acceso.
- `model`: Modelo de IA que utilizará específicamente este agente.
- `mcp-servers`: Servidores MCP que amplían sus capacidades para contextos y operaciones locales/remotas específicas.
- `target`: Dónde se usa el agente (`vscode`, `github-copilot`, etc.).

## 2. Ecosistema de Responsabilidades Reducidas

Para estructurar un ecosistema con responsabilidades reducidas cada agente debe estar claramente segmentado usando el parámetro `tools`:
- **Evitar `tools: ["*"]` o `omission` general**: Definir explícitamente herramientas (ej. solo `["read", "search"]` para un agente de revisión o `["edit", "run"]` para implementación).
- Esto resulta en menos errores, mayor precisión de llamadas y ahorro de tokens de contexto, forzando a cada agente a hacer exclusivamente su trabajo especializado.

Ejemplo de un planificador (Planner):
```yaml
---
name: implementation-planner
description: Creates detailed implementation plans and technical specifications in markdown format
tools: ["read", "search", "edit"]
---
```

## 3. Orquestación y Handoffs (Transferencia entre agentes)

La orquestación de flujos de trabajo entre agentes especializados se maneja a través de la propiedad **Handoffs**. Esto posibilita los flujos secuenciales y la intercomunicación entre componentes del ecosistema manteniendo el contexto de la tarea (generalmente disponible en IDEs).

### Mecánica del Handoff
En la cabecera YAML, se puede definir un arreglo de `handoffs`:
- `label`: Lo que verá el usuario como acción o botón ("Comenzar Implementación").
- `agent`: Identificador del agente de destino o sub-agente (ej. `implementer`).
- `prompt`: Instrucción en texto inyectada y enviada al nuevo contexto del agente.
- `send`: Booleano crítico. Si es `false`, la operación la debe confirmar el _humano-en-el-bucle_ (User-in-the-loop). Si es `true`, la transición/ejecución se lanza inmediatamente.

### Ejemplo de flujo (Planificación → Implementación → Revisión):

`planner.agent.md`
```yaml
---
name: Planner
description: Generates an architecture plan
tools: ['search', 'read']
handoffs:
  - label: Implement Plan
    agent: implementer
    prompt: Implement the plan outlined above.
    send: false 
---
```

`implementer.agent.md`
```yaml
---
name: Implementer
description: Implements the code based on an architecture plan
tools: ['search', 'read', 'edit', 'run']
handoffs:
  - label: Review Implementation
    agent: reviewer
    prompt: Review the generated implementation above against the OWASP top 10 rules.
    send: false 
---
```

## 4. Configuración de Servidores MCP Exclusivos por Agente

Además de poder configurar servidores MCP globalmente (`.vscode/mcp.json`), Copilot permite inyectarlos de manera individual usando la propiedad `mcp-servers` en el frontmatter de cada archivo `.agent.md`.

Configurar MCPs por agente consolida la **Reducción de Responsabilidad**. Sólo el agente asignado puede interactuar con una base de datos, una API en la nube (ej. JIRA) o manipular entornos productivos de CI/CD.

### Ejemplo: Configuración de MCP específico:
```yaml
---
name: launchdarkly-flag-cleanup
description: Automates feature flag cleanup workflows
tools: ['launchdarkly/*'] 
mcp-servers:
  launchdarkly:
    type: local
    command: npx
    args: ['-y', '@launchdarkly/mcp-server', 'start']
---
```

## 5. Mejores Prácticas del Ecosistema

1. **Secuencias Lógicas (Pipelines)**: Organiza pipelines obvios (Ej: Arquitecto -> Implementador -> QA/Reviewer). Limita los `handoffs` configurados en cada agente a 1 o 2 siguientes pasos para no confundir el flujo.
2. **Prompts con Contexto (Context-Aware Prompts)**: Estructura la propiedad `prompt` de un handoff referenciando lo anterior ("Usa el resultado anterior para...").
3. **El Usuario en el Centro (Human-In-The-Loop)**: Utiliza `send: false` en los handoffs de alto riesgo para garantizar que el humano pueda observar el análisis del paso A (ej. "Revisando plan de migración") antes de instruir al paso B (ej. "Lanzar migración").
4. **Least-Privilege Tooling**: Aísla las capacidades (herramientas locales y de MCP) a las estrictamente requeridas por el perfil del agente.


## 6. Configuración Avanzada YAML (Propiedades .agent.md)
De la documentación oficial `custom-agents-configuration`, Copilot admite estas propiedades en el archivo `.agent.md`:

- `name`: Nombre del agente (string, opcional).
- `description`: Descripción obligatoria de sus capacidades.
- `target`: Especifica el entorno `vscode` o `github-copilot`.
- `tools`: Array o string con límite de herramientas (ej. `["read", "edit"]`).
- `disable-model-invocation`: Si es `true`, Copilot no invocará a este agente automáticamente (requiere selección manual).
- `user-invocable`: Si es `false`, oculta el agente de la selección del usuario. Se usa solo para flujos automatizados de sub-agentes (Orquestación).
- `mcp-servers`: Objeto de configuración de Servidores MCP exclusivos.
- `model`: Define el modelo de IA específico a usar (Solo soportado en VS Code/IDEs).
- `handoffs`: Define transiciones hacia otros sub-agentes (Solo soportado en VS Code/IDEs; es ignorado en GitHub.com web).

### Referencia de Tools y Aliases
Al configurar `tools`, puedes usar los siguientes aliases integrados:
*   `execute` (o `shell`, `bash`, `powershell`): Ejecución de comandos del sistema.
*   `read` (o `view`, `NotebookRead`): Lectura de archivos.
*   `edit` (o `Write`, `NotebookEdit`): Habilidad de editar o escribir código en archivos.
*   `search` (o `Grep`, `Glob`): Habilidad de buscar recursivamente archivos y textos.
*   `agent` (o `Task`, `custom-agent`): Permite invocar internamente a otro agente. 
*   `todo` (o `TodoWrite`): Crea listas de tareas estructuradas (Solo VS Code por ahora).
*   **MCP Out-of-the-box**: Las herramientas MCP integradas se nombran usando su namespace: `github/*` o `playwright/*`. Extensiones de VSCode pueden pasarse como `azure.some-extension/some-tool`.

## 7. Jerarquía y Precedencia
El sistema de agentes personalizados funciona a través de un esquema de precedencias donde el nivel más bajo (más específico) anula (override) al de más arriba, resolviéndose por el nombre del archivo (sin `.md` o `.agent.md`):

1.  **Nivel de Repositorio:** Carpeta `.github/agents/` dentro de un repositorio de código.
2.  **Nivel de Organización:** Repositorio `.github-private` de la organización, carpeta `/agents/`.
3.  **Nivel de Enterprise:** Lo mismo, a nivel compañía entera.
4.  **Configuración Personal (IDEs):** Nivel Global local del entorno de usuario en VS Code, o en la definición global de CLI `.copilot/agents`.

Esta jerarquía afecta también al procesamiento de variables de entorno MCP y overrides locales, lo que es vital para la seguridad en ecosistemas de agentes multi-repositorio que se conectan a diferentes entornos (Desarrollo, Stage, y Producción).

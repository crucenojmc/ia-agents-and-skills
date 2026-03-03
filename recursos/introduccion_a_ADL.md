# **Arquitectura Avanzada y Orquestación de Agentes en Ecosistemas de Desarrollo Asistidos por Inteligencia Artificial**

## **1\. Arquitectura de Configuración y Estrategias de Mantenimiento Unificado**

El ecosistema de desarrollo ha madurado hasta el punto en que plataformas líderes como GitHub Copilot (en Visual Studio Code), Claude Code y la reciente incorporación de **Google Antigravity** ofrecen capacidades de alto nivel: todas soportan la ejecución en paralelo de sub-agentes, la inyección de contexto, la personalización de roles mediante esquemas y la automatización del ciclo de vida a través de flujos de trabajo o *Hooks*.

Google Antigravity redefine el paradigma al presentarse como un entorno de desarrollo (IDE) "agente-primero" (*agent-first*), introduciendo una interfaz dual que combina la vista de editor tradicional con una "Superficie de Gestión" (*Manager Surface*) para orquestar agentes de forma nativa. Al trabajar simultáneamente con esta tríada de herramientas (Copilot, Claude y Antigravity) en un mismo proyecto, el principal desafío arquitectónico no es la selección de la herramienta, sino la **estrategia de mantenimiento de las definiciones**. Declarar las habilidades, los metadatos de los agentes y las reglas del repositorio de forma duplicada genera deuda técnica y desincronización cognitiva en el equipo.

La estrategia moderna de configuración se centra en el "How-To" profundo: cómo configurar esquemas unificados, cómo enlazar directorios para que todas las IAs consuman la misma fuente de verdad, y cómo orquestar el paralelismo aprovechando las particularidades de cada motor (el *Manager* de Antigravity, los *Teams* de Claude, o los sub-agentes de Copilot) sin reescribir la lógica subyacente. Esta documentación detalla las configuraciones estructuradas compartidas y las diferencias sintácticas al definir este ecosistema agéntico unificado.

## **2\. Compendio Documental y Fuentes de Información Confiable**

Para explotar al máximo estas configuraciones compartidas y específicas, es necesario remitirse al ecosistema documental técnico de las tres plataformas y a los nuevos estándares de interoperabilidad.

| Categoría de Configuración | Fuente Documental Canónica | Propósito y Alcance del Documento |
| :---- | :---- | :---- |
| **Configuración Core de VS Code y Agentes** | code.visualstudio.com/docs/copilot/agents/overview 1 | Detalla la activación fundamental de agentes, los tipos de agentes y el ciclo de vida de las sesiones interactuando dentro del IDE. |
| **Configuración Core de Google Antigravity** | antigravity.google/docs/agent 14 | Explica los componentes base (Artefactos, Conocimiento, Planificación) y los modos de interacción en la nueva interfaz dual.14 |
| **Sub-agentes y Paralelismo en Copilot** | code.visualstudio.com/docs/copilot/agents/subagents 2 | Especifica la delegación de tareas y los mecanismos para invocar sub-agentes en paralelo en VS Code. |
| **Paralelismo Visual en Antigravity** | antigravity.google/blog/introducing-google-antigravity | Documentación sobre el uso del *Manager Surface* y el *Inbox* para trackear múltiples agentes asíncronos en paralelo. |
| **Ecosistema Claude Code y Agent Teams** | code.claude.com/docs/en/agent-teams y code.claude.com/docs/en/sub-agents 3 | Referencia arquitectónica para la configuración de equipos de agentes autónomos y paralelismo en terminal. |
| **Esquemas de Agentes Personalizados** | docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents 5 | Guía exhaustiva sobre la creación de archivos .agent.md, configuración YAML y propiedades como handoffs.5 |
| **Estándar Abierto Agent Skills** | agentskills.io y antigravity.google/docs/skills 16 | Especificación universal para la carpeta de habilidades (SKILL.md) interoperable entre Copilot, Claude y Antigravity.16 |
| **Hooks y Eventos de Ciclo de Vida** | code.visualstudio.com/docs/copilot/customization/hooks y code.claude.com/docs/en/hooks-guide | Documentación sobre cómo interceptar eventos de agentes (ej. PreToolUse) con *scripts* personalizados. |

## **3\. Parametrización y Configuración Base (VS Code y Antigravity)**

El aprovechamiento estructural de agentes requiere una configuración minuciosa de los entornos. Cada IDE tiene sus propios selectores para habilitar la autonomía que, por seguridad, están controlados mediante políticas estrictas.

**En Visual Studio Code (Copilot):** El pilar fundamental es la directiva chat.agent.enabled en el settings.json.1 En entornos corporativos, esta configuración local puede ser sistemáticamente sobrescrita por políticas de administración en la nube.1 Para escalar el uso de agentes personalizados, se utiliza github.copilot.chat.organizationCustomAgents.enabled, que indexa agentes definidos bajo .github-private.5 Adicionalmente, el límite de herramientas se optimiza con github.copilot.chat.virtualTools.threshold, permitiendo a la IA agrupar lógicamente herramientas bajo demanda para no saturar el contexto.8

**En Google Antigravity:**

Antigravity no utiliza un settings.json tradicional de la misma manera que VS Code, sino que la parametrización de autonomía se gestiona a través de la interfaz gráfica y políticas de ejecución de terminal nativas.

**How-To para Configurar Autonomía en Antigravity:**

El desarrollador debe definir el "Modo de Desarrollo", decidiendo quién conduce la ejecución:

1. **Políticas de Ejecución de Terminal:** Es crítico configurar el nivel de control en la pestaña "Agent". Puede configurarse en **"Off"** (Nunca autoejecutar comandos, salvo lista de permitidos), **"Auto"** (El agente decide según el riesgo), **"Turbo/Always proceed"** (Autoejecución continua sin pedir revisión, útil para TDD rápido), o **"Request review"** (El humano siempre debe aprobar comandos destructivos).  
2. **Modos Operativos:** Puede alternarse entre el modo **Planning** (ideal para investigación profunda) y el modo **Fast** (para tareas simples y refactorizaciones directas).

## **4\. Implementación de Modelos de Lenguaje Personalizados y Endpoints Compatibles**

Visual Studio Code facilita la conexión a modelos de terceros mediante la propiedad experimental github.copilot.chat.customOAIModels.9 Esta propiedad en el settings.json permite definir un arreglo de LLMs compatibles con la API de OpenAI (como infraestructuras de Ollama o LM Studio) especificando la URL base y los *tokens* necesarios.9

Por su parte, Claude Code utiliza la variable de entorno ANTHROPIC\_BASE\_URL para redirigir tráfico, lo que requiere frecuentemente herramientas como claude-code-proxy para traducir formatos.10

Google Antigravity, aunque impulsado nativamente por los potentes modelos Gemini 3 Pro y Flash, también permite flexibilidad multimodelo, soportando de manera nativa arquitecturas como Claude 3.5 Sonnet dentro de su propio entorno, facilitando alternar entre modelos sin necesidad de *proxys* externos. Sin embargo, se debe tener especial cuidado con el uso de *frameworks* de enrutamiento de *tokens* de terceros (como OpenClaw), ya que violaciones a los términos de servicio por manipulación de *endpoints* han resultado en restricciones automáticas de acceso a la plataforma.

## **5\. Agent Skills y Estrategias de Directorio Compartido (Evitando Duplicación)**

El estándar abierto *Agent Skills* dicta que una habilidad es un directorio con un archivo SKILL.md estructurado.12 Una de las mayores ventajas arquitectónicas actuales es que **GitHub Copilot, Claude Code y Google Antigravity comparten exactamente el mismo estándar de *Agent Skills***. Sin embargo, cada herramienta busca estas habilidades en directorios diferentes por defecto. Duplicar estos archivos es un anti-patrón de mantenimiento severo.

**Estrategia de Mantenimiento Unificado (How-To Definitivo):**

1. Copilot busca en .github/skills/ o \~/.copilot/skills/.12  
2. Claude Code busca en .claude/skills/ o \~/.claude/skills/.12  
3. Google Antigravity busca en su propio espacio, típicamente \~/.gemini/antigravity/skills/ para habilidades globales.

Para mantener una **única fuente de verdad** (Single Source of Truth) a nivel global o de proyecto, se debe utilizar un directorio principal (por ejemplo, el directorio de Claude) y crear enlaces simbólicos (*symlinks*) desde los directorios que las otras herramientas esperan leer:

Bash

\# Ejemplo a nivel global de usuario  
ln \-s \~/.claude/skills \~/.gemini/antigravity/skills  
ln \-s \~/.claude/skills \~/.copilot/skills

Al aplicar esta estrategia, si se añade una habilidad de revisión de código (con su respectivo SKILL.md y *scripts* de validación asociados), el *Agent* de Antigravity, los *Agent Teams* de Claude y el orquestador principal de Copilot tendrán acceso inmediato e idéntico a las mismas instrucciones sin ninguna refactorización adicional.

El archivo compartido SKILL.md se define universalmente con un bloque YAML y formato Markdown 12:

YAML

\---  
name: backend-auditor  
description: Activa esta habilidad al crear endpoints para asegurar protección contra inyecciones SQL.  
\---  
\# Instrucciones  
(Instrucciones detalladas de auditoría...)

## **6\. Comparativa de Esquemas: Perfiles de Agentes y Artefactos**

Para definir perfiles de agentes personalizados, estas herramientas utilizan esquemas declarativos, pero difieren en su filosofía subyacente de resultados.

**Esquema en GitHub Copilot (.agent.md):** Los agentes de VS Code se definen en .github/agents/nombre.agent.md.5

* model: Permite forzar el modelo exacto (ej. Claude Sonnet 4.5 (copilot)).7  
* tools: Un arreglo restrictivo (\["read", "edit", "search"\]).5  
* handoffs: Define identificadores de otros agentes a los cuales transferir el control.5

**Esquema en Claude Code (.claude/agents/\*.md):** Claude Code define sus sub-agentes en .claude/agents/.4

* skills: Claude permite incrustar de forma imperativa un arreglo de identificadores de habilidades que el sub-agente cargará estáticamente.4  
* isolation: Puede configurarse en worktree para aislar repositorios Git de forma automática.4

**El Enfoque Antigravity (Artefactos de Planificación):** Google Antigravity no depende de archivos de perfil estáticos tan rígidos como .agent.md. En su lugar, el sistema de agentes se basa en la generación proactiva de **Artefactos** (*Artifacts*). Antes de escribir cualquier línea de código, el agente de Antigravity genera un "Plan de Implementación" (*Implementation Plan*) y una "Lista de Tareas" (*Task List*) estructurada en la interfaz gráfica.15 Como usuario supervisor ("Review-driven development"), modificas este artefacto visual, y el agente adapta su comportamiento de ejecución. Tras finalizar, entrega un artefacto tipo "Walkthrough" (Guía interactiva) para auditar los cambios aplicados.15

## **7\. Orquestación Paralela: El "How-To" Multi-Entorno**

La orquestación paralela es donde las plataformas muestran sus mayores diferencias arquitectónicas, evolucionando desde la simple delegación de *prompts* hacia la simulación de departamentos enteros de ingeniería.

**El How-To para forzar Paralelismo en Copilot (VS Code):** El paralelismo se dispara mediante el *prompting* explícito en el esquema del agente orquestador principal.13

1. Asegurar que la herramienta runSubagent esté declarada bajo la propiedad tools del archivo .agent.md.2  
2. Instruir imperativamente al agente: *"Utiliza la herramienta \#runSubagent para invocar al sub-agente 'Explorer' tres veces en paralelo..."*.13  
3. La interfaz gráfica de VS Code despliega de forma visual las invocaciones simultáneas como herramientas colapsables operando al unísono, resumiendo datos hacia la ventana principal.2

**Agent Teams en Claude Code (Terminal):** Anthropic resuelve el paralelismo con **Agent Teams** descentralizados.4

1. Se habilita inyectando "CLAUDE\_CODE\_EXPERIMENTAL\_AGENT\_TEAMS": "1" en settings.json.3  
2. Se inicializa descriptivamente: *"Crea un equipo con un arquitecto, un tester y un frontend"*.3  
3. Los agentes se coordinan reclamando tareas de un registro local (\~/.claude/tasks/) utilizando bloqueos de archivos del sistema operativo para prevenir colisiones.3  
4. Exige usar multiplexadores externos como tmux o iTerm2 para visualizar paneles divididos en tiempo real.3

**El "Manager Surface" en Google Antigravity:**

Antigravity ha diseñado su interfaz explícitamente para el paralelismo asíncrono. Mientras que Claude Code requiere tmux en la terminal, Antigravity proporciona el **Manager Surface** (Superficie de Gestión).

1. **How-To:** El desarrollador actúa literalmente como un *manager*. Envías al Agente A a realizar una refactorización de base de datos asíncrona en un área de trabajo separada, mientras mantienes abierto tu *Editor View* síncrono para programar la lógica del *frontend*.  
2. **El Inbox Agéntico:** Antigravity introduce el concepto de "Inbox" (Bandeja de entrada). En lugar de bloquear la ventana de chat esperando resultados, el agente trabaja en segundo plano. Cuando el agente termina de planificar, o necesita la aprobación de un comando de terminal (si está configurado en "Request review"), envía una notificación al Inbox. El desarrollador revisa el artefacto propuesto, aprueba y continúa.  
3. **Sub-agente de Navegador:** Antigravity incorpora nativamente herramientas de control de navegador (*Browser control capabilities*), permitiendo a los agentes paralelos probar cambios en UI (interfaz de usuario) interactuando autónomamente con el DOM, renderizando grabaciones o capturas (*Browser Recordings* / *Screenshots*) que se adjuntan en los reportes de revisión.

## **8\. Configuración de Hooks y Gestión del Ciclo de Vida**

Las tres plataformas ofrecen mecanismos para automatizar procesos e interceptar el flujo de trabajo del agente, garantizando seguridad y estandarización de la empresa.

**Configuración de Hooks en GitHub Copilot:** Manejados mediante .github/copilot-hooks.json. Permite interceptar eventos como PreToolUse para validar con un *script* de seguridad si el agente tiene permiso para ejecutar un comando específico, o SubagentStart para preparar un *worktree* asilado de Git.2

**Configuración de Hooks en Claude Code:** Se gestionan en .claude/settings.json o interactivamente con /hooks. Orientados a la terminal pura, permiten usar TaskCompleted o TeammateIdle como compuertas de calidad, denegando el cierre de una tarea emitiendo un código de salida exit 2 si los tests locales fallan.3

**Flujos de Trabajo (Workflows) en Antigravity:**

Antigravity adopta un enfoque de estandarización directa. El comportamiento tipo "hook" para automatizar secuencias de acciones o gatillar verificaciones se orquesta definiendo procesos personalizados de múltiples pasos ubicados estructuralmente dentro del directorio .agent/workflows/. Al colocar lógica procedural allí, Antigravity puede interceptar necesidades operativas antes, durante y después de completar un "Implementation Plan".

## **9\. Estandarización Futura y Mantenimiento Definitivo: Agent Definition Language (ADL)**

La proliferación de configuraciones sutilmente distintas y metodologías (VS Code con sus .agent.md, Claude con CLAUDE.md, y Antigravity con sus reglas y *workflows* en .agent/) crea un ecosistema fragmentado. Como estrategia de mantenimiento corporativo superior, las organizaciones modernas están adoptando el **Agent Definition Language (ADL)**.

ADL es una especificación abierta y declarativa (con licencia Apache 2.0) diseñada para estandarizar la identidad, los modelos, las herramientas, los roles y los permisos de los agentes a través de una única fuente YAML neutral al proveedor.

**Estrategia How-To de ADL:**

1. Los ingenieros ya no escriben configuraciones directamente en el formato propietario de GitHub, Anthropic o Google. En su lugar, escriben un esquema ADL universal.  
2. Utilizando la herramienta adl-cli, el proceso de integración continua compila y genera automáticamente los andamios requeridos para .github/agents/, .claude/agents/ y los flujos de Antigravity simultáneamente.  
3. Esto unifica la auditoría de seguridad y la portabilidad, mitigando de raíz el esfuerzo de mantener directivas operativas en paralelo entre los tres gigantes del desarrollo asistido.

#### **Fuentes citadas**

1. Using agents in Visual Studio Code, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/agents/overview](https://code.visualstudio.com/docs/copilot/agents/overview)  
2. Subagents in Visual Studio Code, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/agents/subagents](https://code.visualstudio.com/docs/copilot/agents/subagents)  
3. Orchestrate teams of Claude Code sessions \- Claude Code Docs, acceso: marzo 2, 2026, [https://code.claude.com/docs/en/agent-teams](https://code.claude.com/docs/en/agent-teams)  
4. Create custom subagents \- Claude Code Docs, acceso: marzo 2, 2026, [https://code.claude.com/docs/en/sub-agents](https://code.claude.com/docs/en/sub-agents)  
5. Creating custom agents for Copilot coding agent \- GitHub Docs, acceso: marzo 2, 2026, [https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)  
6. Tutorial: Work with agents in VS Code, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/agents/agents-tutorial](https://code.visualstudio.com/docs/copilot/agents/agents-tutorial)  
7. Custom agents in VS Code, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/customization/custom-agents](https://code.visualstudio.com/docs/copilot/customization/custom-agents)  
8. GitHub Copilot in VS Code settings reference, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/reference/copilot-settings](https://code.visualstudio.com/docs/copilot/reference/copilot-settings)  
9. AI language models in VS Code, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/customization/language-models](https://code.visualstudio.com/docs/copilot/customization/language-models)  
10. Connecting Claude Code to Local LLMs: Two Practical Approaches \- Medium, acceso: marzo 2, 2026, [https://medium.com/@michael.hannecke/connecting-claude-code-to-local-llms-two-practical-approaches-faa07f474b0f](https://medium.com/@michael.hannecke/connecting-claude-code-to-local-llms-two-practical-approaches-faa07f474b0f)  
11. fuergaosi233/claude-code-proxy: Claude Code to OpenAI API Proxy \- GitHub, acceso: marzo 2, 2026, [https://github.com/fuergaosi233/claude-code-proxy](https://github.com/fuergaosi233/claude-code-proxy)  
12. Use Agent Skills in VS Code, acceso: marzo 2, 2026, [https://code.visualstudio.com/docs/copilot/customization/agent-skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills)  
13. Subagents are now INCREDIBLY functional, its wild : r/GithubCopilot \- Reddit, acceso: marzo 2, 2026, [https://www.reddit.com/r/GithubCopilot/comments/1qqzknq/subagents\_are\_now\_incredibly\_functional\_its\_wild/](https://www.reddit.com/r/GithubCopilot/comments/1qqzknq/subagents_are_now_incredibly_functional_its_wild/)  
14. Google Antigravity Documentation, acceso: marzo 3, 2026, [https://antigravity.google/docs/agent](https://antigravity.google/docs/agent)  
15. Getting Started with Google Antigravity \- Google Codelabs, acceso: marzo 3, 2026, [https://codelabs.developers.google.com/getting-started-google-antigravity](https://codelabs.developers.google.com/getting-started-google-antigravity)  
16. Google Antigravity Documentation, acceso: marzo 3, 2026, [https://antigravity.google/docs/skills](https://antigravity.google/docs/skills)
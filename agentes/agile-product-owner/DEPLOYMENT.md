# Agile Product Owner Agent - Guía de Despliegue

## 📋 Resumen de la Arquitectura

El agente `agile-product-owner` usa un **patrón híbrido (Global Bootstrap + Project Full)** para resolver las limitaciones de VS Code con agentes globales.

### ¿Por qué este diseño?

VS Code tiene una limitación fundamental: **los agentes globales (`~/.github/agents/`) no heredan herramientas del workspace**. Cuando configuras un agente globalmente:

| Capacidad | A nivel de Proyecto | A nivel Global |
|-----------|:------------------:|:--------------:|
| Tools built-in (`read`, `search`) | ✅ | ⚠️ Parcial |
| Tools de edición (`edit`, `bash`) | ✅ | ❌ Deshabilitado |
| `mcp-servers:` en frontmatter | ✅ | ❌ No se resuelve |
| `handoffs:` a sub-agentes | ✅ | ❌ No encuentra agentes |
| MCP global (`.vscode/mcp.json`) | ✅ Hereda | ❌ No hereda |
| Skills del proyecto | ✅ Descubre | ❌ No ve |

**Causa raíz:** Un agente global no tiene un directorio de proyecto asociado, por lo que VS Code no puede resolver paths de MCP servers, no encuentra sub-agentes definidos en otros scopes, y las herramientas que requieren un workspace activo quedan deshabilitadas.

### La Solución: Patrón Bootstrap

```
~/.github/agents/
  └── agile-product-owner.agent.md   ← Bootstrap (read-only, consultivo)

<tu-proyecto>/.github/agents/
  ├── agile-product-owner.agent.md   ← OVERRIDE completo (edición + handoffs)
  ├── plan-mejorado.agent.md         ← Planificador mejorado (peer del PO)
  ├── po-story-writer.agent.md       ← Sub-agente: crea archivos MD
  ├── po-ado-sync.agent.md           ← Sub-agente: sync ADO (tiene MCP) [compartido]
  ├── po-mysql-explorer.agent.md     ← Sub-agente: explora MySQL (tiene MCP) [compartido]
  └── po-analyst.agent.md            ← Sub-agente: analiza requerimientos
```

**¿Cómo funciona?**
1. El agente global está siempre disponible en cualquier workspace
2. Cuando abres un proyecto que tiene su propia versión en `.github/agents/`, el **nivel de proyecto hace override** del global (precedencia workspace > global)
3. Los sub-agentes y MCP solo existen a nivel de proyecto donde SÍ funcionan

---

## 🚀 Instalación

### Opción 1: Script automático

```bash
# Solo global (modo reducido, siempre disponible)
./scripts/install-po-agents.sh --global

# Solo proyecto (funcionalidad completa)
./scripts/install-po-agents.sh --project /ruta/a/mi-proyecto

# Ambos (recomendado)
./scripts/install-po-agents.sh --all /ruta/a/mi-proyecto

# Ver qué haría sin ejecutar
./scripts/install-po-agents.sh --all /ruta/a/mi-proyecto --dry-run
```

### Opción 2: Manual

```bash
# 1. Global bootstrap
mkdir -p ~/.github/agents
cp global/agile-product-owner.agent.md ~/.github/agents/

# 2. Proyecto completo
mkdir -p /ruta/a/mi-proyecto/.github/agents
cp project/*.agent.md /ruta/a/mi-proyecto/.github/agents/
```

---

## ⚙️ Configuración de MCP (Azure DevOps)

El sub-agente `po-ado-sync` necesita el MCP de Azure DevOps. Hay dos formas de configurarlo:

### Opción A: En el agente (ya incluido)

El archivo `po-ado-sync.agent.md` ya incluye la configuración MCP en su frontmatter.
Solo necesitas configurar las variables de entrada cuando VS Code te las pida:

- `azure_devops_org_url`: URL de tu organización (ej: `https://dev.azure.com/mi-org`)
- `azure_devops_pat`: Tu Personal Access Token

### Opción B: En `.vscode/mcp.json` (compartido con todo el workspace)

```json
{
  "servers": {
    "azure-devops-mcp": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "azure-devops-mcp"],
      "env": {
        "AZURE_DEVOPS_ORG_URL": "https://dev.azure.com/mi-org",
        "AZURE_DEVOPS_AUTH_METHOD": "pat",
        "AZURE_DEVOPS_PAT": "${env:AZURE_DEVOPS_PAT}"
      }
    }
  }
}
```

> **Recomendación:** Usa la Opción B si quieres que otros agentes también accedan a Azure DevOps. Usa la Opción A si solo el PO debe tener acceso (principio de menor privilegio).

### Configuración de MCP (MySQL)

El sub-agente `po-mysql-explorer` necesita acceso a MySQL. Similar a ADO:

#### Opción A: En el agente (ya incluido)

El archivo `po-mysql-explorer.agent.md` incluye dos servidores MCP (principal y retail).
Configurará las variables de entrada cuando VS Code las solicite:

- `mysql_host`, `mysql_port`, `mysql_user`, `mysql_password`, `mysql_database` (instancia principal)
- `mysql_retail_host`, `mysql_retail_port`, etc. (instancia retail)

#### Opción B: En `.vscode/mcp.json` (compartido)

```json
{
  "servers": {
    "mcp_server_mysql": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@benborla29/mcp-server-mysql"],
      "env": {
        "MYSQL_HOST": "${env:MYSQL_HOST}",
        "MYSQL_PORT": "${env:MYSQL_PORT}",
        "MYSQL_USER": "${env:MYSQL_USER}",
        "MYSQL_PASSWORD": "${env:MYSQL_PASSWORD}",
        "MYSQL_DATABASE": "${env:MYSQL_DATABASE}"
      }
    },
    "mcp_server_mysql_retail": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@benborla29/mcp-server-mysql"],
      "env": {
        "MYSQL_HOST": "${env:MYSQL_RETAIL_HOST}",
        "MYSQL_PORT": "${env:MYSQL_RETAIL_PORT}",
        "MYSQL_USER": "${env:MYSQL_RETAIL_USER}",
        "MYSQL_PASSWORD": "${env:MYSQL_RETAIL_PASSWORD}",
        "MYSQL_DATABASE": "${env:MYSQL_RETAIL_DATABASE}"
      }
    }
  }
}
```

---

## 🏗️ Arquitectura de Agentes

### Diagrama del Ecosistema

```
                         ┌─────────────────────────────────┐
                         │        Usuario / Humano          │
                         └───────────────┬─────────────────┘
                                        │
                     ┌───────────────┴───────────────┐
                     │   Selección de Modo/Agente         │
                     └───────┬───────────────┬─────────┘
                             │               │
                  ┌─────────┴─────┐  ┌─────┴────────────┐
                  │ Plan Mejorado    │  │ agile-product-   │
                  │ (Planificador)   │  │ owner            │
                  │                  │  │ (Orquestador)    │
                  │ 📝 Solo planifica │  │ ⚙️  Gestiona backlog│
                  │ NO implementa   │  │ crea + sincroniza│
                  └──┬─────┬─────┬──┘  └─┬────┬────┬────┬─┘
                    │     │     │       │    │    │    │
             ┌─────┘     │     │       │    │    │    └──────┐
             │           │     │       │    │    │         │
             │      ┌────┴────┴───────┴────┴─┐  │    ┌─────┴────┐
             │      │    POOL DE SUB-AGENTES   │  │    │ po-story- │
             │      │      (compartidos)       │  │    │ writer    │
             │      └──┬────────────┬───────┘  │    │ edit      │
             │        │            │           │    │ user:false │
      ┌──────┴──┐  ┌─┴────────┐  ┌─┴───────┐  │    └───────────┘
      │ Explore   │  │ po-ado-   │  │ po-mysql- │  │
      │ (built-in)│  │ sync     │  │ explorer  │  │    ┌───────────┐
      │           │  │          │  │           │  └────│ po-analyst│
      │ read,     │  │ MCP: ADO │  │ MCP: MySQL│       │           │
      │ search    │  │ edit     │  │ read-only │       │ read,     │
      │           │  │ user:fls │  │ user:fls  │       │ search    │
      └───────────┘  └──────────┘  └───────────┘       │ user:false│
                                                    └───────────┘
```

**Leyenda:**
- 🟢 **User-invocable (peers):** `Plan Mejorado` y `agile-product-owner` — el usuario los selecciona directamente
- 🔴 **Sub-agentes (`user-invocable: false`):** Solo se invocan vía handoff/delegation
- 🔵 **Compartidos:** `po-ado-sync`, `po-mysql-explorer`, `Explore` — usados por ambos peers
- 🟠 **Exclusivos del PO:** `po-story-writer`, `po-analyst` — solo el PO los necesita

### Flujos de Handoff

```
┌───────────────────────────────────────────────────────┐
│ FLUJO A: Planificación → Backlog                          │
│                                                         │
│ Plan Mejorado ──────────────────────────────────── │
│  │                                                       │
│  ├─[agents]─▶ Explore (codebase)                           │
│  ├─[agents]─▶ po-ado-sync (consulta ADO: items, sprints)   │
│  ├─[agents]─▶ po-mysql-explorer (esquemas, datos)          │
│  │                                                       │
│  ├─[handoff]─▶ Start Implementation (agent por defecto)    │
│  ├─[handoff]─▶ Open in Editor                              │
│  └─[handoff]─▶ 📋 Crear Backlog ─▶ agile-product-owner      │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│ FLUJO B: PO directo (Gestión de Backlog)                 │
│                                                         │
│ agile-product-owner ─────────────────────────────── │
│  │                                                       │
│  ├─[handoff]─▶ 🔍 Analizar ─▶ po-analyst                  │
│  ├─[handoff]─▶ 🗓️ Explorar BD ─▶ po-mysql-explorer         │
│  ├─[handoff]─▶ 📐 Planificar ─▶ Plan Mejorado              │
│  ├─[handoff]─▶ 📝 Escribir Historias ─▶ po-story-writer     │
│  └─[handoff]─▶ 🔄 Sincronizar ADO ─▶ po-ado-sync            │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│ FLUJO C: Completo (Plan → PO → Sync)                    │
│                                                         │
│ Plan Mejorado                                           │
│  ├─ Discovery (Explore + MySQL + ADO queries)            │
│  ├─ Alignment (askQuestions al usuario)                  │
│  ├─ Design (genera plan)                                │
│  └─ [handoff] 📋 Crear Backlog ─▶                          │
│       agile-product-owner                               │
│        ├─ Decomposition (plan → epics/features/stories)  │
│        ├─ [handoff] 📝 ─▶ po-story-writer (crea MDs)      │
│        ├─ Validation (usuario aprueba)                   │
│        └─ [handoff] 🔄 ─▶ po-ado-sync (sube a ADO)       │
└───────────────────────────────────────────────────────┘
```

### Principio de Menor Privilegio

| Agente | read | search | edit | execute | MCP ADO | MCP MySQL | agent | user-invocable |
|--------|:----:|:------:|:----:|:-------:|:-------:|:---------:|:-----:|:--------------:|
| `Plan Mejorado` | ✅ | ✅ | ❌ | ❌ | ❌¹ | ❌¹ | ✅ | ✅ |
| `agile-product-owner` | ✅ | ✅ | ✅ | ✅ | ❌¹ | ❌¹ | ✅ | ✅ |
| `po-analyst` | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `po-story-writer` | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| `po-ado-sync` | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| `po-mysql-explorer` | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |

> ¹ Los peers (Plan y PO) NO tienen MCP directo. Delegan a sub-agentes especializados que son los únicos con acceso MCP.

### ¿Quién Consume a Quién?

| Sub-Agente | Consumido por Plan | Consumido por PO | MCP que posee |
|------------|:------------------:|:-----------------:|:-------------:|
| `Explore` | ✅ (agents) | ❌ | — (built-in) |
| `po-ado-sync` | ✅ (agents) | ✅ (handoff) | Azure DevOps |
| `po-mysql-explorer` | ✅ (agents) | ✅ (handoff) | MySQL × 2 |
| `po-analyst` | ❌ | ✅ (handoff) | — |
| `po-story-writer` | ❌ | ✅ (handoff) | — |
| `Plan Mejorado` | — | ✅ (handoff) | — |

---

## 🔧 Configuración de Skills del Proyecto

Para que el agente funcione completamente, el proyecto destino debe tener estos skills:

```bash
# Estructura recomendada del proyecto destino
mi-proyecto/
├── .github/
│   ├── agents/                          # Agentes (copiados de aquí)
│   │   ├── agile-product-owner.agent.md  # Orquestador PO
│   │   ├── plan-mejorado.agent.md        # Planificador mejorado
│   │   ├── po-story-writer.agent.md      # Sub: escritor de historias
│   │   ├── po-ado-sync.agent.md          # Sub: sync ADO (compartido)
│   │   ├── po-mysql-explorer.agent.md    # Sub: explorador MySQL (compartido)
│   │   └── po-analyst.agent.md           # Sub: analista
│   └── skills/                          # Skills (symlinks o copias)
│       ├── agile-context-injection/
│       ├── agile-decomposition/
│       ├── user-story-writing/
│       ├── backlog-dual-format/
│       └── azure-devops-integration/
├── .vscode/
│   └── mcp.json                         # MCP servers compartidos
└── backlog/                             # Generado por el agente
    ├── _index.md
    ├── epics/
    ├── features/
    ├── user-stories/
    ├── tasks/
    └── json/
```

---

## ❓ Troubleshooting

### "Las herramientas están deshabilitadas"

**Causa:** Estás usando el agente global, no la versión de proyecto.  
**Solución:** Instala los agentes a nivel de proyecto con `install-po-agents.sh --project <path>`.

### "El handoff no encuentra al sub-agente"

**Causa:** Los sub-agentes deben estar en el mismo scope que el orquestador.  
**Solución:** Verifica que todos los `.agent.md` están en `.github/agents/` del proyecto:
`po-story-writer`, `po-ado-sync`, `po-analyst`, `po-mysql-explorer`, `plan-mejorado`.

### "El MCP de Azure DevOps no responde"

**Causa:** El servidor MCP no está configurado o las credenciales son inválidas.  
**Solución:**
1. Verifica que `npx azure-devops-mcp` funciona localmente
2. Configura las variables de entorno o `input:` prompts
3. Revisa `.vscode/mcp.json` si usas configuración compartida

### "El MCP de MySQL no conecta"

**Causa:** Credenciales incorrectas, servidor caído, o paquete npm no disponible.  
**Solución:**
1. Verifica conectividad: `mysql -h <host> -u <user> -p <db>`
2. Verifica que `npx @benborla29/mcp-server-mysql` se instala correctamente
3. Configura las variables de entorno o revisa los `input:` prompts del agente

### "El agente no carga los skills"

**Causa:** Los skills no están en `.github/skills/` del proyecto.  
**Solución:** Copia o crea symlinks de los skills necesarios desde este repositorio.

---

## 📝 Changelog

| Fecha | Cambio |
|-------|--------|
| 2026-03-04 | Migración a patrón híbrido (Global Bootstrap + Project Full) |
| 2026-03-04 | Descomposición en 3 sub-agentes (analyst, story-writer, ado-sync) |
| 2026-03-04 | Agregada configuración MCP embebida en po-ado-sync |
| 2026-03-04 | Agregado Plan Mejorado como peer del PO con sub-agentes compartidos |
| 2026-03-04 | Nuevo sub-agente po-mysql-explorer para exploración de BD |
| 2026-03-04 | Handoffs bidireccionales entre Plan Mejorado ↔ PO |

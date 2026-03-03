# SundialHub — Documentación de Referencia

> **Registry centralizado de Agent Skills para agentes de IA.**
> Fuente: https://www.sundialhub.com/ | Spec: https://agentskills.io/

---

## 🗂️ Índice

1. [¿Qué es SundialHub?](#1-qué-es-sundialhub)
2. [El Estándar Agent Skills (agentskills.io)](#2-el-estándar-agent-skills-agentskillsio)
3. [Cómo Funcionan los Skills](#3-cómo-funcionan-los-skills)
4. [Estructura de un Skill](#4-estructura-de-un-skill)
5. [Formato SKILL.md — Especificación Completa](#5-formato-skillmd--especificación-completa)
6. [CLI: Comandos sundial-hub](#6-cli-comandos-sundial-hub)
7. [Rutas de Instalación por Agente](#7-rutas-de-instalación-por-agente)
8. [Publicación: Push, Versiones y Visibilidad](#8-publicación-push-versiones-y-visibilidad)
9. [Categorías Disponibles](#9-categorías-disponibles)
10. [Flujos de Trabajo](#10-flujos-de-trabajo)
11. [Integración de Skills en Agentes (Para Desarrolladores)](#11-integración-de-skills-en-agentes-para-desarrolladores)
12. [Prácticas Recomendadas de Autoría](#12-prácticas-recomendadas-de-autoría)
13. [Integración con el Flujo MAPPLICS](#13-integración-con-el-flujo-mapplics)
14. [Señales de Confianza al Elegir un Skill](#14-señales-de-confianza-al-elegir-un-skill)
15. [Validación con skills-ref](#15-validación-con-skills-ref)
16. [URLs y Endpoints Útiles](#16-urls-y-endpoints-útiles)
17. [Top Skills por Instalaciones](#17-top-skills-por-instalaciones)
18. [Blog: Posts Destacados](#18-blog-posts-destacados)
19. [Seguridad](#19-seguridad)
20. [Anti-Patrones a Evitar](#20-anti-patrones-a-evitar)
21. [API HTTP Directa (Sin CLI)](#21-api-http-directa-sin-cli)
22. [Autenticación Programática](#22-autenticación-programática)
23. [Seguridad Pre-Publicación](#23-seguridad-pre-publicación)
24. [Lecciones de Automatización (Troubleshooting)](#24-lecciones-de-automatización-troubleshooting)

---

## 1. ¿Qué es SundialHub?

SundialHub es el **registry abierto de skills para agentes de IA**. Funciona de forma análoga a **npm para el ecosistema de Agent Skills**: permite descubrir, compartir e instalar skills de forma eficiente entre cualquier agente compatible.

**Cifras clave (2026):**
- 52,923+ skills públicos disponibles
- Compatible con todos los agentes de IA modernos

**La premisa:** Todo agente de IA moderno — Claude Code, Cursor, Copilot, Codex, Gemini, etc. — puede leer Markdown. Ese sustrato compartido significa que **un único archivo SKILL.md funciona en todos lados**. Sundial es el registry que hace que descubrir, compartir e instalar esos skills sea fácil.

**Agentes compatibles:**
- Claude Code (Anthropic)
- Cursor
- GitHub Copilot
- OpenAI Codex
- Gemini CLI / Antigravity
- Roo Code
- Databricks
- Factory
- Emdash
- ChatGPT (con acceso a filesystem)
- ...y cualquier agente que soporte el estándar Agent Skills

**Contacto:** team@sundialhub.com | [@sundialhub](https://twitter.com/sundialhub) en Twitter

---

## 2. El Estándar Agent Skills (agentskills.io)

El estándar de **Agent Skills** fue desarrollado originalmente por **Anthropic** y luego liberado como estándar abierto. La especificación oficial vive en:

> **https://agentskills.io/**

**¿Por qué existen los skills?** Los agentes de IA tienen capacidades que muchos usuarios desconocen. Un skill cierra la brecha entre lo que el agente ya puede hacer y lo que sabe hacer en un contexto específico. Como dice el blog de Sundial: *"Darle a Claude el conocimiento correcto sobre Tinker y, de repente, puede hacer fine-tuning de modelos. La capacidad siempre estuvo ahí."*

**Beneficios del estándar abierto:**
- Formato único que funciona en todos los agentes
- No requiere reinventar la rueda por cada plataforma
- Comunidad compartida de skills reutilizables
- Interoperabilidad garantizada

---

## 3. Cómo Funcionan los Skills

### Arquitectura de Divulgación Progresiva (Progressive Disclosure)

Los skills usan un modelo de carga en **3 niveles** diseñado para mantener el contexto eficiente:

```
Nivel 1 — Metadatos (~100 tokens)
  └─ Al startup: solo se cargan name + description del YAML frontmatter
  └─ El agente sabe QUÉ skills existen sin leer nada más

Nivel 2 — Cuerpo del SKILL.md (<5000 tokens recomendado)
  └─ Cuando el skill se activa: se lee el cuerpo completo del SKILL.md
  └─ Solo ocurre cuando la tarea del usuario coincide con el skill

Nivel 3 — Archivos referenciados (bajo demanda)
  └─ Referencias en SKILL.md se cargan solo cuando se necesitan
  └─ Scripts se ejecutan sin cargar su código al contexto
```

**Beneficio clave:** Los archivos de referencia, datos o documentación **no consumen tokens de contexto** hasta que se leen activamente. Esto permite incluir documentación completa sin penalizar el contexto.

### Proceso de Activación

Un agente compatible con skills debe:
1. **Descubrir** skills en directorios configurados (scan de carpetas con SKILL.md)
2. **Cargar metadatos** (name + description) al startup
3. **Hacer match** de tareas del usuario con skills relevantes
4. **Activar** el skill cargando las instrucciones completas
5. **Ejecutar** scripts y acceder a recursos según sea necesario

### Cómo los Agentes Inyectan Skills en Contexto

Para agentes basados en Claude, el formato recomendado para el system prompt es XML:

```xml
<available_skills>
  <skill>
    <name>pdf-processing</name>
    <description>Extracts text and tables from PDF files, fills forms, merges documents.</description>
    <location>/path/to/skills/pdf-processing/SKILL.md</location>
  </skill>
  <skill>
    <name>data-analysis</name>
    <description>Analyzes datasets, generates charts, and creates summary reports.</description>
    <location>/path/to/skills/data-analysis/SKILL.md</location>
  </skill>
</available_skills>
```

- **Agentes basados en filesystem:** incluir el campo `location` con ruta absoluta al SKILL.md
- **Agentes basados en herramientas:** el campo `location` puede omitirse
- **Coste por skill:** ~50-100 tokens de metadatos en el contexto inicial

---

## 4. Estructura de un Skill

### Estructura Mínima

```
my-skill/
└── SKILL.md          # Obligatorio. YAML frontmatter + cuerpo Markdown
```

### Estructura Completa (Recomendada)

```
my-skill/
├── SKILL.md              # Obligatorio — instrucciones principales
├── references/           # Documentación que el agente lee bajo demanda
│   ├── api-reference.md
│   ├── examples.md
│   └── advanced.md
├── scripts/              # Scripts ejecutables (Bash, Python, JS)
│   ├── analyze.py
│   ├── validate.sh
│   └── process.js
└── assets/               # Templates, configs, recursos estáticos
    ├── template.json
    └── config.yaml
```

### Regla de Profundidad de Referencias

> ⚠️ **IMPORTANTE:** Las referencias deben estar a **un solo nivel de profundidad** desde SKILL.md.
> referencias anidadas (SKILL.md → advanced.md → details.md) pueden causar lecturas incompletas.

**Mal:** `SKILL.md → advanced.md → details.md`
**Bien:** `SKILL.md → advanced.md` y `SKILL.md → details.md`

### Organización por Dominio (patrón recomendado)

Cuando el skill cubre múltiples dominios, organizar el contenido por dominio evita cargar contexto irrelevante:

```
bigquery-skill/
├── SKILL.md              # Overview y navegación
└── reference/
    ├── finance.md        # Revenue, ARR, billing
    ├── sales.md          # Opportunities, pipeline
    ├── product.md        # API usage, features
    └── marketing.md      # Campaigns, attribution
```

---

## 5. Formato SKILL.md — Especificación Completa

### Frontmatter Mínimo (Obligatorio)

```yaml
---
name: my-skill
description: What this skill does and when to use it.
---
```

### Frontmatter Completo con Campos Opcionales

```yaml
---
name: pdf-processing
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
license: MIT
metadata:
  author: tu-usuario
  version: "1.0"
allowed-tools: Bash Read Glob
compatibility: Requires python3, pdfplumber
---
```

### Reglas de Validación: Campo `name`

| Regla | Descripción |
|-------|-------------|
| Longitud | 1–64 caracteres |
| Caracteres permitidos | Solo minúsculas alfanuméricas (`a-z`, `0-9`) y guiones (`-`) |
| Inicio/fin | No puede empezar ni terminar con `-` |
| Consecutivos | No puede tener guiones dobles (`--`) |
| Directorio | Debe coincidir con el nombre del directorio padre |
| XML | No puede contener etiquetas XML |
| Palabras reservadas | No puede contener `anthropic` ni `claude` |

### Reglas de Validación: Campo `description`

| Regla | Descripción |
|-------|-------------|
| Longitud | 1–1024 caracteres |
| Vacío | No puede estar vacío |
| XML | No puede contener etiquetas XML |
| Contenido | Debe describir QUÉ hace el skill Y CUÁNDO usarlo |
| Persona | Siempre en tercera persona (el sistema la inyecta como descripción de agente) |

### Ejemplos de Descripciones Efectivas

```yaml
# ✅ BIEN — específica, con triggers, tercera persona
description: >
  Extracts text and tables from PDF files, fills forms, merges documents.
  Use when working with PDF files or when the user mentions PDFs, forms,
  or document extraction.

# ✅ BIEN — incluye todos los triggers clave
description: >
  Analyzes Excel spreadsheets, creates pivot tables, generates charts.
  Use when analyzing Excel files, spreadsheets, tabular data, or .xlsx files.

# ❌ MAL — vaga, sin triggers
description: "Helps with documents"

# ❌ MAL — primera persona
description: "I can help you process Excel files"

# ❌ MAL — segunda persona
description: "You can use this to process Excel files"
```

### Convenciones de Naming

**Formato gerundio (recomendado):**
- `processing-pdfs`
- `analyzing-spreadsheets`
- `managing-databases`
- `testing-code`
- `writing-documentation`

**Alternativas aceptables:**
- Noun phrases: `pdf-processing`, `spreadsheet-analysis`
- Action-oriented: `process-pdfs`, `analyze-spreadsheets`

**Evitar:**
- Nombres vagos: `helper`, `utils`, `tools`
- Genéricos: `documents`, `data`, `files`
- Reserved words: `anthropic-helper`, `claude-tools`

### Límite del Cuerpo SKILL.md

> ⚠️ **Mantener el cuerpo SKILL.md bajo 500 líneas.** Si el contenido supera este límite, mover material detallado a archivos en `references/`.

---

## 6. CLI: Comandos sundial-hub

### Instalación

```bash
# Instalar globalmente (opcional)
npm install -g sundial-hub

# Usar sin instalación (recomendado)
npx sundial-hub <comando>
```

**Requisito:** Node.js ≥ 18

### Buscar Skills

```bash
# Búsqueda interactiva
npx sundial-hub find

# Con query específica
npx sundial-hub find "web search"

# Output JSON para agentes (con límite)
npx sundial-hub find "<tarea>" --json --limit 10
```

### Instalar Skills

```bash
# Desde el registry (por nombre)
npx sundial-hub add tinker

# Desde GitHub
npx sundial-hub add github.com/user/repo

# Desde carpeta local
npx sundial-hub add ./my-local-skill

# Con flags adicionales
npx sundial-hub add --yes --claude <author>/<skill>   # Auto-confirmar, target Claude Code
npx sundial-hub add --cursor <author>/<skill>         # Target Cursor
npx sundial-hub add --codex <author>/<skill>          # Target Codex
```

### Publicar Skills

```bash
# Autenticar (solo necesario para publicar)
npx sundial-hub auth login

# Push desde directorio actual
npx sundial-hub push .

# Push con opciones completas
npx sundial-hub push ./my-skill \
  --version 2 \
  --changelog "Added PDF form support" \
  --visibility public \
  --categories coding,productivity
```

### Ver Tus Skills

```bash
npx sundial-hub mine
```

---

## 7. Rutas de Instalación por Agente

| Agente | Ruta de Instalación |
|--------|---------------------|
| **Claude Code** | `.claude/skills/<skill-name>/SKILL.md` |
| **Cursor** | `.cursor/skills/<skill-name>/SKILL.md` |
| **OpenAI Codex** | `.codex/skills/<skill-name>/SKILL.md` |
| **Gemini CLI** | `.gemini/skills/<skill-name>/SKILL.md` |
| **GitHub Copilot** | `.github/skills/<skill-name>/SKILL.md` |
| **Antigravity** | `.agent/skills/<skill-name>/SKILL.md` |
| **Global Claude** | `~/.claude/skills/<skill-name>/SKILL.md` |
| **Global Gemini** | `~/.gemini/antigravity/skills/<skill-name>/SKILL.md` |
| **Global Copilot** | `~/.copilot/skills/<skill-name>/SKILL.md` |

> **Nota para agentes sin filesystem local (hosted chat):** Usar URL directa:
> `https://www.sundialhub.com/raw/<author>/<skill-name>`

---

## 8. Publicación: Push, Versiones y Visibilidad

### Versionado

- Cada push crea un **snapshot inmutable** de la versión
- Si la versión pedida es ≤ la ya publicada → **auto-bump automático**
- Soporta enteros simples (`1`, `2`, `3`) o semver (`1.0.0`, `2.1.3`)
- Los snapshots permiten que los usuarios fijen versiones específicas

### Flags del Comando Push

```bash
npx sundial-hub push ./my-skill [opciones]

--version <n>          # Número de versión (entero o semver)
--changelog "mensaje"  # Descripción del cambio
--visibility public    # Visible para todos (default al publicar)
--visibility private   # Solo visible para el autor (requiere auth)
--categories <lista>   # Categorías separadas por comas
```

### Visibilidad

| Tipo | Descripción |
|------|-------------|
| `public` | Cualquiera puede encontrarlo e instalarlo desde el registry |
| `private` | Solo el autor puede verlo (requiere autenticación activa) |

---

## 9. Categorías Disponibles

Al publicar un skill, se pueden asignar una o más categorías:

| Categoría | Descripción |
|-----------|-------------|
| `product` | Gestión de producto, roadmaps |
| `research` | Investigación, análisis |
| `coding` | Programación, desarrollo |
| `creative` | Contenido creativo, diseño |
| `learning` | Aprendizaje, formación |
| `marketing` | Marketing, campañas |
| `admin` | Administración, ops |
| `financial` | Finanzas, contabilidad |
| `writing` | Redacción, documentación |
| `community` | Comunidad, soporte |
| `outreach` | Outreach, ventas |
| `health` | Salud, bienestar |
| `other` | Sin categoría específica |

---

## 10. Flujos de Trabajo

### Flujo 1: Via Website (Dashboard)

```
1. Ir a sundialhub.com → Dashboard
2. Crear nuevo skill o importar existente
3. Editar SKILL.md en el editor online
4. Configurar visibilidad y categorías
5. Publicar
```

### Flujo 2: Via CLI (Desarrolladores)

```bash
# Descubrir → Agregar → Editar → Publicar
npx sundial-hub find "mi tarea"           # 1. Buscar
npx sundial-hub add <author>/<skill>      # 2. Instalar local
# ... editar SKILL.md manualmente ...    # 3. Modificar
npx sundial-hub push . --visibility public  # 4. Publicar
```

### Flujo 3: Para Agentes Hosted (Sin Filesystem Local)

Cuando el agente no tiene acceso a filesystem local (ej. interfaces web sin extensiones):

```
URL para raw SKILL.md:
https://www.sundialhub.com/raw/<author>/<skill-name>

URL con runbook ejecutable:
https://www.sundialhub.com/agent/<author>/<skill-name>
```

### Flujo 4: Improve (Asistido por IA)

```
1. Ir a sundialhub.com/improve
2. Subir ZIP con tu skill actual
3. La IA evalúa calidad, claridad y estructura
4. Recibir sugerencias de mejora
5. Publicar versión mejorada
```

---

## 11. Integración de Skills en Agentes (Para Desarrolladores)

### Dos Enfoques de Integración

**1. Agentes basados en filesystem (más potente):**
- Operan dentro de un entorno unix/bash
- Skills se activan cuando el modelo ejecuta `cat /path/to/my-skill/SKILL.md`
- Los recursos bundled se acceden via comandos shell

**2. Agentes basados en herramientas:**
- Sin entorno de computadora dedicado
- Implementan herramientas que permiten al modelo activar skills
- La implementación específica de las tools queda a criterio del desarrollador

### Pseudocódigo: Parsing de Metadatos

```python
def parseMetadata(skillPath):
    content = readFile(skillPath + "/SKILL.md")
    frontmatter = extractYAMLFrontmatter(content)
    return {
        "name": frontmatter.name,
        "description": frontmatter.description,
        "path": skillPath
    }
```

### Herramienta de Referencia: skills-ref

La biblioteca [skills-ref](https://github.com/agentskills/agentskills/tree/main/skills-ref) provee utilidades Python y CLI:

```bash
# Validar un directorio de skill
skills-ref validate <path>

# Generar XML <available_skills> para system prompts
skills-ref to-prompt <path>...
```

---

## 12. Prácticas Recomendadas de Autoría

### ✅ Principio 1: Conciso es Clave

El contexto es un bien escaso compartido con todo lo demás que Claude necesita saber. **Solo agregar contexto que Claude no tiene de por sí.**

```markdown
# ✅ CONCISO (~50 tokens)
## Extraer texto de PDF
Usar pdfplumber:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

# ❌ VERBOSO (~150 tokens)
## Extraer texto de PDF
Los archivos PDF (Portable Document Format) son un formato común que contiene
texto, imágenes y otro contenido. Para extraer texto de un PDF, necesitarás
usar una biblioteca. Hay muchas bibliotecas disponibles, pero pdfplumber es
la recomendada porque es fácil de usar...
```

### ✅ Principio 2: Nivel de Libertad Apropiado

| Nivel | Cuándo Usar | Ejemplo |
|-------|-------------|---------|
| **Alta libertad** (texto narrativo) | Múltiples enfoques válidos, decisiones dependen del contexto | Code review process |
| **Libertad media** (pseudocódigo/scripts parametrizados) | Existe un patrón preferido, variación aceptable | Generación de reportes con template |
| **Baja libertad** (scripts específicos sin parámetros) | Operaciones frágiles, consistencia crítica | Database migrations |

### ✅ Principio 3: Testing Multi-Modelo

Los skills funcionan de forma diferente según el modelo subyacente:
- **Haiku** (rápido, económico): ¿El skill provee suficiente guía?
- **Sonnet** (balanceado): ¿El skill es claro y eficiente?
- **Opus** (razonamiento potente): ¿El skill evita sobre-explicar?

### ✅ Principio 4: Patrones de Divulgación Progresiva

**Patrón 1 — Guía con referencias:**
```markdown
# PDF Processing
## Quick start
[instrucciones básicas inline...]

## Advanced features
**Form filling**: See [FORMS.md](FORMS.md)
**API reference**: See [REFERENCE.md](REFERENCE.md)
**Examples**: See [EXAMPLES.md](EXAMPLES.md)
```

**Patrón 2 — Organización por dominio:**
```markdown
## Available datasets
**Finance**: Revenue, ARR, billing → See [reference/finance.md](reference/finance.md)
**Sales**: Pipeline, accounts → See [reference/sales.md](reference/sales.md)
**Product**: API usage, features → See [reference/product.md](reference/product.md)
```

**Patrón 3 — Detalles condicionales:**
```markdown
## Document editing
For simple edits, modify the XML directly.
**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

### ✅ Principio 5: Workflows con Checklists

Para operaciones complejas multi-paso, proveer checklists que Claude puede copiar y trackear:

```markdown
## Workflow de rellenado de formularios PDF
Copiar este checklist y marcar al avanzar:

```
Progreso:
- [ ] Paso 1: Analizar formulario (python scripts/analyze_form.py)
- [ ] Paso 2: Crear field mapping (editar fields.json)
- [ ] Paso 3: Validar mapping (python scripts/validate_fields.py)
- [ ] Paso 4: Rellenar formulario (python scripts/fill_form.py)
- [ ] Paso 5: Verificar output (python scripts/verify_output.py)
```
```

### ✅ Principio 6: Feedback Loops

Patrón: **Ejecutar validador → Corregir errores → Repetir**

```markdown
## Proceso de edición
1. Hacer ediciones en `word/document.xml`
2. **Validar inmediatamente**: `python ooxml/scripts/validate.py <dir>/`
3. Si falla:
   - Revisar el mensaje de error
   - Corregir el XML
   - Ejecutar validación nuevamente
4. **Solo continuar cuando pase la validación**
5. Rebuild: `python ooxml/scripts/pack.py <dir>/ output.docx`
```

### ✅ Principio 7: Desarrollo Iterativo con Claude

El proceso más efectivo de desarrollo usa dos instancias de Claude:

- **Claude A** (experto): ayuda a diseñar y refinar el skill
- **Claude B** (agente): usa el skill en tareas reales y revela gaps

**Ciclo:**
1. Completar tarea sin skill — notar qué contexto provees repetidamente
2. Pedir a Claude A que cree un skill capturando ese patrón
3. Revisar concisión — eliminar explicaciones que Claude ya sabe
4. Probar con Claude B en tareas similares
5. Observar comportamiento — ¿sigue referencias? ¿aplica reglas correctamente?
6. Llevar observaciones a Claude A para refinar
7. Repetir

### ✅ Principio 8: Información No Dependiente del Tiempo

```markdown
# ❌ MAL — se volverá incorrecto
Si estás haciendo esto antes de agosto 2025, usa la API antigua.

# ✅ BIEN — usa sección "Old patterns" colapsable
## Current method
Use the v2 API endpoint: `api.example.com/v2/messages`

<details>
<summary>Legacy v1 API (deprecated 2025-08)</summary>
The v1 API used: `api.example.com/v1/messages`
</details>
```

### ✅ Principio 9: Scripts que Resuelven, No que Delegan

```python
# ✅ BIEN — maneja errores explícitamente
def process_file(path):
    try:
        with open(path) as f:
            return f.read()
    except FileNotFoundError:
        print(f"File {path} not found, creating default")
        with open(path, "w") as f: f.write("")
        return ""

# ❌ MAL — delega el problema a Claude
def process_file(path):
    return open(path).read()  # Que Claude lo maneje
```

### ✅ Principio 10: Tool Calls con Nombres Completos (MCP)

Si el skill usa herramientas MCP, **siempre** usar nombres completamente calificados:

```markdown
# ✅ BIEN — nombre calificado ServerName:tool_name
Use the BigQuery:bigquery_schema tool to retrieve table schemas.
Use the GitHub:create_issue tool to create issues.

# ❌ MAL — nombre ambiguo
Use bigquery_schema to retrieve table schemas.
```

---

## 13. Integración con el Flujo MAPPLICS

Este repositorio (`IA_AGENTS_AND_SKILLS`) puede aprovechar SundialHub en el flujo de `universal-skill-creator` de la siguiente forma:

### Discovery Obligatorio Antes de Crear

```bash
# PASO OBLIGATORIO: buscar antes de crear
npx sundial-hub find "<tema del skill>" --json --limit 10

# Ejemplos
npx sundial-hub find "pdf processing"
npx sundial-hub find "demand forecast"
npx sundial-hub find "azure devops integration"
```

### Criterios para Reusar vs. Crear

| Situación | Acción |
|-----------|--------|
| Skill del registry es genérico y de buena calidad | Instalar y usar directamente |
| Skill existe pero necesita adaptación MAPPLICS | Instalar como base, extender localmente |
| No existe skill relevante | Crear local siguiendo proceso del repo |
| El skill local es de calidad publicable | Publicar en Sundial con `npx sundial-hub push` |

### Flujo Ampliado del universal-skill-creator

```
1. Usuario solicita skill
   ↓
2. Discovery en SundialHub: npx sundial-hub find "<tema>"
   ↓
3. ¿Existe skill relevante?
   ├── SÍ → Evaluar señales de confianza (author, installs, safety)
   │       ├── Alta confianza → npx sundial-hub add <skill>
   │       └── Ajuste necesario → Clonar y adaptar localmente
   └── NO → Crear nuevo skill con templates del repo
   ↓
4. Skill listo (local o desde registry)
   ↓
5. (Opcional) Publicar: npx sundial-hub push . --visibility public
```

### Archivo de Discovery para Agentes

El archivo `find.md` de SundialHub está optimizado para que los propios agentes lo lean:

```bash
# Un agente puede leer este archivo para entender qué hay disponible
https://www.sundialhub.com/find.md
```

---

## 14. Señales de Confianza al Elegir un Skill

Al evaluar skills del registry, considerar estas señales:

| Campo | Descripción | Peso |
|-------|-------------|------|
| `author` | Username del creador | Medio — verificar historial |
| `version` | Versión publicada | Medio — versiones altas indican madurez |
| `installs` | Número de instalaciones | **Alto** — señal de adopción y utilidad real |
| `url` | Página en SundialHub | Bajo — para leer descripción extendida |
| `docsUrl` | URL con SKILL.md docs completo | Medio — evaluar calidad del skill |
| `safety` | String resumen de seguridad | **Alto** — crítico para scripts |

---

## 15. Validación con skills-ref

### Instalación

```bash
# Via pip
pip install skills-ref

# O usar desde el repo oficial
git clone https://github.com/agentskills/agentskills
cd agentskills/skills-ref
```

### Comandos de Validación

```bash
# Validar un skill individual
skills-ref validate ./my-skill

# Generar XML de available_skills para system prompts
skills-ref to-prompt ./skills/skill-a ./skills/skill-b

# Validar múltiples skills
skills-ref validate ./skills/*
```

### Qué Valida

- Presencia y formato del YAML frontmatter
- Reglas del campo `name` (caracteres, longitud, coincidencia con directorio)
- Reglas del campo `description` (longitud, no vacío, no XML)
- Estructura de carpetas recomendada

---

## 16. URLs y Endpoints Útiles

### URLs Web

| Propósito | URL |
|-----------|-----|
| **Homepage** | `https://www.sundialhub.com/` |
| **Explorar skills** | `https://www.sundialhub.com/explore` |
| **Documentación** | `https://www.sundialhub.com/docs` |
| **Mejorar skill con IA** | `https://www.sundialhub.com/improve` |
| **SKILL.md raw de un skill** | `https://www.sundialhub.com/raw/<author>/<skill-name>` |
| **Runbook de un skill** | `https://www.sundialhub.com/agent/<author>/<skill-name>` |
| **Docs de un skill** | `https://www.sundialhub.com/docsUrl/<author>/<skill-name>` |
| **Discovery file para agentes** | `https://www.sundialhub.com/find.md` |
| **Spec abierto** | `https://agentskills.io/` |
| **Spec: What are skills** | `https://agentskills.io/what-are-skills` |
| **Spec: Specification** | `https://agentskills.io/specification` |
| **Spec: Integrate skills** | `https://agentskills.io/integrate-skills` |
| **Spec: Using scripts** | `https://agentskills.io/skill-creation/using-scripts` |
| **skills-ref repo** | `https://github.com/agentskills/agentskills/tree/main/skills-ref` |
| **Anthropic best practices** | `https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices` |

### API HTTP Endpoints (Base: `https://www.sundialhub.com`)

| Método | Endpoint | Propósito |
|--------|----------|----------|
| `GET` | `/api/hub/skills?q=<query>&limit=N&offset=N` | Buscar skills |
| `GET` | `/api/hub/skills?mine=true` | Listar skills propios |
| `GET` | `/api/hub/skills/by-author-name/<author>/<name>` | Obtener skill por autor+nombre |
| `GET` | `/api/hub/skills/by-name/<name>` | Obtener skill por nombre (puede ser ambiguo) |
| `GET` | `/api/hub/skills/<uuid>` | Obtener skill por ID |
| `POST` | `/api/hub/skills` | Crear nuevo skill |
| `POST` | `/api/hub/skills/<uuid>/versions` | Publicar nueva versión |
| `GET` | `/api/hub/assistants/by-slug/<slug>` | Obtener asistente por slug |
| `POST` | `/api/hub/assistants` | Crear asistente |
| `POST` | `/api/hub/assistants/<uuid>/versions` | Publicar versión de asistente |
| `POST` | `/api/cli/telemetry` | Telemetría CLI (desactivable) |

> ⚠️ **Nota:** Estos endpoints fueron descubiertos por reverse-engineering del CLI `sundial-hub` v0.1.13. No existe documentación oficial de la API REST. Ver [sección 21](#21-api-http-directa-sin-cli) para detalles completos.

---

## 17. Top Skills por Instalaciones

Top 10 skills más instalados del registry (referencia 2026):

| Rank | Skill | Instalaciones | Descripción |
|------|-------|---------------|-------------|
| 1 | `find-skills` | 278k | Búsqueda y descubrimiento de skills |
| 2 | `vercel-react-best-practices` | 152k | Best practices para React en Vercel |
| 3 | `web-design-guidelines` | 115k | Guías de diseño web |
| 4 | `remotion-best-practices` | 101k | Best practices para Remotion (video) |
| 5 | `frontend-design` | 91k | Diseño frontend general |
| 6 | `agent-browser` | 49k | Control de navegador para agentes |
| 7 | `browser-use` | 35k | Uso de navegador automatizado |
| 8 | `ui-ux-pro-max` | 32k | UX/UI avanzado |
| 9 | `self-improvement` | 30k | Auto-mejora del agente |
| 10 | `gog` | 30k | Gaming on GitHub |

---

## 18. Blog: Posts Destacados

### "Introducing Sundial" — 2026-02-25

URL: https://www.sundialhub.com/blog/introducing-sundial

**Puntos clave:**
- Todo agente de IA moderno puede leer Markdown → superficie compartida para skills
- Sundial es el registry abierto que hace el descubrimiento/instalación fácil
- **Funcionalidades actuales:** Browse, instalar con 1 comando CLI, publicar skills propios
- **Roadmap:** Team workspaces, skill analytics, IDE integrations más profundas

---

### "Fine-Tuning a Model With One Conversation" — 2026-01-12

URL: https://www.sundialhub.com/blog/fine-tuning-with-tinker

**Sobre Tinker skill:**
- Fine-tuning de modelos LLM via conversación en Claude Code
- Instalación: `npx sundial-hub add tinker`
- Source: https://github.com/sundial-org/skills/tree/main/skills/tinker

**Tres capacidades del skill Tinker:**
1. `tinker` — LoRA fine-tuning via Tinker API (upload data, base model, hyperparams, training)
2. `tinker-training-cost` — Estimar costos antes de iniciar
3. `training-data-curation` — Limpiar y curar datasets

**Resultados del experimento:**
- Un founder entrenó un modelo sobre sus notas de Obsidian
- Resultado: ↓20.7% train loss, ↓4.2% test loss tras 8 epochs
- Una sesión de Claude Code, sin cambiar de contexto, sin archivos de config, sin errores CUDA
- El skill fue **2x más rápido** que trabajar desde documentación cruda

**Por qué usar skills para fine-tuning (insight de SundialHub):**
> "Claude Code overhang: Claude ya puede llamar APIs, escribir Python y orquestar pipelines multi-paso. Tiene más capacidades de las que la mayoría se imagina — solo necesita que le enseñen QUÉ hacer con ellas. Un skill cierra esa brecha."

---

## 19. Seguridad

Al construir agentes que ejecutan scripts de skills, considerar:

| Consideración | Descripción |
|---------------|-------------|
| **Sandboxing** | Ejecutar scripts en entornos aislados |
| **Allowlisting** | Solo ejecutar scripts de skills de confianza |
| **Confirmación** | Pedir confirmación al usuario antes de operaciones potencialmente peligrosas |
| **Logging** | Registrar todas las ejecuciones de scripts para auditoría |
| **Campo `safety`** | Revisar el string de safety del skill en el registry antes de instalar |
| **Visibilidad de código** | Preferir skills open source donde se pueda revisar el código fuente |

---

## 20. Anti-Patrones a Evitar

### ❌ Rutas estilo Windows

```markdown
# ❌ MAL
scripts\helper.py

# ✅ BIEN — forward slashes funcionan en todas las plataformas
scripts/helper.py
```

### ❌ Ofrecer demasiadas opciones

```markdown
# ❌ MAL — confunde al agente
Puedes usar pypdf, o pdfplumber, o PyMuPDF, o pdf2image, o...

# ✅ BIEN — dar un default con escape hatch
Usar pdfplumber para extraer texto. Para PDFs con OCR, usar pdf2image + pytesseract.
```

### ❌ Asumir paquetes instalados

```markdown
# ❌ MAL
Use the pdf library to process the file.

# ✅ BIEN
Install: `pip install pdfplumber`

import pdfplumber
with pdfplumber.open("file.pdf") as pdf: ...
```

### ❌ Referencias anidadas más de 1 nivel

```markdown
# ❌ MAL — Claude puede no leer details.md completamente
SKILL.md → advanced.md → details.md

# ✅ BIEN — todos a 1 nivel desde SKILL.md
SKILL.md → advanced.md
SKILL.md → details.md
SKILL.md → reference.md
```

### ❌ Nombres de herramientas MCP sin calificar

```markdown
# ❌ MAL
Use bigquery_schema to retrieve schemas.

# ✅ BIEN
Use the BigQuery:bigquery_schema tool to retrieve schemas.
```

---

## 21. API HTTP Directa (Sin CLI)

> **Descubierto por reverse-engineering del código fuente de `sundial-hub` CLI v0.1.13.**
> La API REST no tiene documentación oficial. Estos endpoints fueron extraídos del archivo:
> `node_modules/sundial-hub/dist/index.js` (MIT License, autor: Belinda Mo).

SundialHub expone una API HTTP que permite a los agentes de IA interactuar programáticamente con el registry **sin depender del CLI** (`npx sundial-hub`). Esto es útil para:

- Agentes que necesitan consultar skills en tiempo real
- Automatizaciones CI/CD que publican skills
- Flujos donde instalar Node.js/npx no es viable

### Base URL

```
https://www.sundialhub.com
```

### Headers Requeridos

```http
Content-Type: application/json
Authorization: Bearer sd_YOUR_TOKEN_HERE
```

### Endpoints de Consulta

#### Buscar Skills

```bash
curl -s "https://www.sundialhub.com/api/hub/skills?q=pdf%20processing&limit=5" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN"
```

**Parámetros:**

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `q` | string | Término de búsqueda (URL-encoded) |
| `limit` | int | Máximo de resultados (default: 10) |
| `offset` | int | Paginación |
| `mine` | bool | `true` para listar solo skills propios |

**Respuesta (array de skills):**

```json
[
  {
    "id": "a67de250-8803-4353-8e3e-17fb131e37ec",
    "name": "pdf",
    "display_name": "Pdf",
    "slug": "anthropics-pdf",
    "description": "Use this skill whenever the user wants to do anything with PDF files...",
    "author": "anthropics",
    "version": "1",
    "use_count": 17997,
    "visibility": "public",
    "emoji": "📄",
    "github_url": "https://github.com/anthropics/skills",
    "categories": [],
    "downloads_skills_sh": 17995,
    "downloads_clawhub": 0,
    "downloads_cli": 2,
    "scan_status": "completed",
    "scan_is_safe": true,
    "scan_max_severity": null,
    "scan_findings_count": 0,
    "human_description": "Handle any PDF task...",
    "use_cases": [...],
    "works_best_with": [],
    "embedding": [...]  
  }
]
```

#### Obtener Skill por Autor y Nombre (Preferido)

```bash
curl -s "https://www.sundialhub.com/api/hub/skills/by-author-name/anthropics/pdf" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN"
```

> ✅ Este es el endpoint más fiable. Usar `by-name` puede retornar error si hay nombres duplicados.

#### Obtener Skill por ID

```bash
curl -s "https://www.sundialhub.com/api/hub/skills/a67de250-8803-4353-8e3e-17fb131e37ec" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN"
```

#### Listar Skills Propios

```bash
curl -s "https://www.sundialhub.com/api/hub/skills?mine=true" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN"
```

### Endpoints de Publicación

#### Crear Skill Nuevo

```bash
curl -s -X POST "https://www.sundialhub.com/api/hub/skills" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "my-skill",
    "display_name": "My Skill",
    "description": "What this skill does and when to use it.",
    "categories": ["coding"],
    "visibility": "public",
    "version": "1",
    "files": [
      {
        "path": "SKILL.md",
        "content": "---\nname: my-skill\ndescription: What this skill does.\n---\n\n# My Skill\n..."
      }
    ],
    "zip": "<base64-encoded-zip>"
  }'
```

**Campos del body:**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `name` | string | ✅ | Nombre del skill (slug-compatible) |
| `display_name` | string | ✅ | Nombre legible para humanos |
| `description` | string | ✅ | Descripción del skill |
| `categories` | string[] | ❌ | Categorías (ver [sección 9](#9-categorías-disponibles)) |
| `visibility` | string | ✅ | `"public"` o `"private"` |
| `version` | string | ✅ | Versión inicial (ej: `"1"`, `"1.0.0"`) |
| `files` | array | ✅ | Array de objetos `{path, content}` |
| `zip` | string | ✅ | ZIP del skill codificado en base64 |

#### Publicar Nueva Versión

```bash
curl -s -X POST "https://www.sundialhub.com/api/hub/skills/<skill-uuid>/versions" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "2",
    "changelog": "Added new templates and improved validation",
    "display_name": "My Skill",
    "description": "Updated description with new features.",
    "categories": ["coding"],
    "files": [
      {
        "path": "SKILL.md",
        "content": "..."
      }
    ],
    "zip": "<base64-encoded-zip>"
  }'
```

**Campos adicionales para versiones:**

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `version` | string | ✅ | Nueva versión (auto-bump si ≤ actual) |
| `changelog` | string | ❌ | Descripción del cambio |

### Campos de Respuesta Relevantes

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | UUID | Identificador único del skill |
| `name` | string | Nombre técnico |
| `slug` | string | Slug URL-safe (ej: `anthropics-pdf`) |
| `display_name` | string | Nombre para mostrar |
| `description` | string | Descripción funcional |
| `author` | string | Username del creador |
| `version` | string | Versión actual |
| `use_count` | int | Total de instalaciones |
| `visibility` | string | `"public"` o `"private"` |
| `emoji` | string | Emoji representativo |
| `github_url` | string | URL del repositorio fuente |
| `categories` | string[] | Categorías asignadas |
| `downloads_skills_sh` | int | Descargas vía skills.sh |
| `downloads_clawhub` | int | Descargas vía ClawHub |
| `downloads_cli` | int | Descargas vía sundial-hub CLI |
| `scan_status` | string | Estado del scan de seguridad |
| `scan_is_safe` | bool | Si el skill pasó el scan |
| `scan_max_severity` | string\|null | Severidad máxima detectada |
| `scan_findings_count` | int | Cantidad de hallazgos del scan |
| `human_description` | string | Descripción generada por IA |
| `use_cases` | array | Casos de uso sugeridos |
| `works_best_with` | array | Skills complementarios |
| `embedding` | float[] | Vector embedding (1536 dims) |
| `source_registries` | string[] | Registries donde está publicado |

### Backend de Almacenamiento

SundialHub usa **Supabase** como backend. Los ZIPs de skills se almacenan en:

```
https://avszoslgufabicsopage.supabase.co/storage/v1/object/public/skill-zips
```

### Variables de Entorno

| Variable | Descripción | Valor Default |
|----------|-------------|---------------|
| `SUNDIAL_HUB_URL` | URL base del hub (para instancias custom) | `https://www.sundialhub.com` |
| `SUNDIAL_TOKEN` | Token de autenticación (override de auth.json) | — |
| `SUNDIAL_DISABLE_TELEMETRY` | Desactivar telemetría del CLI | `false` |

### Ejemplo Completo: Buscar y Mostrar un Skill

```bash
# 1. Buscar skills de PDF
curl -s "https://www.sundialhub.com/api/hub/skills?q=pdf&limit=3" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN" | jq '.[].name'

# 2. Obtener detalle completo
curl -s "https://www.sundialhub.com/api/hub/skills/by-author-name/anthropics/pdf" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN" | jq '.skill | {name, author, use_count, version, scan_is_safe}'

# Resultado:
# {
#   "name": "pdf",
#   "author": "anthropics",
#   "use_count": 17997,
#   "version": "1",
#   "scan_is_safe": true
# }
```

### Telemetría

El CLI envía telemetría a `/api/cli/telemetry` con cada operación. Para desactivarla:

```bash
export SUNDIAL_DISABLE_TELEMETRY=true
```

---

## 22. Autenticación Programática

### Métodos de Autenticación

SundialHub soporta dos formas de autenticación:

#### 1. Archivo `~/.sundial/auth.json` (usado por CLI)

El CLI escribe el token tras `npx sundial-hub login`:

```json
{
  "token": "sd_YOUR_TOKEN_HERE"
}
```

**Lectura desde scripts:**

```bash
# Bash
TOKEN=$(cat ~/.sundial/auth.json 2>/dev/null | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# O con jq
TOKEN=$(jq -r '.token' ~/.sundial/auth.json 2>/dev/null)
```

#### 2. Variable de entorno `SUNDIAL_TOKEN` (override)

Sobreescribe cualquier token de `auth.json`. Ideal para CI/CD y automatizaciones:

```bash
export SUNDIAL_TOKEN="sd_YOUR_TOKEN_HERE"
```

### Formato del Token

- Prefijo: `sd_` (siempre)
- Longitud: ~48 caracteres totales
- Ejemplo: `sd_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Verificación de Autenticación

```bash
# Via API directa
curl -s "https://www.sundialhub.com/api/hub/skills?mine=true" \
  -H "Authorization: Bearer $SUNDIAL_TOKEN" | head -c 100

# Si autenticado → retorna array JSON (posiblemente vacío)
# Si NO autenticado → retorna error 401 o mensaje de error
```

### Orden de Precedencia

```
1. $SUNDIAL_TOKEN (env var, máxima prioridad)
   ↓ si no existe
2. ~/.sundial/auth.json → campo "token"
   ↓ si no existe
3. Error: no hay autenticación disponible
```

### Seguridad del Token

⚠️ **Reglas críticas:**

- **NUNCA** incluir tokens reales en SKILL.md, guías o documentación
- **NUNCA** commitear `~/.sundial/auth.json` a un repositorio
- Usar siempre variables de entorno en CI/CD
- Los tokens `sd_*` deben considerarse como secretos
- Ejecutar `scan_sensitive_data.sh` antes de publicar (ver [sección 23](#23-seguridad-pre-publicación))

---

## 23. Seguridad Pre-Publicación

### Scan Obligatorio de Información Sensible

Antes de publicar cualquier skill al registry, es **obligatorio** ejecutar un scan de seguridad para detectar información sensible que podría quedar expuesta:

```bash
# Ejecutar scan
bash skills/universal-skill-creator/scripts/scan_sensitive_data.sh <directorio-del-skill>

# Ejemplo
bash skills/universal-skill-creator/scripts/scan_sensitive_data.sh skills/my-skill
```

### Categorías de Detección

El scanner (`scan_sensitive_data.sh`) busca 12 categorías de datos sensibles:

| # | Categoría | Severidad | Patrones Detectados |
|---|-----------|-----------|---------------------|
| 1 | API Tokens | CRITICAL | `sk-`, `sk-proj-`, `ghp_`, `gho_`, `AKIA`, `sd_` |
| 2 | Passwords en config | CRITICAL | `password=`, `passwd=`, `secret=` |
| 3 | Private Keys | CRITICAL | `-----BEGIN.*PRIVATE KEY-----` |
| 4 | Connection Strings | CRITICAL | `mongodb://`, `postgresql://`, `mysql://` con credenciales |
| 5 | Private IPs | HIGH | `192.168.x.x`, `10.x.x.x`, `172.16-31.x.x` |
| 6 | .env Files | HIGH | Archivos `.env`, `.env.local`, `.env.production` |
| 7 | Certificados | MEDIUM | `-----BEGIN CERTIFICATE-----` embebidos |
| 8 | AWS Keys | CRITICAL | Patrones `AKIA[0-9A-Z]{16}` |
| 9 | Generic API Keys | MEDIUM | `api_key=`, `apikey=`, `api-key:` con valores |
| 10 | Bearer Tokens | HIGH | `Authorization: Bearer` con token hardcodeado |
| 11 | SSH Keys | CRITICAL | `-----BEGIN.*SSH.*-----`, `ssh-rsa AAAA` |
| 12 | High-entropy strings | MEDIUM | Strings >40 chars con patrones de secretos |

### Resultado del Scan

```
# Sin hallazgos
✅ LIMPIO — No se encontró información sensible

# Con hallazgos
⚠️ ALERTA — Se encontraron 3 hallazgos:
  [CRITICAL] archivo.md:15 — API Token detectado: sk-proj-***
  [HIGH] config.yaml:8 — Private IP: 192.168.1.100
  [MEDIUM] docs/api.md:42 — Generic API Key
```

### Comportamiento de Bloqueo

- **CRITICAL o HIGH** → ❌ Publicación bloqueada (exit code 1)
- **MEDIUM** → ⚠️ Warning, publicación permitida con confirmación
- **Sin hallazgos** → ✅ Publicación libre

### Integración con el Flujo de Publicación

El script `publish_to_sundial.sh` ejecuta el scan como **Paso 1 obligatorio**:

```
Publicar skill
  │
  ├─ Paso 1/4: 🔒 Scan de seguridad (OBLIGATORIO)
  │     ├─ CRITICAL/HIGH → ❌ BLOQUEA publicación
  │     └─ Limpio/MEDIUM → Continúa
  │
  ├─ Paso 2/4: Validación de estructura
  ├─ Paso 3/4: Empaquetado (ZIP + base64)
  └─ Paso 4/4: Push a SundialHub
```

### Override de Emergencia

```bash
# Solo en casos muy justificados (NO recomendado)
bash scripts/publish_to_sundial.sh --skip-scan
```

> ⚠️ **Nota:** Usar `--skip-scan` elimina la protección contra fugas de secretos. Solo usar si el scan produce falsos positivos confirmados y se ha verificado manualmente.

### Scan de SundialHub (Server-side)

Además del scan local, SundialHub ejecuta su propio scan server-side tras la publicación:

| Campo en respuesta API | Descripción |
|------------------------|-------------|
| `scan_status` | `"completed"`, `"pending"`, `"failed"` |
| `scan_is_safe` | `true` si pasó el scan |
| `scan_max_severity` | Severidad máxima detectada |
| `scan_findings_count` | Número de hallazgos |

Esto proporciona una **doble capa de seguridad**: scan local pre-publicación + scan server-side post-publicación.

---

## 24. Lecciones de Automatización (Troubleshooting)

Cuando se desarrollan agentes de IA o pipelines CI/CD que interactúan con SundialHub, es crítico evitar los siguientes errores comunes descubiertos durante pruebas de integración:

### 1. El "Hang" del Menú Interactivo (CLI)

**El Problema:** Al publicar un skill *nuevo* usando `npx sundial-hub push`, el CLI requiere una categoría. Si omites la bandera `--categories`, el CLI abrirá un menú interactivo (`? Category: ❯ Product ...`). En entornos desasistidos (agentes o CI/CD), esto provoca que la terminal se quede colgada infinitamente, gastando tiempo y recursos del entorno.
**La Solución:** Siempre que uses la bandera `-y` o operes desasistidamente, asegura pasar `--categories`.
```bash
# ❌ MAL: Cuelga el terminal si el skill es nuevo
npx sundial-hub push . -y

# ✅ BIEN: Pasa directo
npx sundial-hub push . -y --categories coding
```
*(Nota: El script `publish_to_sundial.sh` v4.1 incluye un parche que asigna `other` por defecto si detecta `-y` sin `--categories` para mitigar esto).*

### 2. La Avalancha de Embeddings en Contexto LLM

**El Problema:** Al consumir la API HTTP devolviendo los detalles de un skill, la respuesta JSON incluye un arreglo `embedding` de 1536 floats. Imprimir esto en la terminal genera más de 16KB de texto inútil por cada skill que excede el límite del buffer interrumpiendo la lectura (o envenenando el token budget del LLM).
**La Solución:** Trimmer los embeddings usando `jq` o grep invertido.
```bash
# Filtrando con jq
curl -s "https://api..." | jq 'del(.skill.embedding)'

# Filtrando con jq arrays enteros
curl -s "https://api..." | jq '.[0] | del(.embedding)'
```

### 3. Parseo Estricto de `mine=true`

**El Problema:** Intuitivamente se esperaría que el endpoint `/api/hub/skills?mine=true` devuelva un Array plano `[...]` como lo hace la búsqueda general. Sin embargo, devuelve un objeto wrappers: `{"skills": [...]}`. Procesarlo estáticamente bajo la premisa de array resulta en errores duros como `KeyError: 0`.
**La Solución:** Parsear estrictamente contra el diccionario raíz.
```python
# Carga correcta
response = json.loads(rep)
mis_skills = response.get("skills", [])
```

---

## 📋 Checklist de Calidad para Skills

### Core Quality
- [ ] Description es específica e incluye términos clave
- [ ] Description incluye QUÉ hace Y CUÁNDO usarlo
- [ ] Cuerpo SKILL.md ≤ 500 líneas
- [ ] Detalles adicionales en archivos separados (si aplica)
- [ ] Sin información dependiente del tiempo
- [ ] Terminología consistente en todo el skill
- [ ] Ejemplos concretos, no abstractos
- [ ] Referencias a un solo nivel de profundidad desde SKILL.md
- [ ] Divulgación progresiva usada apropiadamente
- [ ] Workflows con pasos claros

### Código y Scripts
- [ ] Scripts resuelven problemas en lugar de delegar a Claude
- [ ] Manejo de errores explícito y útil
- [ ] Sin "voodoo constants" (todos los valores justificados)
- [ ] Paquetes requeridos listados y verificados
- [ ] Scripts con documentación clara
- [ ] Sin rutas estilo Windows (todos forward slashes)
- [ ] Pasos de validación/verificación para operaciones críticas
- [ ] Feedback loops incluidos para tareas de calidad crítica

### Testing
- [ ] Al menos 3 evaluaciones creadas
- [ ] Probado con Haiku, Sonnet y Opus
- [ ] Probado con escenarios de uso real
- [ ] Feedback de equipo incorporado (si aplica)

---

*Última actualización: 2026-03-03 | Fuente: https://www.sundialhub.com/ + https://agentskills.io/ + https://platform.claude.com/docs/en/agents-and-tools/agent-skills/ | API: reverse-engineering de sundial-hub CLI v0.1.13*

# Flujo de Trabajo de Creación de Skills

Esta guía detalla el proceso interactivo que el agente debe seguir al crear un nuevo skill.

## Fase 1: Descubrimiento (Cuestionario)

Antes de crear cualquier skill, haz estas preguntas al usuario:

1. **Propósito**: ¿Qué tarea o comportamiento quieres que el agente aprenda?
2. **Ámbito del Skill**:
   - [ ] GENÉRICO: Aplica a cualquier proyecto (ej: pytest, clean-code)
   - [ ] ESPECÍFICO: Solo para este proyecto (ej: convenciones propias)
   - [ ] ORQUESTADOR: Coordina otros skills
3. **Referencias** (si es específico): ¿Qué archivos ejemplifican el patrón?
4. **Integración**: ¿Deseas auto-invocación?
5. **Documentación**: ¿Existe documentación base?

## Fase 2: Análisis de Necesidad

Analiza la respuesta sobre la documentación:

- **Escueta/Trivial**: NO crear skill. Recomendar custom instructions.
- **Ideal/Patrones**: SÍ crear skill. Capturar el "Know-How".
- **Extensa/Monolítica**: FRAGMENTAR. Proponer estructura modular.

*Criterio Clave*: El skill transforma información pasiva en instrucción activa.

## Fase 3: Diseño de Estructura

Propón la estructura antes de escribir código:

```markdown
skills/{nombre-skill}/
├── SKILL.md              # Instrucciones principales
├── assets/               # Templates y recursos
└── scripts/              # Herramientas de automatización
```

## Fase 4: Implementación

1. Crear carpetas.
2. Usar el template adecuado (`assets/templates/`).
3. Si hay referencias de proyecto, leer archivos y extraer patrones reales.
4. Generar ejemplos de código "Correcto" vs "Incorrecto".

## Fase 5: Integración

Si se solicitó auto-invocación, instruye al usuario para agregar el skill a `AGENTS.md`:

```markdown
| Skill | Trigger | Archivo |
|-------|---------|---------|
| `{nombre}` | {cuándo activar} | [SKILL.md](skills/{nombre}/SKILL.md) |
```

## Fase 6: Despliegue y Configuración

Ofrece ejecutar el script de configuración:

```bash
./skills/universal-skill-creator/scripts/setup_agents.sh --all
```

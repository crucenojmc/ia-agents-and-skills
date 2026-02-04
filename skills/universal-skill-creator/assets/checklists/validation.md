# Checklist: Validación de Skill

Usa esta lista **después** de crear un skill para verificar su calidad.

---

## ✅ Estructura de Archivos

- [ ] Existe `SKILL.md` en la raíz del skill
- [ ] El nombre de la carpeta sigue las convenciones (kebab-case)
- [ ] Las subcarpetas siguen la estructura estándar:
  - [ ] `assets/` para templates y recursos (si aplica)
  - [ ] `scripts/` para código ejecutable (si aplica)
  - [ ] `guides/` para documentación extendida (si aplica)

---

## ✅ Frontmatter YAML

```yaml
---
name: {requerido}
description: {requerido, incluye trigger}
license: {requerido}
metadata:
  author: {requerido}
  version: {requerido, como string "x.y"}
---
```

- [ ] `name` está presente y es kebab-case
- [ ] `description` describe QUÉ hace + CUÁNDO activar
- [ ] `license` está especificado
- [ ] `metadata.author` está presente
- [ ] `metadata.version` está presente (como string)

---

## ✅ Contenido del SKILL.md

### Secciones Obligatorias

- [ ] **When to Use / Cuándo Usar**: Lista clara de condiciones
- [ ] **Al menos un ejemplo de código**: Funcional y relevante
- [ ] **Comportamiento del Agente**: Instrucciones para la IA

### Secciones Recomendadas

- [ ] Árbol de decisiones (si hay lógica condicional)
- [ ] Antipatrones (qué NO hacer)
- [ ] Comandos comunes
- [ ] Tabla de referencia rápida
- [ ] Recursos / Referencias

---

## ✅ Calidad del Contenido

### Ejemplos de Código

- [ ] Los ejemplos son **mínimos y enfocados**
- [ ] Los ejemplos son **funcionales** (no pseudocódigo roto)
- [ ] Incluyen tanto ❌ incorrecto como ✅ correcto
- [ ] Los comentarios explican el "por qué"

### Claridad de Instrucciones

- [ ] Un desarrollador podría seguir las instrucciones sin contexto previo
- [ ] No hay jerga o términos no definidos
- [ ] Las instrucciones para el agente son específicas y accionables

### Triggers

- [ ] La descripción usa verbos de acción claros
- [ ] El trigger no es tan amplio que active innecesariamente
- [ ] El trigger no es tan específico que nunca active

---

## ✅ Validaciones Específicas por Tipo

### Para Skills Genéricos

- [ ] No hay referencias a rutas de proyecto específico
- [ ] Los ejemplos usan nombres genéricos (`ejemplo.py`, `mi_clase`)
- [ ] Podría usarse en cualquier proyecto sin modificación

### Para Skills de Proyecto

- [ ] Las rutas referenciadas existen en el proyecto
- [ ] Hay sección de "Convenciones del Proyecto"
- [ ] Los ejemplos están basados en código real del proyecto

### Para Skills Orquestadores

- [ ] Hay tabla de skills coordinados
- [ ] Hay sección de "Quick Wins"
- [ ] No implementa reglas directamente (delega)
- [ ] Define cuándo delegar a qué skill

---

## ✅ Integración

- [ ] El skill está registrado en `AGENTS.md` (si aplica)
- [ ] Si hay auto-invocación, las instrucciones son claras
- [ ] No conflicta con otros skills existentes

---

## 🔍 Prueba de Humo

Para verificar que el skill funciona:

1. **Simular activación**: ¿El trigger es claro?
   ```
   "Cuando el usuario diga '{frase típica}', ¿este skill debería activar?"
   ```

2. **Revisar ejemplos**: ¿El código de ejemplo funciona?
   ```bash
   # Si es posible, ejecutar los ejemplos
   ```

3. **Probar instrucciones**: ¿El agente sabría qué hacer?
   ```
   "Siguiendo solo este skill, ¿podría completar la tarea correctamente?"
   ```

---

## 📊 Puntuación de Calidad

| Aspecto | Peso | ✓/✗ |
|---------|------|-----|
| Frontmatter completo | 15% | |
| Sección "When to Use" clara | 15% | |
| Ejemplos de código funcionales | 20% | |
| Instrucciones para el agente | 20% | |
| Árbol de decisiones (si aplica) | 10% | |
| Antipatrones documentados | 10% | |
| Recursos/referencias útiles | 10% | |

**Total**: _____ / 100%

**Calificación mínima recomendada**: 70%

---

## ✓ Skill Validado

Si todas las verificaciones obligatorias están marcadas y la puntuación es ≥70%:

- [ ] El skill está listo para uso
- [ ] Considerar agregar a documentación del proyecto
- [ ] Notificar al equipo si es relevante

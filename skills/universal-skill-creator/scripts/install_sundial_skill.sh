#!/usr/bin/env bash
# ==============================================================================
# install_sundial_skill.sh
# Instala un skill desde SundialHub para cualquier agente compatible
# (Claude Code, Cursor, Codex, Gemini, Copilot, Antigravity)
#
# Uso: ./install_sundial_skill.sh <author>/<skill> [opciones]
# Ejemplo: ./install_sundial_skill.sh sundial/pdf-processing --claude
# ==============================================================================

set -e

# Colores
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

usage() {
  echo "Uso: $0 <author>/<skill> [opciones]"
  echo ""
  echo "Argumentos:"
  echo "  author/skill    Identificador del skill en SundialHub (ej: sundial/tinker)"
  echo ""
  echo "Opciones de target (se pueden combinar):"
  echo "  --claude        Instalar para Claude Code  (.claude/skills/)"
  echo "  --cursor        Instalar para Cursor       (.cursor/skills/)"
  echo "  --codex         Instalar para OpenAI Codex (.codex/skills/)"
  echo "  --gemini        Instalar para Gemini CLI   (.gemini/skills/)"
  echo "  --global        Instalar globalmente (Claude: ~/.claude/skills/)"
  echo "  -y, --yes       Auto-confirmar sin prompt"
  echo ""
  echo "Ejemplos:"
  echo "  $0 sundial/tinker --claude"
  echo "  $0 sundial/pdf-processing --claude --cursor"
  echo "  $0 find-skills/find-skills --global"
  echo "  $0 sundial/tinker --yes"
  exit 1
}

# Variables
SKILL_REF=""
TARGETS=()
AUTO_YES=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --claude)
      TARGETS+=("claude")
      shift
      ;;
    --cursor)
      TARGETS+=("cursor")
      shift
      ;;
    --codex)
      TARGETS+=("codex")
      shift
      ;;
    --gemini)
      TARGETS+=("gemini")
      shift
      ;;
    --global)
      TARGETS+=("global")
      shift
      ;;
    -y|--yes)
      AUTO_YES=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ -z "$SKILL_REF" ]]; then
        SKILL_REF="$1"
      fi
      shift
      ;;
  esac
done

if [[ -z "$SKILL_REF" ]]; then
  echo -e "${RED}❌ Error: Falta <author>/<skill>${NC}"
  echo ""
  usage
fi

# Si no se especificó target, usar la lógica de auto-detección
if [[ ${#TARGETS[@]} -eq 0 ]]; then
  echo -e "${YELLOW}⚠ No se especificó target. Usando detección automática...${NC}"

  # Detectar agentes disponibles en el proyecto
  if [[ -d ".claude" ]]; then
    TARGETS+=("claude")
  fi
  if [[ -d ".cursor" ]]; then
    TARGETS+=("cursor")
  fi
  if [[ -d ".codex" ]]; then
    TARGETS+=("codex")
  fi
  if [[ -d ".gemini" ]]; then
    TARGETS+=("gemini")
  fi

  # Si no se detectó nada, instalar por defecto para Claude
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    echo -e "${YELLOW}  No se detectaron agentes configurados. Usando Claude Code por defecto.${NC}"
    TARGETS+=("claude")
  else
    echo -e "${GREEN}  Agentes detectados: ${TARGETS[*]}${NC}"
  fi
fi

echo ""
echo -e "${BOLD}📦 Instalando skill desde SundialHub${NC}"
echo -e "   Skill: ${CYAN}${SKILL_REF}${NC}"
echo -e "   Targets: ${CYAN}${TARGETS[*]}${NC}"
echo ""

# Confirmar si no hay --yes
if [[ "$AUTO_YES" == "false" ]]; then
  read -r -p "¿Continuar? [S/n]: " CONFIRM
  CONFIRM="${CONFIRM:-S}"
  if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
    echo "Cancelado."
    exit 0
  fi
fi

# Instalar para cada target
SUCCESS=0
FAIL=0

for TARGET in "${TARGETS[@]}"; do
  echo -e "  → Instalando para ${BOLD}${TARGET}${NC}..."

  case $TARGET in
    claude)
      TARGET_FLAG="--claude"
      ;;
    cursor)
      TARGET_FLAG="--cursor"
      ;;
    codex)
      TARGET_FLAG="--codex"
      ;;
    gemini)
      TARGET_FLAG="--gemini"
      ;;
    global)
      TARGET_FLAG="--global"
      ;;
    *)
      echo -e "    ${YELLOW}⚠ Target desconocido: $TARGET. Saltando.${NC}"
      continue
      ;;
  esac

  if npx --yes sundial-hub@0.1.13 add "$SKILL_REF" $TARGET_FLAG --yes 2>/dev/null; then
    echo -e "    ${GREEN}✓ Instalado correctamente${NC}"
    SUCCESS=$((SUCCESS + 1))
  else
    echo -e "    ${RED}✗ Error al instalar para $TARGET${NC}"
    FAIL=$((FAIL + 1))
  fi
done

echo ""
echo "════════════════════════════════════════════════════════════"
echo -e "${BOLD}Resumen:${NC} ${GREEN}${SUCCESS} exitosos${NC}  |  ${RED}${FAIL} fallidos${NC}"
echo ""

if [[ $SUCCESS -gt 0 ]]; then
  # Extraer solo el nombre del skill (sin el author)
  SKILL_NAME="${SKILL_REF##*/}"
  echo -e "💡 ${BOLD}Próximos pasos:${NC}"
  echo -e "   • Ver SKILL.md: ${CYAN}https://www.sundialhub.com/raw/${SKILL_REF}${NC}"
  echo -e "   • Registrar en AGENTS.md si quieres auto-invocación"
  echo ""
fi

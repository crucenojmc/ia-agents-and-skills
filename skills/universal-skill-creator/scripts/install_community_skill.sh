#!/usr/bin/env bash
# ==============================================================================
# install_community_skill.sh
# Instala un skill de la comunidad skills.sh para Antigravity
# ==============================================================================

set -e

usage() {
  echo "Uso: $0 <repo> <skill-name> [opciones]"
  echo ""
  echo "Argumentos:"
  echo "  repo        Repositorio en formato owner/repo (ej: anthropics/skills)"
  echo "  skill-name  Nombre del skill a instalar (ej: pdf)"
  echo ""
  echo "Opciones:"
  echo "  -g, --global    Instalar globalmente en ~/.gemini/antigravity/skills/"
  echo "  -h, --help      Mostrar esta ayuda"
  echo ""
  echo "Ejemplos:"
  echo "  $0 anthropics/skills pdf"
  echo "  $0 vercel-labs/agent-skills frontend-design --global"
  exit 1
}

# Parsear argumentos
REPO=""
SKILL=""
GLOBAL=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -g|--global)
      GLOBAL="-g"
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ -z "$REPO" ]]; then
        REPO=$1
      elif [[ -z "$SKILL" ]]; then
        SKILL=$1
      fi
      shift
      ;;
  esac
done

if [[ -z "$REPO" || -z "$SKILL" ]]; then
  echo "❌ Error: Faltan argumentos requeridos"
  echo ""
  usage
fi

echo "📦 Instalando skill '$SKILL' desde '$REPO'..."
echo "   Destino: ${GLOBAL:+Global (~/.gemini/antigravity/skills/)}${GLOBAL:-Local (.agent/skills/)}"
echo ""

# Ejecutar instalación
npx -y skills add "$REPO" --skill "$SKILL" -a antigravity $GLOBAL -y

echo ""
echo "✅ Skill '$SKILL' instalado correctamente para Antigravity"

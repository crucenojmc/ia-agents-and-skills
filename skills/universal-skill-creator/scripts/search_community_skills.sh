#!/usr/bin/env bash
# ==============================================================================
# search_community_skills.sh
# Busca skills de manera inteligente en todo el ecosistema skills.sh usando `npx skills find`
# ==============================================================================

set -e

QUERY=$1

if [[ -z "$QUERY" ]]; then
  echo "Uso: $0 <query>"
  echo "Ejemplo: $0 react"
  exit 1
fi

echo "🔍 Buscando '$QUERY' en todo el ecosistema skills.sh..."
echo "========================================================"

# Pipe 'q' to quit interactive mode immediately after receiving output
# npx skills find output format includes ANSI codes which we need to clean
OUTPUT=$(echo "q" | npx -y skills find "$QUERY" 2>/dev/null)

# Clean ANSI codes using sed
CLEAN_OUTPUT=$(echo "$OUTPUT" | sed 's/\x1b\[[0-9;]*m//g')

if [[ -z "$CLEAN_OUTPUT" || "$CLEAN_OUTPUT" == *"No skills found"* ]]; then
  echo "❌ No se encontraron skills para '$QUERY'."
  echo " Intenta con términos más generales."
else
  # Filter out the header/footer noise if possible, or just show the relevant lines
  # The output contains "Install with...", lines with repo@skill, and description links.
  # We'll just display it as is, but cleaned.
  
  echo "$CLEAN_OUTPUT" | grep -v "No skills found" | grep -v "^$" | head -n 20
  
  echo ""
  echo "========================================================"
  echo "💡 Instalar: ./skills/universal-skill-creator/scripts/install_community_skill.sh <repo> <skill>"
fi

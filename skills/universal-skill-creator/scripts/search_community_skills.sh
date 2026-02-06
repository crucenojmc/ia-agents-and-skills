#!/usr/bin/env bash
# ==============================================================================
# search_community_skills.sh
# Busca skills en los repositorios principales de la comunidad skills.sh
# ==============================================================================

set -e

REPOS=(
  "vercel-labs/agent-skills"
  "vercel-labs/skills"
  "anthropics/skills"
  "obra/superpowers"
  "expo/skills"
  "supabase/agent-skills"
  "better-auth/skills"
)

KEYWORD=${1:-""}

echo "🔍 Buscando skills en la comunidad skills.sh..."
echo "=============================================="
echo ""

for repo in "${REPOS[@]}"; do
  echo "📦 $repo"
  echo "---"
  
  # Ejecutar npx y capturar salida
  if output=$(npx -y skills add "$repo" --list 2>/dev/null); then
    if [[ -n "$KEYWORD" ]]; then
      # Filtrar por keyword si se proporcionó
      echo "$output" | grep -i "$KEYWORD" || echo "  (sin coincidencias para '$KEYWORD')"
    else
      echo "$output"
    fi
  else
    echo "  ⚠️ No disponible o sin skills"
  fi
  echo ""
done

echo "=============================================="
echo "💡 Para instalar: npx -y skills add <repo> --skill <nombre> -a antigravity"

#!/usr/bin/env bash
# ==============================================================================
# search_sundial_skills.sh
# Busca skills en SundialHub (registry oficial del estándar agentskills.io)
#
# Soporta dos modos:
#   - CLI: usa `npx sundial-hub find` (requiere Node.js)
#   - API: usa curl directo a la API HTTP (sin dependencias)
#
# Uso: ./search_sundial_skills.sh "<query>" [--limit N] [--json] [--api]
# Ejemplo: ./search_sundial_skills.sh "pdf processing"
#          ./search_sundial_skills.sh "forecast" --api --json
# ==============================================================================

set -e

# Colores
BOLD='\033[1m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Defaults
QUERY=""
LIMIT=10
JSON_MODE=false
API_MODE=false

# Parsear argumentos
while [[ $# -gt 0 ]]; do
  case $1 in
    --limit)
      LIMIT="$2"
      shift 2
      ;;
    --json)
      JSON_MODE=true
      shift
      ;;
    --api)
      API_MODE=true
      shift
      ;;
    -h|--help)
      echo "Uso: $0 \"<query>\" [--limit N] [--json] [--api]"
      echo ""
      echo "Opciones:"
      echo "  --limit N     Máximo de resultados (default: 10)"
      echo "  --json        Output en formato JSON crudo"
      echo "  --api         Usar API HTTP directa (sin npx/Node.js)"
      echo ""
      echo "Ejemplos:"
      echo "  $0 \"pdf processing\""
      echo "  $0 \"demand forecast\" --limit 5"
      echo "  $0 \"code review\" --json"
      echo "  $0 \"testing\" --api --json"
      exit 0
      ;;
    *)
      QUERY="$1"
      shift
      ;;
  esac
done

if [[ -z "$QUERY" ]]; then
  echo -e "${YELLOW}Uso: $0 \"<query>\" [--limit N] [--json] [--api]${NC}"
  echo -e "${YELLOW}Ejemplo: $0 \"pdf processing\"${NC}"
  exit 1
fi

echo ""
echo -e "${BOLD}${BLUE}🔍 Buscando en SundialHub: '$QUERY'${NC}"
echo -e "${BLUE}   Registry: https://www.sundialhub.com/${NC}"
echo "════════════════════════════════════════════════════════════"

# ── Modo API directa (curl, sin Node.js) ────────────────────────────────────
if [[ "$API_MODE" == "true" ]]; then
  API_SCRIPT="$(dirname "$0")/sundial_api.sh"

  if [[ -f "$API_SCRIPT" ]]; then
    if [[ "$JSON_MODE" == "true" ]]; then
      bash "$API_SCRIPT" search "$QUERY" --limit "$LIMIT" --raw
      exit 0
    fi

    RAW_JSON=$(bash "$API_SCRIPT" search "$QUERY" --limit "$LIMIT" --raw 2>/dev/null || echo '{"skills":[]}')
  else
    # Fallback: curl directo
    ENCODED_QUERY=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$QUERY'))")
    TOKEN=""
    AUTH_FILE="$HOME/.sundial/auth.json"
    [[ -n "$SUNDIAL_TOKEN" ]] && TOKEN="$SUNDIAL_TOKEN"
    [[ -z "$TOKEN" && -f "$AUTH_FILE" ]] && TOKEN=$(python3 -c "import json; print(json.load(open('$AUTH_FILE')).get('token',''))" 2>/dev/null || echo "")

    CURL_ARGS=(-s -H "Content-Type: application/json")
    [[ -n "$TOKEN" ]] && CURL_ARGS+=(-H "Authorization: Bearer $TOKEN")

    BASE_URL="${SUNDIAL_HUB_URL:-https://www.sundialhub.com}"

    if [[ "$JSON_MODE" == "true" ]]; then
      curl "${CURL_ARGS[@]}" "${BASE_URL}/api/hub/skills?q=${ENCODED_QUERY}&limit=${LIMIT}" 2>/dev/null
      exit 0
    fi

    RAW_JSON=$(curl "${CURL_ARGS[@]}" "${BASE_URL}/api/hub/skills?q=${ENCODED_QUERY}&limit=${LIMIT}" 2>/dev/null || echo '{"skills":[]}')
  fi

  # Parsear respuesta API directa (formato skills: [...])
  echo "$RAW_JSON" | python3 -c "
import sys, json

try:
    data = json.load(sys.stdin)
    skills = data.get('skills', [])
except json.JSONDecodeError:
    print('Error: No se pudo parsear la respuesta de SundialHub.')
    sys.exit(1)

if not skills:
    print('No se encontraron skills.')
    sys.exit(0)

print(f'\n  Encontrados: {len(skills)} skills\n')

for i, s in enumerate(skills, 1):
    name       = s.get('name', 'N/A')
    author     = s.get('author', 'N/A')
    version    = s.get('version', 'N/A')
    installs   = s.get('use_count', 0)
    description = (s.get('description', '') or '')[:120]
    scan_safe  = s.get('scan_is_safe')
    scan_sev   = s.get('scan_max_severity', '')
    scan_count = s.get('scan_findings_count', 0)

    if isinstance(installs, int):
        if installs > 10000: trust = '⭐⭐⭐ Alta'
        elif installs > 1000: trust = '⭐⭐   Media'
        elif installs > 100: trust = '⭐    Baja'
        else: trust = '     Nueva'
    else:
        trust = '     N/A'

    # Safety signal
    if scan_safe is True:
        safety = '✅ Safe'
    elif scan_safe is False:
        safety = f'⚠️  {scan_sev} ({scan_count} findings)'
    else:
        safety = '❓ No escaneado'

    print(f'  [{i}] \033[1m{author}/{name}\033[0m  (v{version})')
    print(f'      📦 Installs: {installs:,}  |  Confianza: {trust}')
    if description:
        print(f'      📄 {description}')
    print(f'      🔒 Safety: {safety}')
    print(f'      🔗 https://www.sundialhub.com/{author}/{name}')
    print()
"

  echo "════════════════════════════════════════════════════════════"
  echo ""
  echo -e "💡 ${BOLD}Instalar un skill:${NC}"
  echo -e "   ${CYAN}./skills/universal-skill-creator/scripts/install_sundial_skill.sh <author>/<skill>${NC}"
  echo ""
  exit 0
fi

# ── Modo CLI (npx sundial-hub find) ──────────────────────────────────────────

# Modo JSON crudo (para uso por agentes)
if [[ "$JSON_MODE" == "true" ]]; then
  npx --yes sundial-hub@0.1.13 find "$QUERY" --json --limit "$LIMIT" 2>/dev/null
  exit 0
fi

# Modo interactivo — parsear JSON y mostrar formateado
RAW_JSON=$(npx --yes sundial-hub@0.1.13 find "$QUERY" --json --limit "$LIMIT" 2>/dev/null || echo "[]")

# Verificar si hay resultados
if [[ "$RAW_JSON" == "[]" || -z "$RAW_JSON" ]]; then
  echo -e "${YELLOW}❌ No se encontraron skills para '$QUERY' en SundialHub.${NC}"
  echo ""
  echo -e "💡 Prueba con términos más generales o busca en skills.sh ecosystem:"
  echo -e "   ${CYAN}./skills/universal-skill-creator/scripts/search_community_skills.sh \"$QUERY\"${NC}"
  exit 0
fi

# Mostrar resultados parseando JSON con python3 (disponible en todos los sistemas modernos)
echo "$RAW_JSON" | python3 -c "
import sys, json

try:
    skills = json.load(sys.stdin)
except json.JSONDecodeError:
    print('Error: No se pudo parsear la respuesta de SundialHub.')
    sys.exit(1)

if not skills:
    print('No se encontraron skills.')
    sys.exit(0)

print(f'\\n  Encontrados: {len(skills)} skills\\n')

for i, s in enumerate(skills, 1):
    name       = s.get('name', 'N/A')
    author     = s.get('author', 'N/A')
    version    = s.get('version', 'N/A')
    installs   = s.get('installs', 0)
    description = s.get('description', '')[:120]
    safety     = s.get('safety', '')
    url        = s.get('url', '')

    # Señal de confianza basada en installs
    if isinstance(installs, int):
        if installs > 10000:
            trust = '⭐⭐⭐ Alta'
        elif installs > 1000:
            trust = '⭐⭐   Media'
        elif installs > 100:
            trust = '⭐    Baja'
        else:
            trust = '     Nueva'
    else:
        trust = '     N/A'

    print(f'  [{i}] \033[1m{author}/{name}\033[0m  (v{version})')
    print(f'      📦 Installs: {installs:,}  |  Confianza: {trust}')
    if description:
        print(f'      📄 {description}')
    if safety:
        print(f'      🔒 Safety: {safety}')
    if url:
        print(f'      🔗 {url}')
    print()
"

echo "════════════════════════════════════════════════════════════"
echo ""
echo -e "💡 ${BOLD}Instalar un skill:${NC}"
echo -e "   ${CYAN}./skills/universal-skill-creator/scripts/install_sundial_skill.sh <author>/<skill>${NC}"
echo ""
echo -e "💡 ${BOLD}Ver SKILL.md crudo:${NC}"
echo -e "   ${CYAN}https://www.sundialhub.com/raw/<author>/<skill-name>${NC}"
echo ""

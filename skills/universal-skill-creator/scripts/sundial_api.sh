#!/usr/bin/env bash
# ==============================================================================
# sundial_api.sh
# Cliente HTTP directo para la API de SundialHub.
#
# Permite a los agentes de IA interactuar con SundialHub sin depender del
# CLI interactivo (`sundial-hub`). Usa curl + token Bearer para operaciones
# programáticas: buscar, consultar detalle, listar propios y publicar.
#
# Endpoints descubiertos via reverse-engineering del CLI v0.1.13.
# Base: https://www.sundialhub.com/api/hub/
#
# Uso: ./sundial_api.sh <command> [args] [options]
#
# Commands:
#   search <query>              Buscar skills
#   show <author>/<name>        Detalle de un skill
#   show-id <uuid>              Detalle por ID
#   mine                        Listar mis skills publicados
#   check-name <name>           Verificar si un nombre está disponible
#   publish <ruta-skill>        Publicar (POST) skill al registry
#   verify-auth                 Verificar que el token es válido
#
# Token: Se lee de ~/.sundial/auth.json o de $SUNDIAL_TOKEN env var
# ==============================================================================

set -e

# ── Colores ──────────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

# ── Configuración ───────────────────────────────────────────────────────────
BASE_URL="${SUNDIAL_HUB_URL:-https://www.sundialhub.com}"
AUTH_FILE="$HOME/.sundial/auth.json"

# ── Funciones de utilidad ────────────────────────────────────────────────────

usage() {
  cat <<EOF
Uso: $0 <command> [args] [options]

Cliente HTTP directo para la API de SundialHub.

Commands:
  search <query> [--limit N]   Buscar skills (JSON)
  show <author>/<name>         Detalle de un skill por autor/nombre
  show-id <uuid>               Detalle de un skill por UUID
  mine                         Listar mis skills publicados
  check-name <name>            Verificar disponibilidad de nombre
  publish <ruta-skill> [opts]  Publicar skill al registry
  verify-auth                  Verificar token válido

Options globales:
  --token <token>              Usar token específico (override auth.json)
  --raw                        Output curl sin formatear
  --help                       Mostrar esta ayuda

Opciones de publish:
  --version <ver>              Versión (ej: 1, 1.0.0)
  --changelog <msg>            Mensaje de changelog
  --visibility <type>          public (default) | private
  --categories <list>          Categorías separadas por comas

Variables de entorno:
  SUNDIAL_TOKEN                Token de autenticación (override auth.json)
  SUNDIAL_HUB_URL              Base URL alternativa

Ejemplos:
  $0 search "pdf processing" --limit 5
  $0 show anthropics/pdf
  $0 mine
  $0 check-name my-new-skill
  $0 publish ./skills/my-skill --version 1 --categories coding
  SUNDIAL_TOKEN=sd_xxx $0 search "forecast"
EOF
  exit 0
}

# Resolver token: $SUNDIAL_TOKEN > --token > ~/.sundial/auth.json
resolve_token() {
  local explicit_token="$1"

  # 1. Token explícito (--token flag)
  if [[ -n "$explicit_token" ]]; then
    echo "$explicit_token"
    return
  fi

  # 2. Variable de entorno
  if [[ -n "$SUNDIAL_TOKEN" ]]; then
    echo "$SUNDIAL_TOKEN"
    return
  fi

  # 3. Archivo auth.json
  if [[ -f "$AUTH_FILE" ]]; then
    local file_token
    file_token=$(python3 -c "import json; print(json.load(open('$AUTH_FILE')).get('token',''))" 2>/dev/null || echo "")
    if [[ -n "$file_token" ]]; then
      echo "$file_token"
      return
    fi
  fi

  echo ""
}

# Llamada API genérica
api_call() {
  local method="$1"
  local endpoint="$2"
  local body="$3"
  local token="$4"
  local raw_mode="$5"

  local url="${BASE_URL}${endpoint}"

  local curl_args=(
    -s
    -w "\n%{http_code}"
    -H "Content-Type: application/json"
  )

  if [[ -n "$token" ]]; then
    curl_args+=(-H "Authorization: Bearer ${token}")
  fi

  if [[ "$method" == "POST" ]]; then
    curl_args+=(-X POST)
    if [[ -n "$body" ]]; then
      curl_args+=(-d "$body")
    fi
  fi

  curl_args+=("$url")

  local response
  response=$(curl "${curl_args[@]}" 2>/dev/null) || {
    echo '{"error":"No se pudo conectar con SundialHub en '"$BASE_URL"'"}' >&2
    return 1
  }

  # Separar body y HTTP status code
  local http_code
  http_code=$(echo "$response" | tail -1)
  local response_body
  response_body=$(echo "$response" | sed '$d')

  # Verificar si es JSON
  if ! echo "$response_body" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    echo "{\"error\":\"Respuesta no-JSON del servidor (HTTP $http_code)\",\"http_code\":$http_code}" >&2
    return 1
  fi

  if [[ "$raw_mode" == "true" ]]; then
    echo "$response_body"
  else
    # Añadir http_code al JSON de respuesta
    echo "$response_body" | python3 -c "
import sys, json
data = json.load(sys.stdin)
data['_http_code'] = $http_code
json.dump(data, sys.stdout, indent=2, ensure_ascii=False)
print()
"
  fi

  # Retornar error si HTTP code >= 400
  if [[ $http_code -ge 400 ]]; then
    return 1
  fi
  return 0
}

# ── Comandos ─────────────────────────────────────────────────────────────────

cmd_search() {
  local query="$1"
  local limit="${2:-10}"
  local token="$3"
  local raw="$4"

  if [[ -z "$query" ]]; then
    echo '{"error":"Se requiere un término de búsqueda"}' >&2
    return 1
  fi

  local encoded_query
  encoded_query=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")

  local endpoint="/api/hub/skills?q=${encoded_query}&limit=${limit}"
  api_call "GET" "$endpoint" "" "$token" "$raw"
}

cmd_show() {
  local identifier="$1"
  local token="$2"
  local raw="$3"

  if [[ -z "$identifier" ]]; then
    echo '{"error":"Se requiere author/name"}' >&2
    return 1
  fi

  # Detectar si es author/name o solo name
  if [[ "$identifier" == */* ]]; then
    local author="${identifier%%/*}"
    local name="${identifier#*/}"
    local encoded_author
    encoded_author=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$author'))")
    local encoded_name
    encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$name'))")
    api_call "GET" "/api/hub/skills/by-author-name/${encoded_author}/${encoded_name}" "" "$token" "$raw"
  else
    local encoded_name
    encoded_name=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$identifier'))")
    api_call "GET" "/api/hub/skills/by-name/${encoded_name}" "" "$token" "$raw"
  fi
}

cmd_show_id() {
  local skill_id="$1"
  local token="$2"
  local raw="$3"

  if [[ -z "$skill_id" ]]; then
    echo '{"error":"Se requiere un UUID de skill"}' >&2
    return 1
  fi

  local encoded_id
  encoded_id=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$skill_id'))")
  api_call "GET" "/api/hub/skills/${encoded_id}" "" "$token" "$raw"
}

cmd_mine() {
  local token="$1"
  local raw="$2"

  if [[ -z "$token" ]]; then
    echo '{"error":"Se requiere autenticación para listar skills propios. Configura SUNDIAL_TOKEN o ~/.sundial/auth.json"}' >&2
    return 1
  fi

  api_call "GET" "/api/hub/skills?mine=true" "" "$token" "$raw"
}

cmd_check_name() {
  local name="$1"
  local token="$2"
  local raw="$3"

  if [[ -z "$name" ]]; then
    echo '{"error":"Se requiere un nombre de skill"}' >&2
    return 1
  fi

  # Usar by-name para verificar si existe
  local result
  result=$(api_call "GET" "/api/hub/skills/by-name/$(python3 -c "import urllib.parse; print(urllib.parse.quote('$name'))")" "" "$token" "true" 2>&1) || true

  if echo "$result" | python3 -c "import sys,json; d=json.load(sys.stdin); sys.exit(0 if 'error' in d else 1)" 2>/dev/null; then
    echo "{\"name\": \"$name\", \"available\": true, \"message\": \"El nombre está disponible\"}"
  else
    local candidates
    candidates=$(echo "$result" | python3 -c "
import sys, json
d = json.load(sys.stdin)
if 'skill' in d:
    s = d['skill']
    print(json.dumps({'name': '$name', 'available': False, 'owner': s.get('author',''), 'message': 'Nombre ya registrado'}))
elif 'candidates' in d:
    c = d['candidates']
    print(json.dumps({'name': '$name', 'available': False, 'owners': [x.get('author','') for x in c], 'count': len(c), 'message': f'{len(c)} skills con este nombre'}))
else:
    print(json.dumps({'name': '$name', 'available': True, 'message': 'Disponible'}))
" 2>/dev/null || echo "{\"name\": \"$name\", \"available\": \"unknown\"}")
    echo "$candidates"
  fi
}

cmd_verify_auth() {
  local token="$1"

  if [[ -z "$token" ]]; then
    echo '{"authenticated": false, "error": "No se encontró token"}'
    return 1
  fi

  local result
  if result=$(api_call "GET" "/api/hub/skills?mine=true&limit=1" "" "$token" "true" 2>&1); then
    echo "{\"authenticated\": true, \"token_prefix\": \"${token:0:6}...\"}"
    return 0
  else
    echo "{\"authenticated\": false, \"error\": \"Token inválido o expirado\"}"
    return 1
  fi
}

cmd_publish() {
  local skill_path="$1"
  local token="$2"
  local version="$3"
  local changelog="$4"
  local visibility="${5:-public}"
  local categories="$6"
  local raw="$7"

  # ── Validaciones ──
  if [[ -z "$token" ]]; then
    echo '{"error":"Se requiere autenticación para publicar. Configura SUNDIAL_TOKEN o ~/.sundial/auth.json"}' >&2
    return 1
  fi

  if [[ ! -d "$skill_path" ]]; then
    echo "{\"error\":\"Directorio no encontrado: $skill_path\"}" >&2
    return 1
  fi

  if [[ ! -f "$skill_path/SKILL.md" ]]; then
    echo "{\"error\":\"No se encontró SKILL.md en $skill_path\"}" >&2
    return 1
  fi

  # ── SCAN DE SEGURIDAD OBLIGATORIO ──
  local scan_script
  scan_script="$(dirname "$0")/scan_sensitive_data.sh"

  if [[ -f "$scan_script" ]]; then
    echo -e "${BOLD}🔒 Ejecutando scan de seguridad obligatorio...${NC}" >&2
    if ! bash "$scan_script" "$skill_path" --strict 2>&1 >&2; then
      echo "{\"error\":\"BLOQUEADO: El scan de seguridad encontró información sensible. Corrige los hallazgos antes de publicar.\"}" >&2
      return 1
    fi
    echo -e "${GREEN}  ✓ Scan de seguridad pasado${NC}" >&2
  else
    echo -e "${YELLOW}⚠ Script scan_sensitive_data.sh no encontrado. Ejecutando sin scan.${NC}" >&2
  fi

  # ── Extraer metadata del SKILL.md ──
  local skill_name skill_description skill_version skill_display_name
  skill_name=$(grep -m1 "^name:" "$skill_path/SKILL.md" | sed 's/name: *//' | tr -d '"' | tr -d "'" | xargs 2>/dev/null || echo "")
  skill_description=$(grep -m1 "^description:" "$skill_path/SKILL.md" | sed 's/description: *//' | tr -d '"' | xargs 2>/dev/null || echo "")

  # Intentar extraer description multilinea (>)
  if [[ -z "$skill_description" ]]; then
    skill_description=$(python3 -c "
import re
with open('$skill_path/SKILL.md') as f:
    content = f.read()
m = re.search(r'^description:\s*>\s*\n((?:\s+.+\n?)+)', content, re.MULTILINE)
if m:
    desc = ' '.join(line.strip() for line in m.group(1).strip().split('\n'))
    print(desc)
" 2>/dev/null || echo "")
  fi

  skill_version=$(grep -m1 "^  version:" "$skill_path/SKILL.md" | sed 's/.*version: *//' | tr -d '"' | tr -d "'" | xargs 2>/dev/null || echo "1")
  skill_display_name=$(grep -m1 "^  display_name:" "$skill_path/SKILL.md" | sed 's/.*display_name: *//' | tr -d '"' | xargs 2>/dev/null || echo "$skill_name")

  if [[ -z "$skill_name" ]]; then
    echo '{"error":"No se pudo extraer name del frontmatter de SKILL.md"}' >&2
    return 1
  fi

  # Override con parámetros explícitos
  [[ -n "$version" ]] && skill_version="$version"

  # ── Recolectar archivos ──
  local files_json
  files_json=$(python3 -c "
import os, json

skill_path = '$skill_path'
SKIP = {'.git', 'node_modules', '.DS_Store', '__pycache__', '.env'}
files = []

for root, dirs, filenames in os.walk(skill_path):
    dirs[:] = [d for d in dirs if d not in SKIP and not d.startswith('.')]
    for fname in filenames:
        if fname.startswith('.') or fname in SKIP:
            continue
        full_path = os.path.join(root, fname)
        rel_path = os.path.relpath(full_path, skill_path)
        try:
            with open(full_path, 'r', encoding='utf-8') as f:
                content = f.read()
            files.append({'path': rel_path, 'content': content})
        except (UnicodeDecodeError, PermissionError):
            pass  # Skip binary files

print(json.dumps(files))
" 2>/dev/null)

  # ── Crear ZIP en base64 ──
  local zip_base64
  zip_base64=$(python3 -c "
import zipfile, os, base64, io

skill_path = '$skill_path'
SKIP = {'.git', 'node_modules', '.DS_Store', '__pycache__', '.env'}
buf = io.BytesIO()

with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, filenames in os.walk(skill_path):
        dirs[:] = [d for d in dirs if d not in SKIP and not d.startswith('.')]
        for fname in filenames:
            if fname.startswith('.') or fname in SKIP:
                continue
            full_path = os.path.join(root, fname)
            rel_path = os.path.relpath(full_path, skill_path)
            zf.write(full_path, rel_path)

print(base64.b64encode(buf.getvalue()).decode())
" 2>/dev/null)

  # ── Verificar si ya existe ──
  echo -e "${BOLD}🔍 Verificando si '$skill_name' ya existe en SundialHub...${NC}" >&2

  local existing
  existing=$(api_call "GET" "/api/hub/skills/by-name/$(python3 -c "import urllib.parse; print(urllib.parse.quote('$skill_name'))")" "" "$token" "true" 2>/dev/null) || true

  local has_existing
  has_existing=$(echo "$existing" | python3 -c "import sys,json; d=json.load(sys.stdin); print('yes' if 'skill' in d else 'no')" 2>/dev/null || echo "no")

  # ── Preparar categorías ──
  local categories_json="[]"
  if [[ -n "$categories" ]]; then
    categories_json=$(python3 -c "
import json
cats = [c.strip().lower().replace(' ', '-') for c in '$categories'.split(',') if c.strip()]
print(json.dumps(list(set(cats))))
")
  fi

  if [[ "$has_existing" == "yes" ]]; then
    # ── Publicar nueva versión ──
    local existing_id existing_version
    existing_id=$(echo "$existing" | python3 -c "import sys,json; print(json.load(sys.stdin)['skill']['id'])" 2>/dev/null)
    existing_version=$(echo "$existing" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('version',{}).get('version','0') if isinstance(d.get('version'),dict) else d['skill'].get('version','0'))" 2>/dev/null || echo "0")

    echo -e "${CYAN}  Skill existente encontrado (v${existing_version}). Publicando nueva versión...${NC}" >&2

    local body
    body=$(python3 -c "
import json
body = {
    'version': '$skill_version',
    'display_name': '$skill_display_name',
    'description': '''$skill_description''',
    'files': $files_json,
    'zip': '$zip_base64'
}
if '$changelog':
    body['changelog'] = '$changelog'
if $categories_json != []:
    body['categories'] = $categories_json
print(json.dumps(body))
")

    api_call "POST" "/api/hub/skills/${existing_id}/versions" "$body" "$token" "$raw"
  else
    # ── Crear skill nuevo ──
    echo -e "${CYAN}  Skill no encontrado. Creando nuevo...${NC}" >&2

    local body
    body=$(python3 -c "
import json
body = {
    'name': '$skill_name',
    'display_name': '$skill_display_name',
    'description': '''$skill_description''',
    'categories': $categories_json if $categories_json != [] else ['other'],
    'visibility': '$visibility',
    'version': '$skill_version',
    'files': $files_json,
    'zip': '$zip_base64'
}
print(json.dumps(body))
")

    api_call "POST" "/api/hub/skills" "$body" "$token" "$raw"
  fi
}

# ══════════════════════════════════════════════════════════════════════════════
# DISPATCHER PRINCIPAL
# ══════════════════════════════════════════════════════════════════════════════

COMMAND=""
ARGS=()
TOKEN_OVERRIDE=""
RAW_MODE=false
PUB_VERSION=""
PUB_CHANGELOG=""
PUB_VISIBILITY="public"
PUB_CATEGORIES=""
LIMIT=10

# Parsear argumentos globales
while [[ $# -gt 0 ]]; do
  case $1 in
    --token)
      TOKEN_OVERRIDE="$2"
      shift 2
      ;;
    --raw)
      RAW_MODE=true
      shift
      ;;
    --limit)
      LIMIT="$2"
      shift 2
      ;;
    --version)
      PUB_VERSION="$2"
      shift 2
      ;;
    --changelog)
      PUB_CHANGELOG="$2"
      shift 2
      ;;
    --visibility)
      PUB_VISIBILITY="$2"
      shift 2
      ;;
    --categories)
      PUB_CATEGORIES="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      if [[ -z "$COMMAND" ]]; then
        COMMAND="$1"
      else
        ARGS+=("$1")
      fi
      shift
      ;;
  esac
done

# Resolver token
TOKEN=$(resolve_token "$TOKEN_OVERRIDE")

# Despachar comando
case "$COMMAND" in
  search|find|f)
    cmd_search "${ARGS[0]}" "$LIMIT" "$TOKEN" "$RAW_MODE"
    ;;
  show|get)
    cmd_show "${ARGS[0]}" "$TOKEN" "$RAW_MODE"
    ;;
  show-id)
    cmd_show_id "${ARGS[0]}" "$TOKEN" "$RAW_MODE"
    ;;
  mine|my)
    cmd_mine "$TOKEN" "$RAW_MODE"
    ;;
  check-name|check)
    cmd_check_name "${ARGS[0]}" "$TOKEN" "$RAW_MODE"
    ;;
  publish|push)
    cmd_publish "${ARGS[0]:-.}" "$TOKEN" "$PUB_VERSION" "$PUB_CHANGELOG" "$PUB_VISIBILITY" "$PUB_CATEGORIES" "$RAW_MODE"
    ;;
  verify-auth|auth)
    cmd_verify_auth "$TOKEN"
    ;;
  "")
    usage
    ;;
  *)
    echo "{\"error\":\"Comando desconocido: $COMMAND\"}" >&2
    echo "Usa $0 --help para ver los comandos disponibles." >&2
    exit 1
    ;;
esac

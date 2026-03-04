#!/usr/bin/env bash
# ============================================================================
# install-po-agents.sh
# Instala los agentes del Product Owner en el scope correcto
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SOURCE_DIR="$(dirname "$SCRIPT_DIR")"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  🎯 Agile Product Owner - Agent Installer       ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_help() {
    print_header
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  --global           Instala el agente bootstrap en ~/.github/agents/"
    echo "  --project <path>   Instala agentes completos en <path>/.github/agents/"
    echo "  --all <path>       Instala global + proyecto"
    echo "  --dry-run          Muestra qué haría sin ejecutar"
    echo "  --help             Muestra esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0 --global"
    echo "  $0 --project /home/user/mi-proyecto"
    echo "  $0 --all /home/user/mi-proyecto"
    echo ""
}

install_global() {
    local dry_run="${1:-false}"
    local target_dir="$HOME/.github/agents"
    local source="$AGENTS_SOURCE_DIR/global/agile-product-owner.agent.md"

    echo -e "${YELLOW}📦 Instalando agente GLOBAL (bootstrap)...${NC}"
    echo -e "   Origen:  ${source}"
    echo -e "   Destino: ${target_dir}/"

    if [[ "$dry_run" == "true" ]]; then
        echo -e "${BLUE}   [DRY-RUN] Se copiaría agile-product-owner.agent.md${NC}"
        return
    fi

    mkdir -p "$target_dir"
    cp "$source" "$target_dir/"
    echo -e "${GREEN}   ✅ Agente global instalado${NC}"
    echo ""
    echo -e "${YELLOW}   ⚠️  NOTA: El agente global tiene capacidades REDUCIDAS.${NC}"
    echo -e "${YELLOW}      Para funcionalidad completa, instala también a nivel de proyecto.${NC}"
}

install_project() {
    local project_path="$1"
    local dry_run="${2:-false}"
    local target_dir="${project_path}/.github/agents"
    local source_dir="$AGENTS_SOURCE_DIR/project"

    echo -e "${YELLOW}📦 Instalando agentes de PROYECTO (full)...${NC}"
    echo -e "   Origen:  ${source_dir}/"
    echo -e "   Destino: ${target_dir}/"

    local agents=(
        "agile-product-owner.agent.md"
        "plan-mejorado.agent.md"
        "po-story-writer.agent.md"
        "po-ado-sync.agent.md"
        "po-mysql-explorer.agent.md"
        "po-analyst.agent.md"
    )

    for agent in "${agents[@]}"; do
        if [[ "$dry_run" == "true" ]]; then
            echo -e "${BLUE}   [DRY-RUN] Se copiaría ${agent}${NC}"
        else
            mkdir -p "$target_dir"
            cp "${source_dir}/${agent}" "${target_dir}/"
            echo -e "${GREEN}   ✅ ${agent}${NC}"
        fi
    done

    if [[ "$dry_run" != "true" ]]; then
        echo ""
        echo -e "${GREEN}   ✅ Todos los agentes de proyecto instalados${NC}"
        echo ""
        echo -e "${YELLOW}   📋 Siguiente paso: Configurar MCP de Azure DevOps${NC}"
        echo -e "${YELLOW}      Edita ${project_path}/.vscode/mcp.json con tus credenciales${NC}"
        echo -e "${YELLOW}      O configura las variables de entorno:${NC}"
        echo -e "${YELLOW}        AZURE_DEVOPS_ORG_URL=https://dev.azure.com/tu-org${NC}"
        echo -e "${YELLOW}        AZURE_DEVOPS_PAT=tu-token${NC}"
    fi
}

# Parse args
DRY_RUN=false
MODE=""
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --global)
            MODE="global"
            shift
            ;;
        --project)
            MODE="project"
            PROJECT_PATH="${2:?'Falta la ruta del proyecto'}"
            shift 2
            ;;
        --all)
            MODE="all"
            PROJECT_PATH="${2:?'Falta la ruta del proyecto'}"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help|-h)
            print_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Opción desconocida: $1${NC}"
            print_help
            exit 1
            ;;
    esac
done

if [[ -z "$MODE" ]]; then
    print_help
    exit 1
fi

print_header

case "$MODE" in
    global)
        install_global "$DRY_RUN"
        ;;
    project)
        install_project "$PROJECT_PATH" "$DRY_RUN"
        ;;
    all)
        install_global "$DRY_RUN"
        echo ""
        install_project "$PROJECT_PATH" "$DRY_RUN"
        ;;
esac

echo ""
echo -e "${GREEN}🎉 Instalación completada.${NC}"
echo -e "${BLUE}   Reinicia VS Code para que Copilot detecte los nuevos agentes.${NC}"
echo ""

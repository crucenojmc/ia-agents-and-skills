#!/bin/bash
#
# init-submodules.sh
# Inicializa y actualiza los submódulos git del repositorio
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🔄 Inicializando submódulos git..."

# Inicializar submódulos
git submodule init

# Actualizar submódulos (clonar si no existen)
git submodule update --recursive

echo ""
echo "✅ Submódulos inicializados correctamente:"
echo ""
git submodule status
echo ""
echo "📁 Los repositorios externos están en: recursos/external_repos/"

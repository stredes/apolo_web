#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Script para configurar y arrancar el proyecto web completo
# (Monorepo: Backend Django + Frontend React/Vite)
# Permite ejecutarse desde cualquier subdirectorio.
# ------------------------------------------------------------------
# Uso:
#   chmod +x setup_full_web.sh
#   ./setup_full_web.sh
# ------------------------------------------------------------------

# 0. Detectar la raíz del proyecto (donde existen las carpetas backend frontend)
echo "�� Buscando raíz del monorepo..."
while [ ! -d "backend" ] || [ ! -d "frontend" ]; do
  if [ "$(pwd)" = "/" ]; then
    echo "❌ No se encontró backend/ y frontend/ en ningún padre. Abortando."
    exit 1
  fi
  cd ..
done
ROOT_DIR="$(pwd)"
echo "🏗️ Directorio raíz detectado: $ROOT_DIR"

# Definir rutas absolutas
BACKEND_DIR="$ROOT_DIR/backend"
FRONTEND_DIR="$ROOT_DIR/frontend"
SCRIPTS_DIR="$ROOT_DIR/scripts"

# 1. Ejecutar scaffold si existe
if [ -x "$SCRIPTS_DIR/generate_full_scaffold.sh" ]; then
  echo -e "\n🔄 Ejecutando scaffold de backend/frontend..."
  bash "$SCRIPTS_DIR/generate_full_scaffold.sh"
fi

# 2. Reestructuración si corresponde
if [ -x "$ROOT_DIR/restructure_project.sh" ]; then
  echo -e "\n🔄 Ejecutando reestructuración del monorepo..."
  bash "$ROOT_DIR/restructure_project.sh"
fi

# 3. Configurar backend Django
echo -e "\n📦 Configurando backend Django..."
cd "$BACKEND_DIR"

# Crear virtualenv si no existe
test -d ".venv" || {
  echo "🐍 Creando virtualenv..."
  python3 -m venv .venv
}

# Activar virtualenv
echo "⚡ Activando virtualenv..."
# shellcheck disable=SC1091
source .venv/bin/activate
PYTHON="$(pwd)/.venv/bin/python"
PIP="$(pwd)/.venv/bin/pip"

# Instalar dependencias
echo "📥 Instalando dependencias Django..."
$PYTHON -m pip install --upgrade pip
$PIP install -r requirements.txt

# Ejecutar tests backend si existe pytest
echo "🔍 Ejecutando tests backend..."
if command -v pytest &> /dev/null; then
  $PYTHON -m pytest --maxfail=1 --disable-warnings || echo "⚠️ Algunos tests fallaron"
else
  echo "⚠️ pytest no instalado (backend). Omitiendo."
fi

# Migraciones y staticfiles
echo "🗄️ Aplicando migraciones y recopilando estáticos..."
$PYTHON manage.py migrate --no-input
$PYTHON manage.py collectstatic --no-input

# 4. Configurar frontend React
echo -e "\n📦 Configurando frontend React..."
cd "$FRONTEND_DIR"

echo "📥 Instalando dependencias frontend..."
npm ci || npm install

# Ejecutar tests frontend si existen
echo "🔍 Ejecutando tests frontend..."
if npm test -- --watchAll=false --passWithNoTests; then
  echo "✅ Tests frontend OK"
else
  echo "⚠️ Tests frontend fallaron o no existen."
fi

# Build de producción
echo "🚧 Compilando frontend para producción..."
npm run build

# 5. Integrar build en Django staticfiles
echo "➡️ Integrando build en staticfiles del backend..."
if [ -d "dist" ]; then
  rm -rf "$BACKEND_DIR/apolo_web/static/frontend"
  mkdir -p "$BACKEND_DIR/apolo_web/static/frontend"
  cp -r dist/* "$BACKEND_DIR/apolo_web/static/frontend/"
fi

# 6. Iniciar servidor de desarrollo Django
echo -e "\n🚀 Iniciando servidor Django (Dev)..."
cd "$BACKEND_DIR"
$PYTHON manage.py runserver

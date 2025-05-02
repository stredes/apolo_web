#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# scripts/setup_full.sh
# ------------------------------------------------------------------

echo -e "\n🔎 Iniciando setup completo…"

# 1) Localizar la raíz del monorepo (tiene backend/ y frontend/)
ROOT="$PWD"
if [[ ! -d "$ROOT/backend" || ! -d "$ROOT/frontend" ]]; then
  echo "❌ Ejecuta este script desde la raíz que contenga backend/ y frontend/"
  exit 1
fi
echo "🏗️  Raíz del monorepo: $ROOT"

# 2) Entrar al backend y activar virtualenv
cd "$ROOT/backend"
if [[ -f ".venv/bin/activate" ]]; then
  # shellcheck source=/dev/null
  source .venv/bin/activate
  echo "✅ Virtualenv activado"
else
  echo "❌ No encontré .venv/bin/activate en backend/"
  exit 1
fi

# 3) Instalar y configurar WhiteNoise en Django
echo "🔧 Instalando WhiteNoise…"
pip install whitenoise >/dev/null
SETTINGS="apolo_web/settings.py"
URLS="apolo_web/urls.py"

# A) STATIC_ROOT
grep -q "^STATIC_ROOT" "$SETTINGS" \
  || sed -i "/^STATIC_URL/ a STATIC_ROOT = BASE_DIR / 'staticfiles'" "$SETTINGS"

# B) Middleware WhiteNoise
grep -q "WhiteNoiseMiddleware" "$SETTINGS" \
  || sed -i "/MIDDLEWARE = \[/a \    'whitenoise.middleware.WhiteNoiseMiddleware'," "$SETTINGS"

# C) Enrutamiento SPA en la raíz
if ! grep -q "TemplateView" "$URLS"; then
  sed -i "1i from django.views.generic import TemplateView" "$URLS"
  sed -i "/urlpatterns = \[/i\    path('', TemplateView.as_view(template_name='index.html'), name='spa-root')," "$URLS"
fi

echo "✅ settings.py y urls.py actualizados para servir la SPA"

# 4) Parchear deleteCliente en el servicio de clientes
FRONTEND_SERVICES="$ROOT/frontend/src/services/clientes.js"
if [[ -f "$FRONTEND_SERVICES" ]]; then
  if ! grep -q "export const deleteCliente" "$FRONTEND_SERVICES"; then
    cat >> "$FRONTEND_SERVICES" << 'EOF'

export const deleteCliente = id => api.delete(`clientes/${id}/`);
EOF
    echo "✅ Añadido deleteCliente a frontend/src/services/clientes.js"
  else
    echo "ℹ️ deleteCliente ya estaba presente"
  fi
else
  echo "⚠️ No encontré $FRONTEND_SERVICES, omitiendo parche de deleteCliente"
fi

# 5) Compilar el frontend
cd "$ROOT/frontend"
echo "🔨 Instalando deps y compilando frontend…"
npm install
npm run build

if [[ ! -d "dist" ]]; then
  echo "❌ Build de frontend falló (no existe carpeta dist/)"
  exit 1
fi
echo "✅ frontend compilado en frontend/dist/"

# 6) Copiar dist/ a staticfiles de Django
DEST="$ROOT/backend/static/frontend"
rm -rf "$DEST"
mkdir -p "$DEST"
cp -r dist/* "$DEST/"
echo "✅ Copiado dist/ a backend/static/frontend/"

# 7) Recolectar estáticos y arrancar Django
cd "$ROOT/backend"
echo "🔷 Ejecutando collectstatic…"
python manage.py collectstatic --no-input
echo "✅ collectstatic OK"

echo -e "\n🚀 Servidor Django arrancado en http://0.0.0.0:8000/\n"
exec python manage.py runserver 0.0.0.0:8000

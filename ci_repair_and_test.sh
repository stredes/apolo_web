#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# Script auto-reparador, migrador, integrador y lanzador de tu monorepo Django + Desktop
# ------------------------------------------------------------------
# Uso:
#   chmod +x ci_repair_and_run.sh
#   ./ci_repair_and_run.sh
# ------------------------------------------------------------------

echo "🔎 Buscando la raíz del proyecto..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROBE="$SCRIPT_DIR"
BACKEND=""
DESKTOP=""

# 1) Detectar backend (manage.py) y desktop_app
while [[ "$PROBE" != "/" ]]; do
  if [[ -f "$PROBE/manage.py" ]]; then
    BACKEND="$PROBE"
  elif [[ -f "$PROBE/backend/manage.py" ]]; then
    BACKEND="$PROBE/backend"
  fi
  if [[ -d "$PROBE/desktop_app" ]]; then
    DESKTOP="$PROBE/desktop_app"
  fi
  if [[ -n "$BACKEND" && -n "$DESKTOP" ]]; then break; fi
  PROBE="$(dirname "$PROBE")"
done

if [[ -z "$BACKEND" ]]; then
  echo "❌ No encontré manage.py en ninguna carpeta padre." >&2
  exit 1
fi
if [[ -z "$DESKTOP" ]]; then
  echo "⚠️  No encontré desktop_app/, omitiendo integración de desktop."
else
  echo "💾 Desktop app detectada en: $DESKTOP"
fi

echo "🏗️  Backend Django en: $BACKEND"
cd "$BACKEND"

# 2) Configurar virtualenv
VENV=".venv"
if [[ ! -d "$VENV" ]]; then
  echo "🛠 Creando virtualenv..."
  python3 -m venv "$VENV"
fi
# shellcheck source=/dev/null
source "$VENV/bin/activate"
PIP=$(command -v pip)
PY=$(command -v python)
echo "✅ Virtualenv listo"

# 3) Reparar requirements.txt
REQ="requirements.txt"
if [[ -f "$REQ" ]]; then
  echo "🔧 Limpiando zebra-barcodes de requirements.txt..."
  sed -i '/zebra-barcodes/d' "$REQ"
  grep -q '^zebra' "$REQ" || echo 'zebra>=0.2.0' >> "$REQ"
  echo "✅ requirements.txt corregido"
fi

# 4) Asegurar STATIC_ROOT y ALLOWED_HOSTS en settings.py
SETTINGS="apolo_web/settings.py"
if [[ -f "$SETTINGS" ]]; then
  if ! grep -q '^STATIC_ROOT' "$SETTINGS"; then
    sed -i "/^STATIC_URL/ a\    STATIC_ROOT = BASE_DIR / 'staticfiles'" "$SETTINGS"
    echo "✅ Añadido STATIC_ROOT en settings.py"
  fi
  if grep -q '^ALLOWED_HOSTS' "$SETTINGS"; then
    sed -i "s/^ALLOWED_HOSTS.*/ALLOWED_HOSTS = ['*']/" "$SETTINGS"
  else
    sed -i "/^DEBUG/ a\ALLOWED_HOSTS = ['*']" "$SETTINGS"
  fi
  echo "✅ ALLOWED_HOSTS configurado para '*'"
fi

# 5) Generar stubs básicos
MODELS="informes/models.py"
if [[ -f "$MODELS" ]] && ! grep -q 'class MainAppModel' "$MODELS"; then
  cat >> "$MODELS" << 'EOF'

from django.db import models

class MainAppModel(models.Model):
    placeholder = models.CharField(max_length=10)
    class Meta:
        app_label = 'informes'
EOF
  echo "✅ Stub MainAppModel añadido"
fi

SERIALIZERS="informes/serializers.py"
if [[ -f "$SERIALIZERS" ]] && ! grep -q 'class MainAppSerializer' "$SERIALIZERS"; then
  sed -i "1s|^|from .models import MainAppModel
from rest_framework import serializers
|" "$SERIALIZERS"
  cat >> "$SERIALIZERS" << 'EOF'

class MainAppSerializer(serializers.ModelSerializer):
    class Meta:
        model = MainAppModel
        fields = '__all__'
EOF
  echo "✅ Stub MainAppSerializer añadido"
fi

VIEWS="informes/views.py"
if [[ -f "$VIEWS" ]] && ! grep -q 'class MainAppViewSet' "$VIEWS"; then
  sed -i "1s|^|from .models import MainAppModel
from .serializers import MainAppSerializer
from rest_framework import viewsets
|" "$VIEWS"
  cat >> "$VIEWS" << 'EOF'

class MainAppViewSet(viewsets.ModelViewSet):
    queryset = MainAppModel.objects.all()
    serializer_class = MainAppSerializer
EOF
  echo "✅ Stub MainAppViewSet añadido"
fi

# 6) Configurar urls.py con redirección y desktop
URLS_FILE="apolo_web/urls.py"
cat > "$URLS_FILE" << 'EOF'
from django.contrib import admin
from django.urls import path, include
from django.shortcuts import redirect
from rest_framework import routers
from informes.views import ClienteViewSet

try:
    from informes.views import MainAppViewSet
except ImportError:
    MainAppViewSet = None

router = routers.DefaultRouter()
router.register('clientes', ClienteViewSet, basename='clientes')
if MainAppViewSet:
    router.register('main_app', MainAppViewSet, basename='main_app')

urlpatterns = [
    path('', lambda req: redirect('api/', permanent=False)),
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
]
EOF
echo "✅ urls.py configurado"

# 7) Instalar deps y migrar
echo -e "\n🔷 Instalando dependencias y aplicando migraciones..."
$PIP install --upgrade pip
$PIP install -r requirements.txt
$PY manage.py makemigrations --no-input
$PY manage.py migrate --no-input
$PY manage.py collectstatic --no-input
echo "✅ Backend listo"

# 8) Integrar desktop_app
if [[ -n "$DESKTOP" ]]; then
  echo "🔗 Integrando desktop_app como estático web..."
  mkdir -p staticfiles/desktop_app
  cp -r "$DESKTOP/"* staticfiles/desktop_app/
  echo "✅ desktop_app copiada a staticfiles/desktop_app"
fi

# 9) Iniciar servidor
echo -e "\n🚀 Iniciando servidor Django en: http://127.0.0.1:8000/"
exec $PY manage.py runserver 0.0.0.0:8000
EOF

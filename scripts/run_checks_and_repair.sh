#!/usr/bin/env bash
set -euo pipefail

echo "🔎 Generando stubs faltantes y ejecutando chequeos…"

# 1) Detectar raíz del proyecto
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND="$ROOT_DIR/backend"
INF_DIR="$BACKEND/informes"

# 2) Crear serializers.py si falta
SER_FILE="$INF_DIR/serializers.py"
if [[ ! -f "$SER_FILE" ]]; then
  cat > "$SER_FILE" << 'PY'
from rest_framework import serializers
from .models import MainAppModel, Cliente

class ClienteSerializer(serializers.ModelSerializer):
    class Meta:
        model = Cliente
        fields = '__all__'

# Stub para MainAppModel
class MainAppModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = MainAppModel
        fields = '__all__'
PY
  echo "✅ Se creó stub de serializers en $SER_FILE"
fi

# 3) Crear models.py stub de MainAppModel si falta
MOD_FILE="$INF_DIR/models.py"
if ! grep -q "class MainAppModel" "$MOD_FILE"; then
  cat >> "$MOD_FILE" << 'PY'

# ——— Stub MainAppModel (genera tus campos reales aquí) ———
from django.db import models
class MainAppModel(models.Model):
    # TODO: define your fields
    created = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"MainAppModel #{self.pk}"
PY
  echo "✅ Se añadió MainAppModel stub en $MOD_FILE"
fi

# 4) Crear views.py stub de MainAppViewSet si falta
VIEWS_FILE="$INF_DIR/views.py"
if ! grep -q "class MainAppViewSet" "$VIEWS_FILE"; then
  cat >> "$VIEWS_FILE" << 'PY'

from rest_framework import viewsets
from .models import MainAppModel
from .serializers import MainAppModelSerializer

class MainAppViewSet(viewsets.ModelViewSet):
    """Stub ViewSet para MainAppModel"""
    queryset = MainAppModel.objects.all()
    serializer_class = MainAppModelSerializer
PY
  echo "✅ Se añadió MainAppViewSet en $VIEWS_FILE"
fi

# 5) Asegurarnos de que ClienteViewSet importe su serializer
if ! grep -q "from .serializers import ClienteSerializer" "$VIEWS_FILE"; then
  sed -i "1ifrom .serializers import ClienteSerializer" "$VIEWS_FILE"
  sed -i "/class ClienteViewSet/a\    serializer_class = ClienteSerializer" "$VIEWS_FILE"
  echo "✅ Ajustado ClienteViewSet para usar ClienteSerializer"
fi

# 6) Ejecutar tus chequeos
echo; echo "===== EJECUTANDO CHEQUEOS DJANGO ====="
cd "$BACKEND"

# activar venv y pip install si es necesario
source .venv/bin/activate 2>/dev/null || true

echo; echo "🔷 Django check"
python manage.py check || echo "❌ Django check falló"

echo; echo "🔷 Migraciones"
python manage.py migrate --no-input || echo "❌ Django migrate falló"

echo; echo "🔷 Collectstatic"
python manage.py collectstatic --no-input || echo "❌ Collectstatic falló"

echo; echo "===== CHEQUEOS FRONTEND ====="
if [[ -d "$ROOT_DIR/frontend" ]]; then
  cd "$ROOT_DIR/frontend"
  echo; echo "🔷 npm ci"
  npm ci || echo "❌ npm ci falló"
  echo; echo "🔷 npm run build"
  npm run build || echo "❌ npm build falló"
else
  echo "⚠️ No encontré carpeta frontend/, omitiendo."
fi

echo; echo "🎉 Proceso completado."

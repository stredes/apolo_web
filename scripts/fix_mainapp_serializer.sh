#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# scripts/fix_mainapp_serializer.sh
# ------------------------------------------------------------------
# Añade stubs de MainAppModel, MainAppSerializer y MainAppViewSet
# si no existen, para que Django ya no falle al importarlos.
# ------------------------------------------------------------------

# Detectar raíz del proyecto (contiene backend/)
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
BACKEND="$ROOT/backend"
INF_DIR="$BACKEND/informes"

MODELS="$INF_DIR/models.py"
SERIALIZERS="$INF_DIR/serializers.py"
VIEWS="$INF_DIR/views.py"

echo "🔎 Parcheando informes/models.py…"
if ! grep -q "^class MainAppModel" "$MODELS"; then
  cat >> "$MODELS" << 'EOF'

class MainAppModel(models.Model):
    # stub creado automáticamente
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name
EOF
  echo "✅ Se añadió MainAppModel stub."
else
  echo "ℹ️ MainAppModel ya existe, saltando."
fi

echo "🔎 Parcheando informes/serializers.py…"
if ! grep -q "^class MainAppSerializer" "$SERIALIZERS"; then
  # Asegurar import de MainAppModel
  if ! grep -q "from .models import MainAppModel" "$SERIALIZERS"; then
    sed -i "/from rest_framework import serializers/a from .models import MainAppModel" "$SERIALIZERS"
  fi
  cat >> "$SERIALIZERS" << 'EOF'

class MainAppSerializer(serializers.ModelSerializer):
    class Meta:
        model = MainAppModel
        fields = '__all__'
EOF
  echo "✅ Se añadió MainAppSerializer stub."
else
  echo "ℹ️ MainAppSerializer ya existe, saltando."
fi

echo "🔎 Parcheando informes/views.py…"
# Asegurar import de MainAppModel y MainAppSerializer
if ! grep -q "MainAppModel" "$VIEWS"; then
  sed -i "1i from .models import MainAppModel" "$VIEWS"
fi
if ! grep -q "MainAppSerializer" "$VIEWS"; then
  sed -i "1i from .serializers import MainAppSerializer" "$VIEWS"
fi

# Añadir el ViewSet si falta
if ! grep -q "^class MainAppViewSet" "$VIEWS"; then
  cat >> "$VIEWS" << 'EOF'

class MainAppViewSet(viewsets.ModelViewSet):
    queryset = MainAppModel.objects.all()
    serializer_class = MainAppSerializer
EOF
  echo "✅ Se añadió MainAppViewSet stub."
else
  echo "ℹ️ MainAppViewSet ya existe, saltando."
fi

echo -e "\n🎉 Parche completo. Ahora vuelve a ejecutar:\n"
echo "   cd backend"
echo "   source .venv/bin/activate   # o tu virtualenv"
echo "   python manage.py check"
echo "   python manage.py migrate --no-input"
echo "   python manage.py collectstatic --no-input"
echo "   python manage.py runserver"

#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# scripts/generate_endpoints_scaffold.sh
# ------------------------------------------------------------------
# Lee backend/apolo_web/urls.py y genera en frontend/src/services/
# un servicio Axios por cada router.register(...) y la ruta de print.
# ------------------------------------------------------------------

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
BACKEND="$ROOT/backend/apolo_web/urls.py"
FRONTEND_SERVICES="$ROOT/frontend/src/services"

mkdir -p "$FRONTEND_SERVICES"

echo "🔍 Analizando $BACKEND para extraer endpoints…"

# 1) Para cada router.register('prefix', …)
grep -Po "router\.register\(['\"]\K[^'\"/]+" "$BACKEND" | while read -r prefix; do
  svc="$FRONTEND_SERVICES/${prefix}.js"
  cat > "$svc" <<EOF
import api from './api';

// Servicio generado para /api/${prefix}/
export const fetch${prefix^} = () => api.get('${prefix}/');
export const create${prefix^} = data => api.post('${prefix}/', data);
export const update${prefix^} = (id, data) => api.put(\`${prefix}/\${id}/\`, data);
export const delete${prefix^} = id => api.delete(\`${prefix}/\${id}/\`);
EOF
  echo "✅ $svc generado."
done

# 2) Añadir print_label si existe en urls.py
if grep -q "etiquetas/print" "$BACKEND"; then
  svc="$FRONTEND_SERVICES/etiquetas.js"
  cat > "$svc" <<EOF
import api from './api';

// Servicio para /api/etiquetas/print/
export const printEtiqueta = payload => api.post('etiquetas/print/', payload);
EOF
  echo "✅ $svc generado para print_label."
fi

echo -e "\n🎉 ¡Listo! Ahora tienes servicios en frontend/src/services para todos tus endpoints."

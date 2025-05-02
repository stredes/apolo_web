#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------
# scripts/setup_frontend_full.sh
# ------------------------------------------------------------------
# Automatiza:
#  • Creación de barrel de servicios
#  • Generación de ClientesList y MainAppList
#  • Mensajes finales para arrancar el frontend
# ------------------------------------------------------------------

# 1️⃣ Ajusta si tu carpeta de frontend es distinta
FRONTEND_DIR="frontend"
SRC="$FRONTEND_DIR/src"

# 2️⃣ Directorios necesarios
mkdir -p "$SRC/services" "$SRC/components"

# 3️⃣ Barrel de servicios
cat > "$SRC/services/index.js" << 'EOF'
export * from './api';
export * from './clientes';
export * from './main_app';
export * from './etiquetas';
EOF
echo "✅ Barrel de servicios generado en src/services/index.js"

# 4️⃣ Componente: lista de Clientes
cat > "$SRC/components/ClientesList.jsx" << 'EOF'
import React, { useEffect, useState } from 'react';
import { fetchClientes, deleteCliente } from '../services/clientes';

export default function ClientesList() {
  const [clientes, setClientes] = useState([]);

  useEffect(() => {
    fetchClientes().then(res => setClientes(res.data));
  }, []);

  const onDelete = id => {
    deleteCliente(id).then(() =>
      setClientes(cs => cs.filter(c => c.id !== id))
    );
  };

  return (
    <div>
      <h2>Listado de Clientes</h2>
      <ul>
        {clientes.map(c => (
          <li key={c.id}>
            {c.nombre}{' '}
            <button onClick={() => onDelete(c.id)}>Eliminar</button>
          </li>
        ))}
      </ul>
    </div>
  );
}
EOF
echo "✅ Componente ClientesList.jsx creado en src/components"

# 5️⃣ Componente: lista de MainApp (si existe endpoint)
cat > "$SRC/components/MainAppList.jsx" << 'EOF'
import React, { useEffect, useState } from 'react';
import { fetchMainApp } from '../services/main_app';

export default function MainAppList() {
  const [items, setItems] = useState([]);

  useEffect(() => {
    fetchMainApp().then(res => setItems(res.data));
  }, []);

  return (
    <div>
      <h2>Listado de MainApp</h2>
      <ul>
        {items.map(i => (
          <li key={i.id}>{i.nombre || JSON.stringify(i)}</li>
        ))}
      </ul>
    </div>
  );
}
EOF
echo "✅ Componente MainAppList.jsx creado en src/components"

# 6️⃣ (Opcional) Inyección en App.jsx
if [[ -f "$SRC/App.jsx" ]]; then
  grep -q "ClientesList" "$SRC/App.jsx" || sed -i "/import React/a import { BrowserRouter, Routes, Route } from 'react-router-dom';\nimport ClientesList from './components/ClientesList';\nimport MainAppList from './components/MainAppList';" "$SRC/App.jsx"
  grep -q "<BrowserRouter" "$SRC/App.jsx" || sed -i "s|<div>|<BrowserRouter>\n  <Routes>\n    <Route path=\"/clientes\" element={<ClientesList />} />\n    <Route path=\"/main_app\" element={<MainAppList />} />\n  </Routes>\n</BrowserRouter>\n<div>|" "$SRC/App.jsx"
  echo "✅ App.jsx actualizado con rutas para Clientes y MainApp"
fi

# 7️⃣ Mensaje final
cat << EOF

🎉 ¡Frontend scaffold completo!

Para arrancar:
  cd $FRONTEND_DIR
  npm install
  npm run dev

Tus nuevos componentes estarán disponibles en:
  • /clientes   → ClientesList
  • /main_app   → MainAppList

EOF

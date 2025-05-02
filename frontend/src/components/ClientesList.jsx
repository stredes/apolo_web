import React, { useEffect, useState } from 'react';
import { fetchClientes, deleteCliente } from '../services/clientes';
import { Link } from 'react-router-dom';

export default function ClientesList() {
  const [clientes, setClientes] = useState([]);

  useEffect(() => {
    fetchClientes().then(res => setClientes(res.data));
  }, []);

  return (
    <div>
      <h1>Listado de Clientes</h1>
      <Link to="/nuevo-cliente">+ Nuevo Cliente</Link>
      <ul>
        {clientes.map(c => (
          <li key={c.id}>
            {c.nombre} – {c.email}
            <button onClick={() => {
              deleteCliente(c.id).then(() =>
                setClientes(clientes.filter(x => x.id !== c.id))
              );
            }}>
              Eliminar
            </button>
          </li>
        ))}
      </ul>
    </div>
  );
}

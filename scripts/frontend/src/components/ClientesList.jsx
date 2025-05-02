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

import React, { useEffect, useState } from 'react';
import axios from 'axios';

export default function Dashboard() {
  const [clientes, setClientes] = useState([]);

  useEffect(() => {
    axios.get(import.meta.env.VITE_API_BASE_URL + '/clientes/')
      .then(res => setClientes(res.data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div>
      <h1>Dashboard</h1>
      <ul>
        {clientes.map(c => (
          <li key={c.id}>{c.nombre} - {c.ruc}</li>
        ))}
      </ul>
    </div>
  );
}

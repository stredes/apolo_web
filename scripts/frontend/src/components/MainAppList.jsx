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

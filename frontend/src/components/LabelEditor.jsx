import React, { useState } from 'react';
import axios from 'axios';

export default function LabelEditor() {
  const [ip, setIp] = useState('');
  const [zpl, setZpl] = useState('');
  const [status, setStatus] = useState(null);

  const print = () => {
    axios.post(import.meta.env.VITE_API_BASE_URL + '/etiquetas/print/', { ip, zpl })
      .then(res => setStatus(res.data.status))
      .catch(err => setStatus('Error'));  
  };

  return (
    <div>
      <h1>Editor de Etiquetas</h1>
      <input placeholder="IP impresora" value={ip} onChange={e => setIp(e.target.value)} />
      <textarea placeholder="Código ZPL" value={zpl} onChange={e => setZpl(e.target.value)} />
      <button onClick={print}>Imprimir</button>
      {status && <p>Status: {status}</p>}
    </div>
  );
}

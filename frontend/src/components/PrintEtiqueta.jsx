import React, { useState } from 'react';
import { printEtiqueta } from '../services/etiquetas';

export default function PrintEtiqueta() {
  const [data, setData] = useState({ ip: '', port: 9100, zpl: '' });
  const [status, setStatus] = useState('');

  const submit = e => {
    e.preventDefault();
    printEtiqueta(data).then(() => setStatus('¡Impresión enviada!'));
  };

  return (
    <div>
      <h1>Imprimir Etiqueta</h1>
      <form onSubmit={submit}>
        <input
          placeholder="IP de la impresora"
          value={data.ip}
          onChange={e => setData({ ...data, ip: e.target.value })}
        />
        <input
          type="number"
          placeholder="Puerto"
          value={data.port}
          onChange={e => setData({ ...data, port: +e.target.value })}
        />
        <textarea
          placeholder="Código ZPL"
          value={data.zpl}
          onChange={e => setData({ ...data, zpl: e.target.value })}
        />
        <button type="submit">Enviar a imprimir</button>
      </form>
      {status && <p>{status}</p>}
    </div>
  );
}

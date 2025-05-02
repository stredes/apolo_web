import React, { useState } from 'react';
import { createCliente } from '../services/clientes';
import { useNavigate } from 'react-router-dom';

export default function ClienteForm() {
  const [form, setForm] = useState({ nombre: '', email: '' });
  const nav = useNavigate();

  const submit = e => {
    e.preventDefault();
    createCliente(form).then(() => nav('/'));
  };

  return (
    <form onSubmit={submit}>
      <h1>Nuevo Cliente</h1>
      <input
        placeholder="Nombre"
        value={form.nombre}
        onChange={e => setForm({ ...form, nombre: e.target.value })}
      />
      <input
        placeholder="Email"
        value={form.email}
        onChange={e => setForm({ ...form, email: e.target.value })}
      />
      <button type="submit">Crear</button>
    </form>
  );
}

import React from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import ClientesList from './components/ClientesList';
import ClienteForm from './components/ClienteForm';
import PrintEtiqueta from './components/PrintEtiqueta';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<ClientesList />} />
        <Route path="/nuevo-cliente" element={<ClienteForm />} />
        <Route path="/imprimir-etiqueta" element={<PrintEtiqueta />} />
      </Routes>
    </BrowserRouter>
  );
}

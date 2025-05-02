import api from './api';

// Servicio generado para /api/clientes/
export const fetchClientes = () => api.get('clientes/');
export const createClientes = data => api.post('clientes/', data);
export const updateClientes = (id, data) => api.put(`clientes/${id}/`, data);
export const deleteClientes = id => api.delete(`clientes/${id}/`);

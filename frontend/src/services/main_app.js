import api from './api';

// Servicio generado para /api/main_app/
export const fetchMain_app = () => api.get('main_app/');
export const createMain_app = data => api.post('main_app/', data);
export const updateMain_app = (id, data) => api.put(`main_app/${id}/`, data);
export const deleteMain_app = id => api.delete(`main_app/${id}/`);

import api from './api';

export const printEtiqueta = payload => api.post('etiquetas/print/', payload);

import React, { useEffect, useState } from 'react';
import axios from 'axios';

export default function StockReports() {
  const [reports, setReports] = useState([]);

  useEffect(() => {
    // Endpoint hipotético: /api/stock/
    axios.get(import.meta.env.VITE_API_BASE_URL + '/stock/')
      .then(res => setReports(res.data))
      .catch(err => console.error(err));
  }, []);

  return (
    <div>
      <h1>Informes de Stock</h1>
      <pre>{JSON.stringify(reports, null, 2)}</pre>
    </div>
  );
}

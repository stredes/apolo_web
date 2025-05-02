import React, { useEffect, useState } from 'react';
import axios from 'axios';

export default function _Init_() {
  const [data, setData] = useState([]);
  useEffect(() => {
    axios.get(process.env.VITE_API_BASE_URL + '/__init__/')
      .then(r => setData(r.data))
      .catch(console.error);
  }, []);
  return (
    <div>
      <h1>_Init_</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}

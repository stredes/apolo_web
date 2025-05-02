import React, { useEffect, useState } from 'react';
import axios from 'axios';

export default function MainApp() {
  const [data, setData] = useState([]);
  useEffect(() => {
    axios.get(process.env.VITE_API_BASE_URL + '/main_app/')
      .then(r => setData(r.data))
      .catch(console.error);
  }, []);
  return (
    <div>
      <h1>MainApp</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}

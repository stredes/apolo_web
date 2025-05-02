import React from 'react';
import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import _Init_ from './components/_Init_';
import MainApp from './components/MainApp';

export default function App() {
  return (
    <BrowserRouter>
      <nav>
        <Link to='/__init__'>_Init_</Link> |
        <Link to='/main_app'>MainApp</Link> |
      </nav>
      <Routes>
        <Route path='/__init__' element={<_Init_/>}/>
        <Route path='/main_app' element={<MainApp/>}/>
      </Routes>
    </BrowserRouter>
  );
}

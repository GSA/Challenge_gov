import React from 'react';
import './App.css';
import { LandingPage } from './pages/LandingPage'
import { HelmetProvider } from 'react-helmet-async';



function App() {
  return (
    <div className="App">
      <header className="App-header">
      </header>
      <HelmetProvider>
      <LandingPage />
      </HelmetProvider>
    </div>
  );
}

export default App;

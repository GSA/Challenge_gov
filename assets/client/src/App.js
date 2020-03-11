import React from 'react';
import './App.css';
import { LandingPage } from './pages/LandingPage'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={"/images/challenge-logo.png"} className="App-logo" alt="logo" />
      </header>
      <LandingPage />
    </div>
  );
}

export default App;

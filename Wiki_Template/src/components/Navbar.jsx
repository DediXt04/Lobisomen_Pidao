import React from 'react'
import { Link, NavLink } from 'react-router-dom'

function Navbar() {
  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
      <div className="container">
        <Link className="navbar-brand" to="/">Wiki-Game</Link>
        <button className="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav" aria-controls="nav" aria-expanded="false" aria-label="Toggle navigation">
          <span className="navbar-toggler-icon" />
        </button>
        <div className="collapse navbar-collapse" id="nav">
          <ul className="navbar-nav ms-auto">
            <li className="nav-item"><NavLink className="nav-link" to="/">Home</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/sobre">Sobre</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/equipe">Equipe</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/devlog">Devlog</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/docs">Docs</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/galeria">Galeria</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/teste">Teste</NavLink></li>
          </ul>
        </div>
      </div>
    </nav>
  )
}

export default Navbar

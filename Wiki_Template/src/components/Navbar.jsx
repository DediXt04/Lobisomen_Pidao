import React, { useState } from 'react'
import { Link, NavLink } from 'react-router-dom'

function Navbar() {
  const [isOpen, setIsOpen] = useState(false)

  const toggleNavbar = () => setIsOpen(!isOpen)
  const closeNavbar = () => setIsOpen(false)

  return (
    <nav className="navbar navbar-expand-lg navbar-dark bg-dark">
      <div className="container">
        <Link className="navbar-brand d-flex align-items-center gap-2" to="/" onClick={closeNavbar}>
          <img 
            src={"/Lobo_Face.png"} 
            alt="Logo" 
            style={{ width: "28px", height: "28px", objectFit: "contain" }}
          />
          Wiki-Game
        </Link>
        <button 
          className="navbar-toggler" 
          type="button" 
          onClick={toggleNavbar}
          aria-controls="nav" 
          aria-expanded={isOpen} 
          aria-label="Toggle navigation"
        >
          <span className="navbar-toggler-icon" />
        </button>
        <div className={`collapse navbar-collapse ${isOpen ? 'show' : ''}`} id="nav">
          <ul className="navbar-nav ms-auto">
            <li className="nav-item"><NavLink className="nav-link" to="/" onClick={closeNavbar}>Home</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/sobre" onClick={closeNavbar}>Sobre</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/download" onClick={closeNavbar}>Download</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/equipe" onClick={closeNavbar}>Equipe</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/galeria" onClick={closeNavbar}>Galeria</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/docs" onClick={closeNavbar}>Docs</NavLink></li>
            <li className="nav-item"><NavLink className="nav-link" to="/devlog" onClick={closeNavbar}>Devlog</NavLink></li>
          </ul>
        </div>
      </div>
    </nav>
  )
}

export default Navbar

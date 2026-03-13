import React from "react";
import { Link } from "react-router-dom";

function Footer() {
  return (
    <footer className="bg-dark text-white text-center py-4 mt-5">
      <div className="container">
        <nav className="d-flex flex-wrap justify-content-center justify-content-center gap-3">
          <Link to="/" className="mx-2 text-decoration-none text-white">
            Início
          </Link>
          <Link to="/sobre" className="mx-2 text-decoration-none text-white">
            Sobre
          </Link>
          <Link to="/download" className="mx-2 text-decoration-none text-white">
            Download
          </Link>
          <Link to="/equipe" className="mx-2 text-decoration-none text-white">
            Equipe
          </Link>
          <Link to="/devlog" className="mx-2 text-decoration-none text-white">
            Devlog
          </Link>
          <Link to="/docs" className="mx-2 text-decoration-none text-white">
            Documentação
          </Link>
          <Link to="/galeria" className="mx-2 text-decoration-none text-white">
            Galeria
          </Link>
        </nav>

        <div className="text-center mt-3">
          <small>
            © {new Date().getFullYear()} Lobisomem Pidão • Projeto da faculdade
          </small>
        </div>
      </div>
    </footer>
  );
}

export default Footer;

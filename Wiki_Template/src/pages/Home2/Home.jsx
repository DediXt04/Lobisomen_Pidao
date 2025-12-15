import React from "react";
import { Link } from "react-router-dom";
import "./Home.css";

const Home = () => {
  return (
    <header className="container-xl header p-4 my-2 rounded-3 text-white justify-content-between">
      <div>
        <h1 className="display-5 fw-bold">Lobisomem Pidão</h1>
        <p className="subtitle lead mb-4 col-md-5">
          Stealth e humor em top-down – aproxime-se, peça comida e fuja antes
          que te peguem.
        </p>
        <div className="d-flex flex-wrap gap-2 mb-4">
          <span className="badge bg-dark bg-opacity-50 px-3 py-2">
            🎯 Stealth
          </span>
          <span className="badge bg-dark bg-opacity-50 px-3 py-2">
            😂 Humor
          </span>
          <span className="badge bg-dark bg-opacity-50 px-3 py-2">
            🔝 Top-Down
          </span>
          <span className="badge bg-dark bg-opacity-50 px-3 py-2">
            🐺 Lobisomem
          </span>
        </div>
      </div>

      <div>
        <div className="d-flex flex-wrap gap-3 mb-4">
          <Link to="/sobre" className="btn btn-primary btn-lg px-4">
            Sobre o Jogo
          </Link>
          <Link to="/equipe" className="btn btn-primary btn-lg px-4">
            Equipe
          </Link>
        </div>
      </div>
    </header>
  );
};

export default Home;

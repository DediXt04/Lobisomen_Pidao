import React from "react";
import { Link } from "react-router-dom";
import "./Home.css";

const Home = () => {
  return (
    <div>
      <header
        className="container-xl header text-white rounded-3 my-2 
                   d-flex flex-column justify-content-between
                   p-4 p-md-5"
      >
        <div className="text-center text-md-start">
          <h1 className="fw-bold display-6 display-md-5">Lobisomem Pidão</h1>

          <p className="subtitle lead mb-4 col-12 col-sm-10 col-md-6 mx-auto mx-md-0">
            Stealth e humor em top-down – aproxime-se, peça comida e fuja antes
            que te peguem.
          </p>

          <div className="d-flex flex-wrap justify-content-center justify-content-md-start gap-2 mb-4">
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

        <div className="d-flex flex-column flex-md-row gap-3 justify-content-center justify-content-md-start">
          <Link to="/sobre" className="btn btn-info btn-lg px-4 text-white">
            Sobre o Jogo
          </Link>
          <Link to="/equipe" className="btn btn-info btn-lg px-4 text-white">
            Equipe
          </Link>
        </div>
      </header>

      <div className="container my-5">
        <h2 className="text-center mb-4">Explore o Jogo</h2>
        <p className="text-center text-muted">
          Descubra tudo sobre o Lobisomem Pidão
        </p>

        <div className="row">
          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">História</h5>
                <p className="card-text">
                  Conheça o Lobisomem Pidão e descubra por que ele está sempre
                  com fome nesta jornada divertida e cheia de surpresas.
                </p>
                <Link to="/devlog" className="btn btn-primary mt-auto">
                  Saiba mais
                </Link>
              </div>
            </div>
          </div>

          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">Mecânicas</h5>
                <p className="card-text">
                  Stealth em visão top-down, timing preciso de interação e IA
                  inteligente de guardas para desafiar suas habilidades.
                </p>
                <Link to="/docs" className="btn btn-success mt-auto">
                  Explorar
                </Link>
              </div>
            </div>
          </div>

          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">Galeria</h5>
                <p className="card-text">
                  Veja imagens incríveis, concept art exclusivo e o processo
                  criativo por trás do desenvolvimento do jogo.
                </p>
                <Link to="/galeria" className="btn btn-warning mt-auto">
                  Ver galeria
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;

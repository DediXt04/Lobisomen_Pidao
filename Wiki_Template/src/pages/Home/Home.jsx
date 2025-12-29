import React from "react";
import { Link } from "react-router-dom";
import "./Home.css";

const Home = () => {
  return (
    <div>
      <header className="container-xl header p-4 my-2 rounded-3 text-white justify-content-between d-flex flex-column ">
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
            <Link to="/sobre" className="btn btn-info btn-lg px-4 text-white">
              Sobre o Jogo
            </Link>
            <Link to="/equipe" className="btn btn-info btn-lg px-4 text-white">
              Equipe
            </Link>
          </div>
        </div>
      </header>

      <div class="container my-5">
        <h2 class="text-center mb-4">Explore o Jogo</h2>
        <p class="text-center text-muted">
          Descubra tudo sobre o Lobisomem Pidão
        </p>

        <div class="row">
          <div class="col-md-4 mb-4">
            <div class="card h-100 shadow-sm">
              <div class="card-body d-flex flex-column">
                <h5 class="card-title">História</h5>
                <p class="card-text">
                  Conheça o Lobisomem Pidão e descubra por que ele está sempre
                  com fome nesta jornada divertida e cheia de surpresas.
                </p>
                <a href="#" class="btn btn-primary mt-auto">
                  Saiba mais
                </a>
              </div>
            </div>
          </div>

          <div class="col-md-4 mb-4">
            <div class="card h-100 shadow-sm">
              <div class="card-body d-flex flex-column">
                <h5 class="card-title">Mecânicas</h5>
                <p class="card-text">
                  Stealth em visão top-down, timing preciso de interação e IA
                  inteligente de guardas para desafiar suas habilidades.
                </p>
                <a href="#" class="btn btn-success mt-auto">
                  Explorar
                </a>
              </div>
            </div>
          </div>

          <div class="col-md-4 mb-4">
            <div class="card h-100 shadow-sm">
              <div class="card-body d-flex flex-column">
                <h5 class="card-title">Galeria</h5>
                <p class="card-text">
                  Veja imagens incríveis, concept art exclusivo e o processo
                  criativo por trás do desenvolvimento do jogo.
                </p>
                <a href="#" class="btn btn-warning mt-auto">
                  Ver galeria
                </a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;

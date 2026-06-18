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
          <Link to="/download" className="btn btn-success btn-lg px-4 text-white fw-bold">
            🎮 Jogue Agora
          </Link>
          <Link to="/sobre" className="btn btn-outline-light btn-lg px-4">
            Sobre o Jogo
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
                <h5 className="card-title">📖 Devlog</h5>
                <p className="card-text">
                  Acompanhe o progresso do desenvolvimento sprint a sprint e veja como o jogo evoluiu.
                </p>
                <Link to="/devlog" className="btn btn-primary mt-auto">
                  Ver sprints
                </Link>
              </div>
            </div>
          </div>

          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">📄 Documentação</h5>
                <p className="card-text">
                  Tecnologias, arquitetura e detalhes técnicos por trás do projeto.
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
                <h5 className="card-title">🖼️ Galeria</h5>
                <p className="card-text">
                  Concept art, sprites e imagens do processo criativo do jogo.
                </p>
                <Link to="/galeria" className="btn btn-warning mt-auto">
                  Ver galeria
                </Link>
              </div>
            </div>
          </div>

          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">👥 Equipe</h5>
                <p className="card-text">
                  Conheça os desenvolvedores e artistas por trás do Lobisomem Pidão.
                </p>
                <Link to="/equipe" className="btn btn-info mt-auto text-white">
                  Conhecer
                </Link>
              </div>
            </div>
          </div>

          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">⬇️ Download</h5>
                <p className="card-text">
                  Baixe o executável e jogue agora mesmo no seu computador.
                </p>
                <Link to="/download" className="btn btn-danger mt-auto text-white">
                  Baixar
                </Link>
              </div>
            </div>
          </div>

          <div className="col-md-4 mb-4">
            <div className="card home-card h-100 shadow-sm">
              <div className="card-body d-flex flex-column">
                <h5 className="card-title">🐺 Sobre</h5>
                <p className="card-text">
                  Mecânicas de stealth, fome, NPCs e tudo que torna o jogo único.
                </p>
                <Link to="/sobre" className="btn btn-secondary mt-auto">
                  Saiba mais
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

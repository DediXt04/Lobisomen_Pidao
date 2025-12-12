// Home.jsx
import React from "react";
import { Link } from "react-router-dom";
import "./Home.css";

export default function Home() {
  return (
    <main>
      <div className="hero" role="banner" aria-label="Lobisomem Pidão apresentação">
        <div className="hero-bg" aria-hidden="true" />
        <div className="hero-overlay" />
        
        <div className="container hero-inner">
          <div className="row align-items-center g-4">
            <div className="col-lg-8">
              <div className="hero-text">
                <h1 className="title display-1 fw-bold mb-3">
                  Lobisomem Pidão
                </h1>
                <p className="subtitle lead mb-4">
                  Stealth e humor em top-down – aproxime-se, peça comida e fuja antes que te peguem.
                </p>
                
                <div className="d-flex flex-wrap gap-3 mb-4">
                  <Link to="/sobre" className="btn btn-primary btn-lg px-4 shadow-lg">
                    Sobre o Jogo
                  </Link>
                  <Link to="/equipe" className="btn btn-outline-light btn-lg px-4">
                    Equipe
                  </Link>
                </div>

                <div className="d-flex flex-wrap gap-2">
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
            </div>
            </div>
        </div>

        <div className="hero-decor" aria-hidden="true">
          <div className="paw" />
        </div>
      </div>

      <section className="py-5">
        <div className="container">
          <div className="text-center mb-5">
            <h2 className="display-5 fw-bold mb-3">Explore o Jogo</h2>
            <p className="lead text-muted">Descubra tudo sobre o Lobisomem Pidão</p>
          </div>

          <div className="row g-4">
            {/* Card História */}
            <div className="col-md-6 col-lg-4">
              <div className="card h-100 border-0 shadow-sm hover-lift">
                <div className="card-body p-4">
                  <div className="d-flex align-items-center mb-3">
                    <h3 className="h4 mb-0 text-primary">História</h3>
                  </div>
                  <p className="text-muted mb-3">
                    Conheça o Lobisomem Pidão e descubra por que ele está sempre com fome nesta jornada divertida e cheia de surpresas.
                  </p>
                  <Link to="/sobre" className="btn btn-outline-primary">
                    Saiba mais
                  </Link>
                </div>
              </div>
            </div>

            {/* Card Mecânicas */}
            <div className="col-md-6 col-lg-4">
              <div className="card h-100 border-0 shadow-sm hover-lift">
                <div className="card-body p-4">
                  <div className="d-flex align-items-center mb-3">
                    <h3 className="h4 mb-0 text-primary">Mecânicas</h3>
                  </div>
                  <p className="text-muted mb-3">
                    Stealth em visão top-down, timing preciso de interação e IA inteligente de guardas para desafiar suas habilidades.
                  </p>
                  <Link to="/sobre" className="btn btn-outline-primary">
                    Explorar
                  </Link>
                </div>
              </div>
            </div>

            {/* Card Galeria */}
            <div className="col-md-6 col-lg-4">
              <div className="card h-100 border-0 shadow-sm hover-lift">
                <div className="card-body p-4">
                  <div className="d-flex align-items-center mb-3">
                    <h3 className="h4 mb-0 text-primary">Galeria</h3>
                  </div>
                  <p className="text-muted mb-3">
                    Veja imagens incríveis, concept art exclusivo e o processo criativo por trás do desenvolvimento do jogo.
                  </p>
                  <Link to="/galeria" className="btn btn-outline-primary">
                    Ver galeria
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-5 bg-dark text-white">
        <div className="container text-center">
          <h2 className="display-6 fw-bold mb-3">Acompanhe o Desenvolvimento</h2>
          <p className="lead mb-4">Fique por dentro de todas as novidades e atualizações</p>
          <Link to="/devlog" className="btn btn-primary btn-lg px-5">
            Acessar Devlog
          </Link>
        </div>
      </section>
    </main>
  );
}
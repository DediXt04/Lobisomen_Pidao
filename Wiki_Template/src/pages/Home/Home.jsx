// Home.jsx
import React from "react";
import { Link } from "react-router-dom";
import "./Home.css";

export default function Home() {
  return (
    <main>
      <header className="hero" role="banner" aria-label="Lobisomem Pidão apresentação">
        <div className="hero-bg" aria-hidden="true" />
        <div className="hero-overlay" />
        <div className="hero-inner container">
          <div className="hero-text">
            <h1 className="title">Lobisomem Pidão</h1>
            <p className="subtitle">
              Stealth e humor em top-down — aproxime-se, peça comida e fuja antes que te peguem.
            </p>

            <div className="cta-row" role="navigation" aria-label="Ações principais">
              <Link to="/sobre" className="btn btn-primary btn-lg">Sobre</Link>
              <Link to="/equipe" className="btn btn-outline btn-lg">Equipe</Link>
              <Link to="/devlog" className="btn btn-ghost btn-lg">Devlog</Link>
            </div>

            <div className="meta-row" aria-hidden="false">
              <span className="pill">Alpha</span>
              <span className="pill">Stealth</span>
              <span className="pill">Humor</span>
            </div>
          </div>

          <aside className="hero-card" aria-label="Resumo rápido">
            <h4>Como jogar</h4>
            <ul>
              <li>Aproxime-se sem assustar NPCs</li>
              <li>Peça comida no momento certo</li>
              <li>Escape antes que guardas e caçadores cheguem</li>
            </ul>
            <div className="small-cta">
              <Link to="/docs" className="link">Guia rápido</Link>
            </div>
          </aside>
        </div>

        <div className="hero-decor" aria-hidden="true">
          <div className="paw" />
        </div>
      </header>

      <section className="container features">
        <div className="row">
          <article className="col-md-4 feature">
            <h3>História</h3>
            <p>Conheça o Lobisomem Pidão e por que ele está sempre com fome.</p>
          </article>
          <article className="col-md-4 feature">
            <h3>Mecânicas</h3>
            <p>Stealth top-down, timing de interação e IA de guardas.</p>
          </article>
          <article className="col-md-4 feature">
            <h3>Galeria</h3>
            <p>Veja imagens e concept art do jogo.</p>
            <Link to="/galeria" className="link">Abrir galeria</Link>
          </article>
        </div>
      </section>
    </main>
  );
}

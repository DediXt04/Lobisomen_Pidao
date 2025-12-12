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
        <div className="hero-inner container">
          <div className="hero-text">
            <div className="hero-text-top">
              <h1 className="title">Lobisomem Pidão</h1>
              <p className="subtitle">
                Stealth e humor em top-down — aproxime-se, peça comida e fuja antes que te peguem.
              </p>
            </div>

            <div className="hero-text-bottom">
              <div className="cta-row" role="navigation" aria-label="Ações principais">
                <Link to="/sobre" className="btn btn-primary btn-lg">Sobre</Link>
                <Link to="/equipe" className="btn btn-ghost btn-lg">Equipe</Link>
                <Link to="/devlog" className="btn btn-ghost btn-lg">Devlog</Link>
              </div>
            </div>
          </div>
        </div>

        <div className="hero-decor" aria-hidden="true">
          <div className="paw" />
        </div>
      </div>

      <section className="container features">
        <div className="row">
          <article className="feature">
            <h3>História</h3>
            <p>Conheça o Lobisomem Pidão e por que ele está sempre com fome.</p>
          </article>
          <article className="feature">
            <h3>Mecânicas</h3>
            <p>Stealth top-down, timing de interação e IA de guardas.</p>
          </article>
          <article className="feature">
            <h3>Galeria</h3>
            <p>Veja imagens e concept art do jogo.</p>
            <Link to="/galeria" className="link">Abrir galeria →</Link>
          </article>
        </div>
      </section>
    </main>
  );
}
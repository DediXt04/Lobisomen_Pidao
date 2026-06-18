import React, { useState } from "react";

const imageModules = import.meta.glob(
  "../assets/gallery/*.{png,jpg,jpeg,gif,webp,svg}",
  { eager: true }
);
const imgs = Object.entries(imageModules).map(([path, mod]) => ({
  src: mod.default,
  name: path
    .split("/")
    .pop()
    .replace(/\.[^.]+$/, "")
    .replaceAll("_", " "),
}));

export default function Galeria() {
  const [selecionada, setSelecionada] = useState(null)

  return (
    <div className="container py-4">
      <h2 className="mb-2">🖼️ Galeria</h2>
      <p className="text-muted mb-2">
        Concept art, sprites e imagens do desenvolvimento do jogo.
      </p>
      <span className="badge bg-secondary mb-4">{imgs.length} imagens</span>

      <div className="row g-4">
        {imgs.map((img, i) => (
          <div key={i} className="col-sm-6 col-md-4">
            <div 
              className="card shadow-sm border-0 overflow-hidden h-100" 
              style={{ cursor: 'pointer', transition: 'transform 0.2s, box-shadow 0.2s' }}
              onClick={() => setSelecionada(img)}
              onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-4px)'; e.currentTarget.style.boxShadow = '0 8px 25px rgba(0,0,0,0.15)' }}
              onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '' }}
            >
              <img src={img.src} alt={img.name} className="gallery-img" />
              <div className="card-body py-2 px-3">
                <small className="text-muted text-capitalize">{img.name}</small>
              </div>
            </div>
          </div>
        ))}
      </div>

      {selecionada && (
        <div 
          className="position-fixed top-0 start-0 w-100 h-100 d-flex align-items-center justify-content-center"
          style={{ backgroundColor: 'rgba(0,0,0,0.85)', zIndex: 9999, cursor: 'pointer' }}
          onClick={() => setSelecionada(null)}
        >
          <div className="text-center" style={{ maxWidth: '90vw', maxHeight: '90vh' }}>
            <img 
              src={selecionada.src} 
              alt={selecionada.name} 
              style={{ maxWidth: '100%', maxHeight: '80vh', objectFit: 'contain', borderRadius: '8px' }}
            />
            <p className="text-white mt-3 text-capitalize">{selecionada.name}</p>
            <small className="text-white-50">Clique em qualquer lugar para fechar</small>
          </div>
        </div>
      )}
    </div>
  );
}

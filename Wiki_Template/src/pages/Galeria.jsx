import React from 'react'

export default function Galeria() {
  // Coloque imagens em src/assets/images e referencie aqui
  const imgs = [
    '/src/assets/images/background_03.png',
    '/src/assets/images/Rony01.png',
    '/src/assets/images/pizza.png',
    '/src/assets/images/dancing-banana.gif'
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-2">Galeria</h2>
      <p className="text-muted mb-4">Concept art, sprites e imagens do desenvolvimento do jogo.</p>

      <div className="row g-4">
        {imgs.map((src, i) => (
          <div key={i} className="col-sm-6 col-md-4">
            <div className="card shadow-sm border-0 overflow-hidden">
              <img src={src} alt={`img-${i}`} className="gallery-img" />
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

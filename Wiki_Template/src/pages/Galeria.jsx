import React from 'react'

export default function Galeria() {
  // Coloque imagens em src/assets/images e referencie aqui
  const imgs = [
    '/src/assets/images/background_03.png',
    '/src/assets/images/Rony01.png',
    '/src/assets/images/pizza.png',
  ]

  return (
    <div>
      <h2>Galeria</h2>
      <div className="row">
        {imgs.map((src, i) => (
          <div key={i} className="col-sm-6 col-md-4 mb-3">
            <img src={src} alt={`img-${i}`} className="img-fluid rounded gallery-img" />
          </div>
        ))}
      </div>
    </div>
  )
}

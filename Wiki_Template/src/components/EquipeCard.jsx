import React from 'react'

export default function EquipeCard({ nome, funcao, github }) {
  const gitUser = github.replace('https://github.com/', '')
  const gitPhoto = `https://github.com/${gitUser}.png`

  return (
    <div className="card shadow-sm text-center p-3">

      <img 
        src={gitPhoto}
        alt={nome}
        className="rounded-circle mx-auto mb-3"
        width="120"
        height="120"
      />

      <h5 className="card-title">{nome}</h5>
      <h6 className="card-subtitle mb-2 text-muted">{funcao}</h6>

      <a 
        href={github}
        target="_blank"
        rel="noopener noreferrer"
        className="btn btn-dark btn-sm mt-2"
      >
        GitHub
      </a>

    </div>
  )
}

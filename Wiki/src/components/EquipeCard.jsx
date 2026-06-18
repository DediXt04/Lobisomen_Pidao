import React from 'react'
import { FiGithub } from 'react-icons/fi'

export default function EquipeCard({ nome, funcao, github }) {
  const gitUser = github.replace('https://github.com/', '')
  const gitPhoto = `https://github.com/${gitUser}.png`

  return (
    <div className="card shadow-sm text-center border-0 h-100"
      style={{ transition: 'transform 0.2s, box-shadow 0.2s' }}
      onMouseEnter={e => { e.currentTarget.style.transform = 'translateY(-6px)'; e.currentTarget.style.boxShadow = '0 12px 24px rgba(0,0,0,0.12)' }}
      onMouseLeave={e => { e.currentTarget.style.transform = 'translateY(0)'; e.currentTarget.style.boxShadow = '' }}
    >
      <div className="card-body d-flex flex-column align-items-center p-4">
        <img 
          src={gitPhoto}
          alt={nome}
          className="rounded-circle mb-3 border border-3 border-primary"
          width="120"
          height="120"
          style={{ objectFit: 'cover' }}
        />

        <h5 className="card-title mb-1">{nome}</h5>
        <span className="badge bg-primary bg-opacity-10 text-primary mb-3">{funcao}</span>

        <a 
          href={github}
          target="_blank"
          rel="noopener noreferrer"
          className="btn btn-dark btn-sm d-flex align-items-center gap-2 mt-auto"
        >
          <FiGithub size={16} />
          @{gitUser}
        </a>
      </div>
    </div>
  )
}

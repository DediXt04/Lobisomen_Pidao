import React from 'react'
import EquipeCard from '../components/EquipeCard'

export default function Equipe() {
  const membros = [
    { 
      nome: 'André Queiroz',
      funcao: 'Desenvolvedor / Game Designer',
      github: 'https://github.com/DediXt04'
    },
    { 
      nome: 'Caetano José',
      funcao: 'Desenvolvedor / Game Designer',
      github: 'https://github.com/Cae003'
    },
    { 
      nome: 'Cesar Brossi',
      funcao: 'Game Designer / Pixel Artist',
      github: 'https://github.com/cesaaa-r'
    },
    { 
      nome: 'Eduardo Rabelo',
      funcao: 'Game Designer / Pixel Artist',
      github: 'https://github.com/Edu4rdoMarques'
    },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-2">Equipe</h2>
      <p className="text-muted mb-4">Conheça as pessoas por trás do Lobisomem Pidão.</p>

      <div className="row g-4 justify-content-center">
        {membros.map((m, i) => (
          <div key={i} className="col-sm-6 col-lg-3">
            <EquipeCard 
              nome={m.nome} 
              funcao={m.funcao} 
              github={m.github} 
            />
          </div>
        ))}
      </div>
    </div>
  )
}

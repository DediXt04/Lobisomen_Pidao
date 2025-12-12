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
      nome: 'Eduardo Rabelo',
      funcao: 'Desenvolvedor / Game Designer',
      github: 'https://github.com/Edu4rdoMarques'
    },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-4">Equipe</h2>

      <div className="row">
        {membros.map((m, i) => (
          <div key={i} className="col-md-4 mb-4">
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

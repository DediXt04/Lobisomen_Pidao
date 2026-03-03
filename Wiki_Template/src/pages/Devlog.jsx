import React from 'react'
import { FiCalendar } from 'react-icons/fi'

export default function Devlog() {
  const entradas = [
    {
        data: '27/02/2026',
        titulo: 'Sprint 01',
        texto: 'Início do desenvolvimento do projeto no GameMaker, implementação da movimentação do jogador, criação da HUD e desenvolvimento dos sprites da interface.'  
    },
    {
      data: '01/12/2025',
      titulo: 'Criação da Wiki',
      texto: 'Durante o mês de dezembro, foi realizada a criação e estruturação inicial da Wiki do projeto, com organização das informações e documentação dos principais processos.'
    },
    
  ]

  // Ordena por data decrescente
  const entradasOrdenadas = [...entradas].sort(
    (a, b) => new Date(b.data) - new Date(a.data)
  )

  return (
    <div className="container py-4">
      <h2 className="mb-2">Devlog</h2>
      <p className="text-muted mb-4">Acompanhe o progresso do desenvolvimento do jogo.</p>

      <div className="row g-4">
        {entradasOrdenadas.map((e, i) => (
          <div key={i} className="col-12">
            <div className="card shadow-sm border-start border-primary border-4">
              <div className="card-body">
                <div className="d-flex align-items-center mb-2">
                  <FiCalendar className="text-primary me-2" />
                  <small className="text-muted">{e.data}</small>
                </div>
                <h5 className="card-title mb-2">{e.titulo}</h5>
                <p className="card-text text-muted mb-0">{e.texto}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

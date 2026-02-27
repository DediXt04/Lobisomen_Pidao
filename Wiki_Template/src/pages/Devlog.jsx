import React from 'react'

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
      <h2 className="mb-4">Devlog</h2>
      {entradasOrdenadas.map((e, i) => (
        <div key={i} className="mb-4 border-bottom pb-3">
          <h5>
            {e.titulo} <small className="text-muted">— {e.data}</small>
          </h5>
          <p>{e.texto}</p>
        </div>
      ))}
    </div>
  )
}

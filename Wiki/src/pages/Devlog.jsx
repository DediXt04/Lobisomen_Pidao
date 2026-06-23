import React from 'react'
import { FiCalendar, FiHash } from 'react-icons/fi'

export default function Devlog() {
  const entradas = [
    {
        data: '27/02/2026',
        titulo: 'Sprint 01',
        texto: 'Início do desenvolvimento do projeto no GameMaker, incluindo a implementação da movimentação do jogador, a criação da HUD e o desenvolvimento dos sprites da interface.'  
    },
    {
      data: '01/12/2025',
      titulo: 'Criação da Wiki',
      texto: 'Durante o mês de dezembro, foi realizada a criação e a estruturação inicial da Wiki do projeto, com a organização das informações e a documentação dos principais processos.'
    },
    {
      data: '06/03/2026',
      titulo:'Sprint 02',
      texto:'Implementação da interação do player com objetos de comida e de dano, além da criação da tela de Game Over e dos sprites do lobisomem e dos NPCs.'
    },
    {
      data: '13/03/2026',
      titulo:'Sprint 03',
      texto:'Jogo adaptado para controle, com mecânica de lobisomem faminto que altera o sprite e aumenta a velocidade do personagem.'
    },
    {
      data: '20/03/2026',
      titulo: 'Sprint 04',
      texto: 'Criação da tela de vitória, implementação da condição de vitória após coletar os itens necessários, adição de mecânica de perseguição do player pelo inimigo.'
    },
    {
      data: '27/03/2026',
      titulo: 'Sprint 05',
      texto: 'Finalização dos sprites de NPC e do tileset, implementação de mecânicas básicas de NPC (movimentação e interação), melhorias no sistema de perseguição.'
    },
    {
      data: '17/04/2026',
      titulo: 'Sprint 06',
      texto: 'Implementação da tela de seleção de fases, melhorias nas telas de vitória e derrota, desenvolvimento das mecânicas do inimigo (campo de visão e movimentação) e aprimoramentos no NPC, incluindo feedback visual de interação e aplicação de sprites.'
    },
    {
      data: '24/04/2026',
      titulo: 'Sprint 07',
      texto: 'Melhorias na wiki do projeto, incluindo disponibilização do executável do jogo para download; polimento das mecânicas do inimigo (ajustes em comportamento e movimentação); aplicação da skin do guarda com integração visual ao jogo.'
    },
    {
    data: '08/05/2026',
    titulo: 'Sprint 08',
    texto: 'Implementação do sistema de spawn de comida, correção de bug que permitia interação através de paredes, refatoração da movimentação do NPC.'
    },
    {
    data: '15/05/2026',
    titulo: 'Sprint 09',
    texto: 'Aprimoramento do comportamento dos inimigos e ajustes na estrutura de herança do código, melhorias nas interfaces de menu (incluindo seleção de fases, tela de game over e vitória), evolução do sistema de spawn, que passou a suportar tanto a geração de comida quanto de NPCs.'
    },
    {
    data: '22/05/2026',
    titulo: 'Sprint 10',
    texto: 'Melhorias na documentação do projeto e aprimoramento visual das telas do jogo, com ajustes de layout e polimento de interfaces.'
    },
    {
    data: '29/05/2026',
    titulo: 'Sprint 11',
    texto: 'Criação de uma nova fase, padronização visual das telas do jogo, desenvolvimento do menu principal, melhorias nas telas existentes e resolução de bugs do inimigo relacionados a campo de visão e colisão.'
    },
    {
    data: '12/06/2026',
    titulo: 'Sprint 12',
    texto: 'Implementação da mecânica de desbloqueamento de fases e criação de novos sprites de comida. teste deploy'
    }
  ]

  const entradasOrdenadas = [...entradas].sort((a, b) => {
    const parseData = (d) => {
      const [dia, mes, ano] = d.split('/')
      return new Date(`${ano}-${mes}-${dia}`)
    }
    return parseData(b.data) - parseData(a.data)
  })

  return (
    <div className="container py-4">
      <h2 className="mb-2">📖 Devlog</h2>
      <p className="text-muted mb-2">Acompanhe o progresso do desenvolvimento do jogo.</p>
      <div className="d-flex align-items-center gap-2 mb-4">
        <span className="badge bg-primary">{entradas.length} entradas</span>
        <span className="badge bg-success">{entradas.filter(e => e.titulo.startsWith('Sprint')).length} sprints</span>
      </div>

      <div className="position-relative">
        <div 
          className="position-absolute top-0 start-0 h-100 d-none d-md-block" 
          style={{ width: '3px', backgroundColor: '#dee2e6', marginLeft: '14px' }}
        />

        {entradasOrdenadas.map((e, i) => {
          const isSprint = e.titulo.startsWith('Sprint')
          return (
            <div key={i} className="d-flex gap-3 mb-4">
              <div className="d-none d-md-flex flex-column align-items-center" style={{ minWidth: '30px' }}>
                <div 
                  className={`rounded-circle d-flex align-items-center justify-content-center ${isSprint ? 'bg-primary' : 'bg-secondary'}`}
                  style={{ width: '30px', height: '30px', zIndex: 1 }}
                >
                  {isSprint 
                    ? <FiHash size={14} className="text-white" /> 
                    : <FiCalendar size={14} className="text-white" />
                  }
                </div>
              </div>
              <div className="flex-grow-1">
                <div className={`card shadow-sm border-start border-4 ${i === 0 ? 'border-success' : 'border-primary'}`}>
                  <div className="card-body">
                    <div className="d-flex align-items-center justify-content-between mb-2">
                      <h5 className="card-title mb-0">
                        {e.titulo}
                        {i === 0 && <span className="badge bg-success ms-2 fs-6">Mais recente</span>}
                      </h5>
                      <small className="text-muted d-flex align-items-center gap-1">
                        <FiCalendar size={14} />
                        {e.data}
                      </small>
                    </div>
                    <p className="card-text text-muted mb-0">{e.texto}</p>
                  </div>
                </div>
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}

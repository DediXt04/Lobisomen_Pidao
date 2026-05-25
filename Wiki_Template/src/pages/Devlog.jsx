import React from 'react'
import { FiCalendar } from 'react-icons/fi'

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
    }
  ]

  // Ordena por data decrescente
  const entradasOrdenadas = [...entradas].sort((a, b) => {
    const parseData = (d) => {
      const [dia, mes, ano] = d.split('/')
      return new Date(`${ano}-${mes}-${dia}`)
    }
    return parseData(b.data) - parseData(a.data)
  })

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

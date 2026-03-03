import React from 'react'
import { FiCpu, FiCode, FiGitBranch, FiPenTool, FiBox, FiImage, FiFileText, FiLayout, FiType } from 'react-icons/fi'

export default function Docs() {
  const tecnologias = [
    { icone: <FiCpu size={24} />, nome: 'GameMaker', desc: 'Game engine com foco em 2D, GML como linguagem de script e suporte multiplataforma.' },
    { icone: <FiCode size={24} />, nome: 'React + Bootstrap', desc: 'Frontend rápido e responsivo para o site do projeto.' },
    { icone: <FiGitBranch size={24} />, nome: 'Git + GitHub', desc: 'Controle de versão para colaboração e histórico.' },
    { icone: <FiPenTool size={24} />, nome: 'Libresprite', desc: 'Ferramenta para criação de pixel art.' },
  ]

  const arquitetura = [
    { icone: <FiBox size={24} />, nome: 'Objetos', desc: 'Entidades do jogo (Player, parede, comida, NPC, inimigos...), cada uma com seus próprios eventos e lógica.' },
    { icone: <FiImage size={24} />, nome: 'Sprites', desc: 'Assets visuais — personagens, tiles, itens e efeitos, organizados em pastas no GameMaker.' },
    { icone: <FiFileText size={24} />, nome: 'Scripts', desc: 'Funções GML reutilizáveis, como lógica de HUD, draw de vida, fome e sistemas compartilhados.' },
    { icone: <FiLayout size={24} />, nome: 'Rooms', desc: 'Salas do jogo (menu, gameplay, game over) com câmera, instâncias e transições configuradas.' },
    { icone: <FiType size={24} />, nome: 'Fonts', desc: 'Fontes pixel art utilizadas na HUD, menus e textos para manter a identidade visual.' },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-2">Documentação Técnica</h2>
      <p className="text-muted mb-4">Visão geral das tecnologias e arquitetura do projeto.</p>

      <h4 className="mb-3">Tecnologias</h4>
      <div className="row g-3 mb-5">
        {tecnologias.map((t, i) => (
          <div key={i} className="col-md-6">
            <div className="card h-100 shadow-sm border-0">
              <div className="card-body d-flex align-items-start gap-3">
                <div className="text-primary mt-1">{t.icone}</div>
                <div>
                  <h6 className="mb-1">{t.nome}</h6>
                  <p className="text-muted small mb-0">{t.desc}</p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      <h4 className="mb-3">Arquitetura</h4>
      <p className="text-muted mb-3">
        O jogo é organizado em módulos independentes para facilitar manutenção e expansão:
      </p>
      <div className="row g-3">
        {arquitetura.map((a, i) => (
          <div key={i} className="col-md-6 col-lg-4">
            <div className="card h-100 shadow-sm border-0">
              <div className="card-body d-flex align-items-start gap-3">
                <div className="text-success mt-1">{a.icone}</div>
                <div>
                  <h6 className="mb-1">{a.nome}</h6>
                  <p className="text-muted small mb-0">{a.desc}</p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
import React from 'react'
import { FiCpu, FiCode, FiGitBranch, FiPenTool, FiBox, FiImage, FiFileText, FiLayout, FiType, FiExternalLink } from 'react-icons/fi'

export default function Docs() {
  const tecnologias = [
    { icone: <FiCpu size={24} />, nome: 'GameMaker', desc: 'Game engine com foco em 2D, GML como linguagem de script e suporte multiplataforma.', link: 'https://gamemaker.io' },
    { icone: <FiCode size={24} />, nome: 'React + Bootstrap', desc: 'Frontend rápido e responsivo para o site do projeto.', link: 'https://react.dev' },
    { icone: <FiGitBranch size={24} />, nome: 'Git + GitHub', desc: 'Controle de versão para colaboração e histórico.', link: 'https://github.com/DediXt04/Lobisomen_Pidao' },
    { icone: <FiPenTool size={24} />, nome: 'Libresprite', desc: 'Ferramenta para criação de pixel art.', link: 'https://libresprite.github.io' },
  ]

  const arquitetura = [
    { icone: <FiBox size={24} />, nome: 'Objetos', desc: 'Entidades do jogo (Player, parede, comida, NPC, inimigos...), cada uma com seus próprios eventos e lógica.' },
    { icone: <FiImage size={24} />, nome: 'Sprites', desc: 'Assets visuais — personagens, tiles, itens e efeitos, organizados em pastas no GameMaker.' },
    { icone: <FiFileText size={24} />, nome: 'Scripts', desc: 'Funções GML reutilizáveis, como lógica de HUD, draw de vida, fome e sistemas compartilhados.' },
    { icone: <FiLayout size={24} />, nome: 'Rooms', desc: 'Salas do jogo (menu, gameplay, game over) com câmera, instâncias e transições configuradas.' },
    { icone: <FiType size={24} />, nome: 'Fonts', desc: 'Fontes pixel art utilizadas na HUD, menus e textos para manter a identidade visual.' },
  ]

  const estrutura = [
    { pasta: 'gamemaker/', desc: 'Projeto GameMaker (.yyp e arquivos do jogo)' },
    { pasta: 'Wiki/', desc: 'Código-fonte do site/wiki (React + Vite)' },
    { pasta: 'gamemaker/.../docs/', desc: 'Guias de implementação e documentação técnica' },
    { pasta: 'README.md', desc: 'Documentação principal do repositório' },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-2">📄 Documentação Técnica</h2>
      <p className="text-muted mb-4">Visão geral das tecnologias, arquitetura e estrutura do projeto.</p>

      <h4 className="mb-3">🛠️ Tecnologias</h4>
      <div className="row g-3 mb-5">
        {tecnologias.map((t, i) => (
          <div key={i} className="col-md-6">
            <div className="card h-100 shadow-sm border-0">
              <div className="card-body d-flex align-items-start gap-3">
                <div className="text-primary mt-1">{t.icone}</div>
                <div className="flex-grow-1">
                  <div className="d-flex align-items-center gap-2">
                    <h6 className="mb-0">{t.nome}</h6>
                    <a href={t.link} target="_blank" rel="noopener noreferrer" className="text-muted">
                      <FiExternalLink size={14} />
                    </a>
                  </div>
                  <p className="text-muted small mb-0 mt-1">{t.desc}</p>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      <h4 className="mb-3">🏗️ Arquitetura</h4>
      <p className="text-muted mb-3">
        O jogo é organizado em módulos independentes para facilitar manutenção e expansão:
      </p>
      <div className="row g-3 mb-5">
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

      <h4 className="mb-3">📁 Estrutura do Repositório</h4>
      <div className="card shadow-sm border-0 mb-5">
        <div className="card-body p-0">
          <div className="table-responsive">
            <table className="table table-hover mb-0">
              <thead className="table-dark">
                <tr>
                  <th>Pasta / Arquivo</th>
                  <th>Descrição</th>
                </tr>
              </thead>
              <tbody>
                {estrutura.map((e, i) => (
                  <tr key={i}>
                    <td><code>{e.pasta}</code></td>
                    <td className="text-muted">{e.desc}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div className="card shadow-sm border-start border-info border-4">
        <div className="card-body">
          <h6 className="fw-bold mb-2">📖 Documentação Completa</h6>
          <p className="mb-2">Para mais detalhes sobre o projeto, acesse o documento completo do PI4:</p>
          <a 
            href="https://docs.google.com/document/d/1nHL50iT8IC1sjhRi4BY2lSer2jAshxtH/edit?usp=sharing&ouid=111985572929588771841&rtpof=true&sd=true" 
            target="_blank" 
            rel="noopener noreferrer" 
            className="btn btn-outline-primary btn-sm"
          >
            <FiExternalLink className="me-1" /> Abrir documentação no Google Docs
          </a>
        </div>
      </div>
    </div>
  )
}
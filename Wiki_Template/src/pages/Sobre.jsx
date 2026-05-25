import React from 'react'
import { FiEye, FiHeart, FiClock, FiAlertTriangle, FiUsers, FiZap } from 'react-icons/fi'

export default function Sobre() {
  const mecanicas = [
    { icone: <FiEye size={28} />, titulo: 'Stealth Top-Down', desc: 'Desvie dos guardas que patrulham as fases com campo de visão em cone. Se te avistarem, a perseguição começa!' },
    { icone: <FiHeart size={28} />, titulo: 'Pedir Comida', desc: 'Aproxime-se dos NPCs e interaja para pedir comida. Cada NPC tem paciência limitada e uma chance crescente de te alimentar.' },
    { icone: <FiClock size={28} />, titulo: 'Sistema de Fome', desc: 'Sua barra de fome diminui em tempo real. Se zerar, o lobisomem morre — então corra atrás de comida!' },
    { icone: <FiAlertTriangle size={28} />, titulo: 'Guardas', desc: 'Guardas patrulham em rotas definidas e perseguem ao te avistar. Desvie ou corra antes que te alcancem!' },
    { icone: <FiUsers size={28} />, titulo: 'NPCs e Interação', desc: 'NPCs andam pelas fases e reagem ao lobisomem. Interaja para conseguir comida — mas nem todos vão colaborar.' },
    { icone: <FiZap size={28} />, titulo: 'Fases e Saída', desc: 'Colete toda a comida necessária em cada fase e encontre a saída para avançar. Quanto mais rápido, melhor!' },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-3">Sobre o Jogo</h2>
      <p className="lead mb-4">
        <strong>Lobisomem Pidão</strong> é um jogo top-down de stealth e humor onde você controla um
        lobisomem desajeitado que não quer atacar ninguém — ele só quer comida.
        Em cada fase, o jogador precisa se aproximar dos NPCs,
        pedir comida e escapar antes que os guardas o encontrem.
      </p>

      <div className="card shadow-sm mb-5">
        <div className="card-body">
          <p className="mb-0">
            O foco não é combate, mas sim movimentação estratégica, furtividade e situações caóticas
            criadas pelo comportamento dos NPCs e guardas. O lobisomem é bobo, estranho e faminto
            — e isso é o coração do humor do jogo. Com fome demais, ele fica ainda mais rápido e desesperado!
          </p>
        </div>
      </div>

      <h3 className="mb-4">Mecânicas Principais</h3>
      <div className="row g-4 mb-5">
        {mecanicas.map((m, i) => (
          <div key={i} className="col-md-6 col-lg-4">
            <div className="card h-100 shadow-sm border-0">
              <div className="card-body">
                <div className="text-primary mb-2">{m.icone}</div>
                <h5 className="card-title">{m.titulo}</h5>
                <p className="card-text text-muted">{m.desc}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <h3 className="mb-3">Tema e Estilo</h3>
      <div className="card shadow-sm border-0">
        <div className="card-body">
          <p className="mb-0">
            O jogo mistura tensão, comédia e um mundo cheio de personagens exagerados.
            O lobisomem pidão é estranho, tonto e sempre com fome — transformando encontros comuns
            em momentos caóticos e engraçados.
          </p>
        </div>
      </div>
    </div>
  )
}
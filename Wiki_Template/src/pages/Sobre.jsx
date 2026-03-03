import React from 'react'
import { FiEye, FiHeart, FiClock, FiAlertTriangle, FiUsers, FiZap } from 'react-icons/fi'

export default function Sobre() {
  const mecanicas = [
    { icone: <FiEye size={28} />, titulo: 'Stealth Top-Down', desc: 'Desvie de guardas, caçadores e NPCs medrosos usando cones de visão, sombras e cobertura.' },
    { icone: <FiHeart size={28} />, titulo: 'Pedir Comida', desc: 'Aproxime-se devagar e acione a habilidade de "pedir", tentando convencer NPCs a te alimentar.' },
    { icone: <FiClock size={28} />, titulo: 'Sistema de Fome', desc: 'Sua fome funciona como "tempo": quanto mais demora, pior fica.' },
    { icone: <FiAlertTriangle size={28} />, titulo: 'Alertas', desc: 'NPCs assustados podem denunciar você, ativando guardas e chamando caçadores.' },
    { icone: <FiUsers size={28} />, titulo: 'Tipos de NPC', desc: 'Normais, medrosos, seguranças, caçadores e até cozinheiros que dão muita comida.' },
    { icone: <FiZap size={28} />, titulo: 'Fases Curtas', desc: 'Cada fase tem objetivos simples, como coletar certos alimentos ou alcançar o cozinheiro principal.' },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-3">Sobre o Jogo</h2>
      <p className="lead text-muted mb-4">
        <strong>Lobisomem Pidão</strong> é um jogo top-down de stealth e humor onde você controla um
        lobisomem desajeitado que não quer atacar ninguém — ele só quer comida.
        Em cada fase, o jogador precisa se aproximar das pessoas,
        pedir comida e escapar antes que guardas e caçadores cheguem até ele.
      </p>

      <div className="card shadow-sm mb-5">
        <div className="card-body">
          <p className="mb-0">
            Inspirado no ritmo rápido de jogos como <em>Hotline Miami</em>, o foco aqui não é combate,
            mas sim movimentação estratégica, furtividade e situações caóticas criadas pelo comportamento
            imprevisível dos NPCs. O lobisomem é bobo, estranho e faminto — e isso é o coração do humor do jogo.
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
      <div className="card shadow-sm border-0 bg-dark text-white">
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
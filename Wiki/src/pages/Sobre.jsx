import React from 'react'
import { FiEye, FiHeart, FiClock, FiAlertTriangle, FiUsers, FiZap, FiMap, FiMusic, FiSettings, FiLock, FiMonitor } from 'react-icons/fi'

export default function Sobre() {
  const mecanicas = [
    { icone: <FiEye size={28} />, titulo: 'Stealth Top-Down', desc: 'Desvie dos guardas que patrulham as fases com campo de visão em cone. Se te avistarem, a perseguição começa!' },
    { icone: <FiHeart size={28} />, titulo: 'Pedir Comida', desc: 'Aproxime-se dos NPCs e interaja para pedir comida. Cada NPC tem paciência limitada e uma chance crescente de te alimentar.' },
    { icone: <FiClock size={28} />, titulo: 'Sistema de Fome', desc: 'Sua barra de fome diminui em tempo real. Se zerar, o lobisomem morre — então corra atrás de comida!' },
    { icone: <FiAlertTriangle size={28} />, titulo: 'Guardas Inteligentes', desc: 'Guardas patrulham em rotas definidas com campo de visão e colisão realistas. Desvie ou corra antes que te alcancem!' },
    { icone: <FiUsers size={28} />, titulo: 'NPCs Dinâmicos', desc: 'NPCs com múltiplas skins se movem em diagonais pelas fases e reagem ao lobisomem. Interaja para conseguir comida — mas nem todos vão colaborar.' },
    { icone: <FiZap size={28} />, titulo: 'Modo Faminto', desc: 'Com ≤25% de fome, o lobisomem fica mais rápido e muda de aparência — desespero total para conseguir comida!' },
  ]

  const recursos = [
    { icone: <FiMap size={28} />, titulo: '10 Fases + Tutorial', desc: 'São 10 fases base com dificuldade progressiva, incluindo uma fase tutorial para aprender as mecânicas do jogo.' },
    { icone: <FiLock size={28} />, titulo: 'Desbloqueio Progressivo', desc: 'As fases são desbloqueadas conforme você avança — vença a anterior para liberar a próxima.' },
    { icone: <FiMusic size={28} />, titulo: 'Soundtrack e Efeitos Sonoros', desc: 'Trilha sonora original e efeitos sonoros que acompanham cada momento do jogo, da tensão ao humor.' },
    { icone: <FiSettings size={28} />, titulo: 'Tela de Settings', desc: 'Configurações acessíveis para ajustar o jogo ao seu gosto, direto pelo menu principal.' },
    { icone: <FiMonitor size={28} />, titulo: 'Menu Principal Completo', desc: 'Menu principal polido com navegação intuitiva, acesso rápido às fases e configurações.' },
  ]

  const controles = [
    { acao: 'Mover', teclado: 'WASD / Setas', gamepad: 'Analógico / D-pad' },
    { acao: 'Interagir', teclado: 'E / Espaço', gamepad: 'A / Cruz' },
    { acao: 'Confirmar (menus)', teclado: 'Enter / E', gamepad: 'A / Cruz' },
    { acao: 'Navegar (menus)', teclado: 'WASD / Setas', gamepad: 'D-pad / Analógico' },
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

      <div className="card shadow-sm mb-5 border-start border-primary border-4">
        <div className="card-body">
          <p className="mb-0">
            O foco não é combate, mas sim movimentação estratégica, furtividade e situações caóticas
            criadas pelo comportamento dos NPCs e guardas. O lobisomem é bobo, estranho e faminto
            — e isso é o coração do humor do jogo. Com fome demais, ele fica ainda mais rápido e desesperado!
          </p>
        </div>
      </div>

      <h3 className="mb-4">🎮 Mecânicas Principais</h3>
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

      <h3 className="mb-4">⭐ Recursos do Jogo</h3>
      <div className="row g-4 mb-5">
        {recursos.map((r, i) => (
          <div key={i} className="col-md-6 col-lg-4">
            <div className="card h-100 shadow-sm border-0">
              <div className="card-body">
                <div className="text-success mb-2">{r.icone}</div>
                <h5 className="card-title">{r.titulo}</h5>
                <p className="card-text text-muted">{r.desc}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <h3 className="mb-4">🕹️ Controles</h3>
      <div className="card shadow-sm border-0 mb-5">
        <div className="card-body p-0">
          <div className="table-responsive">
            <table className="table table-hover mb-0">
              <thead className="table-dark">
                <tr>
                  <th>Ação</th>
                  <th>Teclado</th>
                  <th>Gamepad</th>
                </tr>
              </thead>
              <tbody>
                {controles.map((c, i) => (
                  <tr key={i}>
                    <td className="fw-semibold">{c.acao}</td>
                    <td><code>{c.teclado}</code></td>
                    <td><code>{c.gamepad}</code></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
        <div className="card-footer bg-light">
          <small className="text-muted">O jogo detecta automaticamente o gamepad conectado (hot-plug).</small>
        </div>
      </div>

      <h3 className="mb-3">🎨 Tema e Estilo</h3>
      <div className="card shadow-sm border-0 border-start border-warning border-4">
        <div className="card-body">
          <p className="mb-0">
            O jogo mistura tensão, comédia e um mundo cheio de personagens exagerados.
            O lobisomem pidão é estranho, tonto e sempre com fome — transformando encontros comuns
            em momentos caóticos e engraçados. Com pixel art feita à mão, trilha sonora original e
            fases cuidadosamente desenhadas, cada partida é uma experiência única e divertida.
          </p>
        </div>
      </div>
    </div>
  )
}
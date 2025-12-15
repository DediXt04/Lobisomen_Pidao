import React from 'react'

export default function Devlog() {
  const entradas = [
    { data: '2025-11-01', titulo: 'Protótipo inicial', texto: 'Criei o protótipo da mecânica de troca de dimensão ao pular.' },
    { data: '2025-11-10', titulo: 'Arte base', texto: 'Sprites 32x32 prontos para o personagem.' },
    { data: '2025-11-15', titulo: 'Sistema de colisão', texto: 'Implementado sistema simples de colisão com paredes e objetos.' },
    { data: '2025-11-20', titulo: 'Primeiro inimigo', texto: 'Adicionado um NPC que patrulha a área e reage ao jogador.' },
    { data: '2025-11-25', titulo: 'Efeitos sonoros', texto: 'Incluídos sons básicos de passos, porta e alerta do inimigo.' },
    { data: '2025-11-28', titulo: 'Menu inicial', texto: 'Tela de título com opções de iniciar jogo e sair.' },
    { data: '2025-12-01', titulo: 'HUD provisória', texto: 'Barra de energia e contador de itens coletados.' },
    { data: '2025-12-05', titulo: 'Teste de performance', texto: 'Rodando em 60fps estáveis em máquinas de entrada.' },
    { data: '2025-12-10', titulo: 'Refatoração', texto: 'Organizei o código em componentes e módulos mais limpos.' },
    { data: '2025-12-15', titulo: 'Feedback visual', texto: 'Adicionei animações quando o jogador é detectado.' },
    { data: '2025-12-20', titulo: 'Mapa maior', texto: 'Expansão da área jogável com novos cenários e obstáculos.' },
    { data: '2025-12-25', titulo: 'Natal especial', texto: 'Skin temática de lobisomem com gorro vermelho 🎅.' },
    { data: '2026-01-01', titulo: 'Ano novo', texto: 'Pequenos ajustes e correções de bugs para começar o ano.' },
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

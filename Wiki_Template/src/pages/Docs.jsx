import React from 'react'

export default function Docs() {
  return (
    <div className="container py-4">
      <h2 className="mb-4">Documentação Técnica</h2>

      <h4>Tecnologias</h4>
      <ul>
        <li>Game engine: <strong>GameMaker</strong> (foco em 2D, GML como linguagem de script, suporte multiplataforma).</li>
        <li>Site: <strong>React</strong> + <strong>Vite</strong> + <strong>Bootstrap</strong> para frontend rápido e responsivo.</li>
        <li>Controle de versão: <strong>Git + GitHub</strong> para colaboração e histórico.</li>
        <li>Design gráfico: <strong>Aseprite</strong> para pixel art, <strong>Figma</strong> para UI.</li>
        <li>Áudio: <strong>Audacity</strong> para edição, <strong>Bfxr</strong> para efeitos sonoros retrô.</li>
      </ul>

      <h4>Arquitetura</h4>
      <p>
        O jogo será organizado em módulos independentes para facilitar manutenção e expansão:
      </p>
      <ul>
        <li><strong>Player</strong>: objeto principal com scripts de movimento, animações e interações.</li>
        <li><strong>Gerador de obstáculos</strong>: instâncias criadas dinamicamente para paredes, inimigos e itens.</li>
        <li><strong>Gerenciamento de estados</strong>: controladores para menus, gameplay, pausa e transições de sala.</li>
        <li><strong>Assets</strong>: sprites, sons e mapas organizados em pastas do GameMaker.</li>
        <li><strong>IA inimigos</strong>: lógica de patrulha e perseguição implementada em GML.</li>
      </ul>

      <h4>Fluxo de Jogo</h4>
      <ol>
        <li>O jogador inicia na sala principal.</li>
        <li>Explora áreas, coleta itens e evita inimigos.</li>
        <li>Ao ser detectado, entra em modo de fuga.</li>
        <li>Objetivo: sobreviver e completar missões sem ser capturado.</li>
      </ol>

      <h4>Próximos Passos</h4>
      <p>
        - Implementar sistema de save/load.<br />
        - Criar HUD definitiva com barra de energia e inventário.<br />
        - Adicionar cutscenes simples para narrativa.<br />
        - Testar multiplayer local experimental.
      </p>
    </div>
  )
}

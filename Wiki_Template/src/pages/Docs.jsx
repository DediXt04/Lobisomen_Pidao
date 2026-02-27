import React from 'react'

export default function Docs() {
  return (
    <div className="container py-4">
      <h2 className="mb-4">Documentação Técnica</h2>

      <h4>Tecnologias</h4>
      <ul>
        <li>Game engine: <strong>GameMaker</strong> (foco em 2D, GML como linguagem de script, suporte multiplataforma).</li>
        <li>Site: <strong>React</strong> + <strong>Bootstrap</strong> para frontend rápido e responsivo.</li>
        <li>Controle de versão: <strong>Git + GitHub</strong> para colaboração e histórico.</li>
        <li>Design gráfico: <strong>Libresprite</strong> para pixel art.</li>
      </ul>

      <h4>Arquitetura</h4>
      <p>
        O jogo será organizado em módulos independentes para facilitar manutenção e expansão:
      </p>
      <ul>
        <li><strong>Objetos</strong>: entidades do jogo (Player, parede, comida, NPC, inimigos...), cada uma com seus próprios eventos e lógica.</li>
        <li><strong>Sprites</strong>: assets visuais do jogo — personagens, tiles, itens e efeitos, organizados em pastas no GameMaker.</li>
        <li><strong>Scripts</strong>: funções GML reutilizáveis, como lógica de HUD, draw de vida, fome e sistemas compartilhados entre objetos.</li>
        <li><strong>Rooms</strong>: salas do jogo (menu, gameplay, game over) com câmera, instâncias e transições configuradas.</li>
        <li><strong>Fonts</strong>: fontes pixel art utilizadas na HUD, menus e textos para manter a identidade visual.</li>
      </ul>

    </div>
  )
}
# 🐺 Lobisomem Pidão

![GameMaker](https://img.shields.io/badge/GameMaker-2024-blue?logo=gamemaker&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-7-646CFF?logo=vite&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5-7952B3?logo=bootstrap&logoColor=white)

Jogo indie 2D top-down onde você controla um lobisomem faminto que precisa explorar fases, pedir comida aos NPCs e escapar dos inimigos antes que a fome acabe ou que ele seja capturado.

<p align="center">
  <img src="Wiki_Template/src/assets/gallery/lobisomenDDown.png" alt="Lobisomem" width="120" />
  <img src="Wiki_Template/src/assets/gallery/burguer.png" alt="Burger" width="120" />
  <img src="Wiki_Template/src/assets/gallery/pizza.png" alt="Pizza" width="120" />
  <img src="gamemaker\LobisomenPidao_Demo\sprites\sNpcDown\32c78989-5ab8-4314-b29f-90d9fc89d257.png" alt="NPC" width="120" />
</p>

---

## 🎮 Mecânicas

- **Fome** — barra de fome que diminui em tempo real. Se zerar, o lobo morre.
- **Coleta de comida** — interaja com NPCs para pedir comida. Cada NPC tem paciência limitada e chance crescente de dar comida.
- **Stealth** — inimigos patrulham e têm cone de visão. Se te avistarem, perseguem.
- **Modo faminto** — com ≤25% de fome, o lobisomem fica mais rápido e muda de aparência.
- **Saída** — colete todas as comidas e encontre a porta de saída para vencer a fase.

## 🕹️ Controles

| Ação | Teclado | Gamepad |
|---|---|---|
| Mover | WASD / Setas | Analógico esquerdo / D-pad |
| Interagir | E / Espaço | A / Cruz |
| Confirmar (menus) | Enter / E | A / Cruz |
| Navegar (menus) | WASD / Setas | D-pad / Analógico |

> O jogo detecta automaticamente o gamepad conectado (hot-plug).

## 🛠️ Tecnologias

- **Game Engine:** [GameMaker](https://gamemaker.io) — foco em 2D, GML como linguagem de script, suporte multiplataforma.
- **Site/Wiki:** [React](https://react.dev) + [Vite](https://vite.dev) + [Bootstrap](https://getbootstrap.com) — frontend rápido e responsivo.
- **Controle de versão:** Git + GitHub para colaboração e histórico.
- **Design gráfico:** [Libresprite](https://libresprite.github.io) para pixel art.

## 🏗️ Arquitetura

O jogo é organizado em módulos independentes para facilitar manutenção e expansão:

- **Objetos** — entidades do jogo (Player, parede, comida, NPC, inimigos...), cada uma com seus próprios eventos e lógica.
- **Sprites** — assets visuais do jogo — personagens, tiles, itens e efeitos, organizados em pastas no GameMaker.
- **Scripts** — funções GML reutilizáveis, como lógica de HUD, draw de vida, fome e sistemas compartilhados entre objetos.
- **Rooms** — salas do jogo (menu, gameplay, game over) com câmera, instâncias e transições configuradas.
- **Fonts** — fontes pixel art utilizadas na HUD, menus e textos para manter a identidade visual.

## 📁 Estrutura do Repositório

```
Projeto_Integrador_04/
├── gamemaker/
│   └── LobisomenPidao_Demo/   # projeto GameMaker (.yyp e arquivos do jogo)
├── Wiki_Template/             # código-fonte do site/wiki (React + Vite)
└── README.md
```

## 🚀 Como Rodar

### Pré-requisitos

- [GameMaker](https://gamemaker.io) (versão gratuita funciona) — para o jogo
- [Node.js](https://nodejs.org) (v18+) — para o site

### Jogo
1. Abra o GameMaker
2. Abra o arquivo `.yyp` dentro de `gamemaker/LobisomenPidao_Demo/`
3. Pressione **F5** para rodar

### Site
```bash
cd Wiki_Template
npm install
npm run dev
```

## 👥 Equipe

| Nome | Função | GitHub |
|---|---|---|
| André Queiroz | Desenvolvedor / Game Designer | [@DediXt04](https://github.com/DediXt04) |
| Caetano José | Desenvolvedor / Game Designer | [@Cae003](https://github.com/Cae003) |
| Cesar | Desenvolvedor / Game Designer | [@cesaaa-r](https://github.com/cesaaa-r) |
| Eduardo Rabelo | Desenvolvedor / Game Designer | [@Edu4rdoMarques](https://github.com/Edu4rdoMarques) |

## 📖 Documentação

Para mais detalhes, acesse a [documentação completa do PI4](https://docs.google.com/document/d/1nHL50iT8IC1sjhRi4BY2lSer2jAshxtH/edit?usp=sharing&ouid=111985572929588771841&rtpof=true&sd=true).

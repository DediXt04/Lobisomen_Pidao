# 🐺 Lobisomem Pidão

![GameMaker](https://img.shields.io/badge/GameMaker-2024-blue?logo=gamemaker&logoColor=white)
![React](https://img.shields.io/badge/React-19-61DAFB?logo=react&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-7-646CFF?logo=vite&logoColor=white)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5-7952B3?logo=bootstrap&logoColor=white)

Jogo indie 2D top-down de stealth e humor onde você controla um lobisomem faminto que precisa explorar fases, pedir comida aos NPCs e escapar dos inimigos antes que a fome acabe ou que ele seja capturado.

> 🔗 **Repositório:** [github.com/DediXt04/Lobisomen_Pidao](https://github.com/DediXt04/Lobisomen_Pidao)

---

## 🎮 Mecânicas

| Mecânica | Descrição |
|---|---|
| **Fome** | Barra de fome que diminui em tempo real. Se zerar, o lobo morre. |
| **Coleta de comida** | Interaja com NPCs para pedir comida. Cada NPC tem paciência limitada e chance crescente de dar comida. |
| **Stealth** | Inimigos patrulham com cone de visão e colisão realistas. Se te avistarem, perseguem. |
| **Modo faminto** | Com ≤25% de fome, o lobisomem fica mais rápido e muda de aparência. |
| **Desbloqueio de fases** | Vença a fase atual para desbloquear a próxima. Progressão gradual com 10 fases + tutorial. |
| **Saída** | Colete todas as comidas e encontre a porta de saída para vencer a fase. |

## 🕹️ Controles

| Ação | Teclado | Gamepad |
|---|---|---|
| Mover | WASD / Setas | Analógico esquerdo / D-pad |
| Interagir | E / Espaço | A / Cruz |
| Confirmar (menus) | Enter / E | A / Cruz |
| Navegar (menus) | WASD / Setas | D-pad / Analógico |

> O jogo detecta automaticamente o gamepad conectado (hot-plug).

## ⭐ Recursos

- 🗺️ **10 fases + tutorial** com dificuldade progressiva
- 🔓 **Desbloqueio progressivo** de fases
- 🎵 **Soundtrack e efeitos sonoros** originais
- ⚙️ **Tela de settings** para configurações do jogo
- 🏠 **Menu principal** completo e polido
- 👥 **NPCs dinâmicos** com múltiplas skins e movimento diagonal
- 🛡️ **Guardas inteligentes** com campo de visão e colisão

## 🛠️ Tecnologias

| Tecnologia | Uso |
|---|---|
| [GameMaker](https://gamemaker.io) | Game engine — foco em 2D, GML como linguagem de script |
| [React](https://react.dev) + [Vite](https://vite.dev) + [Bootstrap](https://getbootstrap.com) | Site/Wiki — frontend rápido e responsivo |
| [Git + GitHub](https://github.com/DediXt04/Lobisomen_Pidao) | Controle de versão e colaboração |
| [Libresprite](https://libresprite.github.io) | Pixel art e design gráfico |

## 🏗️ Arquitetura

O jogo é organizado em módulos independentes para facilitar manutenção e expansão:

| Módulo | Descrição |
|---|---|
| **Objetos** | Entidades do jogo (Player, parede, comida, NPC, inimigos...), cada uma com seus próprios eventos e lógica. |
| **Sprites** | Assets visuais — personagens, tiles, itens e efeitos, organizados em pastas no GameMaker. |
| **Scripts** | Funções GML reutilizáveis, como lógica de HUD, draw de vida, fome e sistemas compartilhados. |
| **Rooms** | Salas do jogo (menu, gameplay, game over) com câmera, instâncias e transições configuradas. |
| **Fonts** | Fontes pixel art utilizadas na HUD, menus e textos para manter a identidade visual. |

## 📁 Estrutura do Repositório

```
Lobisomen_Pidao/
├── gamemaker/
│   └── LobisomenPidao_Demo/       # Projeto GameMaker (.yyp e arquivos do jogo)
│       └── docs/                   # Guias de implementação e documentação técnica
├── Wiki/                           # Código-fonte do site/wiki (React + Vite)
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

### Site / Wiki
```bash
cd Wiki
npm install
npm run dev
```

## 👥 Equipe

| Nome | Função | GitHub |
|---|---|---|
| André Queiroz | Desenvolvedor / Game Designer | [@DediXt04](https://github.com/DediXt04) |
| Caetano José | Desenvolvedor / Game Designer | [@Cae003](https://github.com/Cae003) |
| Cesar Brossi | Game Designer / Pixel Artist  | [@cesaaa-r](https://github.com/cesaaa-r) |
| Eduardo Rabelo | Game Designer / Pixel Artist | [@Edu4rdoMarques](https://github.com/Edu4rdoMarques) |

## 📖 Documentação

Para mais detalhes, acesse a [documentação completa do PI4](https://docs.google.com/document/d/1nHL50iT8IC1sjhRi4BY2lSer2jAshxtH/edit?usp=sharing&ouid=111985572929588771841&rtpof=true&sd=true).

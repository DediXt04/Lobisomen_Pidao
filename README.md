# Informações Gerais
O projeto se trata de um jogo indie 2D no estilo top-down onde um lobisomem precisa explorar fases, interagir com NPCs e coletar comida antes que a fome acabe ou que ele seja capturado.

## Tecnologias

- Game engine: **GameMaker** (foco em 2D, GML como linguagem de script, suporte multiplataforma).
- Site: **React** + **Bootstrap** para frontend rápido e responsivo.
- Controle de versão: **Git + GitHub** para colaboração e histórico.
- Design gráfico: **Libresprite** para pixel art.

## Arquitetura

O jogo será organizado em módulos independentes para facilitar manutenção e expansão:

- **Objetos**: entidades do jogo (Player, parede, comida, NPC, inimigos...), cada uma com seus próprios eventos e lógica.
- **Sprites**: assets visuais do jogo — personagens, tiles, itens e efeitos, organizados em pastas no GameMaker.
- **Scripts**: funções GML reutilizáveis, como lógica de HUD, draw de vida, fome e sistemas compartilhados entre objetos.
- **Rooms**: salas do jogo (menu, gameplay, game over) com câmera, instâncias e transições configuradas.
- **Fonts**: fontes pixel art utilizadas na HUD, menus e textos para manter a identidade visual.

## Estrutura do Repositório

```
Projeto_Integrador_04/
├── gamemaker/
│   └── LobisomenPidao_Demo/   # projeto GameMaker (.yyp e arquivos do jogo)
├── Wiki_Template/             # código-fonte do site/wiki
└── README.md
```

## Como Rodar

### Jogo
1. Instale o [GameMaker](https://gamemaker.io) (versão gratuita funciona)
2. Abra o arquivo `.yyp` dentro de `gamemaker/LobisomenPidao_Demo/`
3. Pressione **F5** para rodar

### Site
1. Entre na pasta `Wiki_Template/`
2. Instale as dependências:
```bash
npm install
```
3. Rode em modo desenvolvimento:
```bash
npm run dev
```

## Documentação Completa
Caso queira saber mais detalhes acesse a Página Wiki ou nossa documentação [PI4_Documentação](https://docs.google.com/document/d/1nHL50iT8IC1sjhRi4BY2lSer2jAshxtH/edit?usp=sharing&ouid=111985572929588771841&rtpof=true&sd=true)

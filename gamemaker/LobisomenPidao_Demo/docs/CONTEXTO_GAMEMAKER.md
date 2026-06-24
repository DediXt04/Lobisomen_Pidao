# 🐺 Contexto do Projeto — Lobisomem Pidão (GameMaker)

> Resumo técnico completo do projeto GameMaker para onboarding rápido. Use este arquivo como referência ao iniciar uma nova sessão de desenvolvimento.

---

## 📌 Visão Geral

**Lobisomem Pidão** é um jogo indie 2D top-down de stealth e humor. O jogador controla um lobisomem faminto que precisa explorar fases, pedir comida aos NPCs e escapar dos inimigos antes que a fome acabe ou que ele seja capturado.

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Gênero | Top-down stealth / humor |
| Arquivo principal | `LobisomenPidao_Demo.yyp` |
| Localização | `gamemaker/LobisomenPidao_Demo/` |

### Condições de Vitória e Derrota

- **Vitória:** coletar todas as comidas (`global.comida >= global.comidaMax`) e entrar na porta de saída
- **Derrota (dano):** vida chega a 0 (`oController.vida <= 0`)
- **Derrota (fome):** timer de fome chega a 0 (`oController.tempoFome <= 0`)

---

## 🎮 Controles

| Ação | Teclado | Gamepad |
|---|---|---|
| Mover | WASD | Analógico esquerdo / D-pad |
| Interagir | E / Espaço | A / Cruz |
| Pausar | ESC | Start |
| Navegar menus | WASD | D-pad / Analógico |
| Confirmar menus | Enter / E / Espaço | A / Cruz |

O gamepad é detectado automaticamente via `oProcuraControle` (objeto persistente que seta `global.gamepad_main`).

---

## 🏗️ Arquitetura Técnica

| Item | Valor |
|---|---|
| Resolução interna (view) | 320×180 |
| Viewport (porta de saída) | 1920×1080 |
| Tile size | 16×16 |
| Grid de pathfinding | 16×16 px (`mp_grid` no `oController`, criado com `mp_grid_create(0,0,rw/16,rh/16,16,16)`) |
| Fonte do projeto | `fnt_pixel` |
| Paleta de cores UI | Navy escuro `rgb(14,14,26)` + Teal `rgb(80,200,210)` |

### Layers das Rooms (ordem de cima para baixo)

| Layer | Tipo | Profundidade | Uso |
|---|---|---|---|
| `instancias` | Instance Layer | 0 | Player, oController, oSpawner, oSaida, oInimigo, oSpawnZone |
| `tiles` | Tile Layer | 100 | Tilemap visual (chão, paredes decorativas) |
| `colisoes` | Instance Layer | 200 | oWall, oSolidWall, oParedeFina (colisão invisível) |
| `Background` | Background Layer | 300 | Cor de fundo ou sprite de fundo |

### Câmera (Viewport 0)

- View: 320×180, seguindo `oPlayer` (Hborder: 128, Vborder: 64, Hspeed/Vspeed: -1)
- Port: 1920×1080 (estica a imagem para tela — visual pixel art escalado)

---

## 📦 Mapa de Objetos

### Objetos de Gameplay

| Objeto | Sprite | Função | Eventos |
|---|---|---|---|
| `oPlayer` | `sLobo*` / `sLobo*Hungry` | Jogador controlável | Create, 
Step, Draw |
| `oController` | — | Gerencia vida, fome, HUD, pausa, pathfinding, interação | Create, Step, Draw (GUI), Draw_64 |
| `oInimigo` | `sFreddyFasbear` | **Objeto pai** de todos os inimigos; máquina de estados + campo de visão | Create, Step, Draw, Collision_oPlayer |
| `oGuarda1` | `sGuarda*` | Filho de `oInimigo`; sprites de guarda, herda toda a lógica | Create (event_inherited + sprites), Step, Draw |
| `oFreddy` | `sFreddyFasbear` | Filho de `oInimigo`; sprite único para todas as direções | Create (event_inherited + sprites), Step, Draw |
| `oNpc` | `sNpc*` | NPC que dá comida via interação; sistema de paciência e probabilidade | Create, Step, Draw |
| `oNpc2` | `sNpc2*` | Segunda skin de NPC (variante visual) — mesma lógica do `oNpc` | Create, Step, Draw |
| `oComida` | — | **Objeto pai** de comida; flutua e é coletável | Create, Step, Draw |
| `oBurger` | `sBurguer` | Filho de `oComida` | Herda de oComida |
| `oCereja` | `sCereja` | Filho de `oComida` | Herda de oComida |
| `oCoxinha` | `sCoxinha` | Filho de `oComida` | Herda de oComida |
| `oChave` | `sChave` | Chave coletável que desbloqueia `oPorta` | Create, Step, Draw |
| `oSaida` | `sPortaFechada` / `sPortaAberta` | Porta de saída da fase; abre quando toda comida é coletada | Step |
| `oPorta` | `sPortaTrancada` / `sPortaDestrancada` | Portão que bloqueia passagem; abre com chave | Step |
| `oSpawner` | — | Cria comida e NPCs nas SpawnZones; se destrói após spawnar | Create, Alarm_0 |
| `oSpawnZone` | `sSpawnZone` | Retângulo invisível que define onde comida/NPCs podem spawnar | — |

### Objetos de Colisão

| Objeto | Função |
|---|---|
| `oWall` | Parede normal — bloqueia player/NPCs, entra no pathfinding grid |
| `oSolidWall` | Parede sólida — bordas externas do mapa |
| `oParedeFina` | Parede fina — bloqueia passagem mas não ocupa tile inteiro |

### Objetos de Tela/Menu

| Objeto | Room | Função |
|---|---|---|
| `oMenuPrincipal` | `rm_MenuPrincipal` | Menu principal do jogo |
| `oLoboMenu` | `rm_MenuPrincipal` | Mascote reativo (sprite 16×16 escalado 20×) — state machine com 9 estados: idle ativo, foco/confirmação dos 3 botões, 3 níveis de inatividade (revirando→dormindo→envelhecendo) |
| `oSeletorDeFases` | `rm_SelecaoDeFases` | Grade de cards para selecionar fases; paginação |
| `oVitoria` | `rm_Vitoria` | Tela de vitória com botões de reiniciar/sair |
| `oGameOver` | `rm_gameOver` | Tela de game over com motivo da morte |
| `oProcuraControle` | `rm_MenuPrincipal` | **Persistente**; detecta gamepads e seta `global.gamepad_main` |

### Hierarquia de Herança

```
oInimigo (pai)
├── oGuarda1   (sprites de guarda, herda lógica via event_inherited)
└── oFreddy    (sprite Freddy para todas as direções)

oComida (pai)
├── oBurger    (sprite sBurguer)
├── oCereja    (sprite sCereja)
└── oCoxinha   (sprite sCoxinha)
```

---

## 📜 Scripts Reutilizáveis

| Script | Assinatura | Função |
|---|---|---|
| `scr_drawVida` | `scr_drawVida(_vida, _vidaMax)` | Desenha corações da HUD (sprite `sVida`, 3 frames: vazio/meio/cheio) |
| `scr_drawFome` | `scr_drawFome(_fome, _fomeMax)` | Desenha barra de fome da HUD (sprite `sFomeG`, 10 frames) |
| `scr_drawComida` | `scr_drawComida(_comida, _comidaMax)` | Desenha ícone de pizza + texto "X/Y" da comida coletada |
| `scr_initMovimento` | `scr_initMovimento(_spd, _timer_min, _timer_max)` | Inicializa variáveis de movimento para NPCs (velocidade, timers, pixels_walked) |
| `scr_escolherDirecao` | `scr_escolherDirecao(_spd, _min_px, _max_px, _diagonal)` | Escolhe direção aleatória (4 ou 8 direções) e distância para andar |

---

## 🏠 Rooms

| Room | Tipo | Descrição |
|---|---|---|
| `rm_MenuPrincipal` | Menu | Menu principal; contém `oProcuraControle` (persistente) |
| `rm_SelecaoDeFases` | Menu | Seletor de fases em grade (3 colunas × 2 linhas por página) |
| `room_01` | Gameplay | Fase 1 (testes — legado; usa nome antigo `room_XX`) |
| `room_02` | Gameplay | Fase 2 (testes com tileset — legado; usa nome antigo `room_XX`) |
| `rm_fase03` | Gameplay | Fase 3 — "Acho que conheço esse lugar..." (padrão atual: `rm_faseXX`) |
| `rm_fase04` | Gameplay | Fase 4 — "Fase Caótica" |
| `rm_Vitoria` | Tela | Tela de vitória |
| `rm_gameOver` | Tela | Tela de game over |

### Room Order (fluxo do jogo)

```
rm_MenuPrincipal → rm_SelecaoDeFases → room_XX (gameplay)
                                            │
                                   ┌────────┴────────┐
                                   ▼                  ▼
                              rm_Vitoria         rm_gameOver
                                   │                  │
                                   └──────┬───────────┘
                                          ▼
                                   rm_SelecaoDeFases (ou reinicia fase)
```

---

## 🌐 Variáveis Globais

| Variável | Tipo | Setada em | Lida em | Descrição |
|---|---|---|---|---|
| `global.comida` | int | oController/Create, oComida/Step, oNpc/Step | oController/Step, oSaida/Step, HUD | Comidas coletadas na fase atual |
| `global.comidaMax` | int | Room Creation Code (fallback: oController) | oController, oSaida, HUD | Meta de comidas para abrir a saída |
| `global.comidaSpawn` | int | Room Creation Code (fallback: oController) | oSpawner/Alarm_0 | Quantas comidas spawnar no mapa |
| `global.npcSpawn` | int | Room Creation Code (fallback: oController) | oSpawner/Alarm_0 | Quantos NPCs spawnar |
| `global.tempoFomeMax` | int | Room Creation Code (fallback: oController) | oController/Create | Tempo máximo de fome em segundos |
| `global.comidaCheia` | bool | oController/Step | oSaida/Step, oPlayer/Step | `true` quando comida >= comidaMax |
| `global.temChave` | bool | oController/Create, oChave/Step | oPorta/Step, oPlayer/Step, oNpc/Step | Se o player coletou a chave |
| `global.pausado` | bool | oController | Todos os objetos de gameplay | Estado de pausa do jogo |
| `global.motivoMorte` | string | oController/Step | oGameOver | `"dano"` ou `"fome"` |
| `global.fase_room_atual` | room | oController/Create | oVitoria/Step, oGameOver/Step | Room da fase atual (para reiniciar) |
| `global.gamepad_main` | int/undefined | oProcuraControle | oPlayer, oController, menus | Slot do gamepad principal |
| `global.gamepads` | array | oProcuraControle | — | Array de gamepads conectados |
| `global.fase_rooms` | array de room | oSeletorDeFases/Create | oSeletorDeFases | Lista de rooms de fase na ordem do seletor |
| `global.total_fases` | int | oSeletorDeFases/Create | oSeletorDeFases | `array_length(global.fase_rooms)` |
| `global.fase_atual` | int | oSeletorDeFases (ao confirmar fase) | oVitoria/Step | Índice da fase atualmente sendo jogada |
| `global.fase_desbloqueada` | int | oSeletorDeFases/Create (lê do INI), oVitoria/Step (incrementa ao vencer) | oSeletorDeFases | Maior índice de fase desbloqueada; persistido em `save_progresso.ini` seção `[progresso]` |

### Valores padrão (fallback se Room Creation Code não definir)

| Variável | Padrão |
|---|---|
| `global.comidaMax` | 5 |
| `global.comidaSpawn` | 5 |
| `global.npcSpawn` | 2 |
| `global.tempoFomeMax` | 90 |

---

## ⚙️ Sistemas Principais

### 1. Máquina de Estados do Inimigo (`oInimigo`)

Cada estado é uma **função armazenada em variável**. No Step, basta chamar `estado()`.

| Estado | Cor Debug | Comportamento |
|---|---|---|
| `estado_parado` | branco | Parado; 2% de chance/frame de começar a passear; checa campo de visão |
| `estado_passeando` | vermelho | Anda em direção aleatória por ~2 segundos; checa campo de visão |
| `estado_perseguindo` | magenta | Persegue o player; timer_see de 2s de "memória" após perder visão |

```
estado_parado ──(vê player)──► estado_perseguindo
     ▲                              │
     │                              │ (perde visão + timer_see = 0)
     │◄─────────────────────────────┘
     │
     │◄──(timer_estado = 0)── estado_passeando
     └──(chance 2%)──────────► estado_passeando
```

### 2. Campo de Visão (`campo_visao`)

Função definida no `oInimigo/Create_0.gml`:
- **Parâmetros:** `_dist` (distância máxima), `_angulo_visao` (ângulo do cone)
- **Chamada padrão:** `campo_visao(120, 60)` → 120px de alcance, 60° de abertura
- **Lógica:** calcula direção atual (baseada em velocidade ou `face`), verifica se o player está dentro do ângulo, e traça `collision_line` para checar paredes
- ⚠️ **Bug conhecido:** o parâmetro `_dist` é recebido mas **nunca usado** — a detecção é infinita. Ver `GUIA_COLISAO_E_VISAO_INIMIGO.md` para a correção.

### 3. Sistema de Fome (`oController`)

- `tempoFome` diminui em tempo real usando `delta_time / 1000000` (independente de framerate)
- `tempoMax` guarda o valor máximo (para cálculos de %)
- Ambos são setados a partir de `global.tempoFomeMax` no Create
- Fome ≤ 25% do máximo → modo faminto do player (velocidade 2.5, sprites escuros)
- Fome = 0 → game over com `motivoMorte = "fome"`

### 4. Sistema de Vida (`oController`)

- `vida` = 6, `vidaMax` = 6 (3 corações, cada um com 2 pontos)
- Dano aplicado via `oInimigo/Collision_oPlayer.gml`: subtrai `other.dano` do `oController.vida`
- Knockback: aplica vetor de força no player + 90 frames de invencibilidade
- Vida ≤ 0 → game over com `motivoMorte = "dano"`

### 5. Interação com NPCs (`oNpc`)

- **Proximidade:** distância < 32px + `oController.interagir` + sem parede no caminho
- **Probabilidade escalante:** começa em 10%, sobe 10-15% a cada tentativa
- **Paciência:** 5 tentativas máximas; esgotada → NPC não interage mais
- **Cooldown:** 120 frames entre interações
- **Reações visuais:** frame 0 = deu comida, frame 1 = não deu, frame 2 = sem paciência (sprite `sReacao`)

### 6. Spawner (`oSpawner`)

- **Create:** `alarm[0] = 1` (delay de 1 frame para garantir que todas as SpawnZones existem)
- **Alarm_0:** itera config `[quantidade, [tipos]]`, tenta até 200 posições aleatórias por item
- Usa `collision_rectangle` com margem de 16px para validar posições (checa oWall, oSolidWall, oParedeFina, oSaida, oComida, oNpc, oPlayer, oPorta)
- Se destrói após spawnar tudo

### 7. Sistema de Pausa (`oController`)

- Toggle: ESC / Start no gamepad
- `global.pausado = true` → todos os objetos de gameplay executam `exit` no início do Step
- Menu com 3 opções: Continuar, Reiniciar Fase, Voltar ao Menu
- Navegação: W/S ou D-pad, confirmação: E/Espaço/Enter ou A do gamepad
- Desenhado no `Draw_64` (Draw GUI) por cima de tudo

### 8. Chave e Portão

- `oChave`: spawna automaticamente pelo `oSpawner`; flutua; coletável com interação → `global.temChave = true`
- `oPorta`: posicionado manualmente; sprite muda entre `sPortaTrancada`/`sPortaDestrancada`
- Player e NPCs colidem com `oPorta` apenas quando `!global.temChave`

### 9. Seletor de Fases (`oSeletorDeFases`)

- Grade de cards: 3 colunas × 2 linhas por página, com paginação
- Arrays paralelos: `fase_rooms[]`, `fase_nomes[]`, `fase_subtitulos[]`
- `total_fases` calculado com `array_length(fase_rooms)`
- Navegação por teclado (WASD) ou gamepad (D-pad/analógico)

---

## 🔧 Configuração por Fase (Room Creation Code)

Cada room de gameplay define variáveis no **Room Creation Code** (roda **antes** dos Create events dos objetos):

```gml
// Exemplo — Room Creation Code de uma fase
global.comidaMax    = 5;    // meta de comida
global.comidaSpawn  = 5;    // comidas no mapa
global.npcSpawn     = 3;    // NPCs no mapa
global.tempoFomeMax = 90;   // tempo de fome (segundos)
```

| Dificuldade | comidaMax | comidaSpawn | npcSpawn | tempoFomeMax |
|---|---|---|---|---|
| Fácil | 3 | 3 | 1 | 120 |
| Média | 5 | 5 | 3 | 90 |
| Difícil | 7-10 | 7-8 | 2-3 | 60-70 |

---

## 🔄 Ordem de Execução do GameMaker

```
Room carrega
  │
  ├─ 1. Room Creation Code → globals de configuração setados
  │
  ├─ 2. Create events de todas as instâncias
  │     ├─ oController/Create → lê globals, cria mp_grid, seta pausa/vida/fome
  │     ├─ oPlayer/Create → variáveis de movimento, sprites
  │     ├─ oInimigo/Create → máquina de estados, campo de visão
  │     └─ oSpawner/Create → alarm[0] = 1
  │
  ├─ 3. Frame 1 → Alarm events
  │     └─ oSpawner/Alarm_0 → spawna comida + NPCs → instance_destroy()
  │
  └─ 4. Game loop (cada frame)
        ├─ Step events (lógica)
        ├─ Collision events
        ├─ Draw events (renderização do jogo)
        └─ Draw GUI events (HUD, menus por cima)
```

---

## 🎨 Sistema de Sprites e Direções

### Array de `face` (usado por oPlayer, oInimigo, oNpc)

| face | Direção | image_xscale |
|---|---|---|
| 0 | Lado (esquerda/direita) | 1 = direita, -1 = esquerda |
| 1 | Diagonal cima | 1 = direita-cima, -1 = esquerda-cima |
| 2 | Cima | 1 |
| 3 | Baixo (padrão inicial) | 1 |
| 4 | Diagonal baixo | 1 = direita-baixo, -1 = esquerda-baixo |

Cada objeto tem um array `sprite[]` indexado por `face`:

```gml
// oPlayer (normal)
sprite[0] = sLoboSide;    sprite[1] = sLoboDUp;     sprite[2] = sLoboUp;
sprite[3] = sLoboDown;    sprite[4] = sLoboDDown;

// oPlayer (faminto — ≤25% fome)
sprite[0] = sLoboSideHungry;  sprite[1] = sLoboDUpHungry;  sprite[2] = sLoboUpHungry;
sprite[3] = sLoboDownHungry;  sprite[4] = sLoboDDownHungry;

// oGuarda1
sprite[0] = sGuardaSide;  sprite[1] = sGuardaDUp;  sprite[2] = sGuardaUp;
sprite[3] = sGuardaDown;  sprite[4] = sGuardaDDown;

// oFreddy (sprite único para todas as direções)
sprite[0..4] = sFreddyFasbear;

// oNpc (3 direções — sem diagonal)
sprite[0] = sNpcSide;  sprite[2] = sNpcUp;  sprite[3] = sNpcDown;
```

### Profundidade

Todos os objetos de gameplay usam `depth = -y` ou `depth = -bbox_bottom` para ordenação visual (objetos mais abaixo são desenhados na frente).

---

## 📁 Estrutura de Pastas do GameMaker

```
gamemaker/LobisomenPidao_Demo/
├── LobisomenPidao_Demo.yyp          # arquivo principal do projeto
├── docs/                            # documentação e guias
├── fonts/                           # fnt_pixel
├── objects/                         # todos os objetos do jogo
│   ├── oController/                 # gerente central (vida, fome, HUD, pausa)
│   ├── oPlayer/                     # jogador
│   ├── oInimigo/                    # inimigo base (pai)
│   ├── oGuarda1/                    # filho de oInimigo
│   ├── oFreddy/                     # filho de oInimigo
│   ├── oNpc/                        # NPC interativo
│   ├── oNpc2/                       # NPC segunda skin (herda de oNpc)
│   ├── oComida/                     # comida base (pai)
│   ├── oBurger/                     # filho de oComida
│   ├── oCereja/                     # filho de oComida
│   ├── oCoxinha/                    # filho de oComida
│   ├── oChave/                      # chave coletável
│   ├── oPorta/                      # portão desbloqueável
│   ├── oSaida/                      # porta de saída da fase
│   ├── oSpawner/                    # spawner genérico
│   ├── oSpawnZone/                  # zona de spawn
│   ├── oWall/                       # parede (colisão + pathfinding)
│   ├── oSolidWall/                  # parede sólida
│   ├── oParedeFina/                 # parede fina
│   ├── oMenuPrincipal/              # menu principal
│   ├── oSeletorDeFases/             # seletor de fases
│   ├── oVitoria/                    # tela de vitória
│   ├── oGameOver/                   # tela de game over
│   └── oProcuraControle/            # detecção de gamepad (persistente)
├── rooms/                           # todas as rooms
├── scripts/                         # funções GML reutilizáveis
├── sprites/                         # assets visuais
└── tilesets/                        # tilesets para pintura de rooms
```

---

## 📝 Convenções do Projeto

| Convenção | Exemplo |
|---|---|
| Nomes de objetos | `oNomeDoObjeto` (prefixo `o`) |
| Nomes de sprites | `sNomeDoSprite` (prefixo `s`) |
| Nomes de scripts | `scr_nomeDoScript` (prefixo `scr_`) |
| Nomes de rooms (fases) | `rm_faseXX` (padrão atual, ex: `rm_fase03`). `room_01`/`room_02` são legado. |
| Nomes de rooms (menus/telas) | `rm_NomeDaRoom` (ex: `rm_MenuPrincipal`, `rm_SelecaoDeFases`, `rm_Vitoria`, `rm_gameOver`) |
| Nomes de fonts | `fnt_nome` (prefixo `fnt_`) |
| Variáveis globais | `global.nomeDaVariavel` |
| Layers obrigatórias | `instancias`, `tiles`, `colisoes`, `Background` |
| Face padrão inicial | `face = 3` (olhando para baixo) |
| Guard clause de pausa | `if (global.pausado) exit;` no início de todo Step de gameplay |

---

## 📚 Guias Existentes na Pasta `docs/`

| Arquivo | Status | Assunto |
|---|---|---|
| `DONE_GUIA_CHAVE_E_PORTAO.md` | ✅ Implementado | Mecânica de chave + portão desbloqueável |
| `DONE_GUIA_COLISAO_E_VISAO_INIMIGO.md` | ✅ Implementado | Correção de colisões + bug do campo de visão |
| `DONE_GUIA_DESBLOQUEIO_DE_FASES.md` | ✅ Implementado | Progressão: desbloqueio de fases ao vencer |
| `DONE_GUIA_INVESTIGACAO_INIMIGO.md` | ✅ Implementado | Estado de investigação do inimigo |
| `DONE_GUIA_LOBO_MENU_REATIVO.md` | ✅ Implementado | Mascote reativo no menu principal (`oLoboMenu` + state machine) |
| `DONE_GUIA_MENU_PRINCIPAL.md` | ✅ Implementado | Menu principal |
| `DONE_GUIA_SPAWNER_GENERICO.md` | ✅ Implementado | Spawner genérico + configuração por fase |
| `DONE_GUIA_TELA_DE_PAUSA.md` | ✅ Implementado | Sistema de pausa + botões vitória/game over |
| `GUIA_AUDIO_E_MUSICA.md` | 📋 Guia | BGM (oMusicManager) + SFX inline + persistência de volume |
| `GUIA_CHAVES_COLORIDAS.md` | 📋 Guia | N chaves de cores diferentes (struct genérico) |
| `GUIA_CRIACAO_DE_FASES.md` | 📋 Guia | Passo a passo para criar novas fases |
| `GUIA_FASE_TUTORIAL.md` | 📋 Guia | Implementação da fase tutorial |
| `GUIA_NPC_IDLE.md` | 📋 Guia | Sprites idle animados no oNpc e oNpc2 |
| `GUIA_SETTINGS_EXTRA.md` | 📋 Guia | Fullscreen + Mostrar FPS + Idioma PT/EN |
| `GUIA_SISTEMA_DE_ESTRELAS.md` | 📋 Guia | Pontuação por estrelas (1-3) na vitória |
| `GUIA_VITORIA_E_SETTINGS.md` | 📋 Guia | Botão "Próxima Fase" + tela de Settings base |

> **Dica:** Arquivos com prefixo `DONE_` já foram implementados no código. Os demais são guias de implementação futura.

---

## ⚠️ Bugs Conhecidos / Pontos de Atenção

1. **Tecla de debug** — `oController/Step_0.gml` (linha 61) ainda tem `if keyboard_check_pressed(ord("I")) global.comida += 1;` que deve ser removido antes da entrega final.

> Os bugs anteriores ("campo de visão infinito", "colisões do inimigo incompletas" e "mockups no seletor") já foram **corrigidos** — guias `DONE_GUIA_COLISAO_E_VISAO_INIMIGO.md` e `DONE_GUIA_DESBLOQUEIO_DE_FASES.md` documentam as correções.

# 🗺️ Guia de Criação de Fases

> Guia passo a passo para criar uma nova fase do início ao fim. Cobre desde a criação da room no GameMaker até o registro no seletor de fases.

---

## 📌 Contexto do Projeto

| Item | Valor |
|---|---|
| Tamanho da room base | 640×360 (room_01) — escalável |
| Viewport | 320×180 seguindo o `oPlayer` |
| Porta de saída | 1920×1080 (wport × hport) |
| Tile size | 16×16 |
| Grid de pathfinding | 4×4 px |
| Layers da room | `instancias`, `tiles`, `colisoes`, `Background` |

---

## 🏗️ Passo a Passo

### Passo 1: Criar a Room no GameMaker

1. No Asset Browser, clique com botão direito em **Rooms** → **Create Room**
2. Nomeie como `room_03` (ou o número da sua fase)
3. Configure as **Room Settings** (no painel à esquerda):
   - **Width**: `640` (ou maior se quiser mapa grande — múltiplo de 16)
   - **Height**: `360` (ou maior — múltiplo de 16)
   - **Persistent**: `false`

### Passo 2: Configurar a Câmera (View)

1. No painel da room, vá em **Viewports and Cameras**
2. Marque **Enable Viewports**
3. Na **Viewport 0**:
   - Marque **Visible**
   - **Camera Properties:**
     - X View: `0`, Y View: `0`
     - W View: `320`, H View: `180`
   - **Viewport Properties (porta de saída):**
     - X Port: `0`, Y Port: `0`
     - W Port: `1920`, H Port: `1080`
   - **Object Following:** selecione `oPlayer`
     - Hborder: `128`, Vborder: `64`
     - Hspeed: `-1`, Vspeed: `-1`

> **Por que 320×180?** É a resolução interna do jogo. O viewport de 1920×1080 estica a imagem para a tela — isso dá o visual pixel art escalado.

### Passo 3: Criar as Layers

Crie as layers na ordem correta (de cima para baixo = menor profundidade primeiro):

| Layer | Tipo | Profundidade | Uso |
|---|---|---|---|
| `instancias` | Instance Layer | 0 | Player, oController, oSpawner, oSaida, oInimigo |
| `tiles` | Tile Layer | 100 | Tilemap visual (chão, paredes decorativas) |
| `colisoes` | Instance Layer | 200 | oWall, oSolidWall, oParedeFina (colisão invisível) |
| `Background` | Background Layer | 300 | Cor de fundo ou sprite de fundo |

> **Importante:** Os nomes das layers devem ser **exatamente** esses — o oSpawner usa `layer` para criar instâncias na mesma layer que ele, que é a `instancias`.

### Passo 4: Pintar o Tilemap

1. Selecione a layer `tiles`
2. No painel de tiles, selecione seu tileset (ex: `tsTileset`)
3. Pinte o chão e as paredes visuais

> As tiles são apenas **visuais** — a colisão real é feita pelos objetos na layer `colisoes`.

### Passo 5: Colocar os Objetos de Colisão

Na layer `colisoes`, posicione os objetos invisíveis de colisão para definir onde o player não pode andar:

| Objeto | Uso |
|---|---|
| `oWall` | Parede normal — bloqueia player e entra no pathfinding grid (usado pela IA de inimigos) |
| `oSolidWall` | Parede sólida — igual ao oWall mas para bordas externas do mapa |
| `oParedeFina` | Parede fina — bloqueia passagem mas não ocupa tile inteiro |

> **Dica:** Coloque `oWall` cobrindo todas as áreas onde as tiles parecem paredes. A layer `colisoes` pode ficar invisível no editor (clique no olho 👁️ da layer).

### Passo 6: Colocar os Objetos de Gameplay

Na layer `instancias`, posicione os objetos obrigatórios:

#### Obrigatórios (toda fase precisa)

| Objeto | Qtd | Onde colocar | Função |
|---|---|---|---|
| `oController` | **1** | Qualquer lugar (canto da room) | Gerencia vida, fome, HUD, pausa, pathfinding |
| `oPlayer` | **1** | Posição inicial do jogador | O player — a câmera segue ele |
| `oSaida` | **1** | Final da fase (porta/saída) | Porta que abre quando coleta toda a comida |
| `oSpawner` | **1** | Qualquer lugar (canto da room) | Spawna comida e NPCs automaticamente nas SpawnZones |
| `oSpawnZone` | **1+** | Áreas abertas do mapa | Define onde a comida e NPCs podem aparecer |

#### Opcionais (posicione manualmente)

| Objeto | Descrição |
|---|---|
| `oInimigo` | Posicione manualmente onde quer guardas/inimigos fixos |
| `oGuarda1` | Variante de inimigo — posicione manualmente |

> **Comida e NPCs NÃO são colocados manualmente** — o `oSpawner` cuida disso automaticamente usando as `oSpawnZone`.

### Passo 7: Posicionar as SpawnZones

As `oSpawnZone` são retângulos invisíveis que definem **onde** a comida e NPCs podem spawnar:

1. Na layer `instancias`, coloque objetos `oSpawnZone`
2. **Redimensione** cada um para cobrir as áreas abertas (sem paredes)
3. Evite cobrir corredores estreitos ou áreas perto da saída
4. Use **múltiplas** SpawnZones para espalhar os spawns pelo mapa

```
┌─────────────────────────────────────┐
│  ██████                    ██████   │
│  ██████  ┌────────────┐   ██████   │  ██ = paredes
│          │ SpawnZone 1 │            │
│          └────────────┘    ████    │
│  ████                      ████    │
│  ████    ┌─────────┐              │
│          │SpawnZone2│    ☆ saída   │
│  P       └─────────┘              │  P = player
│  ████████████████████████████████   │
└─────────────────────────────────────┘
```

### Passo 8: Criar o Room Creation Code

1. No editor da room, clique em **Room Properties** (ou vá em Room → Settings)
2. Encontre o campo **Creation Code** e clique para editar
3. Cole o código de configuração da fase:

```gml
// === CONFIG DA FASE 3 ===
global.comidaMax    = 7;    // quantas comidas o player precisa coletar para abrir a saída
global.comidaSpawn  = 7;    // quantas comidas o spawner vai criar no mapa
global.npcSpawn     = 3;    // quantos NPCs o spawner vai criar
global.tempoFomeMax = 80;   // tempo de fome em segundos (menor = mais difícil)
```

> **Se não criar Room Creation Code**, o oController usa os valores padrão: comidaMax=5, comidaSpawn=5, npcSpawn=2, tempoFomeMax=90.

#### Referência de dificuldade

| Dificuldade | comidaMax | comidaSpawn | npcSpawn | tempoFomeMax |
|---|---|---|---|---|
| Fácil (tutorial) | 3 | 3 | 1 | 120 |
| Média | 5 | 5 | 3 | 90 |
| Difícil | 7-10 | 7-8 | 2-3 | 60-70 |
| Caótica | 7+ | 10+ | 5+ | 45 |

---

## 📋 Registrar a Fase no Seletor

### Modificar `oSeletorDeFases/Create_0.gml`

Adicione a nova room nos 3 arrays — **na mesma posição** (índice):

```gml
fase_rooms = [
    room_01,
    room_02,
    room_03,     // ← ADICIONAR
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset",
    "Nome da Fase 3",     // ← ADICIONAR
];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
    "Subtítulo da fase 3",     // ← ADICIONAR
];
```

**Pronto!** O seletor calcula `total_fases` automaticamente com `array_length()`, a grade se ajusta, e a navegação funciona.

> Se implementou o desbloqueio de fases (GUIA_DESBLOQUEIO_DE_FASES.md), lembre de atualizar o valor máximo de `global.fase_desbloqueada` se necessário.

---

## 🔄 Fluxo Completo (o que acontece quando o jogador entra na fase)

```
rm_SelecaoDeFases
  │  jogador confirma fase 3
  ▼
room_03 inicia
  │
  ├─ Room Creation Code roda PRIMEIRO:
  │   global.comidaMax    = 7
  │   global.comidaSpawn  = 7
  │   global.npcSpawn     = 3
  │   global.tempoFomeMax = 80
  │
  ├─ oController/Create_0 roda:
  │   lê global.comidaMax (meta = 7)
  │   tempoFome = global.tempoFomeMax (80)
  │   cria pathfinding grid (mp_grid)
  │   salva global.fase_room_atual = room
  │
  ├─ oSpawner/Create_0 roda:
  │   alarm[0] = 1  (dispara no próximo frame)
  │
  ├─ oSpawner/Alarm_0 roda (1 frame depois):
  │   spawna 7 comidas (oBurger/oPunk) nas SpawnZones
  │   spawna 3 oNpc nas SpawnZones
  │   oSpawner se destrói
  │
  ├─ GAMEPLAY:
  │   oPlayer se move, coleta comida
  │   tempoFome diminui → fome 0 = game over
  │   oInimigo patrulha → dano no player
  │   oNpc interage → pode dar/tirar comida
  │   global.comida == global.comidaMax → oSaida abre
  │
  ├─ SAÍDA (jogador entra na oSaida aberta):
  │   room_goto(rm_Vitoria)
  │
  ├─ GAME OVER (vida ou fome = 0):
  │   global.motivoMorte = "dano" ou "fome"
  │   room_goto(rm_gameOver)
  │
  ▼
rm_Vitoria ou rm_gameOver
  │  Reiniciar Fase → room_goto(global.fase_room_atual)
  │  Sair → room_goto(rm_SelecaoDeFases)
  ▼
volta ao seletor ou reinicia
```

---

## ✅ Checklist Rápida

Use esta checklist ao criar cada nova fase:

- [ ] Room criada com tamanho múltiplo de 16
- [ ] Viewport 0 configurada (320×180 view, 1920×1080 port, seguindo oPlayer)
- [ ] 4 layers criadas: `instancias`, `tiles`, `colisoes`, `Background`
- [ ] Tilemap pintado na layer `tiles`
- [ ] Objetos de colisão na layer `colisoes` (oWall, oSolidWall)
- [ ] oController colocado na layer `instancias` (1 por room)
- [ ] oPlayer colocado na posição inicial
- [ ] oSaida colocada no final/saída da fase
- [ ] oSpawner colocado (1 por room)
- [ ] oSpawnZone(s) cobrindo áreas abertas
- [ ] oInimigo posicionado manualmente (se quiser)
- [ ] Room Creation Code com comidaMax, comidaSpawn, npcSpawn, tempoFomeMax
- [ ] Room adicionada nos 3 arrays do oSeletorDeFases/Create_0.gml
- [ ] Testar: comida spawna, saída abre, game over funciona, vitória funciona

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Comida/NPC não spawna | Faltou oSpawner ou oSpawnZone | Verificar se ambos estão na layer `instancias` |
| Player não aparece | Faltou oPlayer na room | Colocar na layer `instancias` |
| Player atravessa paredes | Faltou oWall na layer `colisoes` | Pintar colisão invisível sobre as tiles de parede |
| Inimigo fica parado | oController não criou o pathfinding grid | Verificar se oController existe na room |
| Câmera não segue player | View mal configurada | Checar Viewport 0: Object Following = oPlayer |
| HUD não aparece | oController ausente ou em layer errada | Deve estar na layer `instancias` |
| Fase não aparece no seletor | Faltou adicionar nos arrays | Adicionar nos 3 arrays: fase_rooms, fase_nomes, fase_subtitulos |
| Valores padrão em vez dos customizados | Sem Room Creation Code | Criar o Room Creation Code da room |
| Spawn em cima de parede | SpawnZone cobre área com oWall | Redimensionar SpawnZone para evitar paredes |

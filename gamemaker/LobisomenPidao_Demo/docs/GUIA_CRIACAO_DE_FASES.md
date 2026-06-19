# 🗺️ Guia de Criação de Fases

> Guia passo a passo para criar uma nova fase do início ao fim. Cobre desde a criação da room no GameMaker até o registro no seletor de fases.

---

## 📌 Contexto do Projeto

| Item | Valor |
|---|---|
| Tamanho da room base | 640×320 (`room_01`/`room_02`) — escalável (`rm_fase03` usa 640×640) |
| Viewport (view interno) | 320×180 seguindo o `oPlayer` |
| Porta de saída | 1920×1080 (wport × hport) |
| Tile size | 16×16 |
| Grid de pathfinding (`mp_grid`) | 16×16 px (`oController` cria com `mp_grid_create(0,0,rw/16,rh/16,16,16)`) |
| Layers da room | `instancias`, `tiles`, `colisoes`, `Background` |
| Convenção de nome de room | `rm_faseXX` para fases novas (`room_01`/`room_02` são legado) |

---

## 🏗️ Passo a Passo

### Passo 1: Criar a Room no GameMaker

1. No Asset Browser, clique com botão direito em **Rooms** → **Create Room**
2. Nomeie como `rm_faseXX` (ex: `rm_fase04`, `rm_fase05`) — esse é o padrão atual do projeto
3. Configure as **Room Settings** (no painel à esquerda):
   - **Width**: `640` (ou maior se quiser mapa grande — múltiplo de 16)
   - **Height**: `320` ou `640` (ou maior — múltiplo de 16)
   - **Persistent**: `false`

> **Nomenclatura:** `room_01` e `room_02` existem por motivos históricos. Fases novas devem usar o prefixo `rm_faseXX`, alinhado com o padrão geral do projeto (`rm_MenuPrincipal`, `rm_SelecaoDeFases`, `rm_Vitoria`, `rm_gameOver`, `rm_fase03`).

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
| `instancias` | Instance Layer | 0 | Player, oController, oSpawner, oSaida, oInimigo, oChave, oPorta |
| `tiles` | Tile Layer | 100 | Tilemap visual (chão, paredes decorativas) |
| `colisoes` | Instance Layer | 200 | oWall, oSolidWall, oParedeFina (colisão invisível) |
| `Background` | Background Layer | 300 | Cor de fundo ou sprite de fundo |

> **Importante:** Os nomes das layers devem ser **exatamente** esses — o `oSpawner` usa a variável `layer` (built-in da instância) para criar comida/NPCs na mesma layer em que ele foi posto, que é a `instancias`.

> **Nota de inconsistência:** `rm_fase03` usa o nome `tileset` em vez de `tiles` para a layer de tiles. Tecnicamente funciona (o `oSpawner` não depende desse nome), mas para novas fases use `tiles` para manter coerência com `room_01`/`room_02`.

### Passo 4: Pintar o Tilemap

1. Selecione a layer `tiles`
2. No painel de tiles, selecione seu tileset (ex: `tsTileset`)
3. Pinte o chão e as paredes visuais

> As tiles são apenas **visuais** — a colisão real é feita pelos objetos na layer `colisoes`.

### Passo 5: Colocar os Objetos de Colisão

Na layer `colisoes`, posicione os objetos invisíveis de colisão para definir onde o player não pode andar:

| Objeto | Uso | Entra no pathfinding (`mp_grid`)? |
|---|---|---|
| `oWall` | Parede normal — bloqueia player e inimigos | ✅ Sim |
| `oSolidWall` | Parede sólida — bordas externas do mapa | ❌ Não |
| `oParedeFina` | Parede fina — bloqueia passagem mas não ocupa tile inteiro | ❌ Não |

> **Atenção ao pathfinding:** o `oController/Create` só adiciona `oWall` (e `oSaida`) ao `mp_grid` via `mp_grid_add_instances`. Se você usar apenas `oSolidWall` ou `oParedeFina` para fechar um corredor, os **inimigos podem tentar atravessá-lo** porque essas paredes não existem no grid de pathfinding. Para corredores onde inimigos vão passar, use `oWall`.

> **Dica:** Coloque `oWall` cobrindo todas as áreas onde as tiles parecem paredes. A layer `colisoes` pode ficar invisível no editor (clique no olho 👁️ da layer).

### Passo 6: Colocar os Objetos de Gameplay

Na layer `instancias`, posicione os objetos obrigatórios:

#### Obrigatórios (toda fase precisa)

| Objeto | Qtd | Onde colocar | Função |
|---|---|---|---|
| `oController` | **1** | Qualquer lugar (canto da room) | Gerencia vida, fome, HUD, pausa, pathfinding |
| `oPlayer` | **1** | Posição inicial do jogador | O player — a câmera segue ele |
| `oSaida` | **1** | Final da fase (porta/saída) | Porta que abre quando coleta toda a comida |

#### Comida e NPCs — dois modos

**Modo A: Automático (recomendado para mapas grandes)** — usa o `oSpawner` para distribuir comida/NPCs aleatoriamente:

| Objeto | Qtd | Onde colocar | Função |
|---|---|---|---|
| `oSpawner` | **1** | Qualquer lugar (canto da room) | Spawna comida e NPCs nas SpawnZones |
| `oSpawnZone` | **1+** | Áreas abertas do mapa | Define onde a comida e NPCs podem aparecer |

O `oSpawner` cria automaticamente:
- **Comida:** sorteia entre `oBurger`, `oCereja`, `oCoxinha` (filhos de `oComida`)
- **NPCs:** sorteia entre `oNpc` e `oNpc2`
- Quantidade controlada por `global.comidaSpawn` e `global.npcSpawn` (Passo 9)

**Modo B: Manual** — coloque cada comida/NPC à mão na layer `instancias` (exemplo: `room_02` faz isso):

| Objeto | Função |
|---|---|
| `oBurger`, `oCereja`, `oCoxinha` | Comida posicionada manualmente |
| `oNpc`, `oNpc2` | NPCs posicionados manualmente |

> **⚠️ Não misture os dois modos** na mesma fase — se colocar `oSpawner` + comida manual, a fase fica com comida duplicada (e provavelmente `global.comidaMax` desalinhado). Escolha um.

#### Opcionais (sempre manuais)

| Objeto | Descrição |
|---|---|
| `oInimigo` | **Objeto pai** — normalmente não use direto |
| `oGuarda1` | Filho de `oInimigo` — guarda padrão; posicione onde quiser patrulhamento |
| `oFreddy` | Filho de `oInimigo` — variante visual |
| `oChave` + `oPorta` | Mecânica de chave/portão interno (ver Passo 8) |

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

### Passo 8: (Opcional) Chave e Portão

Se a fase precisa de uma **chave coletável** que destranca um **portão interno** (mecânica usada em `rm_fase03`), siga este passo. Senão, pule para o Passo 9.

#### Como funciona

- `global.temChave` é o estado da chave na run atual — `oController/Create` já inicializa em `false` automaticamente
- `oChave` é o item coletável — quando o player interage, seta `global.temChave = true`
- `oPorta` é o portão — `oPorta/Step` alterna entre `sPortaTrancada` (bloqueia) e `sPortaDestrancada` (passa) baseado em `global.temChave`
- `oPlayer` e `oNpc` colidem com `oPorta` apenas enquanto `global.temChave == false`

> **Não existe flag de configuração por fase.** Basta posicionar (ou não) `oChave` e `oPorta` na room — se a fase não tem chave/portão, a variável `global.temChave` simplesmente fica `false` sem efeito.

#### Posicionamento manual (modelo de `rm_fase03`)

Na layer `instancias`, posicione **manualmente**:

| Objeto | Qtd | Onde colocar |
|---|---|---|
| `oChave` | 1 | Antes do portão no percurso, em uma área acessível desde o início |
| `oPorta` | 1+ | Bloqueando um corredor que leva a uma área obrigatória (ex: parte do mapa onde tem comida) |

> **Importante:** A `oChave` deve ser acessível **sem** precisar passar pelo `oPorta`, senão a fase fica impossível.

> **Spawn automático:** existe uma proposta em `DONE_GUIA_CHAVE_E_PORTAO.md` para o `oSpawner` criar a chave automaticamente nas `oSpawnZone`, mas **essa integração não está implementada no código** — `oSpawner` não cria `oChave`. Posicione `oChave` e `oPorta` à mão no Room Editor.

### Passo 9: Criar o Room Creation Code

1. No editor da room, clique em **Room Properties** (ou vá em Room → Settings)
2. Encontre o campo **Creation Code** e clique para editar
3. Cole o código de configuração da fase:

```gml
// === CONFIG DA FASE rm_faseXX ===
global.comidaMax    = 7;    // meta de comida para vencer a fase
global.comidaSpawn  = 7;    // quantas comidas o spawner vai criar no mapa
global.npcSpawn     = 3;    // quantos NPCs o spawner vai criar
global.tempoFomeMax = 80;   // tempo máximo de fome (em segundos) — menor = mais difícil
```

> **Se não criar Room Creation Code**, o `oController` usa os valores padrão: `comidaMax=5`, `comidaSpawn=5`, `npcSpawn=2`, `tempoFomeMax=90`.

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
    rm_fase03,
    rm_faseXX,     // ← ADICIONAR (siga o padrão rm_faseXX)
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset",
    "Fase nova",
    "Nome da fase XX",     // ← ADICIONAR
];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
    "Faso nova",
    "Subtítulo da fase XX",     // ← ADICIONAR
];
```

**Pronto!** O seletor calcula `total_fases` automaticamente com `array_length()`, a grade se ajusta, e a navegação funciona.

> Se implementou o desbloqueio de fases (GUIA_DESBLOQUEIO_DE_FASES.md), lembre de atualizar o valor máximo de `global.fase_desbloqueada` se necessário.

---

## 🔄 Fluxo Completo (o que acontece quando o jogador entra na fase)

```
rm_SelecaoDeFases
  │  jogador confirma fase rm_faseXX
  ▼
rm_faseXX inicia
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
  │   global.temChave = false
  │   cria pathfinding grid (mp_grid 16×16) com oWall + oSaida
  │   salva global.fase_room_atual = room
  │
  ├─ oSpawner/Create_0 roda (se houver):
  │   alarm[0] = 1  (dispara no próximo frame)
  │
  ├─ oSpawner/Alarm_0 roda (1 frame depois):
  │   spawna global.comidaSpawn comidas (oBurger / oCereja / oCoxinha) nas SpawnZones
  │   spawna global.npcSpawn NPCs (oNpc / oNpc2) nas SpawnZones
  │   oSpawner se destrói
  │
  ├─ GAMEPLAY:
  │   oPlayer se move, coleta comida
  │   tempoFome diminui → fome 0 = game over
  │   oInimigo (oGuarda1/oFreddy) patrulha → dano no player
  │   oNpc interage → pode dar/tirar comida
  │   se a fase tem oChave/oPorta: ao coletar oChave → global.temChave = true → oPorta abre
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

- [ ] Room criada como `rm_faseXX` com tamanho múltiplo de 16
- [ ] Viewport 0 configurada (320×180 view, 1920×1080 port, seguindo `oPlayer`)
- [ ] 4 layers criadas: `instancias`, `tiles`, `colisoes`, `Background`
- [ ] Tilemap pintado na layer `tiles` (ou `tileset` — manter um padrão)
- [ ] Objetos de colisão na layer `colisoes` — usar `oWall` em corredores onde inimigos vão passar (entra no pathfinding); `oSolidWall`/`oParedeFina` para o resto
- [ ] `oController` colocado na layer `instancias` (1 por room)
- [ ] `oPlayer` colocado na posição inicial (1 só — não duplicar)
- [ ] `oSaida` colocada no final/saída da fase
- [ ] **Modo A:** `oSpawner` (1) + `oSpawnZone(s)` cobrindo áreas abertas — OU **Modo B:** comida (`oBurger`/`oCereja`/`oCoxinha`) e NPCs (`oNpc`/`oNpc2`) posicionados manualmente
- [ ] `oGuarda1`/`oFreddy` posicionados manualmente (se quiser inimigos)
- [ ] (Opcional) `oChave` + `oPorta` posicionados manualmente se a fase usa chave
- [ ] Room Creation Code com `comidaMax`, `comidaSpawn`, `npcSpawn`, `tempoFomeMax`
- [ ] Room adicionada nos 3 arrays do `oSeletorDeFases/Create_0.gml`
- [ ] Testar: comida spawna/coleta, saída abre, game over (vida e fome) funciona, vitória funciona, chave/portão funcionam (se aplicável)

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Comida/NPC não spawna | Faltou `oSpawner` ou `oSpawnZone` | Verificar se ambos estão na layer `instancias` (Modo A); ou colocar manualmente (Modo B) |
| Comida duplicada / `comidaMax` errado | Misturou `oSpawner` com comida manual | Escolher um modo só — remover o outro |
| Player não aparece | Faltou `oPlayer` na room | Colocar na layer `instancias` |
| Player atravessa paredes | Faltou `oWall`/`oSolidWall`/`oParedeFina` na layer `colisoes` | Pintar colisão invisível sobre as tiles de parede |
| Inimigo atravessa parede ou fica parado | A parede do corredor é `oSolidWall`/`oParedeFina` (não entra no pathfinding) | Trocar por `oWall` nas paredes que afetam patrulhamento; ou verificar se `oController` existe |
| Câmera não segue player | View mal configurada | Checar Viewport 0: Object Following = `oPlayer` |
| HUD não aparece | `oController` ausente ou em layer errada | Deve estar na layer `instancias` |
| Fase não aparece no seletor | Faltou adicionar nos arrays | Adicionar nos 3 arrays: `fase_rooms`, `fase_nomes`, `fase_subtitulos` |
| Valores padrão em vez dos customizados | Sem Room Creation Code | Criar o Room Creation Code da room |
| Spawn em cima de parede | `oSpawnZone` cobre área com `oWall` | Redimensionar `oSpawnZone` para evitar paredes |
| Portão (`oPorta`) nunca abre | `oChave` não foi posicionada, ou está atrás do próprio portão | Posicionar `oChave` em área acessível **antes** do portão no percurso |
| `oPorta` aberto desde o início | Ficou de uma fase anterior — `global.temChave` não resetou | Reiniciar a room (`oController/Create` reseta para `false`) |

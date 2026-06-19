# 🔑 Guia de Implementação — Chave + Portão

> Guia completo para adicionar a mecânica de **chave coletável** que desbloqueia um **portão interno** da fase, bloqueando acesso a uma área obrigatória do mapa.

---

> ⚠️ **Estado de implementação (junho/2025):** Apenas a mecânica básica está no código — `oChave`, `oPorta` e `global.temChave` funcionam, mas a **integração com `oSpawner` via `global.faseTemChave` NÃO foi implementada**. Nenhum objeto/script lê `global.faseTemChave`. Para usar a mecânica hoje (como `rm_fase03` faz), basta **posicionar `oChave` e `oPorta` manualmente** no Room Editor — ignore as seções deste guia que descrevem `global.faseTemChave` e a modificação no `oSpawner/Alarm_0`.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Resolução | 1920×1080 |
| Paleta de cores | Navy escuro `rgb(14,14,26)` + Teal `rgb(80,200,210)` |
| Fonte | `fnt_pixel` |
| Objetos de referência | `oComida` (coleta), `oSaida` (porta condicional), `oSpawner` (spawn dinâmico) |
| Sprites existentes de porta | `sPortaAberta` / `sPortaFechada` (usados pela saída — **NÃO reutilizar**) |
| Sprites novos necessários | `sChave`, `sPortaoFechado`, `sPortaoAberto` |

---

## 🏗️ Estrutura Geral

### Como funciona

1. **`global.temChave`** — booleano que indica se o player já pegou a chave (começa `false`)
2. A **chave** é spawnada pelo `oSpawner` em uma posição aleatória dentro das `oSpawnZone`
3. O **portão** (`oPortao`) é posicionado manualmente no Room Editor, bloqueando a passagem para uma área do mapa
4. Ao coletar a chave, `global.temChave = true` → o portão abre (muda sprite e libera passagem)
5. A área atrás do portão contém comida necessária para completar a fase (sem chave = impossível vencer)
6. Configurável por fase via Room Creation Code: `global.faseTemChave = true/false`

### Fluxo

```
Room carrega
  │
  ├─ Room Creation Code → global.faseTemChave = true
  │
  ├─ oController/Create → global.temChave = false
  │
  ├─ oSpawner/Alarm_0 → se faseTemChave, cria 1 oChave nas zonas de spawn
  │
  └─ Gameplay
       │
       ├─ Player encontra oChave → interage (E/Space/A)
       │     └─ global.temChave = true → chave some
       │
       ├─ oPortao detecta global.temChave
       │     ├─ false → sPortaoFechado (sólido, bloqueia passagem)
       │     └─ true  → sPortaoAberto  (player passa)
       │
       ├─ Player acessa área trancada → coleta comida restante
       │
       └─ global.comidaCheia = true → oSaida abre → vitória
```

---

## 🎨 Sprites Necessários (Criar no GameMaker)

Antes de começar o código, crie estes sprites:

| Sprite | Tamanho sugerido | Descrição |
|---|---|---|
| `sChave` | 16×16 ou 32×32 | Chave dourada/prateada, item coletável |
| `sPortaoFechado` | Mesmo tamanho das paredes (ex: 32×32 ou 64×64) | Portão/grade trancado |
| `sPortaoAberto` | Mesmo tamanho de `sPortaoFechado` | Portão aberto/sem grade |

> **Dica:** O `sPortaoFechado` pode ser uma grade com cadeado. O `sPortaoAberto` pode ser a mesma grade sem o cadeado ou um espaço vazio. Mantenha a origin no **centro** para os dois sprites do portão.

> **Dica:** O `sChave` pode ter a origin no **centro** para a animação de flutuação funcionar bem (igual à comida).

---

## 🔑 Parte 1 — oChave (Novo Objeto)

### Passo 1.1 — Criar o objeto

No GameMaker: **Assets → Create → Object** → nome: `oChave`, sprite: `sChave`.

### Passo 1.2 — Create Event

**`objects/oChave/Create_0.gml`:**

```gml
base_y = y;
```

> Salva a posição Y original para a animação de flutuação (mesmo padrão do `oComida`).

### Passo 1.3 — Step Event

**`objects/oChave/Step_0.gml`:**

```gml
// Pausar
if (global.pausado) exit;

// Profundidade baseada em Y
depth = -bbox_bottom;

// Distância até o player
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

// Animação de flutuação (sobe e desce suavemente)
y = base_y + sin(current_time / 200) * 1.5;
depth = -y;

// Coleta: perto + botão de interação + sem parede entre os dois
if (_dist < 16 && oController.interagir
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
{
    global.temChave = true;
    instance_destroy();
}
```

> O código é praticamente idêntico ao `oComida/Step_0.gml`. A diferença é que em vez de somar `global.comida`, seta `global.temChave = true`.

### Passo 1.4 — Draw Event

**`objects/oChave/Draw_0.gml`:**

```gml
// Desenha o sprite da chave
draw_self();

// Indicador "!" quando o player está perto
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

if (_dist < 16)
{
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_yellow);
    draw_text_transformed(x + 0.5, y - 20, "!", 0.35, 0.35, 0);
}
```

> Usa `c_yellow` em vez de `c_white` (diferencia visualmente da comida). Pode trocar para a cor que preferir.

---

## 🚪 Parte 2 — oPortao (Novo Objeto)

### Passo 2.1 — Criar o objeto

No GameMaker: **Assets → Create → Object** → nome: `oPortao`, sprite: `sPortaoFechado`.

> **Importante:** Marque a caixa **"Solid"** no objeto? **NÃO.** Vamos controlar a colisão manualmente no `oPlayer`, como já é feito com `oSaida` e `oWall`.

### Passo 2.2 — Step Event

**`objects/oPortao/Step_0.gml`:**

```gml
// Pausar
if (global.pausado) exit;

// Muda sprite baseado na chave
if (global.temChave) {
    sprite_index = sPortaoAberto;
} else {
    sprite_index = sPortaoFechado;
}
```

> Mesma lógica do `oSaida/Step_0.gml` que troca entre `sPortaFechada` e `sPortaAberta` baseado em `global.comidaCheia`.

---

## 🎮 Parte 3 — oController (Modificações)

### Passo 3.1 — Create Event (adicionar variável)

**`objects/oController/Create_0.gml`** — adicionar **depois** da linha `global.comidaCheia = false;`:

```gml
// ADICIONAR — chave
global.temChave = false;
```

O trecho completo fica assim:

```gml
// inventário
global.comida = 0;
if (!variable_global_exists("comidaMax"))    global.comidaMax    = 5;
if (!variable_global_exists("comidaSpawn"))  global.comidaSpawn  = 5;
if (!variable_global_exists("npcSpawn"))     global.npcSpawn     = 2;
if (!variable_global_exists("tempoFomeMax")) global.tempoFomeMax = 90;
global.comidaCheia = false;

// chave
global.temChave = false;
```

### Passo 3.2 — Draw 64 (HUD — ícone da chave)

**`objects/oController/Draw_64.gml`** — adicionar **antes** do bloco `//menu pausa`:

```gml
// HUD da chave (só mostra se a fase usa chave)
if (variable_global_exists("faseTemChave") && global.faseTemChave) {
    var _chave_x = 30;
    var _chave_y = 140;  // abaixo dos outros indicadores do HUD

    if (global.temChave) {
        // Chave coletada — ícone brilhante
        draw_sprite_ext(sChave, 0, _chave_x, _chave_y, 2, 2, 0, c_white, 1.0);
    } else {
        // Chave não coletada — ícone escuro/transparente
        draw_sprite_ext(sChave, 0, _chave_x, _chave_y, 2, 2, 0, c_dkgray, 0.4);
    }
}
```

> **Posição Y = 140** é uma sugestão — ajuste para ficar abaixo dos indicadores de vida, fome e comida que já existem. O `draw_sprite_ext` com escala `2` dobra o tamanho do sprite para ficar legível na HUD.

> O `variable_global_exists("faseTemChave")` protege contra fases que não definem essa variável (não mostra o ícone se a fase não usa chave).

---

## 🐺 Parte 4 — oPlayer (Colisão com Portão)

### Passo 4.1 — Step Event (bloquear movimento)

**`objects/oPlayer/Step_0.gml`** — na região de movimento (`#region` / `#endregion`), logo **depois** das checagens de colisão com `oWall` e `oNpc`, adicionar a colisão com `oPortao`:

```gml
// Colisões existentes (já estão no código):
if place_meeting(x + xspd, y, oWall) xspd = 0;
if place_meeting(x + xspd, y, oNpc)  xspd = 0;

if place_meeting(x, y + yspd, oWall) yspd = 0;
if place_meeting(x, y + yspd, oNpc)  yspd = 0;

// ADICIONAR — colisão com portão (só bloqueia se NÃO tem a chave)
if (!global.temChave) {
    if place_meeting(x + xspd, y, oPortao) xspd = 0;
    if place_meeting(x, y + yspd, oPortao) yspd = 0;
}
```

> Quando `global.temChave = true`, o player passa direto pelo portão (ele já mudou de sprite para `sPortaoAberto` visualmente).

---

## 🔄 Parte 5 — oSpawner (Adicionar Chave ao Spawn)

### Passo 5.1 — Modificar o Alarm 0

**`objects/oSpawner/Alarm_0.gml`** — adicionar `oChave` ao array `_config`, **condicionado** a `global.faseTemChave`:

```gml
// ANTES (código atual):
var _config = [
    [global.comidaSpawn,  [oBurger, oPunk]],
    [global.npcSpawn,     [oNpc]],
];

// DEPOIS (com chave):
var _config = [
    [global.comidaSpawn,  [oBurger, oPunk]],
    [global.npcSpawn,     [oNpc]],
];

// Adiciona chave ao spawn se a fase usa chave
if (variable_global_exists("faseTemChave") && global.faseTemChave) {
    array_push(_config, [1, [oChave]]);
}
```

> Sempre spawna **exatamente 1 chave**. O `variable_global_exists` protege fases que não definem a variável.

### Passo 5.2 — Adicionar oPortao às checagens de colisão

No mesmo arquivo, dentro do loop de validação de posição, adicionar `oPortao` para evitar que itens spawnem dentro do portão:

```gml
// ANTES:
if (!collision_rectangle(_x1, _y1, _x2, _y2, oWall,      false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oSolidWall, false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oParedeFina,false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oSaida,     false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oComida,    false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oNpc,       false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oPlayer,    false, true)) {

// DEPOIS (adicionar oPortao):
if (!collision_rectangle(_x1, _y1, _x2, _y2, oWall,      false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oSolidWall, false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oParedeFina,false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oSaida,     false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oComida,    false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oNpc,       false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oPlayer,    false, true)
 && !collision_rectangle(_x1, _y1, _x2, _y2, oPortao,    false, true)) {
```

> Sem isso, comida ou NPCs poderiam spawnar dentro do portão.

---

## 🗺️ Parte 6 — Room Editor (Configuração por Fase)

### Passo 6.1 — Room Creation Code

Para cada fase que usa chave, adicionar no **Room Creation Code** da room:

**Exemplo — `rooms/room_02/RoomCreationCode.gml`:**

```gml
// === CONFIG DA FASE 2 ===
global.comidaMax    = 5;
global.comidaSpawn  = 5;
global.npcSpawn     = 3;
global.tempoFomeMax = 90;

// Chave + Portão
global.faseTemChave = true;
```

**Exemplo — `rooms/room_01/RoomCreationCode.gml` (sem chave):**

```gml
// === CONFIG DA FASE 1 ===
global.comidaMax    = 3;
global.comidaSpawn  = 3;
global.npcSpawn     = 2;
global.tempoFomeMax = 120;

// Fase 1 não usa chave
global.faseTemChave = false;
```

> Se uma fase não definir `faseTemChave`, o spawner não cria chave e o HUD não mostra o ícone (protegido pelo `variable_global_exists`).

### Passo 6.2 — Posicionar o Portão no Room Editor

1. Abra a room que usa chave (ex: `room_02`)
2. Na camada de instâncias (**Instances layer**), arraste o `oPortao` para a posição desejada
3. Posicione o portão **bloqueando um corredor ou passagem** que leva à área trancada
4. **NÃO** coloque `oChave` manualmente — o `oSpawner` cuida disso automaticamente

#### Dicas de posicionamento

```
┌─────────────────────────────────┐
│                                 │
│   [oSpawnZone]                  │
│      comida, NPCs, chave        │
│      spawnam aqui               │
│                                 │
│              ╔═══╗              │
│   ──────────═╣ P ╠═──────────  │  ← oPortao (P) bloqueando passagem
│              ╚═══╝              │
│                                 │
│   [Área trancada]               │
│      mais comida aqui           │
│      (necessária para vencer)   │
│                                 │
│                        [Saída]  │
└─────────────────────────────────┘
```

> O portão deve ter o **mesmo tamanho** que as paredes para bloquear a passagem corretamente. Se o corredor tem 64px de largura, o sprite do portão deve ter 64px de largura.

> Coloque comida manualmente ou outra `oSpawnZone` na área trancada para garantir que tem comida lá dentro.

---

## 🔧 Parte 7 — Pathfinding (oController — mp_grid)

Se os inimigos usam pathfinding (`mp_grid`), o portão precisa ser adicionado ao grid quando fechado e removido quando aberto.

### Passo 7.1 — oController Create (adicionar portão ao grid)

**`objects/oController/Create_0.gml`** — depois de `mp_grid_add_instances(grid, oSaida, 0);`:

```gml
// ADICIONAR — portão no pathfinding
mp_grid_add_instances(grid, oPortao, 0);
```

### Passo 7.2 — oPortao Step (atualizar grid quando abre)

Quando o portão abre, os inimigos devem poder passar por ele também. Adicionar no `oPortao/Step_0.gml`:

```gml
// Pausar
if (global.pausado) exit;

// Muda sprite baseado na chave
if (global.temChave) {
    sprite_index = sPortaoAberto;

    // Remove do grid de pathfinding (permite inimigos passarem)
    // Só executa uma vez usando flag
    if (!variable_instance_exists(id, "portao_abriu")) {
        portao_abriu = true;
        mp_grid_clear_cell(oController.grid, x div 4, y div 4);
    }
} else {
    sprite_index = sPortaoFechado;
}
```

> O `mp_grid_clear_cell` limpa a célula do portão no grid, liberando passagem para o pathfinding dos inimigos. O `div 4` converte coordenadas de pixel para coordenadas do grid (que usa células de 4×4 pixels, conforme definido no `oController/Create`).

> **Nota:** Se o portão ocupa mais de uma célula do grid, use um loop para limpar todas as células que ele cobre. Para a maioria dos casos (portão de 32×32) em um grid de 4×4, seriam 8×8 células.

---

## ✅ Checklist Final

### Sprites
- [ ] Criar `sChave` (16×16 ou 32×32, origin no centro)
- [ ] Criar `sPortaoFechado` (tamanho da passagem, origin no centro)
- [ ] Criar `sPortaoAberto` (mesmo tamanho, origin no centro)

### Objetos novos
- [ ] Criar `oChave` com sprite `sChave`
- [ ] Adicionar `oChave/Create_0.gml` → `base_y = y;`
- [ ] Adicionar `oChave/Step_0.gml` → flutuação + coleta + `global.temChave = true`
- [ ] Adicionar `oChave/Draw_0.gml` → `draw_self()` + indicador "!"
- [ ] Criar `oPortao` com sprite `sPortaoFechado`
- [ ] Adicionar `oPortao/Step_0.gml` → troca sprite + pathfinding update

### Modificações em objetos existentes
- [ ] `oController/Create_0.gml` → adicionar `global.temChave = false;`
- [ ] `oController/Create_0.gml` → adicionar `mp_grid_add_instances(grid, oPortao, 0);`
- [ ] `oController/Draw_64.gml` → adicionar ícone de chave no HUD
- [ ] `oPlayer/Step_0.gml` → adicionar colisão com `oPortao` (só quando `!global.temChave`)
- [ ] `oSpawner/Alarm_0.gml` → adicionar `oChave` ao `_config` (se `faseTemChave`)
- [ ] `oSpawner/Alarm_0.gml` → adicionar `oPortao` às checagens de `collision_rectangle`

### Room Editor
- [ ] Configurar Room Creation Code com `global.faseTemChave = true` nas fases com chave
- [ ] Posicionar `oPortao` manualmente bloqueando a passagem desejada
- [ ] Garantir que há comida (ou `oSpawnZone`) na área atrás do portão

### Teste
- [ ] Rodar fase SEM chave (ex: room_01) → ícone de chave NÃO aparece no HUD, sem portão
- [ ] Rodar fase COM chave (ex: room_02) → chave spawna, ícone escuro no HUD
- [ ] Coletar chave → ícone brilha, portão muda sprite, passagem livre
- [ ] Tentar passar pelo portão SEM chave → bloqueado
- [ ] Inimigos não atravessam portão fechado (pathfinding)
- [ ] Inimigos podem atravessar portão aberto
- [ ] Completar a fase coletando comida da área trancada → vitória funciona

---

## 📝 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `objects/oChave/Create_0.gml` | **NOVO** — `base_y = y;` |
| `objects/oChave/Step_0.gml` | **NOVO** — flutuação, coleta, `global.temChave` |
| `objects/oChave/Draw_0.gml` | **NOVO** — draw_self + indicador "!" |
| `objects/oPortao/Step_0.gml` | **NOVO** — troca sprite + pathfinding |
| `objects/oController/Create_0.gml` | **MODIFICAR** — adicionar `global.temChave` e `mp_grid` |
| `objects/oController/Draw_64.gml` | **MODIFICAR** — ícone de chave no HUD |
| `objects/oPlayer/Step_0.gml` | **MODIFICAR** — colisão com `oPortao` |
| `objects/oSpawner/Alarm_0.gml` | **MODIFICAR** — spawn da chave + colisão do portão |
| `rooms/*/RoomCreationCode.gml` | **MODIFICAR** — `global.faseTemChave` |

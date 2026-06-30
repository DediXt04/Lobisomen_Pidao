# 💤 Guia de Implementação — Sprites Idle no NPC

> Guia para adaptar o `oNpc` (e seu filho `oNpc2`) para usar **sprites de idle animados** quando o NPC para de se mover, em vez de congelar no frame 0 do sprite de walk.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Objetos afetados | `oNpc`, `oNpc2` (filho via parent) |
| Estado atual | Quando o NPC para, congela no frame 0 do sprite de walk |
| Objetivo | Ter sprite idle animando em loop quando parado |
| Padrão de referência | `oPlayer/Step_0.gml` (já faz idle separado) |
| Convenção de nome | `s<Skin><Direcao>Idle` (ex: `sNpcSideIdle`, `sNpc2DownIdle`) |
| Pré-requisito | Sprites idle já criados pelo usuário |

### Faces (sistema de direções do projeto)

| Face | Direção | Sprite walk | Sprite idle |
|---|---|---|---|
| 0 | Lado (esq/dir) | `sNpcSide` | `sNpcSideIdle` |
| 2 | Cima | `sNpcUp` | `sNpcUpIdle` |
| 3 | Baixo (default) | `sNpcDown` | `sNpcDownIdle` |
| 4 | Diagonal pra baixo | `sNpcDDown` | `sNpcDDownIdle` |
| 5 | Diagonal pra cima | `sNpcDUp` | `sNpcDUpIdle` |

> Face 1 (diagonal cima invertida) não é usada pelo NPC — só pelo Player.

---

## 🏗️ Visão Geral

### Estado atual (problema)

```
NPC andando → anima walk ✓
   ↓
NPC para
   ↓
walk_timer chega a 0
   ↓
image_speed = 0
image_index = 0    ← CONGELA no frame 0
   ↓
Visualmente parece estátua até começar a andar de novo ✗
```

### Estado desejado (após adaptar)

```
NPC andando → sprite_walk[face] anima ✓
   ↓
NPC para
   ↓
walk_timer chega a 0
   ↓
sprite = sprite_idle  ← TROCA pro array idle
image_speed = 1       ← MANTÉM rodando
   ↓
NPC anima idle (respira, pisca, balança) em loop ✓
```

### Princípio — 2 arrays paralelos

Igual ao `oPlayer`, o NPC vai ter **dois arrays de sprites indexados por `face`**:
- `sprite_walk[]` — frames de movimento
- `sprite_idle[]` — frames de idle

A variável `sprite` (que o Step usa pra setar `sprite_index`) aponta pra um ou outro array conforme o estado.

---

## 🎨 Sprites Necessários

> **Pré-requisito:** todos esses sprites já devem estar criados no GameMaker antes de seguir o guia.

### Skin 1 — `oNpc`

| Walk (já existem) | Idle (novos) |
|---|---|
| `sNpcSide` | `sNpcSideIdle` |
| `sNpcUp` | `sNpcUpIdle` |
| `sNpcDown` | `sNpcDownIdle` |
| `sNpcDDown` | `sNpcDDownIdle` |
| `sNpcDUp` | `sNpcDUpIdle` |

### Skin 2 — `oNpc2`

| Walk (já existem) | Idle (novos) |
|---|---|
| `sNpc2Side` | `sNpc2SideIdle` |
| `sNpc2Up` | `sNpc2UpIdle` |
| `sNpc2Down` | `sNpc2DownIdle` |
| `sNpc2DDown` | `sNpc2DDownIdle` |
| `sNpc2DUp` | `sNpc2DUpIdle` |

### Dicas pra criação dos sprites idle

- **FPS sugerido:** 4–6 fps (idle calmo, sem ficar nervoso)
- **Frames sugeridos:** 2–4 frames bastam (respiração, piscada)
- **Origin:** **MESMO** valor do sprite de walk correspondente (geralmente Middle Centre ou o mesmo offset que o walk). Sprites com origin diferente fazem o NPC "pular" ao trocar.
- **Tamanho do canvas:** mesmo do walk (não trocar entre 16×16 e 32×32 sem alinhar o origin)

---

## 🧱 Parte 1 — Refatorar `oNpc/Create_0.gml`

### 1.1 Estado atual

```gml
scr_initMovimento(2, 90, 300);

// Interação
chance_comida = 10;
valor_comida  = 1;
paciencia     = 5;
paciencia_max = 5;

cooldown      = 0;
cooldown_max  = 120;

// sprite control (mesmo padrão do oPlayer)
walk_timer = 0;

face = 3;              // 3 = baixo
sprite[0] = sNpcSide;
sprite[2] = sNpcUp;
sprite[3] = sNpcDown;
sprite[4] = sNpcDDown;
sprite[5] = sNpcDUp;

sprite_index = sprite[face];
image_speed  = 0;
mask_index   = sprite[3];

// Reação
reacao_frame  = -1;
reacao_timer  = 0;
reacao_dur    = 90;
```

### 1.2 Versão refatorada

Substitua o bloco "sprite control" pelo seguinte:

```gml
// sprite control — dois arrays paralelos (walk + idle)
walk_timer = 0;

face = 3;              // 3 = baixo

// Array de sprites de WALK
sprite_walk[0] = sNpcSide;
sprite_walk[2] = sNpcUp;
sprite_walk[3] = sNpcDown;
sprite_walk[4] = sNpcDDown;
sprite_walk[5] = sNpcDUp;

// Array de sprites de IDLE (NOVO)
sprite_idle[0] = sNpcSideIdle;
sprite_idle[2] = sNpcUpIdle;
sprite_idle[3] = sNpcDownIdle;
sprite_idle[4] = sNpcDDownIdle;
sprite_idle[5] = sNpcDUpIdle;

// Por padrão começa parado → idle
sprite = sprite_idle;

sprite_index = sprite[face];
image_speed  = 1;             // ← MUDOU: idle anima desde o início
mask_index   = sprite_walk[3]; // mask sempre do walk (silhueta consistente)
```

> **Por que `mask_index = sprite_walk[3]`?** A máscara de colisão deve ser estável (não mudar conforme o sprite muda). Usar o sprite de walk "olhando pra baixo" como referência fixa garante que a hitbox não oscila.

---

## 🚶 Parte 2 — Refatorar `oNpc/Step_0.gml`

### 2.1 Bloco "sprite control" atual (linhas 38-73)

```gml
// sprite control
#region
var _movendo = (pixels_walked > 0);

if (_movendo) {
    image_speed = 1;
    walk_timer = 10;

    var _h = (xspd != 0);
    var _v = (yspd != 0);

    if (_h && _v) {
        face = (yspd < 0) ? 5 : 4;
        image_xscale = (xspd > 0) ? 1 : -1;
    } else if (_h) {
        face = 0;
        image_xscale = (xspd > 0) ? 1 : -1;
    } else if (_v) {
        face = (yspd < 0) ? 2 : 3;
        image_xscale = 1;
    }
}

if (walk_timer > 0) walk_timer--;
if (walk_timer == 0) {
    image_speed = 0;
    image_index = 0;
}

mask_index   = sprite[3];
sprite_index = sprite[face];
depth = -y;
#endregion
```

### 2.2 Versão refatorada

```gml
// sprite control — alterna entre arrays walk e idle
#region
var _movendo = (pixels_walked > 0);

if (_movendo) {
    sprite = sprite_walk;   // ← NOVO: usa o array de walk
    image_speed = 1;
    walk_timer = 10;

    var _h = (xspd != 0);
    var _v = (yspd != 0);

    if (_h && _v) {
        face = (yspd < 0) ? 5 : 4;
        image_xscale = (xspd > 0) ? 1 : -1;
    } else if (_h) {
        face = 0;
        image_xscale = (xspd > 0) ? 1 : -1;
    } else if (_v) {
        face = (yspd < 0) ? 2 : 3;
        image_xscale = 1;
    }
}

if (walk_timer > 0) walk_timer--;
if (walk_timer == 0) {
    sprite = sprite_idle;   // ← NOVO: troca pro idle
    image_speed = 1;        // ← MUDOU: deixa o idle animar (era 0)
    // ← REMOVIDO: image_index = 0;  (deixa o idle correr livre)
}

mask_index   = sprite_walk[3];   // ← MUDOU: sempre walk pra mask
sprite_index = sprite[face];
depth = -y;
#endregion
```

### 2.3 Diff resumido

| Linha | Antes | Depois |
|---|---|---|
| `if (_movendo)` | — | `sprite = sprite_walk;` (novo) |
| `if (walk_timer == 0)` | `image_speed = 0;` | `sprite = sprite_idle; image_speed = 1;` |
| `if (walk_timer == 0)` | `image_index = 0;` | (removido) |
| `mask_index` | `sprite[3]` | `sprite_walk[3]` |

---

## 👯 Parte 3 — Criar `oNpc2/Create_0.gml`

Hoje `oNpc2` **não tem evento Create** — ele só herda o sprite default `sNpc2Down` via `spriteId` no `.yy`. Pra dar sprites idle próprios à skin 2, é preciso criar o Create event e sobrescrever os arrays.

### 3.1 Adicionar o evento

No GameMaker:
1. Abra `oNpc2` no Object Editor
2. Clique em **Add Event** → **Create**
3. Cole o código abaixo

### 3.2 `objects/oNpc2/Create_0.gml` (NOVO)

```gml
// Herda toda a lógica do oNpc (timers, interação, etc.)
event_inherited();

// Sobrescreve os arrays de sprite com a skin 2
sprite_walk[0] = sNpc2Side;
sprite_walk[2] = sNpc2Up;
sprite_walk[3] = sNpc2Down;
sprite_walk[4] = sNpc2DDown;
sprite_walk[5] = sNpc2DUp;

sprite_idle[0] = sNpc2SideIdle;
sprite_idle[2] = sNpc2UpIdle;
sprite_idle[3] = sNpc2DownIdle;
sprite_idle[4] = sNpc2DDownIdle;
sprite_idle[5] = sNpc2DUpIdle;

// Reset visual baseado nos novos arrays
sprite = sprite_idle;
sprite_index = sprite[face];
mask_index = sprite_walk[3];
```

> **Ordem importa:** `event_inherited()` **DEVE** ser a primeira linha — ele roda o Create do `oNpc` primeiro (que cria os arrays com sprites `sNpc*`), e depois você sobrescreve com `sNpc2*`.

### 3.3 Verificar que o Step herda automaticamente

`oNpc2` não tem evento Step próprio — ele herda do `oNpc`. Como o Step só usa as variáveis `sprite_walk[]`, `sprite_idle[]`, `sprite`, e essas foram sobrescritas no Create do `oNpc2`, **tudo funciona automaticamente**.

Não precisa duplicar o Step.

---

## ✅ Testes Esperados

Após implementar:

- [ ] `oNpc` parado → anima idle (respiração/piscada) em loop
- [ ] `oNpc` começa a andar → troca pro sprite de walk imediatamente
- [ ] `oNpc` para de novo → após 10 frames de `walk_timer`, volta pra idle
- [ ] `oNpc` muda de direção parado → idle reflete a nova direção (cima → idle de cima)
- [ ] `oNpc2` (skin 2) → mostra `sNpc2*Idle` quando parado (não usa sprites do `oNpc`)
- [ ] `oNpc2` andando → mostra `sNpc2*` (walk) normalmente
- [ ] Hitbox do NPC permanece estável (não fica oscilando entre walk/idle)
- [ ] Interação com player continua funcionando (E pra pedir comida)

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Idle não anima | Esqueceu de mudar `image_speed = 0` → `1` no bloco `walk_timer == 0` | Conferir Step (Parte 2.2) |
| NPC "pula" ao trocar walk↔idle | Origin diferente entre `sNpcSide` e `sNpcSideIdle` (ou qualquer par) | Setar mesmo Origin em todos os pares (Middle Centre é o mais comum) |
| `oNpc2` continua estático no sprite default | Esqueceu de criar `Create_0.gml` no `oNpc2` | Add Event → Create + colar código da Parte 3.2 |
| `oNpc2` usa sprites do `oNpc` em vez dos próprios | Esqueceu de `event_inherited()` no início ou sobrescreveu na ordem errada | Garantir `event_inherited()` PRIMEIRO, depois reatribuir os arrays |
| Erro `variable sprite_idle not set` | `event_inherited()` não foi chamado no `oNpc2/Create` | Adicionar `event_inherited();` como 1ª linha |
| Animação idle muito rápida/lenta | FPS do sprite mal configurado | Ajustar FPS no Sprite Editor (4-6 fps recomendado pra idle calmo) |
| Hitbox oscila ou some | `mask_index` está usando `sprite[3]` que muda | Trocar pra `mask_index = sprite_walk[3]` (referência fixa) |
| Idle não muda ao virar de direção | `sprite_index = sprite[face]` não está sendo recalculado | Conferir que a linha está fora dos `if` (Parte 2.2 — penúltima linha) |
| Idle aparece "espelhado errado" ao parar virado pra esquerda | `image_xscale` não é resetado | Sem problema — `image_xscale` deve manter o valor (NPC continua virado pro lado que parou) |

---

## 📁 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `sprites/sNpcSideIdle`, `sNpcUpIdle`, `sNpcDownIdle`, `sNpcDDownIdle`, `sNpcDUpIdle` | Pré-existentes (criados pelo usuário) |
| `sprites/sNpc2SideIdle`, `sNpc2UpIdle`, `sNpc2DownIdle`, `sNpc2DDownIdle`, `sNpc2DUpIdle` | Pré-existentes |
| `objects/oNpc/Create_0.gml` | **MODIFICAR** — substituir `sprite[]` por `sprite_walk[]` + `sprite_idle[]` |
| `objects/oNpc/Step_0.gml` | **MODIFICAR** — alternar arrays, manter `image_speed = 1` no idle |
| `objects/oNpc2/Create_0.gml` | **NOVO** — `event_inherited()` + arrays próprios |
| `objects/oNpc2/oNpc2.yy` | **MODIFICAR** automaticamente — `eventList` ganha o Create event ao adicionar pelo IDE |

---

## 📝 Notas Finais

- **Compatibilidade:** o padrão segue exatamente o mesmo modelo usado em `oPlayer/Step_0.gml`, então fica fácil de manter coerente com o resto do projeto.
- **Performance:** zero impacto — apenas troca de referência de array.
- **Extensibilidade futura:** se quiser adicionar mais variantes (NPC bravo, NPC dormindo após X segundos parado), basta adicionar `sprite_dormindo[]` e um timer com a mesma lógica do guia `GUIA_LOBO_MENU_REATIVO.md` (escalação de estágios de inatividade).
- **Outras skins futuras:** se quiser uma `oNpc3`, basta seguir exatamente o padrão da Parte 3 — `event_inherited()` + arrays próprios com `sNpc3*` e `sNpc3*Idle`.

---

> **Resumo:** este guia adapta o `oNpc` pra ter idle animado em loop seguindo o mesmo padrão do `oPlayer`. A herança de `oNpc → oNpc2` é preservada — o filho só precisa de um Create curto que sobrescreve os arrays com seus próprios sprites. Total: 2 arquivos modificados + 1 novo, sem refatorar lógica de movimento ou interação.

# 🔄 Padronização da Movimentação do NPC com o Player

> Guia de refatoração para alinhar as variáveis e padrões do `oNpc` com o `oPlayer`.  
> **Objetivo:** Manter a mesma nomenclatura e estrutura de código entre os dois objetos, sem alterar o comportamento do jogo.

---

## 📊 Comparativo Atual — Player vs NPC

### Variáveis de Movimento

| Conceito | oPlayer (atual) | oNpc (atual) | Problema |
|---|---|---|---|
| Velocidade base | `moveSpd` | `move_speed` | Nome diferente |
| Velocidade X | `xspd` | `vx` | Nome diferente |
| Velocidade Y | `yspd` | `vy` | Nome diferente |
| Direção visual | `face` (0–4) | `direcao_sprite` (não usado!) | Variável existe mas não é utilizada |
| Sprites | `sprite[]` (array com 5 sprites) | Atribuição direta a `sprite_index` | Padrão completamente diferente |
| Timer de animação | `walk_timer` (10 frames pós-input) | `image_speed` toggle (0/1) | Padrão diferente |

### Estrutura de Sprite Control

**Player (padrão atual):**
```gml
// Create_0.gml
face = 3;
sprite[0] = sLoboSide;
sprite[1] = sLoboDUp;
sprite[2] = sLoboUp;
sprite[3] = sLoboDown;
sprite[4] = sLoboDDown;

// Step_0.gml — controle de sprite
sprite_index = sprite[face];
mask_index   = sprite[3];
```

**NPC (padrão atual — diferente):**
```gml
// Create_0.gml
direcao_sprite = 0;   // não é usado em lugar nenhum!
sprite_index = sNpcDown;

// Step_0.gml — controle de sprite (atribuição direta)
if (vy > 0)  sprite_index = sNpcDown;
if (vy < 0)  sprite_index = sNpcUp;
if (vx != 0) sprite_index = sNpcSide;
```

---

## 🗺️ Mapeamento de Renomeação

| Variável Atual (NPC) | Nova Variável (NPC) | Referência (Player) |
|---|---|---|
| `move_speed` | `moveSpd` | `moveSpd` |
| `vx` | `xspd` | `xspd` |
| `vy` | `yspd` | `yspd` |
| `direcao_sprite` | `face` | `face` |
| _(não existia)_ | `sprite[]` | `sprite[]` |
| _(não existia)_ | `walk_timer` | `walk_timer` |

> **Nota:** O NPC possui apenas **3 sprites direcionais** (Side, Up, Down), enquanto o Player possui **5** (inclui diagonais). O array `sprite[]` do NPC usará os índices **0, 2 e 3** para manter compatibilidade com os valores de `face` do Player.

---

## 📁 Arquivos a Modificar

### 1. `objects/oNpc/Create_0.gml`
### 2. `objects/oNpc/Step_0.gml`
### 3. `scripts/scr_escolherDirecao/scr_escolherDirecao.gml`

---

## 💻 Código Sugerido

### 1. `objects/oNpc/Create_0.gml` — NOVO

```gml
// movimento (mesmo padrão do oPlayer)
moveSpd = 2;
xspd = 0;
yspd = 0;

timer = 0;
timer_max = 180;

pixels_walked = 0;

// Interação
chance_comida = 10;
valor_comida  = 1;
paciencia     = 5;
paciencia_max = 5;

cooldown      = 0;
cooldown_max  = 120;

// sprite control (mesmo padrão do oPlayer)
walk_timer = 0;

face = 3;              // 3 = baixo (mesmo valor inicial do Player)
sprite[0] = sNpcSide;  // face 0 = lado
sprite[2] = sNpcUp;    // face 2 = cima
sprite[3] = sNpcDown;  // face 3 = baixo

sprite_index = sprite[face];
image_speed  = 0;
mask_index   = sprite[3];

// Reação (balão acima da cabeça)
// frame 0 = deu comida | frame 1 = não deu nada | frame 2 = sem paciência
reacao_frame  = -1;
reacao_timer  = 0;
reacao_dur    = 90;
```

**Mudanças:**
- `move_speed` → `moveSpd`
- `vx`, `vy` → `xspd`, `yspd`
- `direcao_sprite` removido → substituído por `face = 3`
- Adicionado array `sprite[]` com 3 sprites (índices 0, 2, 3)
- Adicionado `walk_timer = 0`
- `sprite_index` agora usa `sprite[face]`
- `mask_index` agora usa `sprite[3]` (igual ao Player)

---

### 2. `objects/oNpc/Step_0.gml` — NOVO

```gml
// Movimentação
#region
timer++;
if (timer >= timer_max) {
    timer = 0;
    scr_escolherDirecao();
}

if (pixels_walked > 0) {

    if (xspd != 0) {
        if place_meeting(x + xspd, y, oWall)   { pixels_walked = 0; xspd = 0; }
        if place_meeting(x + xspd, y, oPlayer) { pixels_walked = 0; xspd = 0; }
        if (xspd != 0) { x += xspd; pixels_walked -= abs(xspd); }
    }

    if (yspd != 0) {
        if place_meeting(x, y + yspd, oWall)   { pixels_walked = 0; yspd = 0; }
        if place_meeting(x, y + yspd, oPlayer) { pixels_walked = 0; yspd = 0; }
        if (yspd != 0) { y += yspd; pixels_walked -= abs(yspd); }
    }
}
#endregion

// sprite control (mesmo padrão do oPlayer)
#region
var _movendo = (pixels_walked > 0);

if (_movendo) {
    walk_timer = 10;

    if (xspd != 0 && yspd == 0) { face = 0; image_xscale = (xspd > 0) ? 1 : -1; }
    if (xspd == 0 && yspd != 0) { face = (yspd < 0) ? 2 : 3; image_xscale = 1; }
}

if (walk_timer > 0) walk_timer--;

if (walk_timer == 0) image_index = 0;

mask_index   = sprite[3];
sprite_index = sprite[face];
depth = -y;
#endregion

// Cooldown
if (cooldown > 0) cooldown--;

// Timer da reação
if (reacao_timer > 0) {
    reacao_timer--;
    if (reacao_timer <= 0) reacao_frame = -1;
}

// Interação
#region
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

if (_dist < 32 && oController.interagir && cooldown <= 0)
{
    // Sem paciência — reação 2
    if (paciencia <= 0) {
        reacao_frame = 2;
        reacao_timer = reacao_dur;

    } else {
        // Tem paciência — tenta dar comida
        if (irandom(99) <= chance_comida) {
            global.comida += valor_comida;
            reacao_frame = 0;
        } else {
            reacao_frame = 1;
        }

        reacao_timer   = reacao_dur;
        chance_comida += irandom_range(10, 15);
        chance_comida  = min(chance_comida, 100);
        paciencia--;
    }

    cooldown = cooldown_max;
}
#endregion
```

**Mudanças no Step_0:**

| Seção | Antes | Depois |
|---|---|---|
| **Movimentação** | `vx` / `vy` | `xspd` / `yspd` |
| **Sprite control** | `if (vy > 0) sprite_index = sNpcDown;` etc. | `face = 3; sprite_index = sprite[face];` |
| **Animação** | `image_speed = 1` (movendo) / `image_speed = 0` (parado) | `walk_timer = 10` (movendo) / decrementa até 0 → `image_index = 0` |
| **Flip horizontal** | `image_xscale = (vx > 0) ? 1 : -1;` | `image_xscale = (xspd > 0) ? 1 : -1;` |
| **Mask** | _(não definido)_ | `mask_index = sprite[3];` |
| **Profundidade** | `depth = -y;` no início | `depth = -y;` na seção de sprite (igual ao Player) |

---

### 3. `scripts/scr_escolherDirecao/scr_escolherDirecao.gml` — NOVO

```gml
function scr_escolherDirecao() {
    var d = irandom(3);
    xspd = 0;
    yspd = 0;

    switch (d) {
        case 0: xspd =  moveSpd; break; // direita
        case 1: xspd = -moveSpd; break; // esquerda
        case 2: yspd =  moveSpd; break; // baixo
        case 3: yspd = -moveSpd; break; // cima
    }

    pixels_walked = irandom_range(16, 64);
}
```

**Mudanças:**
- `vx` → `xspd`
- `vy` → `yspd`
- `move_speed` → `moveSpd`

---

## 🔍 Checklist de Validação

Após aplicar as mudanças, verificar que:

- [ ] `move_speed` não aparece mais em nenhum arquivo do oNpc nem em scr_escolherDirecao
- [ ] `vx` e `vy` não aparecem mais em nenhum arquivo do oNpc nem em scr_escolherDirecao
- [ ] `direcao_sprite` não aparece mais no código
- [ ] `sprite_index` no Step_0 do NPC agora usa `sprite[face]` (não atribuição direta)
- [ ] `image_speed` não é mais usado para controle de animação no NPC
- [ ] O NPC continua vagando normalmente pelo mapa
- [ ] O NPC continua dando comida quando interagido
- [ ] As reações visuais (balão) continuam funcionando
- [ ] A colisão com paredes e jogador continua funcionando
- [ ] O sprite muda de direção corretamente (lado, cima, baixo)
- [ ] O sprite para (frame 0) quando o NPC não está se movendo

---

## ⚠️ Observações Importantes

1. **Comportamento idêntico** — Nenhuma regra de negócio é alterada. É apenas renomeação de variáveis e reestruturação de padrão.

2. **Índices do array `sprite[]`** — O NPC usa apenas 3 dos 5 índices do Player:
   - `sprite[0]` = `sNpcSide` (lado)
   - `sprite[2]` = `sNpcUp` (cima)
   - `sprite[3]` = `sNpcDown` (baixo)
   - `sprite[1]` e `sprite[4]` (diagonais) — **não existem** para o NPC

3. **Valores de `face`** — Compatíveis com o Player:
   - `0` = lado (esquerda/direita controlado por `image_xscale`)
   - `2` = cima
   - `3` = baixo

4. **`scr_escolherDirecao`** — Este script é chamado **apenas** pelo oNpc, então renomear as variáveis nele é seguro e não afeta nenhum outro objeto.

5. **`walk_timer`** — No Player, mantém a animação de andar por 10 frames após soltar o input. No NPC, serve o mesmo propósito: mantém a animação por 10 frames após o NPC parar de se mover.

6. **`mask_index`** — Adicionado `mask_index = sprite[3]` (sprite de baixo), igual ao Player, para garantir colisão consistente independente da direção visual.

---

## 📋 Resumo das Mudanças por Arquivo

| Arquivo | Tipo | Mudanças |
|---|---|---|
| `objects/oNpc/Create_0.gml` | Variáveis | Renomear 3 variáveis, adicionar `face`, `sprite[]`, `walk_timer` |
| `objects/oNpc/Step_0.gml` | Lógica | Substituir nomes + reestruturar sprite control e animação |
| `scripts/scr_escolherDirecao/scr_escolherDirecao.gml` | Script | Renomear 3 variáveis |
| `objects/oNpc/Draw_0.gml` | **Sem mudanças** | Não referencia nenhuma variável renomeada |

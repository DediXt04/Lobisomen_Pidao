# 🔄 Documentação da Movimentação do NPC — Estado Atual

> Documentação do padrão de movimentação e controle de sprite do `oNpc`, com comparativo ao `oPlayer`.  
> **Última atualização:** Abril 2026 — extraída diretamente do código-fonte.

---

## 📊 Comparativo Atual — Player vs NPC

### Variáveis de Movimento

| Conceito | oPlayer | oNpc | Observação |
|---|---|---|---|
| Velocidade base | `moveSpd = 2` | `move_speed = 2` | Nomes diferentes, mesmo valor |
| Velocidade X | `xspd` | `vx` | Nomes diferentes |
| Velocidade Y | `yspd` | `vy` | Nomes diferentes |
| Direção visual | `face` (0–4, usado ativamente) | `direcao_sprite` (inicializado mas **não usado**) | NPC não utiliza essa variável |
| Sprites | `sprite[]` (array com 5 sprites) | Atribuição direta a `sprite_index` | Padrões diferentes |
| Timer de animação | `walk_timer` (10 frames pós-input) | `image_speed` toggle (0/1) | Padrões diferentes |
| Colisão máscara | `mask_index = sprite[3]` | `mask_index = sNpcDown` | Player usa array, NPC atribui direto |
| Movimentação | Contínua (input do jogador) | Por distância (`pixels_walked`) | NPC anda distância fixa e para |

> **Nota:** O `oInimigo` já foi padronizado e usa o mesmo padrão do Player (`xspd`/`yspd`, `face`, `sprite[]`).

---

## 📁 Arquivos do oNpc

### 1. `objects/oNpc/Create_0.gml`
### 2. `objects/oNpc/Step_0.gml`
### 3. `objects/oNpc/Draw_0.gml`
### 4. `scripts/scr_escolherDirecao/scr_escolherDirecao.gml`

---

## 💻 Código Atual

### 1. `objects/oNpc/Create_0.gml`

```gml
vx = 0;
vy = 0;
move_speed = 2;

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

// Direção do sprite
direcao_sprite = 0;   // inicializado mas NÃO usado em nenhum evento

sprite_index = sNpcDown;
image_speed  = 0;
mask_index   = sNpcDown;

// Reação (balão acima da cabeça)
// frame 0 = deu comida | frame 1 = não deu nada | frame 2 = sem paciência
reacao_frame  = -1;   // -1 = nenhuma reação ativa
reacao_timer  = 0;
reacao_dur    = 90;   // frames que o balão fica (~1.5s a 60fps)
```

---

### 2. `objects/oNpc/Step_0.gml`

```gml
// Movimentação
#region
timer++;
if (timer >= timer_max) {
    timer = 0;
    scr_escolherDirecao();
}

if (pixels_walked > 0) {

    if (vx != 0) {
        if place_meeting(x + vx, y, oWall)   { pixels_walked = 0; vx = 0; }
        if place_meeting(x + vx, y, oPlayer) { pixels_walked = 0; vx = 0; }
        if (vx != 0) { x += vx; pixels_walked -= abs(vx); }
    }

    if (vy != 0) {
        if place_meeting(x, y + vy, oWall)   { pixels_walked = 0; vy = 0; }
        if place_meeting(x, y + vy, oPlayer) { pixels_walked = 0; vy = 0; }
        if (vy != 0) { y += vy; pixels_walked -= abs(vy); }
    }
}
#endregion

// Controle de sprite
#region
depth = -y;
var _movendo = (pixels_walked > 0);

if (_movendo) {
    if (vy > 0) {
        if (sprite_index != sNpcDown) { sprite_index = sNpcDown; image_index = 0; }
    } else if (vy < 0) {
        if (sprite_index != sNpcUp)   { sprite_index = sNpcUp;   image_index = 0; }
    } else if (vx != 0) {
        if (sprite_index != sNpcSide) { sprite_index = sNpcSide; image_index = 0; }
        image_xscale = (vx > 0) ? 1 : -1;
    }
    image_speed = 1;
} else {
    image_speed = 0;
    image_index = 0;
}
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
            reacao_frame = 0;   // deu comida
        } else {
            reacao_frame = 1;   // não deu nada
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

---

### 3. `objects/oNpc/Draw_0.gml`

```gml
draw_self();

// Reação — balão acima da cabeça
if (reacao_frame >= 0) {
    var _bx = x;
    var _by = y - sprite_height - 6;

    draw_sprite_ext(
        sReacao,          // sprite de reações (3 frames)
        reacao_frame,     // 0 = comida | 1 = nada | 2 = sem paciência
        _bx, _by,
        1, 1,             // scale
        0,                // rotação
        c_white,          // cor
        1                 // alpha
    );
}
```

---

### 4. `scripts/scr_escolherDirecao/scr_escolherDirecao.gml`

```gml
function scr_escolherDirecao() {
    var d = irandom(3);
    vx = 0;
    vy = 0;

    switch (d) {
        case 0: vx =  move_speed; break; // direita
        case 1: vx = -move_speed; break; // esquerda
        case 2: vy =  move_speed; break; // baixo
        case 3: vy = -move_speed; break; // cima
    }

    pixels_walked = irandom_range(16, 64);
}
```

---

## 📋 Resumo de Variáveis do oNpc

### Movimento

| Variável | Tipo | Valor Inicial | Uso |
|---|---|---|---|
| `vx` | real | 0 | Velocidade horizontal atual |
| `vy` | real | 0 | Velocidade vertical atual |
| `move_speed` | real | 2 | Velocidade base (pixels/frame) |
| `timer` | real | 0 | Contador para decidir nova direção |
| `timer_max` | real | 180 | Intervalo entre mudanças de direção (~3s a 60fps) |
| `pixels_walked` | real | 0 | Pixels restantes a caminhar na direção atual |

### Sprite

| Variável | Tipo | Valor Inicial | Uso |
|---|---|---|---|
| `direcao_sprite` | real | 0 | **NÃO USADO** — inicializado mas nunca lido |
| `sprite_index` | asset | `sNpcDown` | Sprite atual — atribuído diretamente no Step |
| `image_speed` | real | 0 | 0 = parado, 1 = animando |
| `mask_index` | asset | `sNpcDown` | Máscara de colisão fixa |

### Interação

| Variável | Tipo | Valor Inicial | Uso |
|---|---|---|---|
| `chance_comida` | real | 10 | % de chance de dar comida (incrementa a cada tentativa) |
| `valor_comida` | real | 1 | Quanto de comida dá por sucesso |
| `paciencia` | real | 5 | Tentativas restantes antes de recusar |
| `paciencia_max` | real | 5 | Paciência máxima (referência) |
| `cooldown` | real | 0 | Frames restantes de cooldown |
| `cooldown_max` | real | 120 | Cooldown entre interações (~2s a 60fps) |

### Reação Visual

| Variável | Tipo | Valor Inicial | Uso |
|---|---|---|---|
| `reacao_frame` | real | -1 | Frame do sprite `sReacao` (-1 = sem reação) |
| `reacao_timer` | real | 0 | Frames restantes da reação visível |
| `reacao_dur` | real | 90 | Duração da reação (~1.5s a 60fps) |

---

## 🔄 Controle de Sprite — Como Funciona

### Sprites Direcionais

O NPC possui **3 sprites direcionais** (sem diagonais):

| Sprite | Direção | Condição de ativação |
|---|---|---|
| `sNpcDown` | Baixo | `vy > 0` |
| `sNpcUp` | Cima | `vy < 0` |
| `sNpcSide` | Lado | `vx != 0` (com flip via `image_xscale`) |

### Prioridade de Direção

```
1. vy > 0  → sNpcDown (prioridade máxima)
2. vy < 0  → sNpcUp
3. vx != 0 → sNpcSide (com image_xscale para espelhar)
```

### Animação

- **Movendo** (`pixels_walked > 0`): `image_speed = 1` (anima normalmente)
- **Parado** (`pixels_walked ≤ 0`): `image_speed = 0`, `image_index = 0` (trava no frame 0)
- Troca de sprite reseta `image_index = 0` para evitar glitch visual

### Diferença vs Player

O Player usa um sistema mais sofisticado:
- Array `sprite[]` indexado por `face` (0–4, incluindo diagonais)
- `walk_timer` de 10 frames para manter animação após soltar input
- `mask_index = sprite[3]` dinâmico

O NPC usa um sistema mais simples:
- Atribuição direta de `sprite_index` por comparação de velocidade
- Toggle de `image_speed` (0/1) para controle de animação
- `mask_index = sNpcDown` fixo

---

## 📐 Sistema de Movimentação — Como Funciona

### Fluxo

```
1. timer++ a cada frame
2. Quando timer >= 180: chama scr_escolherDirecao()
   → Escolhe direção aleatória (0-3)
   → Define vx/vy com move_speed
   → Define pixels_walked (16-64 px aleatório)
3. Enquanto pixels_walked > 0:
   → Verifica colisão antes de mover
   → Move x += vx / y += vy
   → Decrementa pixels_walked
4. Se colide com oWall ou oPlayer:
   → Para imediatamente (pixels_walked = 0, velocidade = 0)
```

### Colisão

- Verifica `oWall` e `oPlayer` separadamente para X e Y
- Colisão cancela o movimento restante (`pixels_walked = 0`)
- Profundidade: `depth = -y` (ordenação por posição vertical)

---

> 📝 **Nota:** Esta documentação reflete o código-fonte atual. Variáveis e valores podem mudar durante o desenvolvimento.

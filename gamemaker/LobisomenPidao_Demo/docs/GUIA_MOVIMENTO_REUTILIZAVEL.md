# 🔄 Guia de Refatoração — Sistema de Movimento Reutilizável

> Guia para transformar o `scr_escolherDirecao` em um sistema de movimento genérico que qualquer objeto pode usar — não apenas o `oNpc`.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Script atual | `scr_escolherDirecao()` — sem parâmetros, depende de `moveSpd` |
| Usado por | Apenas `oNpc` (no `Step_0.gml`) |
| Variáveis necessárias | `moveSpd`, `xspd`, `yspd`, `pixels_walked` |
| Problema | Qualquer objeto que quiser usar precisa definir todas essas variáveis manualmente |

---

## 🏗️ Mudanças Necessárias

### Mudança 1 — Refatorar `scr_escolherDirecao`

**Arquivo:** `scripts/scr_escolherDirecao/scr_escolherDirecao.gml`

**Código atual:**
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

**Substituir por:**
```gml
/// @function scr_escolherDirecao([_spd], [_min_px], [_max_px], [_diagonal])
/// @description Escolhe uma direção aleatória e define xspd/yspd.
///              Suporta 4 direções (padrão) ou 8 direções (com diagonal).
///              Funciona em qualquer objeto que tenha xspd, yspd e pixels_walked.
/// @param {real} [_spd]      Velocidade de movimento (default: moveSpd da instância)
/// @param {real} [_min_px]   Mínimo de pixels a caminhar (default: 16)
/// @param {real} [_max_px]   Máximo de pixels a caminhar (default: 64)
/// @param {bool} [_diagonal] Se true, inclui diagonais — 8 direções (default: false)

function scr_escolherDirecao(_spd = moveSpd, _min_px = 16, _max_px = 64, _diagonal = false) {
    var _h = 0;
    var _v = 0;

    if (_diagonal) {
        // 8 direções (4 cardinais + 4 diagonais)
        var d = irandom(7);

        switch (d) {
            case 0: _h =  1;          break; // direita
            case 1: _h = -1;          break; // esquerda
            case 2: _v =  1;          break; // baixo
            case 3: _v = -1;          break; // cima
            case 4: _h =  1; _v = -1; break; // ↗ direita-cima
            case 5: _h = -1; _v = -1; break; // ↖ esquerda-cima
            case 6: _h =  1; _v =  1; break; // ↘ direita-baixo
            case 7: _h = -1; _v =  1; break; // ↙ esquerda-baixo
        }
    } else {
        // 4 direções (comportamento original)
        var d = irandom(3);

        switch (d) {
            case 0: _h =  1; break; // direita
            case 1: _h = -1; break; // esquerda
            case 2: _v =  1; break; // baixo
            case 3: _v = -1; break; // cima
        }
    }

    // Normalização (mesmo padrão do oPlayer)
    var _dir   = point_direction(0, 0, _h, _v);
    var _level = clamp(point_distance(0, 0, _h, _v), 0, 1);

    xspd = lengthdir_x(_spd * _level, _dir);
    yspd = lengthdir_y(_spd * _level, _dir);

    pixels_walked = irandom_range(_min_px, _max_px);

    // re-sorteia o timer para a próxima mudança de direção
    timer_max = irandom_range(timer_min, timer_max);
}
```

**O que mudou:**
- Adicionados 4 parâmetros **opcionais** com valores padrão
- `_spd` default = `moveSpd` → `oNpc` continua funcionando **sem nenhuma mudança**
- `_min_px` / `_max_px` defaults = 16 / 64 → mesmo comportamento de antes
- **`_diagonal`** default = `false` → 4 direções (retrocompatível). Se `true` → 8 direções
- Velocidade diagonal normalizada com fator `0.707` (1/√2) para que mover na diagonal não seja mais rápido que nas cardinais
- Adicionada documentação JSDoc

### Sobre a normalização diagonal

Usa o **mesmo padrão do `oPlayer`**: `point_direction` + `lengthdir_x/y` com `clamp` em 1. Quando `_h=1, _v=1` (diagonal), `point_distance(0,0,1,1) = √2 ≈ 1.414` é clampado para `1`, e `lengthdir_x/y` distribui a velocidade corretamente nos dois eixos. Resultado: velocidade real é sempre `_spd`, tanto na cardinal quanto na diagonal.

---

### Mudança 2 — Criar `scr_initMovimento`

> Novo script que inicializa todas as variáveis de movimento de uma vez.

**Criar pasta:** `scripts/scr_initMovimento/`

**Criar arquivo:** `scripts/scr_initMovimento/scr_initMovimento.gml`

```gml
/// @function scr_initMovimento([_spd], [_timer_min], [_timer_max])
/// @description Inicializa as variáveis do sistema de movimento aleatório.
///              Chamar no Create de qualquer objeto que usar scr_escolherDirecao.
///              O timer_max é gerado aleatoriamente dentro do range fornecido.
/// @param {real} [_spd]       Velocidade de movimento (default: 2)
/// @param {real} [_timer_min] Mínimo de frames entre mudanças de direção (default: 90)
/// @param {real} [_timer_max] Máximo de frames entre mudanças de direção (default: 300)

function scr_initMovimento(_spd = 2, _timer_min = 90, _timer_max = 300) {
    moveSpd       = _spd;
    xspd          = 0;
    yspd          = 0;
    timer         = 0;
    timer_min     = _timer_min;
    timer_max     = irandom_range(_timer_min, _timer_max);
    pixels_walked = 0;
}
```

> **Timer aleatório:** Cada instância recebe um `timer_max` diferente dentro do range, evitando que todos os objetos mudem de direção ao mesmo tempo. Além disso, a cada mudança de direção (no Step), o `timer_max` é re-sorteado — veja a Mudança 1 abaixo.

**Criar arquivo:** `scripts/scr_initMovimento/scr_initMovimento.yy`

```json
{
  "$GMScript":"",
  "%Name":"scr_initMovimento",
  "isDnD":false,
  "name":"scr_initMovimento",
  "parent":{
    "name":"scripts",
    "path":"folders/Scripts.yy",
  },
  "resourceType":"GMScript",
  "resourceVersion":"2.0",
}
```

> ⚠️ **Nota:** O formato exato do `.yy` pode variar dependendo da versão do GameMaker. Se der erro, crie o script pelo IDE do GameMaker (botão direito em Scripts → Create Script) e cole o código do `.gml`.

---

### Mudança 3 — Registrar no projeto `.yyp`

**Arquivo:** `LobisomenPidao_Demo.yyp`

Procure a seção onde os outros scripts estão listados (perto de `scr_escolherDirecao`) e adicione:

```json
{"id":{"name":"scr_initMovimento","path":"scripts/scr_initMovimento/scr_initMovimento.yy",},},
```

> ⚠️ Mesma nota: se preferir, crie o script pelo IDE e essa entrada será adicionada automaticamente.

---

### Mudança 4 — Simplificar `oNpc/Create_0.gml`

**Arquivo:** `objects/oNpc/Create_0.gml`

**Código atual (linhas 1-8):**
```gml
moveSpd = 2;
xspd = 0;
yspd = 0;

timer = 0;
timer_max = 180;

pixels_walked = 0;
```

**Substituir por:**
```gml
scr_initMovimento(2, 90, 300);
```

> `scr_initMovimento(2, 90, 300)` → vel=2, timer entre 90–300 frames (1.5–5 seg). O timer é re-sorteado automaticamente a cada mudança de direção.

O restante do arquivo (`// Interação`, `// sprite control`, `// Reação`) permanece **inalterado**.

---

## 📐 Como Funciona

### Antes (acoplado ao oNpc)

```
oNpc Create → define moveSpd, xspd, yspd, pixels_walked manualmente
oNpc Step   → chama scr_escolherDirecao() que usa moveSpd hardcoded
```

### Depois (genérico)

```
Qualquer objeto Create → chama scr_initMovimento(_spd, _timer_min, _timer_max)
Qualquer objeto Step   → chama scr_escolherDirecao() ou scr_escolherDirecao(_spd, _min, _max)
```

### Fluxo para novo objeto

```
1. Create:  scr_initMovimento(vel, tMin, tMax)  → cria moveSpd, xspd, yspd, timer, pixels_walked
2. Step:    timer++ → if timer >= timer_max → scr_escolherDirecao()
3. Step:    if pixels_walked > 0 → move + colisão (copiar de oNpc ou fazer seu próprio)
```

---

## 🛠️ Exemplo Completo — Usando em um Novo Objeto

Supondo que você queira criar um `oAnimal` que anda aleatoriamente:

### `objects/oAnimal/Create_0.gml`

```gml
// Movimento — usa o sistema reutilizável
scr_initMovimento(1, 60, 180);   // vel=1, muda de direção a cada 1-3 segundos (random)

// Sprite control
face = 3;
sprite[0] = sAnimalSide;
sprite[2] = sAnimalUp;
sprite[3] = sAnimalDown;

sprite_index = sprite[face];
image_speed  = 0;
mask_index   = sprite[3];
```

### `objects/oAnimal/Step_0.gml`

```gml
// Movimentação (mesmo padrão do oNpc)
timer++;
if (timer >= timer_max) {
    timer = 0;
    scr_escolherDirecao();                    // 4 direções, usa moveSpd do init
    // OU: scr_escolherDirecao(3);            // override: velocidade 3
    // OU: scr_escolherDirecao(1, 32, 128);   // override: vel=1, anda 32-128px
    // OU: scr_escolherDirecao(1, 16, 64, true);  // 8 direções (com diagonais!)
}

if (pixels_walked > 0) {
    if (xspd != 0) {
        if place_meeting(x + xspd, y, oWall) { pixels_walked = 0; xspd = 0; }
        if (xspd != 0) { x += xspd; pixels_walked -= abs(xspd); }
    }

    if (yspd != 0) {
        if place_meeting(x, y + yspd, oWall) { pixels_walked = 0; yspd = 0; }
        if (yspd != 0) { y += yspd; pixels_walked -= abs(yspd); }
    }
}

// Sprite control (com suporte a diagonal)
var _movendo = (pixels_walked > 0);
if (_movendo) {
    var _h = sign(xspd);
    var _v = sign(yspd);

    // Cardinais (mesmo padrão do oNpc)
    if (_h != 0 && _v == 0) { face = 0; image_xscale = _h; }
    if (_h == 0 && _v != 0) { face = (_v == -1) ? 2 : 3; image_xscale = 1; }

    // Diagonais (se o objeto tiver sprites diagonais nas faces 1 e 4)
    // face 1 = diagonal-cima, face 4 = diagonal-baixo (mesmo padrão do oInimigo)
    if (_h != 0 && _v == -1) { face = 1; image_xscale = _h; }
    if (_h != 0 && _v ==  1) { face = 4; image_xscale = _h; }
}
sprite_index = sprite[face];
depth = -y;
```

> **Nota sobre sprites diagonais:** Se seu objeto **não** tem sprites de diagonal, basta omitir as faces 1 e 4 e remover as duas linhas de diagonal acima. O objeto usará o sprite lateral (`face = 0`) ao se mover na diagonal, o que já fica visualmente aceitável.

---

## ⚙️ Referência Rápida dos Parâmetros

### `scr_initMovimento(_spd, _timer_min, _timer_max)`

| Parâmetro | Default | Descrição |
|---|---|---|
| `_spd` | `2` | Velocidade de movimento (pixels/frame) |
| `_timer_min` | `90` | Mínimo de frames entre mudanças de direção (90 = 1.5 seg) |
| `_timer_max` | `300` | Máximo de frames entre mudanças de direção (300 = 5 seg) |

> O `timer_max` é sorteado no init e **re-sorteado** a cada chamada de `scr_escolherDirecao`, gerando um comportamento mais orgânico.

### `scr_escolherDirecao(_spd, _min_px, _max_px, _diagonal)`

| Parâmetro | Default | Descrição |
|---|---|---|
| `_spd` | `moveSpd` | Velocidade para esta movimentação |
| `_min_px` | `16` | Mínimo de pixels a caminhar |
| `_max_px` | `64` | Máximo de pixels a caminhar |
| `_diagonal` | `false` | Se `true`, inclui 4 diagonais (8 direções no total) |

### Mapa de direções

```
_diagonal = false (4 dirs)       _diagonal = true (8 dirs)

         ↑ (cima)                  ↖    ↑    ↗
         |                          \   |   /
    ← ───┼──→                   ← ──┼───┼──→
         |                          /   |   \
         ↓ (baixo)                 ↙    ↓    ↘
```

---

## ⚠️ Observações

1. **Retrocompatível** — O `oNpc` continua funcionando exatamente como antes. A chamada `scr_escolherDirecao()` sem argumentos usa os defaults.

2. **`oInimigo` não é afetado** — Ele tem seu próprio sistema de estados (`estado_parado`, `estado_passeando`, `estado_perseguindo`) com `lengthdir_x/y`. Sistemas diferentes, propósitos diferentes.

3. **Variáveis na instância** — O script `scr_escolherDirecao` seta `xspd`, `yspd` e `pixels_walked` diretamente na instância que o chamou (`self`). Isso é o padrão do GameMaker.

4. **GML 2.3+** — A sintaxe `_spd = moveSpd` (parâmetros opcionais) requer GameMaker 2.3 ou superior. Se estiver usando uma versão anterior, será necessário usar `argument_count` e `argument[n]`.

5. **Ordem de criação** — Certifique-se de chamar `scr_initMovimento()` **antes** de `scr_escolherDirecao()`. Normalmente o init vai no Create e o escolher vai no Step, então não tem problema.

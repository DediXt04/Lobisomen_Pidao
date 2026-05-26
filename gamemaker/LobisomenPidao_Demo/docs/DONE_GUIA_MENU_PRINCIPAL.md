# 🎮 Guia de Implementação — Tela Principal (Main Menu)

> Guia para criar a tela principal do jogo com nome do jogo e 3 botões (Play, Settings, Exit) posicionados no canto inferior direito.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Resolução da room | 1920×1080 |
| Fonte | `fnt_pixel` (já existe no projeto) |
| Paleta de cores | Navy escuro (`rgb(20, 22, 38)`) + Teal (`rgb(80, 200, 210)`) |
| Input | Teclado (WASD/Arrows/Space/E) + Gamepad (D-pad/Stick/A) |
| `global.gamepad_main` | Gerenciado por `oProcuraControle` (persistente) |
| Room inicial atual | `rm_SelecaoDeFases` |
| Room de seleção de fases | `rm_SelecaoDeFases` (destino do botão Play) |

---

## 🏗️ Estrutura Geral

### Layout Visual

O nome do jogo e os botões ficam **agrupados no canto inferior direito** da tela. O restante da tela fica livre para arte de fundo, ilustração ou animação.

```
┌───────────────────────────────────────────────────────────┐
│                                                           │
│                                                           │
│   (área livre — fundo, arte, ilustração do lobo, etc.)    │
│                                                           │
│                                                           │
│                                                           │
│                                                           │
│                                         ┌───────────────┐ │
│                                         │  LOBISOMEM    │ │
│                                         │    PIDÃO      │ │
│                                         │               │ │
│                                         │  ▸ Play       │ │
│                                         │    Settings   │ │
│                                         │    Exit       │ │
│                                         └───────────────┘ │
└───────────────────────────────────────────────────────────┘
```

### Hierarquia de Elementos (de cima para baixo no grupo)

1. **Nome do jogo** — título grande, cor teal
2. **Botão Play** — leva para `rm_SelecaoDeFases`
3. **Botão Settings** — abre tela de configurações (futuro)
4. **Botão Exit** — fecha o jogo

---

## 📦 O Que Criar

| Recurso | Tipo | Descrição |
|---|---|---|
| `rm_MenuPrincipal` | Room | Nova room 1920×1080, será a room inicial do jogo |
| `oMenuPrincipal` | Objeto | Sem sprite. Gerencia título, botões, navegação e desenho |

### Instâncias na Room

| Objeto | Obrigatório | Nota |
|---|---|---|
| `oMenuPrincipal` | ✅ Sim | Posição não importa (sem sprite, tudo desenhado via Draw) |
| `oProcuraControle` | ✅ Sim | Precisa existir para `global.gamepad_main` funcionar |

---

## 💻 Código

### `objects/oMenuPrincipal/Create_0.gml`

```gml
// === BOTÕES ===
botoes = ["Play", "Settings", "Exit"];
total_botoes = array_length(botoes);
botao_focado = 0;

// === LAYOUT (canto inferior direito) ===
// Resolução base da GUI (fixa, independente de câmera)
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

// Margem a partir do canto inferior direito da tela
margem_direita = 120;   // distância da borda direita
margem_inferior = 100;  // distância da borda inferior

// Dimensões dos botões
btn_w = 280;
btn_h = 50;
btn_gap = 16;  // espaço vertical entre botões

// Posição X dos botões (alinhados à direita)
btn_x = gui_w - margem_direita - btn_w;

// Posição Y do grupo (calculada de baixo para cima)
// Altura total: 3 botões + 2 gaps + espaço pro título
var _altura_botoes = total_botoes * btn_h + (total_botoes - 1) * btn_gap;
var _espaco_titulo = 80;  // espaço entre título e primeiro botão

btn_y_inicio = gui_h - margem_inferior - _altura_botoes;

// Posição do título (acima dos botões)
titulo_x = btn_x + btn_w / 2;  // centralizado com os botões
titulo_y = btn_y_inicio - _espaco_titulo;

// === NAVEGAÇÃO ===
nav_cooldown = 0;
NAV_COOLDOWN_MAX = 12;  // frames entre inputs (evita rapidez)
input_mode = "teclado";
DEADZONE = 0.5;
```

---

### `objects/oMenuPrincipal/Step_0.gml`

```gml
// ===============================================================
// DETECTAR MODO DE INPUT (teclado vs controle)
// ===============================================================
var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

if (_tem_controle) {
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    var _btn_any = gamepad_button_check_pressed(_gp, gp_face1)
                || gamepad_button_check_pressed(_gp, gp_padu)
                || gamepad_button_check_pressed(_gp, gp_padd);

    if (abs(_ay) > DEADZONE || _btn_any) {
        input_mode = "controle";
    }
}

if (keyboard_check_pressed(vk_anykey)) {
    input_mode = "teclado";
}

// ===============================================================
// COOLDOWN DE NAVEGAÇÃO
// ===============================================================
if (nav_cooldown > 0) nav_cooldown--;

// ===============================================================
// NAVEGAÇÃO VERTICAL ENTRE BOTÕES
// ===============================================================
var _mover = 0;

// Teclado
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) _mover =  1;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) _mover = -1;

// Gamepad
if (_tem_controle && nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padd)) _mover =  1;
    if (gamepad_button_check_pressed(_gp, gp_padu)) _mover = -1;

    var _ay = gamepad_axis_value(_gp, gp_axislv);
    if (_ay >  DEADZONE) _mover =  1;
    if (_ay < -DEADZONE) _mover = -1;

    if (_mover != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Aplica navegação (com wrap-around)
if (_mover != 0) {
    botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
}

// ===============================================================
// CONFIRMAR — SPACE / E / botão A
// ===============================================================
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (_tem_controle) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(_gp, gp_face1);
}

if (_confirmar) {
    switch (botao_focado) {
        case 0:  // Play → ir para seleção de fases
            room_goto(rm_SelecaoDeFases);
            break;

        case 1:  // Settings → tela de configurações
            // TODO: implementar tela de configurações
            // room_goto(rm_Settings);
            break;

        case 2:  // Exit → fechar o jogo
            game_end();
            break;
    }
}
```

---

### `objects/oMenuPrincipal/Draw_64.gml`

> ⚠️ **IMPORTANTE:** Usar evento **Draw GUI** (Draw_64), NÃO Draw normal. O Draw GUI desenha na tela independente de câmera/views — funciona com qualquer configuração de room.

```gml
// ===============================================================
// FUNDO
// ===============================================================
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_color(make_color_rgb(20, 22, 38));
draw_rectangle(0, 0, _gw, _gh, false);

// Linhas decorativas (mesmo estilo do oSeletorDeFases)
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.2);
draw_line_width(0, _gh - 140, _gw, _gh - 140, 2);
draw_set_alpha(1);

// ===============================================================
// NOME DO JOGO
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Sombra do título
draw_set_color(make_color_rgb(10, 10, 20));
draw_text_transformed(titulo_x + 3, titulo_y + 3, "LOBISOMEM\nPIDAO", 2, 2, 0);

// Título principal
draw_set_color(make_color_rgb(80, 200, 210));
draw_text_transformed(titulo_x, titulo_y, "LOBISOMEM\nPIDAO", 2, 2, 0);

// ===============================================================
// BOTÕES
// ===============================================================
for (var i = 0; i < total_botoes; i++) {
    var _bx = btn_x;
    var _by = btn_y_inicio + i * (btn_h + btn_gap);
    var _focado = (i == botao_focado);

    // --- Fundo do botão ---
    if (_focado) {
        // Botão selecionado — fundo teal escuro
        draw_set_color(make_color_rgb(25, 55, 75));
    } else {
        // Botão normal — navy escuro
        draw_set_color(make_color_rgb(18, 22, 42));
    }
    draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, false);

    // --- Barra lateral esquerda (indicador de foco) ---
    if (_focado) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_bx, _by, _bx + 5, _by + btn_h, false);
    }

    // --- Borda do botão ---
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(_focado ? 0.8 : 0.3);
    draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, true);
    draw_set_alpha(1);

    // --- Texto do botão ---
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (_focado) {
        draw_set_color(make_color_rgb(120, 230, 240));
    } else {
        draw_set_color(make_color_rgb(80, 130, 150));
    }
    draw_text(_bx + btn_w / 2, _by + btn_h / 2, botoes[i]);

    // --- Seta indicadora ▸ (só no botão focado) ---
    if (_focado) {
        draw_set_halign(fa_right);
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_text(_bx - 12, _by + btn_h / 2, chr(9658));  // ▸
    }
}

// ===============================================================
// RODAPÉ — DICA DE INPUT DINÂMICA
// ===============================================================
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(45, 80, 95));

var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

if (_tem_controle && input_mode == "controle") {
    draw_text(_gw / 2, _gh - 20, "D-pad / Analogico: Navegar    A / Cruz: Confirmar");
} else {
    draw_text(_gw / 2, _gh - 20, "W S / Setas: Navegar    SPACE / E: Confirmar");
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

---

## 📐 Como Funciona

### Fluxo de Telas

```
┌──────────────────────┐
│   rm_MenuPrincipal   │  ← Room inicial do jogo (NOVA)
│   (oMenuPrincipal)   │
└──────┬───────────────┘
       │
       │ Play
       ▼
┌──────────────────────┐
│  rm_SelecaoDeFases   │  ← Room que já existe
│  (oSeletorDeFases)   │
└──────┬───────────────┘
       │
       │ Seleciona fase
       ▼
┌──────────────────────┐
│  room_01 / room_02   │  ← Gameplay
└──┬───────────────┬───┘
   │               │
   │ Morreu        │ Venceu
   ▼               ▼
┌────────┐   ┌──────────────────────┐
│ Game   │   │ Vitória              │
│ Over   │   │  ├─ Seleção de Fases │ → rm_SelecaoDeFases
│        │   │  └─ Menu Principal   │ → rm_MenuPrincipal
└───┬────┘   └──────────────────────┘
    │
    └─→ rm_MenuPrincipal
```

### Posicionamento (Canto Inferior Direito)

O layout é calculado **de baixo para cima**:

```
1920
  ├── margem_direita (120px) ──┤
                               │
  ┌─────── btn_w (280px) ─────┐│
  │                            ││
  │  titulo_y ─── LOBISOMEM   ││
  │               PIDÃO        ││
  │                            ││
  │  80px de espaço            ││
  │                            ││
  │  btn_y_inicio ── [ Play ]  ││
  │  + btn_h + gap── [Settings]││
  │  + btn_h + gap── [ Exit ]  ││
  │                            ││
  │  margem_inferior (100px)   ││
  └────────────────────────────┘│
                             1080
```

### Navegação por Botões

```
botao_focado = 0  →  Play        ← W / ↑ / D-pad Up
botao_focado = 1  →  Settings    
botao_focado = 2  →  Exit        ← S / ↓ / D-pad Down
                                   (com wrap-around: Exit → Play)
```

A navegação usa **wrap-around**: ao descer no último botão, volta pro primeiro (e vice-versa). Isso é feito com a fórmula:

```gml
botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
```

### Detecção de Input (Teclado vs Controle)

O sistema detecta automaticamente qual dispositivo está sendo usado:

```
Usuário aperta tecla   → input_mode = "teclado"  → mostra dicas de teclado
Usuário aperta gamepad → input_mode = "controle" → mostra dicas de controle
```

Isso é o **mesmo padrão usado pelo `oSeletorDeFases`** — consistência visual.

---

## 🛠️ Instruções de Implementação

### Passo 1 — Criar a Room

1. No GameMaker, clique com botão direito em **Rooms** → **Create Room**
2. Nomeie como `rm_MenuPrincipal`
3. **Tamanho:** 1920 × 1080
4. **Views:** não importa (o Draw GUI ignora câmera/views)
5. Arraste `oMenuPrincipal` para a room (posição não importa)
6. Arraste `oProcuraControle` para a room (se já estiver lá por persistência, pule)

### Passo 2 — Criar o Objeto

1. Clique com botão direito em **Objects** → **Create Object**
2. Nomeie como `oMenuPrincipal`
3. **Não** atribua sprite
4. Crie 3 eventos:
   - **Create** → cole o código do `Create_0.gml`
   - **Step** → cole o código do `Step_0.gml`
   - **Draw GUI** → cole o código do `Draw_64.gml` (⚠️ é Draw GUI, NÃO Draw normal!)

### Passo 3 — Mudar a Room Inicial

1. No **Room Order** (painel da esquerda), arraste `rm_MenuPrincipal` para o **topo** da lista
2. A ordem final deve ser:
   ```
   rm_MenuPrincipal      ← PRIMEIRA (tela de menu)
   rm_SelecaoDeFases
   room_01
   room_02
   rm_gameOver
   rm_Vitoria
   ```

### Passo 4 — Atualizar `oGameOver` (retorno ao menu)

**`oGameOver/Step_0.gml`:**
```gml
// ANTES:
room_goto(rm_SelecaoDeFases);

// DEPOIS:
room_goto(rm_MenuPrincipal);
```

### Passo 5 — Reescrever `oVitoria` (2 botões com navegação)

A tela de vitória agora tem **dois botões** com navegação por teclado/controle:
- **Seleção de Fases** → volta para `rm_SelecaoDeFases`
- **Menu Principal** → volta para `rm_MenuPrincipal`

#### 5.1 — Criar evento Create no `oVitoria`

No GameMaker, abra `oVitoria` → **Add Event** → **Create**.

**`objects/oVitoria/Create_0.gml`:**

```gml
// === BOTÕES ===
botoes = ["Selecao de Fases", "Menu Principal"];
total_botoes = array_length(botoes);
botao_focado = 0;

// === NAVEGAÇÃO ===
nav_cooldown = 0;
NAV_COOLDOWN_MAX = 12;
input_mode = "teclado";
DEADZONE = 0.5;
```

#### 5.2 — Substituir o Step do `oVitoria`

**`objects/oVitoria/Step_0.gml`** — substituir todo o conteúdo por:

```gml
// ===============================================================
// DETECTAR MODO DE INPUT
// ===============================================================
var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

if (_tem_controle) {
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    var _btn_any = gamepad_button_check_pressed(_gp, gp_face1)
                || gamepad_button_check_pressed(_gp, gp_padu)
                || gamepad_button_check_pressed(_gp, gp_padd);

    if (abs(_ay) > DEADZONE || _btn_any) {
        input_mode = "controle";
    }
}

if (keyboard_check_pressed(vk_anykey)) {
    input_mode = "teclado";
}

// ===============================================================
// COOLDOWN
// ===============================================================
if (nav_cooldown > 0) nav_cooldown--;

// ===============================================================
// NAVEGAÇÃO VERTICAL
// ===============================================================
var _mover = 0;

// Teclado
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) _mover =  1;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) _mover = -1;

// Gamepad
if (_tem_controle && nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padd)) _mover =  1;
    if (gamepad_button_check_pressed(_gp, gp_padu)) _mover = -1;

    var _ay = gamepad_axis_value(_gp, gp_axislv);
    if (_ay >  DEADZONE) _mover =  1;
    if (_ay < -DEADZONE) _mover = -1;

    if (_mover != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Aplica navegação (com wrap-around)
if (_mover != 0) {
    botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
}

// ===============================================================
// CONFIRMAR — SPACE / E / botão A
// ===============================================================
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (_tem_controle) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(_gp, gp_face1);
}

if (_confirmar) {
    switch (botao_focado) {
        case 0:  // Seleção de Fases
            room_goto(rm_SelecaoDeFases);
            break;
        case 1:  // Menu Principal
            room_goto(rm_MenuPrincipal);
            break;
    }
}
```

#### 5.3 — Substituir o Draw do `oVitoria`

**`objects/oVitoria/Draw_64.gml`** (⚠️ Draw GUI!) — substituir todo o conteúdo por:

```gml
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;
var _cy = _gh / 2;

// ===============================================================
// FUNDO
// ===============================================================
draw_set_alpha(0.85);
draw_set_color(make_color_rgb(14, 14, 26));
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// Linhas decorativas
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.35);
draw_line_width(0, _cy - 140, _gw, _cy - 140, 2);
draw_line_width(0, _cy + 140, _gw, _cy + 140, 2);
draw_set_alpha(1);

// ===============================================================
// TÍTULO
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(80, 200, 210));
draw_text(_cx, _cy - 80, "VOCE VENCEU!");

// Mensagem
draw_set_color(make_color_rgb(130, 165, 180));
draw_text(_cx, _cy - 30, "Mim de papai.");

// ===============================================================
// BOTÕES (mesmo estilo do oGameOver)
// ===============================================================
var _bw = 280;
var _bh = 54;
var _btn_gap = 16;
var _btn_start_y = _cy + 30;

for (var i = 0; i < total_botoes; i++) {
    var _bx = _cx - _bw / 2;
    var _by = _btn_start_y + i * (_bh + _btn_gap);
    var _focado = (i == botao_focado);

    // Fundo do botão
    draw_set_color(_focado
        ? make_color_rgb(30, 60, 80)
        : make_color_rgb(20, 35, 55));
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

    // Barra lateral esquerda (indicador de foco)
    if (_focado) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_bx, _by, _bx + 5, _by + _bh, false);
    }

    // Borda
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(_focado ? 0.8 : 0.4);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
    draw_set_alpha(1);

    // Texto
    draw_set_color(_focado
        ? make_color_rgb(120, 225, 235)
        : make_color_rgb(80, 200, 210));
    draw_text(_cx, _by + _bh / 2, botoes[i]);
}

// ===============================================================
// RODAPÉ — dica de input dinâmica
// ===============================================================
var _rodape_y = _btn_start_y + total_botoes * (_bh + _btn_gap) + 20;

var _gp = global.gamepad_main;
var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);

draw_set_color(make_color_rgb(45, 80, 95));
if (_temControle && input_mode == "controle") {
    draw_text(_cx, _rodape_y, "D-pad: Navegar    A / Cruz: Confirmar");
} else {
    draw_text(_cx, _rodape_y, "W S / Setas: Navegar    SPACE / E: Confirmar");
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

> **Nota:** O `oVitoria` não tinha evento Create antes — precisa ser adicionado pelo IDE (Add Event → Create). O Draw deve ser **Draw GUI** (Draw_64), não Draw normal. O `.yy` será atualizado automaticamente.

### Passo 6 — Testar

1. Rode o jogo — deve abrir em `rm_MenuPrincipal`
2. Teste navegação com teclado (W/S, setas, Space)
3. Teste navegação com controle (D-pad, analog, botão A)
4. Confirme que:
   - **Menu Principal:**
     - **Play** → vai para `rm_SelecaoDeFases`
     - **Settings** → não faz nada ainda (TODO)
     - **Exit** → fecha o jogo
   - **Tela de Vitória:**
     - **Seleção de Fases** → vai para `rm_SelecaoDeFases`
     - **Menu Principal** → vai para `rm_MenuPrincipal`
     - Navegação W/S e D-pad funciona entre os 2 botões
   - **Tela de Game Over:**
     - Space/A → vai para `rm_MenuPrincipal`

---

## ⚙️ Personalização

### Ajustar Posição do Grupo

Para mover o grupo inteiro, altere as margens no `Create_0.gml`:

```gml
margem_direita = 120;   // aumentar = move para esquerda
margem_inferior = 100;  // aumentar = move para cima
```

### Alterar Tamanho dos Botões

```gml
btn_w = 280;   // largura do botão
btn_h = 50;    // altura do botão
btn_gap = 16;  // espaço entre botões
```

### Adicionar Fundo/Arte

No `Draw_0.gml`, **antes** de desenhar os botões, adicione um sprite de fundo:

```gml
// Desenhar arte de fundo (se tiver sprite)
draw_sprite_stretched(sMenuFundo, 0, 0, 0, 1920, 1080);
```

### Adicionar Novos Botões

1. Adicione o texto no array `botoes` no Create:
   ```gml
   botoes = ["Play", "Settings", "Credits", "Exit"];
   ```
2. Adicione o case no switch do Step:
   ```gml
   case 2:  // Credits
       room_goto(rm_Credits);
       break;
   case 3:  // Exit (agora é o índice 3)
       game_end();
       break;
   ```
3. O layout se ajusta automaticamente (usa `total_botoes` e `array_length`).

---

## ⚠️ Observações

1. **`oProcuraControle`** — Este objeto é persistente e se auto-previne de duplicação. Se ele já existe de uma sessão anterior, não será duplicado. Basta garantir que ele esteja na `rm_MenuPrincipal` (ou que já tenha sido criado antes).

2. **Draw GUI (Draw_64)** — O guia usa `Draw_64` (Draw GUI) porque esse evento desenha **na tela independente de câmera/views**. Isso evita o problema de botões ficarem fora da área visível quando a room tem viewport/câmera ativa. Não precisa desabilitar views na room.

3. **Paleta de cores** — As cores usadas seguem o mesmo padrão do `oSeletorDeFases`, `oGameOver` e `oVitoria` para manter consistência visual:
   - Fundo: `rgb(20, 22, 38)` — navy escuro
   - Destaque: `rgb(80, 200, 210)` — teal
   - Texto normal: `rgb(80, 130, 150)` — cinza azulado
   - Texto focado: `rgb(120, 230, 240)` — teal claro

4. **Settings** — O botão Settings está preparado como `TODO`. Quando for implementar, crie uma nova room ou overlay e adicione o `room_goto` no case 1 do switch.

5. **Wrap-around** — Diferente do `oSeletorDeFases` (que usa `clamp`), o menu principal usa módulo (`%`) para que a navegação "gire" entre o último e o primeiro botão. Isso é intencional — em menus com poucos botões, wrap-around é mais confortável.

6. **`chr(9658)`** — O caractere `▸` usado como seta indicadora. Se a fonte `fnt_pixel` não incluir esse caractere, substitua por `">"` ou use um sprite de seta (`draw_sprite` em vez de `draw_text`).

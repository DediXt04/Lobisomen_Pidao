# 🏆⚙️ Guia de Implementação — Botão "Próxima Fase" + Tela de Settings

> Guia completo para adicionar o botão **"Próxima Fase"** na tela de vitória e criar a **Tela de Settings** com opção de resetar progresso (com confirmação).

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Resolução das rooms de menu | 1920×1080 |
| Fonte | `fnt_pixel` (já existe no projeto) |
| Paleta de cores | Navy escuro `rgb(14,14,26)` + Teal `rgb(80,200,210)` |
| Input | Teclado (WASD/AD + Space/E/Enter) + Gamepad (D-pad/Stick + A/Cruz) |
| `global.gamepad_main` | Gerenciado por `oProcuraControle` (persistente) |
| Progressão existente | `global.fase_atual`, `global.fase_desbloqueada`, INI `save_progresso.ini` |
| Objetos de referência | `oVitoria`, `oMenuPrincipal`, `oSeletorDeFases` |

---

## 🏗️ Estrutura Geral

### Feature 1 — Botão "Próxima Fase" (oVitoria)

O botão aparece **somente** se a fase atual não é a última. Ao clicar, desbloqueia a próxima fase e vai direto para ela.

**Layout visual (3 botões — se não é última fase):**

```
┌──────────────────────────────────────────────────────┐
│                ═══════════════                        │
│                                                      │
│               VOCÊ VENCEU!                           │
│              Mim de papai.                           │
│                                                      │
│   ┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│   │▌ Próxima Fase  │ │  Reiniciar     │ │  Voltar ao     │
│   │                │ │  Fase          │ │  Menu          │
│   └────────────────┘ └────────────────┘ └────────────────┘
│                                                      │
│       A D  para navegar     SPACE  para confirmar    │
│                ═══════════════                        │
└──────────────────────────────────────────────────────┘
```

**Layout visual (2 botões — última fase):**

```
┌──────────────────────────────────────────────────────┐
│               VOCÊ VENCEU!                           │
│              Mim de papai.                           │
│                                                      │
│      ┌────────────────────┐  ┌────────────────────┐  │
│      │▌ Reiniciar Fase    │  │   Voltar ao Menu   │  │
│      └────────────────────┘  └────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

### Feature 2 — Tela de Settings

Acessível pelo botão "Settings" do menu principal (atualmente TODO). Tem 2 opções: **Resetar Progresso** e **Voltar**. O reset exige **confirmação** com overlay.

**Layout visual (normal):**

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│                        SETTINGS              (direita)│
│                                                      │
│                  ┌──────────────────────┐            │
│                  │▌ Resetar Progresso   │            │
│                  └──────────────────────┘            │
│                  ┌──────────────────────┐            │
│                  │    Voltar            │            │
│                  └──────────────────────┘            │
│                                                      │
│      W S  para navegar   SPACE para confirmar        │
│                                      ESC para voltar │
└──────────────────────────────────────────────────────┘
```

**Layout visual (overlay de confirmação):**

```
┌──────────────────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░  ┌─────────────────────────┐  ░░░░░░░░░░ │
│ ░░░░░░░░░░  │    Tem certeza?         │  ░░░░░░░░░░ │
│ ░░░░░░░░░░  │                         │  ░░░░░░░░░░ │
│ ░░░░░░░░░░  │   ┌──────┐  ┌──────┐   │  ░░░░░░░░░░ │
│ ░░░░░░░░░░  │   │▌ Sim │  │  Não │   │  ░░░░░░░░░░ │
│ ░░░░░░░░░░  │   └──────┘  └──────┘   │  ░░░░░░░░░░ │
│ ░░░░░░░░░░  └─────────────────────────┘  ░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
└──────────────────────────────────────────────────────┘
```

### Fluxo

```
oMenuPrincipal
  │
  ├─ "Play" → rm_SelecaoDeFases
  ├─ "Settings" → rm_Settings  ← NOVO
  │       │
  │       ├─ "Resetar Progresso" → overlay "Tem certeza?"
  │       │       ├─ "Sim" → reseta INI + global → volta ao menu normal
  │       │       └─ "Não" → fecha overlay
  │       │
  │       └─ "Voltar" / ESC → rm_MenuPrincipal
  │
  └─ "Exit" → game_end()

oVitoria (após vencer fase)
  │
  ├─ "Próxima Fase" → desbloqueia + room_goto(próxima)  ← NOVO
  ├─ "Reiniciar Fase" → room_goto(fase_atual)
  └─ "Voltar ao Menu" → desbloqueia + rm_SelecaoDeFases
```

---

## 📦 O Que Criar / Modificar

| Arquivo | Ação |
|---|---|
| `oSeletorDeFases/Create_0.gml` | **MODIFICAR** — tornar `fase_rooms` e `total_fases` globais |
| `oSeletorDeFases/Step_0.gml` | **MODIFICAR** — remover tecla debug F2 |
| `oVitoria/Create_0.gml` | **MODIFICAR** — botões dinâmicos com "Próxima Fase" |
| `oVitoria/Step_0.gml` | **MODIFICAR** — ação "Próxima Fase" + ajustes |
| `oSettings/Create_0.gml` | **NOVO** — botões + estado de confirmação |
| `oSettings/Step_0.gml` | **NOVO** — navegação + reset + confirmação |
| `oSettings/Draw_64.gml` | **NOVO** — visual do menu + overlay de confirmação |
| `oMenuPrincipal/Step_0.gml` | **MODIFICAR** — ativar botão Settings |
| `rm_Settings` (room) | **NOVO** — room 1920×1080 com oSettings |

---

## 💻 Código

---

### Parte 1 — Globals no Seletor de Fases

O `oVitoria` precisa saber quais rooms existem e quantas fases há no total. Para isso, tornamos `fase_rooms` e `total_fases` globais.

#### Modificar `oSeletorDeFases/Create_0.gml`

**ANTES (linhas 1–20):**

```gml
fase_rooms = [
    room_01,
    room_02,
    rm_fase03,
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset",
    "Fase nova",

];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
    "Faso nova",
];

total_fases      = array_length(fase_rooms);
```

**DEPOIS:**

```gml
global.fase_rooms = [
    room_01,
    room_02,
    rm_fase03,
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset",
    "Fase nova",
];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
    "Faso nova",
];

global.total_fases = array_length(global.fase_rooms);
```

> **Importante:** Agora `fase_rooms` e `total_fases` são globais. Isso exige trocar as referências locais no mesmo arquivo.

#### Atualizar referências em `oSeletorDeFases/Create_0.gml`

Trocar as variáveis locais pelas globais no restante do Create:

| Antes | Depois |
|---|---|
| `total_fases` | `global.total_fases` |
| `fase_rooms[...]` | `global.fase_rooms[...]` |

**Linhas afetadas (substituir):**

```gml
// ANTES:
total_paginas = max(1, ceil(total_fases / por_pagina));

// DEPOIS:
total_paginas = max(1, ceil(global.total_fases / por_pagina));
```

#### Atualizar referências em `oSeletorDeFases/Step_0.gml`

Substituir todas as ocorrências:

| Antes | Depois |
|---|---|
| `total_fases - 1` | `global.total_fases - 1` |
| `fase_rooms[fase_selecionada]` | `global.fase_rooms[fase_selecionada]` |

**Linhas afetadas:**

```gml
// ANTES:
_novo = clamp(_novo, 0, total_fases - 1);
// (aparece 2 vezes)

// DEPOIS:
_novo = clamp(_novo, 0, global.total_fases - 1);
```

```gml
// ANTES:
room_goto(fase_rooms[fase_selecionada]);

// DEPOIS:
room_goto(global.fase_rooms[fase_selecionada]);
```

#### Atualizar referências em `oSeletorDeFases/Draw_0.gml`

```gml
// ANTES:
var _fim = min(_inicio + por_pagina, total_fases);

// DEPOIS:
var _fim = min(_inicio + por_pagina, global.total_fases);
```

---

### Parte 2 — Remover Debug F2

#### Modificar `oSeletorDeFases/Step_0.gml`

**REMOVER** as linhas 1–7 (bloco inteiro do F2):

```gml
// DEBUG: F2 reseta o progresso
if (keyboard_check_pressed(vk_f2)) {
    global.fase_desbloqueada = 0;
    ini_open("save_progresso.ini");
    ini_write_real("progresso", "fase_desbloqueada", 0);
    ini_close();
}
```

> Essa funcionalidade agora será feita pela tela de Settings de forma adequada.

---

### Parte 3 — Botão "Próxima Fase" no oVitoria

#### Modificar `oVitoria/Create_0.gml`

**Substituir TODO o conteúdo** por:

```gml
// Verifica se existe próxima fase
tem_proxima = (global.fase_atual < global.total_fases - 1);

// Botões dinâmicos
btn_selecionado = 0;
if (tem_proxima) {
    btn_opcoes = ["Proxima Fase", "Reiniciar Fase", "Voltar ao Menu"];
} else {
    btn_opcoes = ["Reiniciar Fase", "Voltar ao Menu"];
}
btn_total = array_length(btn_opcoes);
btn_nav_cooldown = 0;
BTN_NAV_CD_MAX = 12;
```

**Variáveis explicadas:**

| Variável | Tipo | Descrição |
|---|---|---|
| `tem_proxima` | bool | `true` se não é a última fase |
| `btn_opcoes` | array | Textos dos botões (2 ou 3 dependendo da fase) |
| `btn_total` | int | Quantidade de botões (adapta o layout automaticamente) |

#### Modificar `oVitoria/Step_0.gml`

**Substituir TODO o conteúdo** por:

```gml
var _gp = global.gamepad_main;

// cooldown de navegação (para analógico)
if (btn_nav_cooldown > 0) btn_nav_cooldown--;

// navegação horizontal: A/D no teclado
var _nav = 0;
if (keyboard_check_pressed(ord("D"))) _nav = 1;
if (keyboard_check_pressed(ord("A"))) _nav = -1;

// navegação horizontal: D-pad / analógico no gamepad
if (_gp != undefined && gamepad_is_connected(_gp) && btn_nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padr)) _nav = 1;
    if (gamepad_button_check_pressed(_gp, gp_padl)) _nav = -1;
    var _ax = gamepad_axis_value(_gp, gp_axislh);
    if (_ax >  0.5) _nav =  1;
    if (_ax < -0.5) _nav = -1;
    if (_nav != 0) btn_nav_cooldown = BTN_NAV_CD_MAX;
}

btn_selecionado = clamp(btn_selecionado + _nav, 0, btn_total - 1);

// confirmar seleção
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"))
              || keyboard_check_pressed(vk_enter);
if (_gp != undefined) _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);

if (_confirmar) {
    // Identifica ação pelo texto do botão (independente do índice)
    var _acao = btn_opcoes[btn_selecionado];

    switch (_acao) {
        case "Proxima Fase":
            // Desbloqueia próxima fase
            if (global.fase_atual >= global.fase_desbloqueada) {
                global.fase_desbloqueada = min(global.fase_atual + 1, global.total_fases - 1);
                ini_open("save_progresso.ini");
                ini_write_real("progresso", "fase_desbloqueada", global.fase_desbloqueada);
                ini_close();
            }
            // Vai direto para a próxima fase
            var _prox = global.fase_atual + 1;
            global.fase_atual = _prox;
            global.comida = 0;
            room_goto(global.fase_rooms[_prox]);
            break;

        case "Reiniciar Fase":
            room_goto(global.fase_room_atual);
            break;

        case "Voltar ao Menu":
            // Desbloqueia próxima fase antes de sair
            if (global.fase_atual >= global.fase_desbloqueada) {
                global.fase_desbloqueada = min(global.fase_atual + 1, global.total_fases - 1);
                ini_open("save_progresso.ini");
                ini_write_real("progresso", "fase_desbloqueada", global.fase_desbloqueada);
                ini_close();
            }
            room_goto(rm_SelecaoDeFases);
            break;
    }
}
```

**Por que switch em string?** Porque o array `btn_opcoes` muda de tamanho dependendo de `tem_proxima`. Usar o texto garante que cada ação executa corretamente independente do índice.

#### `oVitoria/Draw_0.gml` — Nenhuma mudança necessária!

O código de Draw já usa `btn_total` no loop, então 2 ou 3 botões são desenhados automaticamente. O layout horizontal se adapta:
- 3 botões: `3 × 280 + 2 × 24 = 888px` (cabe em 1920px)
- 2 botões: `2 × 280 + 1 × 24 = 584px` (layout atual)

---

### Parte 4 — Tela de Settings (Novo Objeto + Room)

#### Passo 4.1 — Criar o objeto no GameMaker

No GameMaker: **Assets → Create → Object** → nome: `oSettings`

- Sprite: nenhum (o visual é desenhado por código)
- Não precisa de parent

#### Passo 4.2 — Create Event

**`objects/oSettings/Create_0.gml`:**

```gml
// === BOTÕES ===
botoes = ["Resetar Progresso", "Voltar"];
total_botoes = array_length(botoes);
botao_focado = 0;

// === NAVEGAÇÃO ===
nav_cooldown = 0;
NAV_COOLDOWN_MAX = 12;
input_mode = "teclado";
DEADZONE = 0.5;

// === CONFIRMAÇÃO ===
confirmando = false;
conf_selecionado = 1;  // padrão em "Não" (mais seguro)
conf_opcoes = ["Sim", "Nao"];
conf_total = 2;
conf_nav_cooldown = 0;

// === LAYOUT ===
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();
```

**Variáveis explicadas:**

| Variável | Tipo | Descrição |
|---|---|---|
| `confirmando` | bool | Se `true`, mostra overlay de confirmação |
| `conf_selecionado` | int | 0 = Sim, 1 = Não (padrão seguro em "Não") |

#### Passo 4.3 — Step Event

**`objects/oSettings/Step_0.gml`:**

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
// ESTADO: CONFIRMAÇÃO ATIVA
// ===============================================================
if (confirmando) {

    // Cooldown
    if (conf_nav_cooldown > 0) conf_nav_cooldown--;

    // Navegação horizontal (A/D ou D-pad)
    var _nav = 0;
    if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) _nav = 1;
    if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))  _nav = -1;

    if (_tem_controle && conf_nav_cooldown == 0) {
        if (gamepad_button_check_pressed(_gp, gp_padr)) _nav = 1;
        if (gamepad_button_check_pressed(_gp, gp_padl)) _nav = -1;
        var _ax = gamepad_axis_value(_gp, gp_axislh);
        if (_ax >  DEADZONE) _nav =  1;
        if (_ax < -DEADZONE) _nav = -1;
        if (_nav != 0) conf_nav_cooldown = NAV_COOLDOWN_MAX;
    }

    conf_selecionado = clamp(conf_selecionado + _nav, 0, conf_total - 1);

    // Confirmar
    var _confirmar = keyboard_check_pressed(vk_space)
                  || keyboard_check_pressed(ord("E"))
                  || keyboard_check_pressed(vk_enter);
    if (_tem_controle) _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);

    // Cancelar (ESC / B = equivale a "Não")
    var _cancelar = keyboard_check_pressed(vk_escape);
    if (_tem_controle) _cancelar = _cancelar || gamepad_button_check_pressed(_gp, gp_face2);

    if (_cancelar) {
        confirmando = false;
        conf_selecionado = 1;
    }

    if (_confirmar) {
        if (conf_selecionado == 0) {
            // "Sim" — resetar progresso
            global.fase_desbloqueada = 0;
            ini_open("save_progresso.ini");
            ini_write_real("progresso", "fase_desbloqueada", 0);
            ini_close();

            confirmando = false;
            conf_selecionado = 1;
        } else {
            // "Não" — cancelar
            confirmando = false;
            conf_selecionado = 1;
        }
    }

    exit; // Bloqueia navegação normal enquanto confirma
}

// ===============================================================
// ESTADO NORMAL — NAVEGAÇÃO DO MENU
// ===============================================================

// Cooldown
if (nav_cooldown > 0) nav_cooldown--;

// Navegação vertical
var _mover = 0;
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) _mover =  1;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) _mover = -1;

if (_tem_controle && nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padd)) _mover =  1;
    if (gamepad_button_check_pressed(_gp, gp_padu)) _mover = -1;
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    if (_ay >  DEADZONE) _mover =  1;
    if (_ay < -DEADZONE) _mover = -1;
    if (_mover != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Wrap-around
if (_mover != 0) {
    botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
}

// ===============================================================
// CONFIRMAR
// ===============================================================
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (_tem_controle) {
    _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);
}

if (_confirmar) {
    switch (botao_focado) {
        case 0:  // Resetar Progresso → abre confirmação
            confirmando = true;
            conf_selecionado = 1;  // padrão em "Não"
            break;

        case 1:  // Voltar → menu principal
            room_goto(rm_MenuPrincipal);
            break;
    }
}

// ===============================================================
// VOLTAR COM ESC / B
// ===============================================================
var _voltar = keyboard_check_pressed(vk_escape);
if (_tem_controle) _voltar = _voltar || gamepad_button_check_pressed(_gp, gp_face2);

if (_voltar) {
    room_goto(rm_MenuPrincipal);
}
```

#### Passo 4.4 — Draw GUI Event

**`objects/oSettings/Draw_64.gml`:**

```gml
// ===============================================================
// FUNDO
// ===============================================================
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;
var _cy = _gh / 2;

draw_set_color(make_color_rgb(20, 22, 38));
draw_rectangle(0, 0, _gw, _gh, false);

// Linha decorativa
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.2);
draw_line_width(0, _gh - 100, _gw, _gh - 100, 2);
draw_line_width(0, 100, _gw, 100, 2);
draw_set_alpha(1);

// ===============================================================
// TÍTULO
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Sombra
draw_set_color(make_color_rgb(10, 10, 20));
draw_text_transformed(_cx + 3, 180 + 3, "SETTINGS", 2, 2, 0);
// Principal
draw_set_color(make_color_rgb(80, 200, 210));
draw_text_transformed(_cx, 180, "SETTINGS", 2, 2, 0);

// ===============================================================
// BOTÕES (centralizados verticalmente)
// ===============================================================
var _btn_w = 360;
var _btn_h = 60;
var _btn_gap = 16;
var _altura_total = total_botoes * _btn_h + (total_botoes - 1) * _btn_gap;
var _btn_y_inicio = _cy - _altura_total / 2 + 40;

for (var i = 0; i < total_botoes; i++) {
    var _bx = _cx - _btn_w / 2;
    var _by = _btn_y_inicio + i * (_btn_h + _btn_gap);
    var _focado = (i == botao_focado);

    // Fundo
    draw_set_color(_focado ? make_color_rgb(25, 55, 75) : make_color_rgb(18, 22, 42));
    draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, false);

    // Indicador lateral
    if (_focado) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_bx, _by, _bx + 6, _by + _btn_h, false);
    }

    // Borda
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(_focado ? 0.8 : 0.3);
    draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, true);
    draw_set_alpha(1);

    // Texto
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_focado ? make_color_rgb(120, 230, 240) : make_color_rgb(80, 130, 150));
    draw_text(_bx + _btn_w / 2, _by + _btn_h / 2, botoes[i]);
}

// ===============================================================
// RODAPÉ
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(130, 180, 195));

var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

if (_tem_controle && input_mode == "controle") {
    draw_text(_gw / 2, _gh - 25, "[D-pad] Navegar    [A] Confirmar    [B] Voltar");
} else {
    draw_text(_gw / 2, _gh - 25, "[WASD] Navegar    [E] Confirmar    [ESC] Voltar");
}

// ===============================================================
// OVERLAY DE CONFIRMAÇÃO (por cima de tudo)
// ===============================================================
if (confirmando) {

    // Fundo escuro semitransparente
    draw_set_alpha(0.8);
    draw_set_color(make_color_rgb(10, 10, 18));
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // Caixa de diálogo
    var _box_w = 500;
    var _box_h = 200;
    var _box_x = _cx - _box_w / 2;
    var _box_y = _cy - _box_h / 2;

    // Fundo da caixa
    draw_set_color(make_color_rgb(20, 30, 50));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

    // Borda da caixa
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(0.8);
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);
    draw_set_alpha(1);

    // Linha superior decorativa
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + 4, false);

    // Título "Tem certeza?"
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(210, 230, 235));
    draw_text(_cx, _box_y + 55, "Tem certeza?");

    // Subtítulo
    draw_set_color(make_color_rgb(130, 150, 165));
    draw_text(_cx, _box_y + 90, "Todo progresso sera perdido.");

    // Botões Sim / Não (horizontais)
    var _cbw = 160;
    var _cbh = 50;
    var _cgap = 30;
    var _cblocoW = conf_total * _cbw + (conf_total - 1) * _cgap;
    var _cstartX = _cx - _cblocoW / 2;
    var _cby = _box_y + 130;

    for (var j = 0; j < conf_total; j++) {
        var _cbx = _cstartX + j * (_cbw + _cgap);
        var _csel = (j == conf_selecionado);

        // Fundo
        draw_set_color(_csel
            ? make_color_rgb(30, 60, 80)
            : make_color_rgb(20, 35, 55));
        draw_rectangle(_cbx, _cby, _cbx + _cbw, _cby + _cbh, false);

        // Borda esquerda (selecionado)
        if (_csel) {
            draw_set_color(make_color_rgb(80, 200, 210));
            draw_rectangle(_cbx, _cby, _cbx + 5, _cby + _cbh, false);
        }

        // Borda
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(_csel ? 0.8 : 0.3);
        draw_rectangle(_cbx, _cby, _cbx + _cbw, _cby + _cbh, true);
        draw_set_alpha(1);

        // Texto
        draw_set_color(_csel
            ? make_color_rgb(120, 225, 235)
            : make_color_rgb(80, 200, 210));
        draw_text(_cbx + _cbw / 2, _cby + _cbh / 2, conf_opcoes[j]);
    }
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

---

### Parte 5 — Criar Room `rm_Settings`

No GameMaker:

1. **Assets → Create → Room** → nome: `rm_Settings`
2. **Room Properties:**
   - Width: `1920`
   - Height: `1080`
   - **Desmarcar** "Enable Viewports" (não usa câmera)
3. **Layers:**
   - Crie uma Instance Layer chamada `instancias`
   - Arraste `oSettings` para a room (posição não importa — o objeto desenha na GUI)
4. **Room Order:**
   - Coloque `rm_Settings` **após** `rm_MenuPrincipal` na ordem de rooms (não precisa ser a primeira room)

---

### Parte 6 — Ativar Botão Settings no Menu Principal

#### Modificar `oMenuPrincipal/Step_0.gml`

**ANTES (linhas 69–73):**

```gml
        case 1:  // Settings → tela de configurações
            // TODO: implementar tela de configurações
            // room_goto(rm_Settings);
            break;
```

**DEPOIS:**

```gml
        case 1:  // Settings → tela de configurações
            room_goto(rm_Settings);
            break;
```

---

## ✅ Checklist Final

### Preparação (Globals)
- [ ] `oSeletorDeFases/Create_0.gml` → trocar `fase_rooms` por `global.fase_rooms`
- [ ] `oSeletorDeFases/Create_0.gml` → trocar `total_fases` por `global.total_fases`
- [ ] `oSeletorDeFases/Step_0.gml` → atualizar referências para globals
- [ ] `oSeletorDeFases/Step_0.gml` → remover bloco debug F2
- [ ] `oSeletorDeFases/Draw_0.gml` → atualizar referência `total_fases`

### Botão "Próxima Fase" (oVitoria)
- [ ] `oVitoria/Create_0.gml` → substituir por versão com `tem_proxima`
- [ ] `oVitoria/Step_0.gml` → substituir por versão com switch em string

### Tela de Settings (novo)
- [ ] Criar objeto `oSettings` no GameMaker (sem sprite)
- [ ] Adicionar `oSettings/Create_0.gml`
- [ ] Adicionar `oSettings/Step_0.gml`
- [ ] Adicionar `oSettings/Draw_64.gml` (Draw GUI event)
- [ ] Criar room `rm_Settings` (1920×1080, sem viewport)
- [ ] Colocar `oSettings` na room `rm_Settings`

### Menu Principal
- [ ] `oMenuPrincipal/Step_0.gml` → ativar `room_goto(rm_Settings)`

---

## 🧪 Como Testar

### Teste 1 — Botão "Próxima Fase"

1. Rode o jogo e complete a **Fase 1** (room_01)
2. Na tela de vitória, devem aparecer **3 botões**: "Próxima Fase", "Reiniciar Fase", "Voltar ao Menu"
3. Navegue com **A/D** — o botão selecionado muda
4. Selecione **"Próxima Fase"** e confirme:
   - O jogo deve ir direto para a Fase 2 (room_02)
   - `global.fase_desbloqueada` deve ter aumentado
5. Agora complete a **última fase** (rm_fase03)
6. Na tela de vitória, devem aparecer apenas **2 botões**: "Reiniciar Fase", "Voltar ao Menu"
7. Verifique que "Próxima Fase" **NÃO** aparece na última fase

### Teste 2 — Tela de Settings

1. No menu principal, selecione **"Settings"** e confirme
2. O jogo deve ir para a tela de Settings
3. Navegue entre "Resetar Progresso" e "Voltar" com **W/S**
4. Selecione **"Voltar"** → deve voltar ao menu principal
5. Teste também **ESC** → deve voltar ao menu principal

### Teste 3 — Resetar Progresso (com confirmação)

1. Primeiro, desbloqueie pelo menos a fase 2 (complete a fase 1)
2. Vá em Settings → selecione **"Resetar Progresso"**
3. O overlay de confirmação deve aparecer com "Tem certeza?" e botões "Sim" / "Não"
4. O cursor deve começar em **"Não"** (proteção contra reset acidental)
5. Navegue com **A/D** e selecione **"Não"** → overlay fecha, nada muda
6. Abra novamente e selecione **"Sim"**:
   - O progresso deve ser resetado
   - Vá ao seletor de fases e confirme que apenas a Fase 1 está desbloqueada
7. Teste cancelar com **ESC** ou **B** no gamepad → deve fechar o overlay (equivale a "Não")

### Teste 4 — Gamepad

1. Repita os testes acima usando gamepad:
   - **D-pad** ou **Stick** para navegar
   - **A/Cruz** para confirmar
   - **B/Círculo** para voltar/cancelar

---

## ⚠️ Cuidados

1. **Ordem de execução** — `global.fase_rooms` e `global.total_fases` são setados no `oSeletorDeFases/Create`. Como o menu principal vai para o seletor antes de qualquer fase, esses valores estarão definidos quando `oVitoria` precisar. Se por algum motivo o jogo iniciar direto numa fase (debug), esses globals podem não existir — usar `variable_global_exists()` como fallback se necessário.

2. **Room Order no GameMaker** — `rm_Settings` deve estar **após** `rm_MenuPrincipal` na Room Order do projeto. Isso não afeta o gameplay, mas é boa prática.

3. **INI file** — o arquivo `save_progresso.ini` é compartilhado entre oVitoria (desbloqueio) e oSettings (reset). Ambos usam a seção `"progresso"` com a key `"fase_desbloqueada"`.

4. **`global.total_fases - 1` como limite** — O `clamp` na hora de desbloquear usa `global.total_fases - 1` como máximo. Isso impede que `fase_desbloqueada` ultrapasse o índice máximo do array.

5. **Confirmação padrão em "Não"** — O `conf_selecionado` começa em 1 ("Não") para evitar reset acidental caso o jogador aperte confirmar rapidamente.

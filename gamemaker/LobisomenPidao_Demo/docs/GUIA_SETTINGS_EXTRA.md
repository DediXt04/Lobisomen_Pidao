# ⚙️➕ Guia de Implementação — Extensões da Tela de Settings

> Guia para adicionar três opções extras à tela de Settings: **Fullscreen**, **Mostrar FPS** e **Idioma (PT-BR / EN)**. Todas com persistência em `save_progresso.ini`.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Resolução das rooms de menu | 1920×1080 |
| Fonte | `fnt_pixel` |
| Paleta UI | Navy escuro `rgb(14,14,26)` + Teal `rgb(80,200,210)` |
| Persistência | `save_progresso.ini` — novas seções `[video]` e `[lang]` |
| Pré-requisitos | `oSettings` + `rm_Settings` criados pelo `GUIA_VITORIA_E_SETTINGS.md`; volumes do `GUIA_AUDIO_E_MUSICA.md` |
| Novos globals | `global.fullscreen`, `global.mostrarFps`, `global.idioma` |
| Novo objeto | `oFpsDrawer` (persistente) |
| Novos scripts | `scr_inicializarConfigs`, `scr_salvarConfigs`, `scr_lang` |

### Defaults

| Variável | Valor inicial |
|---|---|
| `global.fullscreen` | `false` |
| `global.mostrarFps` | `false` |
| `global.idioma` | `"pt"` |

---

## 🏗️ Visão Geral

### Como funciona

1. **Configs centralizadas** — três novos globals carregados pelo `oProcuraControle/Create` (já persistente, já roda primeiro no `rm_MenuPrincipal`).
2. **Settings estendido** — três novas opções entram entre as existentes; cada uma tem seu tipo (`toggle`, `lang`).
3. **Persistência** — gravada no mesmo `save_progresso.ini`, seções `[video]` (fullscreen/fps) e `[lang]` (idioma).
4. **Idioma** — todas as strings hardcoded passam a vir de `scr_lang("chave")`. O dicionário tem um mapa por idioma.

### Layout final da Tela de Settings

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│                        SETTINGS                      │
│                                                      │
│       Volume Música     ▌▌▌▌▌▌▌░░░  70%              │
│       Volume SFX        ▌▌▌▌▌▌▌░░░  70%              │
│       Fullscreen        [ ON ]  OFF                  │
│       Mostrar FPS         ON  [ OFF ]                │
│       Idioma            [Português]  English         │
│                                                      │
│       ┌──────────────────────┐                       │
│       │  Resetar Progresso   │                       │
│       └──────────────────────┘                       │
│       ┌──────────────────────┐                       │
│       │      Voltar          │                       │
│       └──────────────────────┘                       │
│                                                      │
│   W S navegar    A D alterar    SPACE confirmar      │
│                                       ESC para voltar│
└──────────────────────────────────────────────────────┘
```

### Diagrama de fluxo

```
Boot do jogo
  │
  ▼
rm_MenuPrincipal carrega
  │
  ├─ oProcuraControle/Create (persistente):
  │     - detecta gamepads
  │     - scr_inicializarConfigs() → defaults
  │     - ini_open(save_progresso.ini)
  │     - lê [video].fullscreen, [video].fps, [lang].idioma
  │     - lê [audio].bgm, [audio].sfx (do guia áudio)
  │     - aplica audio_group_set_gain (do guia áudio)
  │     - window_set_fullscreen(global.fullscreen)
  │     - display_set_gui_size(1920, 1080)
  │
  ├─ oFpsDrawer (persistente, criado em rm_MenuPrincipal):
  │     - Draw GUI: se global.mostrarFps, desenha "60 fps" no canto
  │
  ├─ oMenuPrincipal: labels via scr_lang("menu_play"), etc.
  │
  Jogador entra em Settings:
  ├─ oSettings/Step: navega/edita 7 opções
  │     - mudou fullscreen → window_set_fullscreen + scr_salvarConfigs
  │     - mudou FPS → scr_salvarConfigs (oFpsDrawer já reage automaticamente)
  │     - mudou idioma → scr_salvarConfigs (todos os draws com scr_lang
  │                       atualizam no próximo frame)
  │
  Jogador sai (Voltar / ESC):
  └─ scr_salvarConfigs() → grava INI
```

---

## 📜 Parte 1 — Scripts Base

### 1.1 `scr_inicializarConfigs` (defaults)

Asset Browser → Scripts → Create Script.

**`scripts/scr_inicializarConfigs/scr_inicializarConfigs.gml`:**

```gml
// scr_inicializarConfigs()
// Garante que todos os globals de configuração existem com valores padrão.
// Chame antes de tentar ler do INI.

function scr_inicializarConfigs() {
    if (!variable_global_exists("fullscreen")) global.fullscreen = false;
    if (!variable_global_exists("mostrarFps")) global.mostrarFps = false;
    if (!variable_global_exists("idioma"))     global.idioma     = "pt";
}
```

### 1.2 `scr_salvarConfigs`

**`scripts/scr_salvarConfigs/scr_salvarConfigs.gml`:**

```gml
// scr_salvarConfigs()
// Grava os globals de configuração no save_progresso.ini.
// Chame após qualquer mudança no Settings.

function scr_salvarConfigs() {
    ini_open("save_progresso.ini");
    ini_write_real("video", "fullscreen", global.fullscreen ? 1 : 0);
    ini_write_real("video", "fps",        global.mostrarFps ? 1 : 0);
    ini_write_string("lang", "idioma",    global.idioma);
    ini_close();
}
```

> **Nota:** se você já implementou o `GUIA_AUDIO_E_MUSICA.md`, pode unificar isso com `scr_salvarVolumes` em um único `scr_salvarTudo` — mas manter separado é mais limpo.

### 1.3 `scr_lang` (dicionário central)

**`scripts/scr_lang/scr_lang.gml`:**

```gml
// scr_lang(_chave)
// Retorna a string traduzida no idioma atual (global.idioma).
// Se a chave não existe, retorna "[chave]" para facilitar debug.

function scr_lang(_chave) {
    var _dict;

    if (global.idioma == "en") {
        _dict = {
            // Menu principal
            menu_play:      "Play",
            menu_settings:  "Settings",
            menu_exit:      "Exit",

            // Menu de pausa
            pause_continuar:    "Continue",
            pause_reiniciar:    "Restart Stage",
            pause_voltar_menu:  "Back to Menu",

            // Vitória
            vitoria_titulo:     "YOU WIN!",
            vitoria_subtitulo:  "Dad's bite.",
            vitoria_proxima:    "Next Stage",
            vitoria_reiniciar:  "Restart Stage",
            vitoria_voltar:     "Back to Menu",

            // Game Over
            gameover_dano:      "You were caught!",
            gameover_fome:      "You starved!",
            gameover_reiniciar: "Restart Stage",
            gameover_voltar:    "Back to Menu",

            // Settings
            settings_titulo:    "SETTINGS",
            settings_volMusic:  "Music Volume",
            settings_volSfx:    "SFX Volume",
            settings_fullscreen:"Fullscreen",
            settings_fps:       "Show FPS",
            settings_idioma:    "Language",
            settings_reset:     "Reset Progress",
            settings_voltar:    "Back",
            settings_confirm:   "Are you sure?",
            settings_sim:       "Yes",
            settings_nao:       "No",
            settings_on:        "ON",
            settings_off:       "OFF",
            settings_lang_pt:   "Português",
            settings_lang_en:   "English",

            // Dicas de input
            dica_navegar:       "to navigate",
            dica_confirmar:     "to confirm",
            dica_voltar:        "to go back",
            dica_alterar:       "to change",
        };
    } else {
        // Default PT-BR
        _dict = {
            menu_play:      "Play",
            menu_settings:  "Settings",
            menu_exit:      "Exit",

            pause_continuar:    "Continuar",
            pause_reiniciar:    "Reiniciar Fase",
            pause_voltar_menu:  "Voltar ao Menu",

            vitoria_titulo:     "VOCÊ VENCEU!",
            vitoria_subtitulo:  "Mim de papai.",
            vitoria_proxima:    "Próxima Fase",
            vitoria_reiniciar:  "Reiniciar Fase",
            vitoria_voltar:     "Voltar ao Menu",

            gameover_dano:      "Você foi pego!",
            gameover_fome:      "Você morreu de fome!",
            gameover_reiniciar: "Reiniciar Fase",
            gameover_voltar:    "Voltar ao Menu",

            settings_titulo:    "SETTINGS",
            settings_volMusic:  "Volume Música",
            settings_volSfx:    "Volume SFX",
            settings_fullscreen:"Fullscreen",
            settings_fps:       "Mostrar FPS",
            settings_idioma:    "Idioma",
            settings_reset:     "Resetar Progresso",
            settings_voltar:    "Voltar",
            settings_confirm:   "Tem certeza?",
            settings_sim:       "Sim",
            settings_nao:       "Não",
            settings_on:        "LIG",
            settings_off:       "DESL",
            settings_lang_pt:   "Português",
            settings_lang_en:   "English",

            dica_navegar:       "para navegar",
            dica_confirmar:     "para confirmar",
            dica_voltar:        "para voltar",
            dica_alterar:       "para alterar",
        };
    }

    if (variable_struct_exists(_dict, _chave)) {
        return variable_struct_get(_dict, _chave);
    }
    return "[" + string(_chave) + "]";
}
```

> **Como usar:** em vez de `draw_text(x, y, "VOCÊ VENCEU!");` use `draw_text(x, y, scr_lang("vitoria_titulo"));`.

---

## 🚀 Parte 2 — Inicialização no `oProcuraControle`

`oProcuraControle` é persistente, vive desde o `rm_MenuPrincipal` e roda antes de qualquer Settings ser aberto. É o lugar perfeito para carregar tudo do INI no boot.

### Modificar `objects/oProcuraControle/Create_0.gml`

Adicione no **final** do arquivo (sem mexer no que já existe de detecção de gamepad):

```gml
// === CONFIGURAÇÕES PERSISTIDAS ===
scr_inicializarConfigs();

ini_open("save_progresso.ini");
global.fullscreen = ini_read_real("video", "fullscreen", 0) > 0;
global.mostrarFps = ini_read_real("video", "fps",        0) > 0;
global.idioma     = ini_read_string("lang", "idioma",   "pt");
ini_close();

// Aplica fullscreen no boot
window_set_fullscreen(global.fullscreen);

// Garante o tamanho da GUI (caso ainda não tenha sido setado)
display_set_gui_size(1920, 1080);
```

> Se `oProcuraControle` for substituído por um manager unificado (após implementar todos os guias), centralize tudo lá.

---

## 🖥️ Parte 3 — Feature 1: Fullscreen

### 3.1 Comportamento

- Toggle entre `true` (tela cheia) e `false` (janela).
- Aplica `window_set_fullscreen()` em tempo real ao mudar.
- Salva no INI imediatamente.
- Atalho global F11 alterna independente da Settings.

### 3.2 Atalho F11

Edite `objects/oController/Step_0.gml`. Adicione **antes** da guard clause de pausa (`if (global.pausado) exit;` está no menu de pausa, mas o F11 deve funcionar mesmo pausado):

Procure o início do `#region //pausa` e adicione **acima** dele:

```gml
// Atalho global de fullscreen (funciona pausado)
if (keyboard_check_pressed(vk_f11)) {
    global.fullscreen = !global.fullscreen;
    window_set_fullscreen(global.fullscreen);
    scr_salvarConfigs();
}

//pausa
#region
// ... resto inalterado
```

### 3.3 Toggle no Settings

Coberto na Parte 6 (Settings estendido).

---

## 📊 Parte 4 — Feature 2: Mostrar FPS

### 4.1 Comportamento

- Toggle ON/OFF no Settings.
- Quando ON, desenha `fps_real` no canto superior direito de **qualquer** room.
- Estilo: texto amarelo, fonte `fnt_pixel`, formato `"60 fps"`.

### 4.2 Criar `oFpsDrawer` (persistente)

Asset Browser → Objects → Create Object → nome `oFpsDrawer`, sem sprite, **Persistent: True**, sem visible no editor.

**Eventos:**

**`objects/oFpsDrawer/Create_0.gml`:**

```gml
// Apenas existe — toda a lógica está no Draw GUI
```

**`objects/oFpsDrawer/Draw_64.gml`** (Draw GUI):

```gml
if (!global.mostrarFps) exit;

draw_set_font(fnt_pixel);
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_colour(c_yellow);

draw_text(display_get_gui_width() - 16, 12, string(fps_real) + " fps");

// Reset de estado de draw (boa prática)
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
```

### 4.3 Posicionar no `rm_MenuPrincipal`

1. Abra `rm_MenuPrincipal`.
2. Crie (ou reutilize) uma layer `Managers` ao lado de `instancias`.
3. Arraste uma instância de `oFpsDrawer`.
4. Como é Persistent, continua existindo em todas as rooms seguintes.

> **Não duplicar** em outras rooms — vai virar duas instâncias e desenhar o FPS por cima dele mesmo.

---

## 🌐 Parte 5 — Feature 3: Idioma PT-BR / EN

### 5.1 Comportamento

- Toggle PT ⇄ EN no Settings.
- Aplica em tempo real (todos os textos que usam `scr_lang` se atualizam no próximo frame).
- Salva no INI imediatamente.

### 5.2 Substituir strings hardcoded por `scr_lang`

Para cada arquivo abaixo, troque os literais string pelos lookups. Mostro os antes/depois mais importantes.

#### 5.2.1 `objects/oController/Create_0.gml`

```gml
// ANTES
pause_opcoes = ["Continuar", "Reiniciar Fase", "Voltar ao Menu"];

// DEPOIS
pause_opcoes = [
    scr_lang("pause_continuar"),
    scr_lang("pause_reiniciar"),
    scr_lang("pause_voltar_menu"),
];
```

> **Pegadinha:** isso é avaliado **uma vez** no Create. Se o idioma mudar com o jogo já rodando, o menu de pausa fica com as strings antigas. Solução: recalcular `pause_opcoes` dentro do Step do menu de pausa, ou diretamente desenhar `scr_lang(...)` no Draw em vez de armazenar no array. **Recomendação:** mudar o Draw do menu de pausa para chamar `scr_lang` direto.

Modifique o Draw GUI do menu de pausa (`oController/Draw_64.gml`, no bloco que desenha as opções de pausa) para usar `scr_lang` diretamente em vez do array:

```gml
// Em vez de:
draw_text(x, y, pause_opcoes[i]);

// Use:
var _chaves = ["pause_continuar", "pause_reiniciar", "pause_voltar_menu"];
draw_text(x, y, scr_lang(_chaves[i]));
```

#### 5.2.2 `objects/oMenuPrincipal/Draw_64.gml`

Onde estiver desenhando os botões:

```gml
// ANTES
var _labels = ["Play", "Settings", "Exit"];

// DEPOIS
var _labels = [
    scr_lang("menu_play"),
    scr_lang("menu_settings"),
    scr_lang("menu_exit"),
];
```

#### 5.2.3 `objects/oVitoria/Draw_64.gml`

```gml
// ANTES
draw_text(cx, 200, "VOCÊ VENCEU!");
draw_text(cx, 260, "Mim de papai.");

var _labels = ["Próxima Fase", "Reiniciar Fase", "Voltar ao Menu"];

// DEPOIS
draw_text(cx, 200, scr_lang("vitoria_titulo"));
draw_text(cx, 260, scr_lang("vitoria_subtitulo"));

var _labels = [
    scr_lang("vitoria_proxima"),
    scr_lang("vitoria_reiniciar"),
    scr_lang("vitoria_voltar"),
];
```

#### 5.2.4 `objects/oGameOver/Draw_64.gml`

```gml
// ANTES
var _msg = (global.motivoMorte == "dano") ? "Você foi pego!" : "Você morreu de fome!";

// DEPOIS
var _msg = scr_lang(global.motivoMorte == "dano" ? "gameover_dano" : "gameover_fome");
```

#### 5.2.5 `objects/oSettings/Draw_64.gml`

Tudo que é label vira `scr_lang(...)` — está coberto na Parte 6.

#### 5.2.6 Dicas de input (rodapé dos menus)

Onde tiver linhas tipo `"W S para navegar  SPACE para confirmar"`:

```gml
// ANTES
draw_text(cx, base, "W S para navegar    SPACE para confirmar");

// DEPOIS
draw_text(cx, base, "W S " + scr_lang("dica_navegar") + "    SPACE " + scr_lang("dica_confirmar"));
```

### 5.3 Sobre `fase_nomes` e `fase_subtitulos`

Os nomes e subtítulos das fases no `oSeletorDeFases/Create_0.gml` são conteúdo do jogo, não UI. **Não traduzir agora** — adicionar como TODO no `TODO_LIST.md` quando o time decidir as traduções oficiais.

Se quiser traduzir depois, o padrão seria:

```gml
// Opção A: arrays paralelos por idioma
fase_nomes_pt = ["Fase testes", ...];
fase_nomes_en = ["Test stage",  ...];
fase_nomes = (global.idioma == "en") ? fase_nomes_en : fase_nomes_pt;

// Opção B: chaves no dicionário (mais escalável)
// scr_lang("fase_01_nome"), scr_lang("fase_01_subtitulo")
```

---

## 🎛️ Parte 6 — Estender o `oSettings`

### 6.1 Estrutura final (7 opções)

| Índice | Item | Tipo | Como alterar |
|---|---|---|---|
| 0 | Volume Música | `slider` (10 steps) | A/D ou D-pad horizontal |
| 1 | Volume SFX | `slider` (10 steps) | A/D ou D-pad horizontal |
| 2 | Fullscreen | `toggle` (ON/OFF) | A/D, Enter ou Space |
| 3 | Mostrar FPS | `toggle` (ON/OFF) | A/D, Enter ou Space |
| 4 | Idioma | `lang` (PT/EN) | A/D, Enter ou Space |
| 5 | Resetar Progresso | `botao` | Enter / Space (abre overlay) |
| 6 | Voltar | `botao` | Enter / Space / ESC |

### 6.2 Modificar `oSettings/Create_0.gml`

```gml
// === OPÇÕES ===
opcao_focada = 0;

// Lista paralela de chaves de tradução (label), tipo e ação
opcao_chaves = [
    "settings_volMusic",
    "settings_volSfx",
    "settings_fullscreen",
    "settings_fps",
    "settings_idioma",
    "settings_reset",
    "settings_voltar",
];

opcao_tipo = [
    "slider",   // 0 Volume Música
    "slider",   // 1 Volume SFX
    "toggle",   // 2 Fullscreen
    "toggle",   // 3 Mostrar FPS
    "lang",     // 4 Idioma
    "botao",    // 5 Resetar
    "botao",    // 6 Voltar
];

total_opcoes = array_length(opcao_chaves);

// Cooldown de navegação (mantém o que já existe)
nav_cooldown = 0;
NAV_COOLDOWN_MAX = 12;

// Estado de confirmação de reset (do guia base)
mostrando_confirmacao = false;
confirma_selecionado  = 1; // 0 = Sim, 1 = Não (default no "Não")

// Cooldown só para sliders/toggles horizontais
ajuste_cooldown = 0;
AJUSTE_COOLDOWN_MAX = 8;
```

### 6.3 Modificar `oSettings/Step_0.gml`

```gml
if (mostrando_confirmacao) {
    // — manter a lógica do overlay de confirmação que o GUIA_VITORIA_E_SETTINGS.md já fez —
    exit;
}

var _gp = global.gamepad_main;

// Cooldowns
if (nav_cooldown    > 0) nav_cooldown--;
if (ajuste_cooldown > 0) ajuste_cooldown--;

// === NAVEGAÇÃO VERTICAL (escolhe a opção) ===
var _nav = 0;
if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) _nav =  1;
if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up))   _nav = -1;

if (_gp != undefined && nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padd)) _nav =  1;
    if (gamepad_button_check_pressed(_gp, gp_padu)) _nav = -1;
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    if (_ay >  0.5) _nav =  1;
    if (_ay < -0.5) _nav = -1;
    if (_nav != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

opcao_focada = (opcao_focada + _nav + total_opcoes) % total_opcoes;

// === AJUSTE HORIZONTAL (slider/toggle/lang) ===
var _dir = 0;
if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) _dir =  1;
if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))  _dir = -1;

if (_gp != undefined && ajuste_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padr)) _dir =  1;
    if (gamepad_button_check_pressed(_gp, gp_padl)) _dir = -1;
    var _ax = gamepad_axis_value(_gp, gp_axislh);
    if (_ax >  0.5) _dir =  1;
    if (_ax < -0.5) _dir = -1;
    if (_dir != 0) ajuste_cooldown = AJUSTE_COOLDOWN_MAX;
}

if (_dir != 0) {
    var _tipo = opcao_tipo[opcao_focada];

    switch (_tipo) {
        case "slider":
            if (opcao_focada == 0) {
                global.volumeBgm = clamp(global.volumeBgm + _dir * 0.1, 0, 1);
            } else if (opcao_focada == 1) {
                global.volumeSfx = clamp(global.volumeSfx + _dir * 0.1, 0, 1);
            }
            scr_aplicarVolumes();
            scr_salvarVolumes();
            // audio_play_sound(snd_uiNav, 1, false); // se já tiver o guia áudio
            break;

        case "toggle":
            if (opcao_focada == 2) {
                global.fullscreen = !global.fullscreen;
                window_set_fullscreen(global.fullscreen);
            } else if (opcao_focada == 3) {
                global.mostrarFps = !global.mostrarFps;
            }
            scr_salvarConfigs();
            break;

        case "lang":
            global.idioma = (global.idioma == "pt") ? "en" : "pt";
            scr_salvarConfigs();
            break;
    }
}

// === CONFIRMAR (Enter / Space / botão A) ===
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"))
              || keyboard_check_pressed(vk_enter);

if (_gp != undefined) {
    _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);
}

if (_confirmar) {
    var _tipo = opcao_tipo[opcao_focada];

    switch (_tipo) {
        case "toggle":
            // Enter também alterna toggle (atalho)
            if (opcao_focada == 2) {
                global.fullscreen = !global.fullscreen;
                window_set_fullscreen(global.fullscreen);
            } else if (opcao_focada == 3) {
                global.mostrarFps = !global.mostrarFps;
            }
            scr_salvarConfigs();
            break;

        case "lang":
            global.idioma = (global.idioma == "pt") ? "en" : "pt";
            scr_salvarConfigs();
            break;

        case "botao":
            if (opcao_focada == 5) {
                // Resetar Progresso → abrir overlay (guia base)
                mostrando_confirmacao = true;
                confirma_selecionado  = 1;
            } else if (opcao_focada == 6) {
                // Voltar
                scr_salvarConfigs();
                room_goto(rm_MenuPrincipal);
            }
            break;
    }
}

// === ESC volta direto ===
var _voltar = keyboard_check_pressed(vk_escape);
if (_gp != undefined) {
    _voltar = _voltar || gamepad_button_check_pressed(_gp, gp_face2);
}

if (_voltar) {
    scr_salvarConfigs();
    room_goto(rm_MenuPrincipal);
}
```

### 6.4 Modificar `oSettings/Draw_64.gml`

```gml
// Constantes visuais
var _navy = make_color_rgb(14, 14, 26);
var _teal = make_color_rgb(80, 200, 210);
var _cx   = 1920 / 2;

draw_set_font(fnt_pixel);

// Título
draw_set_halign(fa_center);
draw_set_colour(c_white);
draw_text_transformed(_cx, 100, scr_lang("settings_titulo"), 4, 4, 0);

// Loop pelas opções
var _base_y = 280;
var _espaco = 80;

for (var i = 0; i < total_opcoes; i++) {
    var _y = _base_y + i * _espaco;
    var _focado = (i == opcao_focada);
    var _tipo   = opcao_tipo[i];
    var _label  = scr_lang(opcao_chaves[i]);

    // Label à esquerda do bloco
    draw_set_halign(fa_right);
    draw_set_colour(_focado ? _teal : c_white);
    draw_text(_cx - 100, _y, _label);

    // Valor à direita
    draw_set_halign(fa_left);

    switch (_tipo) {
        case "slider":
            var _valor = (i == 0) ? global.volumeBgm : global.volumeSfx;
            scr_desenharStepBar(_cx - 60, _y - 10, _valor, 10);
            draw_set_colour(c_white);
            draw_text(_cx + 380, _y, string(round(_valor * 100)) + "%");
            break;

        case "toggle":
            var _on = (i == 2) ? global.fullscreen : global.mostrarFps;
            draw_set_colour(_on ? _teal : c_white);
            draw_text(_cx - 60, _y, _on ? "[ " + scr_lang("settings_on") + " ]" : "  " + scr_lang("settings_on") + "  ");
            draw_set_colour(!_on ? _teal : c_white);
            draw_text(_cx + 60, _y, !_on ? "[ " + scr_lang("settings_off") + " ]" : "  " + scr_lang("settings_off") + "  ");
            break;

        case "lang":
            var _pt = (global.idioma == "pt");
            draw_set_colour(_pt ? _teal : c_white);
            draw_text(_cx - 60, _y, _pt ? "[ " + scr_lang("settings_lang_pt") + " ]" : "  " + scr_lang("settings_lang_pt") + "  ");
            draw_set_colour(!_pt ? _teal : c_white);
            draw_text(_cx + 80, _y, !_pt ? "[ " + scr_lang("settings_lang_en") + " ]" : "  " + scr_lang("settings_lang_en") + "  ");
            break;

        case "botao":
            // Botão com retângulo destacado
            var _w = 320;
            var _h = 50;
            var _x = _cx - _w / 2;

            draw_set_colour(_focado ? _teal : _navy);
            draw_rectangle(_x, _y - _h/2, _x + _w, _y + _h/2, false);
            draw_set_colour(_teal);
            draw_rectangle(_x, _y - _h/2, _x + _w, _y + _h/2, true);

            draw_set_halign(fa_center);
            draw_set_colour(_focado ? c_white : _teal);
            draw_text(_cx, _y - 8, _label);
            break;
    }
}

// Dicas de input no rodapé
draw_set_halign(fa_center);
draw_set_colour(c_white);
draw_text(_cx, 1000,
    "W S " + scr_lang("dica_navegar") + "    "
  + "A D " + scr_lang("dica_alterar") + "    "
  + "SPACE " + scr_lang("dica_confirmar"));

draw_set_halign(fa_right);
draw_text(1908, 1040, "ESC " + scr_lang("dica_voltar"));

// Reset
draw_set_halign(fa_left);
draw_set_colour(c_white);

// Se o overlay de confirmação estiver ativo, desenhar (lógica do guia base)
if (mostrando_confirmacao) {
    // — manter o overlay que o GUIA_VITORIA_E_SETTINGS.md já desenha —
}
```

### 6.5 Script auxiliar `scr_desenharStepBar`

Se você seguiu o `GUIA_AUDIO_E_MUSICA.md`, esse script já existe. Senão, crie:

```gml
// scr_desenharStepBar(_x, _y, _valor, _steps)
// Desenha uma barra horizontal em quadradinhos pixel art.
// _valor: 0.0 a 1.0
// _steps: quantos quadradinhos

function scr_desenharStepBar(_x, _y, _valor, _steps) {
    var _step_w   = 30;
    var _step_h   = 30;
    var _step_gap = 6;
    var _navy = make_color_rgb(14, 14, 26);
    var _teal = make_color_rgb(80, 200, 210);
    var _preenchidos = round(_valor * _steps);

    for (var s = 0; s < _steps; s++) {
        var _sx = _x + s * (_step_w + _step_gap);

        if (s < _preenchidos) {
            draw_set_colour(_teal);
            draw_rectangle(_sx, _y, _sx + _step_w, _y + _step_h, false);
        } else {
            draw_set_colour(_navy);
            draw_rectangle(_sx, _y, _sx + _step_w, _y + _step_h, false);
            draw_set_colour(_teal);
            draw_rectangle(_sx, _y, _sx + _step_w, _y + _step_h, true);
        }
    }

    draw_set_colour(c_white);
}
```

---

## ✅ Checklist Rápida

### Scripts a criar
- [ ] `scr_inicializarConfigs`
- [ ] `scr_salvarConfigs`
- [ ] `scr_lang`
- [ ] `scr_desenharStepBar` (se ainda não criado pelo guia áudio)

### Objetos a criar
- [ ] `oFpsDrawer` (Persistent: True), com Draw GUI
- [ ] Posicionar instância em `rm_MenuPrincipal` na layer `Managers` (ou `instancias`)

### Objetos a modificar
- [ ] `oProcuraControle/Create` — carregar configs do INI + aplicar fullscreen + setar GUI size
- [ ] `oController/Step` — atalho F11
- [ ] `oController/Draw_64` — menu de pausa usar `scr_lang` em tempo real
- [ ] `oMenuPrincipal/Draw_64` — labels via `scr_lang`
- [ ] `oVitoria/Draw_64` — título/subtítulo/botões via `scr_lang`
- [ ] `oGameOver/Draw_64` — mensagem de morte via `scr_lang`
- [ ] `oSettings/Create_0` — arrays `opcao_chaves`, `opcao_tipo`, cooldowns
- [ ] `oSettings/Step_0` — navegação + ajuste + confirmação + salvar
- [ ] `oSettings/Draw_64` — desenho dinâmico por tipo

### INI
- [ ] Nova seção `[video]` (chaves: `fullscreen`, `fps`)
- [ ] Nova seção `[lang]` (chave: `idioma`)

### Testes
- [ ] F11 alterna fullscreen e persiste após reiniciar o jogo
- [ ] Toggle FPS no Settings liga/desliga o display em **todas** as rooms
- [ ] Troca de idioma atualiza menus em tempo real (sem precisar reiniciar)
- [ ] Voltar do Settings (botão ou ESC) salva tudo
- [ ] Defaults funcionam quando o INI não existe (primeiro boot)

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| FPS aparece em uma room mas não em outra | `oFpsDrawer` não é Persistent OU foi duplicado em outra room | Marcar Persistent: True; colocar apenas em `rm_MenuPrincipal` |
| Idioma volta pra PT depois de reiniciar | Esqueceu `ini_write_string` ou `scr_salvarConfigs` | Garantir que o Voltar/ESC chama `scr_salvarConfigs()` |
| Menu de pausa fica em PT mesmo trocando para EN | `pause_opcoes` foi cacheado no Create | Trocar para chamar `scr_lang` direto no Draw, sem cache |
| Fullscreen quebra a UI / texto sumiu | `display_set_gui_size` não foi chamado | Garantir `display_set_gui_size(1920, 1080)` no `oProcuraControle/Create` |
| F11 não funciona durante pausa | Atalho foi colocado depois da guard clause de pausa | Mover o `if (keyboard_check_pressed(vk_f11))` para antes de `if (global.pausado)` |
| Toggle fica mudando de estado várias vezes ao pressionar | Usou `keyboard_check` em vez de `keyboard_check_pressed` | Trocar para `_pressed` no Step |
| `scr_lang("xxx")` mostra `[xxx]` | Chave não existe no dicionário | Adicionar ao struct `_dict` nos dois idiomas |
| `fase_nomes` continuam em PT | Não está no escopo deste guia | Documentar como TODO no `TODO_LIST.md` |

---

## 📁 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `scripts/scr_inicializarConfigs/scr_inicializarConfigs.gml` | **NOVO** |
| `scripts/scr_salvarConfigs/scr_salvarConfigs.gml` | **NOVO** |
| `scripts/scr_lang/scr_lang.gml` | **NOVO** |
| `scripts/scr_desenharStepBar/scr_desenharStepBar.gml` | **NOVO** (se ainda não existe) |
| `objects/oFpsDrawer/{Create_0,Draw_64}.gml` + `.yy` | **NOVO** (Persistent) |
| `objects/oProcuraControle/Create_0.gml` | **MODIFICAR** — carregar INI + fullscreen + GUI size |
| `objects/oController/Step_0.gml` | **MODIFICAR** — atalho F11 |
| `objects/oController/Draw_64.gml` | **MODIFICAR** — `scr_lang` no menu de pausa |
| `objects/oMenuPrincipal/Draw_64.gml` | **MODIFICAR** — `scr_lang` nos botões |
| `objects/oVitoria/Draw_64.gml` | **MODIFICAR** — `scr_lang` em título/subtítulo/botões |
| `objects/oGameOver/Draw_64.gml` | **MODIFICAR** — `scr_lang` na mensagem de morte |
| `objects/oSettings/{Create_0,Step_0,Draw_64}.gml` | **ESTENDER** — 3 novas opções (Fullscreen/FPS/Idioma) |
| `save_progresso.ini` (runtime) | Novas seções `[video]` (`fullscreen`, `fps`) e `[lang]` (`idioma`) |

---

## 📝 TODOs Pós-Implementação

- [ ] Atualizar `CONTEXTO_GAMEMAKER.md` adicionando `global.fullscreen`, `global.mostrarFps`, `global.idioma` à tabela de variáveis globais; mencionar `oFpsDrawer` no mapa de objetos.
- [ ] Traduzir `fase_nomes` e `fase_subtitulos` quando o time decidir as traduções oficiais (criar arrays paralelos PT/EN ou adicionar chaves `fase_XX_nome` ao `scr_lang`).
- [ ] (Opcional) Adicionar mais idiomas — basta criar mais um `else if (global.idioma == "es")` em `scr_lang`.

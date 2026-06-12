# 🔓 Guia de Implementação — Desbloqueio Progressivo de Fases

> Guia para implementar o sistema de progressão onde a fase 1 é sempre acessível e as próximas só desbloqueiam ao vencer a anterior.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Objeto do seletor | `oSeletorDeFases` (já existe em `rm_SelecaoDeFases`) |
| Objeto de vitória | `oVitoria` (já existe em `rm_Vitoria`) |
| Paleta de cores | Navy escuro + Teal (padrão do projeto) |
| Fonte | `fnt_pixel` |
| Persistência | Salva progresso em arquivo para manter entre sessões |

---

## 🏗️ Estrutura Geral

### Como funciona

1. **`global.fase_desbloqueada`** — número inteiro que indica até qual fase o jogador pode jogar (índice 0 = fase 1 sempre aberta)
2. **`global.fase_atual`** — índice da fase sendo jogada (definido ao confirmar no seletor)
3. Ao **vencer uma fase**, se era a fase mais avançada desbloqueada, a próxima é liberada
4. No **seletor de fases**, fases bloqueadas aparecem escurecidas com "🔒" e não podem ser selecionadas
5. O progresso é **salvo em arquivo** (`save_progresso.sav`) para persistir entre sessões

### Fluxo

```
[Seletor] → jogador escolhe fase desbloqueada → [Gameplay]
                                                     │
                                                     ▼
                                              jogador vence
                                                     │
                                                     ▼
                                           [rm_Vitoria]
                                           se fase_atual >= fase_desbloqueada:
                                               fase_desbloqueada++
                                               salvar progresso
                                                     │
                                                     ▼
                                            [Seletor] próxima fase aparece desbloqueada
```

### Layout Visual do Seletor

```
┌──────────────────────────────────────────────────────┐
│                 Escolha sua Fase                      │
│                                                      │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│   │    1     │    │    2     │    │   🔒     │      │
│   │          │    │          │    │          │      │
│   │ Fase 1   │    │ Fase 2   │    │ Bloqueada│      │
│   │ subtitulo│    │ subtitulo│    │          │      │
│   └──────────┘    └──────────┘    └──────────┘      │
│    desbloqueada    desbloqueada       bloqueada       │
│    (selecionável)  (selecionável)     (escurecida)    │
└──────────────────────────────────────────────────────┘
```

---

## 📦 O Que Modificar

| Arquivo | Tipo de Mudança |
|---|---|
| `oSeletorDeFases/Create_0.gml` | Adicionar variáveis globais de progressão + carregar save |
| `oSeletorDeFases/Step_0.gml` | Bloquear confirmação em fases travadas + setar fase_atual |
| `oSeletorDeFases/Draw_0.gml` | Visual diferente para fases bloqueadas (escurecido + cadeado) |
| `oVitoria/Step_0.gml` | Desbloquear próxima fase ao vencer + salvar progresso |

---

## 💻 Código

### Modificar `oSeletorDeFases/Create_0.gml`

Adicionar **após** a linha `if (!variable_global_exists("comida")) global.comida = 0;`:

```gml
// --- Progressão de fases ---
global.fase_atual = 0;

// Carregar progresso salvo (ou iniciar com fase 0 desbloqueada)
if (file_exists("save_progresso.sav")) {
    var _map = json_parse(file_text_read_string(file_text_open_read("save_progresso.sav")));
    file_text_close(_map);
    // Fallback: tentar ler, se falhar usa 0
    if (is_struct(_map) && variable_struct_exists(_map, "fase_desbloqueada")) {
        global.fase_desbloqueada = _map.fase_desbloqueada;
    } else {
        global.fase_desbloqueada = 0;
    }
} else {
    global.fase_desbloqueada = 0;
}

// Garantir que nunca passe do total de fases
global.fase_desbloqueada = clamp(global.fase_desbloqueada, 0, total_fases - 1);
```

**Alternativa simplificada (sem JSON, usando ini):**

```gml
// --- Progressão de fases ---
global.fase_atual = 0;

ini_open("save_progresso.ini");
global.fase_desbloqueada = ini_read_real("progresso", "fase_desbloqueada", 0);
ini_close();

global.fase_desbloqueada = clamp(global.fase_desbloqueada, 0, total_fases - 1);
```

> **Recomendação:** Use a versão com `ini_open/ini_close` — é mais simples e nativa do GameMaker.

**Variáveis explicadas:**

| Variável | Tipo | Descrição |
|---|---|---|
| `global.fase_desbloqueada` | int | Índice da última fase acessível (0 = só a primeira) |
| `global.fase_atual` | int | Índice da fase que o jogador está jogando agora |

---

### Modificar `oSeletorDeFases/Step_0.gml`

**Mudança 1:** No bloco de confirmação, adicionar verificação de desbloqueio e setar `global.fase_atual`.

Substituir o bloco de confirmação existente:

```gml
// -------------------------------------------------------
// CONFIRMAR — SPACE / E / botão A
// -------------------------------------------------------
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(global.gamepad_main, gp_face1);
}

if (_confirmar) {
    global.comida = 0;
    room_goto(fase_rooms[fase_selecionada]);
}
```

**Por este código:**

```gml
// -------------------------------------------------------
// CONFIRMAR — SPACE / E / botão A (só se desbloqueada)
// -------------------------------------------------------
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(global.gamepad_main, gp_face1);
}

if (_confirmar && fase_selecionada <= global.fase_desbloqueada) {
    global.fase_atual = fase_selecionada;
    global.comida = 0;
    room_goto(fase_rooms[fase_selecionada]);
}
```

A única mudança é:
- `&& fase_selecionada <= global.fase_desbloqueada` — impede entrar em fases bloqueadas
- `global.fase_atual = fase_selecionada;` — registra qual fase está sendo jogada

---

### Modificar `oSeletorDeFases/Draw_0.gml`

**Mudança:** No loop de cards, adicionar visual diferente para fases bloqueadas.

Dentro do `for (var i = 0; i < total_fases; i++)`, adicionar uma variável de bloqueio e modificar o visual:

Após a linha `var _sel = (i == fase_selecionada);`, adicionar:

```gml
    var _bloqueada = (i > global.fase_desbloqueada);
```

Depois, **substituir** o bloco da área de thumbnail (que desenha o número) por:

```gml
    // --- Área de thumbnail (topo do card) ---
    if (_bloqueada) {
        draw_set_color(make_color_rgb(12, 14, 25));
    } else if (_sel) {
        draw_set_color(make_color_rgb(25, 55, 85));
    } else {
        draw_set_color(make_color_rgb(20, 28, 55));
    }
    draw_rectangle(_cx, _cy, _cx + card_w, _cy + thumb_h, false);

    // Número ou cadeado no thumbnail
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (_bloqueada) {
        draw_set_color(make_color_rgb(50, 30, 30));
        draw_text(_cx + card_w / 2, _cy + thumb_h / 2, "X");
    } else {
        draw_set_color(_sel
            ? make_color_rgb(80, 200, 210)
            : make_color_rgb(35, 70, 90));
        draw_text(_cx + card_w / 2, _cy + thumb_h / 2, string(i + 1));
    }
```

E **substituir** o bloco de nome/subtítulo por:

```gml
    // Nome da fase
    if (_bloqueada) {
        draw_set_color(make_color_rgb(50, 55, 65));
        draw_text_ext(_cx + card_w / 2, _info_y, "Bloqueada", -1, card_w - 24);

        draw_set_color(make_color_rgb(35, 40, 50));
        draw_text_ext(_cx + card_w / 2, _info_y + 30, "Venca a fase anterior", -1, card_w - 24);
    } else {
        draw_set_color(_sel
            ? make_color_rgb(210, 240, 245)
            : make_color_rgb(130, 160, 175));
        draw_text_ext(_cx + card_w / 2, _info_y, fase_nomes[i], -1, card_w - 24);

        draw_set_color(_sel
            ? make_color_rgb(80, 180, 195)
            : make_color_rgb(50, 75, 95));
        draw_text_ext(_cx + card_w / 2, _info_y + 30, fase_subtitulos[i], -1, card_w - 24);
    }
```

E **substituir** o bloco de borda do card por:

```gml
    // --- Borda do card ---
    if (_bloqueada) {
        draw_set_color(make_color_rgb(25, 20, 20));
        draw_set_alpha(0.4);
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, true);
        draw_set_alpha(1);
    } else if (_sel) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(0.9);
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, true);
        draw_set_alpha(1);

        // Borda superior mais grossa como destaque
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + 4, false);
    } else {
        draw_set_color(make_color_rgb(35, 55, 80));
        draw_set_alpha(0.6);
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, true);
        draw_set_alpha(1);
    }
```

---

### Modificar `oVitoria/Step_0.gml`

Substituir todo o conteúdo por:

```gml
var _gp = global.gamepad_main;
var _gpConfirmar = (_gp != undefined) && gamepad_button_check_pressed(_gp, gp_face1);

if (keyboard_check_pressed(vk_space) || _gpConfirmar) {

    // Desbloquear próxima fase (se a fase atual era a mais avançada)
    if (global.fase_atual >= global.fase_desbloqueada) {
        global.fase_desbloqueada = min(global.fase_atual + 1, 4);

        // Salvar progresso
        ini_open("save_progresso.ini");
        ini_write_real("progresso", "fase_desbloqueada", global.fase_desbloqueada);
        ini_close();
    }

    room_goto(rm_SelecaoDeFases);
}
```

**O que mudou:**
- Antes de voltar ao seletor, verifica se a fase atual era a mais avançada
- Se sim, incrementa `global.fase_desbloqueada` (limitado ao total de fases - 1)
- Salva o progresso em `save_progresso.ini` para persistir entre sessões

> **Nota:** O `min(global.fase_atual + 1, 4)` usa 4 como limite porque há 5 fases (índices 0–4). Ajuste o número se adicionar mais fases. Ou use `array_length(oSeletorDeFases.fase_rooms) - 1` se o seletor estiver instanciado.

---

## 🧪 Como Testar

1. **Primeiro acesso** — Abra o seletor. Somente a Fase 1 deve estar acessível (as outras escurecidas com "X" e "Bloqueada")
2. **Tentar selecionar bloqueada** — Navegue até uma fase bloqueada e pressione Space. Nada deve acontecer
3. **Jogar e vencer Fase 1** — Colete todas as comidas e saia. Na tela de vitória, pressione Space
4. **Voltar ao seletor** — Agora Fase 1 e Fase 2 devem estar acessíveis
5. **Fechar e reabrir o jogo** — O progresso deve ser mantido (arquivo `save_progresso.ini`)
6. **Resetar progresso (debug)** — Delete o arquivo `save_progresso.ini` da pasta do jogo

---

## 🔧 Debug: Desbloquear Todas as Fases

Para testes durante o desenvolvimento, adicione temporariamente no `oSeletorDeFases/Step_0.gml`:

```gml
// DEBUG: pressione F1 para desbloquear tudo
if (keyboard_check_pressed(vk_f1)) {
    global.fase_desbloqueada = total_fases - 1;
}
// DEBUG: pressione F2 para resetar progresso
if (keyboard_check_pressed(vk_f2)) {
    global.fase_desbloqueada = 0;
    ini_open("save_progresso.ini");
    ini_write_real("progresso", "fase_desbloqueada", 0);
    ini_close();
}
```

> **Lembre-se de remover essas linhas antes de entregar!**

---

## ⚠️ Cuidados

- **Número máximo de fases** — O `min()` no oVitoria deve refletir o total de fases. Se mudar o array `fase_rooms`, ajuste o limite.
- **Fases repetidas** — Atualmente `fase_rooms` repete rooms (room_01 aparece 2x). O desbloqueio funciona por índice, não por room, então não há conflito.
- **Save corrompido** — Se o arquivo `.ini` for editado manualmente com valor inválido, o `clamp()` no Create garante que não quebre.
- **Ordem do código** — O carregamento do save DEVE estar no `Create_0` do seletor, que roda toda vez que entra na `rm_SelecaoDeFases`.

---

## ⚙️ Parte Extra — Menu de Configurações + Reset de Progresso + Confirmação para Sair

> Extensão do sistema de desbloqueio: o botão "Settings" do menu principal leva a um sub-menu onde o jogador pode resetar todo o progresso (com confirmação). O botão "Exit" do menu principal também ganha um diálogo de confirmação antes de fechar o jogo.

---

### 🏗️ Estrutura Geral

#### Como funciona

1. O menu principal tem 3 botões: **Play**, **Settings**, **Exit**
2. **Settings** abre um sub-menu (na mesma room, sem trocar de room) com opções
3. No sub-menu Settings aparece o botão **"Resetar Progresso"**
4. Ao clicar em "Resetar Progresso", aparece um **diálogo de confirmação** ("Tem certeza?") com opções **Sim / Não**
5. Se confirmar: apaga o `save_progresso.ini` e reseta `global.fase_desbloqueada = 0`
6. O botão **Exit** do menu principal também exibe um **diálogo de confirmação** antes de `game_end()`
7. Em ambos os diálogos, o padrão é **"Não"** (evita ações acidentais)

#### Fluxo Visual

```
┌─────────────────────────────────────┐
│         MENU PRINCIPAL              │
│                                     │
│           [Play]                    │
│           [Settings]  ───────┐      │
│           [Exit] ──────┐     │      │
│                        │     │      │
└────────────────────────│─────│──────┘
                         │     │
                         ▼     ▼
              ┌──────────────────────────┐
              │   "Sair do jogo?"        │
              │                          │
              │    [Não]     [Sim]       │
              └──────────────────────────┘
                    │           │
                    ▼           ▼
                 volta       game_end()
              
                         ▼
              ┌──────────────────────────┐
              │      SETTINGS            │
              │                          │
              │   [Resetar Progresso]    │
              │   [Voltar]              │
              └──────────────────────────┘
                         │
                         ▼ (ao clicar Resetar)
              ┌──────────────────────────┐
              │  "Tem certeza que quer   │
              │   resetar todo o         │
              │   progresso?"            │
              │                          │
              │    [Não]     [Sim]       │
              └──────────────────────────┘
                    │           │
                    ▼           ▼
                 volta       reseta save
                             + feedback visual
```

---

### 💻 Implementação — `oMenuPrincipal/Create_0.gml`

Adicionar **após** `DEADZONE = 0.5;`:

```gml
// === SUB-MENUS E CONFIRMAÇÃO ===
menu_estado = "principal";  // "principal", "settings", "confirmar_sair", "confirmar_reset"

// Settings
settings_botoes = ["Resetar Progresso", "Voltar"];
total_settings = array_length(settings_botoes);
settings_focado = 0;

// Confirmação (genérica — usada para sair e reset)
confirmar_opcoes = ["Nao", "Sim"];
confirmar_focado = 0;  // padrão em "Não" (segurança)
confirmar_texto = "";   // mensagem exibida no diálogo
confirmar_acao = "";    // "sair" ou "reset" — define o que acontece ao confirmar
```

---

### 💻 Implementação — `oMenuPrincipal/Step_0.gml`

Substituir **todo** o bloco de confirmação (a partir de `// CONFIRMAR — SPACE / E / botão A`) por:

```gml
// ===============================================================
// CONFIRMAR — SPACE / E / botão A
// ===============================================================
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (_tem_controle) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(_gp, gp_face1);
}

// VOLTAR — ESC / B no gamepad
var _voltar = keyboard_check_pressed(vk_escape);

if (_tem_controle) {
    _voltar = _voltar
            || gamepad_button_check_pressed(_gp, gp_face2);
}

// ---------------------------------------------------------------
// ESTADO: MENU PRINCIPAL
// ---------------------------------------------------------------
if (menu_estado == "principal")
{
    // Navegação vertical (código existente de W/S funciona aqui)
    if (_confirmar) {
        switch (botao_focado) {
            case 0:  // Play
                room_goto(rm_SelecaoDeFases);
                break;

            case 1:  // Settings
                menu_estado = "settings";
                settings_focado = 0;
                break;

            case 2:  // Exit → pedir confirmação
                menu_estado = "confirmar_sair";
                confirmar_focado = 0;  // foco em "Não"
                confirmar_texto = "Sair do jogo?";
                confirmar_acao = "sair";
                break;
        }
    }
}
// ---------------------------------------------------------------
// ESTADO: SETTINGS
// ---------------------------------------------------------------
else if (menu_estado == "settings")
{
    // Navegação vertical entre botões do settings
    if (_mover != 0) {
        settings_focado = (settings_focado + _mover + total_settings) % total_settings;
    }

    if (_confirmar) {
        switch (settings_focado) {
            case 0:  // Resetar Progresso → pedir confirmação
                menu_estado = "confirmar_reset";
                confirmar_focado = 0;  // foco em "Não"
                confirmar_texto = "Resetar todo o progresso?";
                confirmar_acao = "reset";
                break;

            case 1:  // Voltar
                menu_estado = "principal";
                break;
        }
    }

    // Voltar com ESC/B
    if (_voltar) {
        menu_estado = "principal";
    }
}
// ---------------------------------------------------------------
// ESTADO: CONFIRMAÇÃO (genérico — sair ou reset)
// ---------------------------------------------------------------
else if (menu_estado == "confirmar_sair" || menu_estado == "confirmar_reset")
{
    // Navegação horizontal entre "Não" e "Sim"
    var _mover_h = 0;

    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) _mover_h =  1;
    if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) _mover_h = -1;

    if (_tem_controle && nav_cooldown == 0) {
        if (gamepad_button_check_pressed(_gp, gp_padr)) _mover_h =  1;
        if (gamepad_button_check_pressed(_gp, gp_padl)) _mover_h = -1;

        var _ax = gamepad_axis_value(_gp, gp_axislh);
        if (_ax >  DEADZONE) _mover_h =  1;
        if (_ax < -DEADZONE) _mover_h = -1;

        if (_mover_h != 0) nav_cooldown = NAV_COOLDOWN_MAX;
    }

    if (_mover_h != 0) {
        confirmar_focado = (confirmar_focado + _mover_h + 2) % 2;
    }

    // Confirmar escolha
    if (_confirmar) {
        if (confirmar_focado == 1)  // "Sim"
        {
            if (confirmar_acao == "sair") {
                game_end();
            }
            else if (confirmar_acao == "reset") {
                // Resetar progresso
                global.fase_desbloqueada = 0;

                ini_open("save_progresso.ini");
                ini_write_real("progresso", "fase_desbloqueada", 0);

                // Resetar estrelas também (se implementado)
                for (var i = 0; i < 10; i++) {
                    ini_write_real("estrelas", "fase_" + string(i), 0);
                }
                ini_close();

                // Voltar ao settings com feedback
                menu_estado = "settings";
            }
        }
        else  // "Não"
        {
            // Volta para o menu anterior
            if (confirmar_acao == "sair") {
                menu_estado = "principal";
            } else {
                menu_estado = "settings";
            }
        }
    }

    // Voltar com ESC/B (equivale a "Não")
    if (_voltar) {
        if (confirmar_acao == "sair") {
            menu_estado = "principal";
        } else {
            menu_estado = "settings";
        }
    }
}
```

> **Nota:** O bloco de navegação vertical (`_mover`) já existente no início do Step continua funcionando — ele é usado pelo menu principal e pelo settings. O diálogo de confirmação usa navegação **horizontal** (A/D ou D-pad esquerda/direita).

---

### 💻 Implementação — `oMenuPrincipal/Draw_64.gml`

Substituir **todo** o bloco `// BOTÕES` por um bloco condicional que desenha o menu correto de acordo com `menu_estado`:

```gml
// ===============================================================
// BOTÕES — desenha de acordo com o estado do menu
// ===============================================================

if (menu_estado == "principal")
{
    // --- MENU PRINCIPAL (3 botões) ---
    for (var i = 0; i < total_botoes; i++) {
        var _bx = btn_x;
        var _by = btn_y_inicio + i * (btn_h + btn_gap);
        var _focado = (i == botao_focado);

        // fundo
        draw_set_color(_focado ? make_color_rgb(25, 55, 75) : make_color_rgb(18, 22, 42));
        draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, false);

        // indicador lateral
        if (_focado) {
            draw_set_color(make_color_rgb(80, 200, 210));
            draw_rectangle(_bx, _by, _bx + 6, _by + btn_h, false);
        }

        // borda
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(_focado ? 0.8 : 0.3);
        draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, true);
        draw_set_alpha(1);

        // texto
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(_focado ? make_color_rgb(120, 230, 240) : make_color_rgb(80, 130, 150));
        draw_text(_bx + btn_w / 2, _by + btn_h / 2, botoes[i]);
    }
}
else if (menu_estado == "settings")
{
    // --- SUB-MENU SETTINGS ---
    // Título do sub-menu
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_text_transformed(btn_x + btn_w / 2, btn_y_inicio - 50, "CONFIGURACOES", 1.5, 1.5, 0);

    for (var i = 0; i < total_settings; i++) {
        var _bx = btn_x;
        var _by = btn_y_inicio + i * (btn_h + btn_gap);
        var _focado = (i == settings_focado);

        // fundo
        draw_set_color(_focado ? make_color_rgb(25, 55, 75) : make_color_rgb(18, 22, 42));
        draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, false);

        // indicador lateral
        if (_focado) {
            draw_set_color(make_color_rgb(80, 200, 210));
            draw_rectangle(_bx, _by, _bx + 6, _by + btn_h, false);
        }

        // borda
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(_focado ? 0.8 : 0.3);
        draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, true);
        draw_set_alpha(1);

        // texto
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);

        // Botão "Resetar Progresso" em vermelho para destacar ação destrutiva
        if (i == 0) {
            draw_set_color(_focado ? make_color_rgb(255, 120, 120) : make_color_rgb(150, 70, 70));
        } else {
            draw_set_color(_focado ? make_color_rgb(120, 230, 240) : make_color_rgb(80, 130, 150));
        }
        draw_text(_bx + btn_w / 2, _by + btn_h / 2, settings_botoes[i]);
    }

    // Dica de voltar
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(60, 90, 110));
    var _dica_y = btn_y_inicio + total_settings * (btn_h + btn_gap) + 20;
    draw_text(btn_x + btn_w / 2, _dica_y, "[ESC] Voltar");
}
else if (menu_estado == "confirmar_sair" || menu_estado == "confirmar_reset")
{
    // --- DIÁLOGO DE CONFIRMAÇÃO ---
    var _cx = _gw / 2;
    var _cy = _gh / 2;

    // Fundo escuro overlay
    draw_set_alpha(0.7);
    draw_set_color(make_color_rgb(8, 8, 16));
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // Caixa do diálogo
    var _box_w = 500;
    var _box_h = 200;
    var _box_x = _cx - _box_w / 2;
    var _box_y = _cy - _box_h / 2;

    draw_set_color(make_color_rgb(20, 25, 45));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

    // Borda do diálogo
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(0.6);
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);
    draw_set_alpha(1);

    // Linha superior decorativa
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + 4, false);

    // Texto da pergunta
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(210, 230, 240));
    draw_text(_cx, _cy - 40, confirmar_texto);

    // Botões "Não" e "Sim"
    var _btn_confirm_w = 140;
    var _btn_confirm_h = 50;
    var _btn_gap_h = 40;

    for (var i = 0; i < 2; i++) {
        var _bx = _cx - _btn_gap_h - _btn_confirm_w + i * (_btn_confirm_w + _btn_gap_h);
        var _by = _cy + 20;
        var _focado = (i == confirmar_focado);

        // Fundo
        if (i == 1) {
            // "Sim" — cor de perigo quando focado
            draw_set_color(_focado ? make_color_rgb(80, 25, 25) : make_color_rgb(30, 18, 18));
        } else {
            // "Não" — cor normal
            draw_set_color(_focado ? make_color_rgb(25, 55, 75) : make_color_rgb(18, 22, 42));
        }
        draw_rectangle(_bx, _by, _bx + _btn_confirm_w, _by + _btn_confirm_h, false);

        // Borda
        if (i == 1) {
            draw_set_color(_focado ? make_color_rgb(255, 80, 80) : make_color_rgb(100, 40, 40));
        } else {
            draw_set_color(_focado ? make_color_rgb(80, 200, 210) : make_color_rgb(40, 80, 100));
        }
        draw_set_alpha(_focado ? 0.9 : 0.4);
        draw_rectangle(_bx, _by, _bx + _btn_confirm_w, _by + _btn_confirm_h, true);
        draw_set_alpha(1);

        // Indicador lateral
        if (_focado) {
            var _ind_color = (i == 1) ? make_color_rgb(255, 80, 80) : make_color_rgb(80, 200, 210);
            draw_set_color(_ind_color);
            draw_rectangle(_bx, _by, _bx + 5, _by + _btn_confirm_h, false);
        }

        // Texto
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        if (i == 1) {
            draw_set_color(_focado ? make_color_rgb(255, 130, 130) : make_color_rgb(150, 70, 70));
        } else {
            draw_set_color(_focado ? make_color_rgb(120, 230, 240) : make_color_rgb(80, 130, 150));
        }
        draw_text(_bx + _btn_confirm_w / 2, _by + _btn_confirm_h / 2, confirmar_opcoes[i]);
    }

    // Dica de navegação
    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(60, 90, 110));
    draw_text(_cx, _box_y + _box_h - 20, "[A/D] Escolher    [E] Confirmar    [ESC] Cancelar");
}
```

---

### 💻 Implementação — Navegação no Step (importante)

O bloco de **navegação vertical** (`_mover`) que já existe no `Step_0.gml` deve ser **condicionado** ao estado do menu para não interferir nos diálogos:

Substituir o bloco de navegação existente por:

```gml
// ===============================================================
// NAVEGAÇÃO VERTICAL ENTRE BOTÕES (só no menu principal e settings)
// ===============================================================
var _mover = 0;

if (menu_estado == "principal" || menu_estado == "settings")
{
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

    // Aplica navegação
    if (_mover != 0) {
        if (menu_estado == "principal") {
            botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
        } else if (menu_estado == "settings") {
            settings_focado = (settings_focado + _mover + total_settings) % total_settings;
        }
    }
}
```

---

### ✅ Checklist — Settings + Confirmação

#### Create_0 (novas variáveis)
- [ ] Adicionar `menu_estado = "principal";`
- [ ] Adicionar `settings_botoes`, `total_settings`, `settings_focado`
- [ ] Adicionar `confirmar_opcoes`, `confirmar_focado`, `confirmar_texto`, `confirmar_acao`

#### Step_0 (lógica de estados)
- [ ] Condicionar navegação vertical ao `menu_estado`
- [ ] Adicionar input de **voltar** (ESC / gp_face2)
- [ ] Estado `"principal"`: Settings abre sub-menu, Exit abre confirmação
- [ ] Estado `"settings"`: Resetar Progresso abre confirmação, Voltar retorna
- [ ] Estado `"confirmar_sair"` / `"confirmar_reset"`: navegação horizontal + ação

#### Draw_64 (visual por estado)
- [ ] Menu principal: desenha botões normais (Play, Settings, Exit)
- [ ] Settings: desenha título + botões (Resetar Progresso em vermelho, Voltar)
- [ ] Confirmação: overlay escuro + caixa com pergunta + botões Não/Sim

#### Lógica de Reset
- [ ] Reseta `global.fase_desbloqueada = 0`
- [ ] Escreve `0` no `save_progresso.ini` (seção "progresso")
- [ ] Reseta estrelas de todas as fases no ini (seção "estrelas")
- [ ] Volta ao sub-menu settings após reset

#### Teste
- [ ] Settings abre e fecha (ESC / Voltar)
- [ ] "Resetar Progresso" mostra diálogo de confirmação
- [ ] "Não" no reset volta ao settings sem resetar
- [ ] "Sim" no reset limpa o progresso (verificar no seletor de fases)
- [ ] "Exit" mostra diálogo de confirmação
- [ ] "Não" no exit volta ao menu principal
- [ ] "Sim" no exit fecha o jogo
- [ ] ESC/B funciona como "Não" em ambos os diálogos
- [ ] Navegação com gamepad funciona em todos os estados
- [ ] Foco padrão é sempre em "Não" (segurança)

---

### 📝 Resumo de Arquivos (Settings + Confirmação)

| Arquivo | Ação |
|---|---|
| `objects/oMenuPrincipal/Create_0.gml` | **MODIFICAR** — adicionar variáveis de estado/settings/confirmação |
| `objects/oMenuPrincipal/Step_0.gml` | **MODIFICAR** — máquina de estados do menu + lógica de reset + confirmação |
| `objects/oMenuPrincipal/Draw_64.gml` | **MODIFICAR** — desenho condicional por estado (principal/settings/confirmação) |

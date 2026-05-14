# ⏸️ Guia de Implementação — Tela de Pausa

> Guia para implementar o sistema de pausa no jogo. Pressionar ESC (teclado) ou Start (gamepad) congela toda a lógica e exibe um menu com 3 opções: Continuar, Reiniciar Fase e Sair.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Resolução da room | 1920×1080 |
| Fonte | `fnt_pixel` (já existe no projeto) |
| Paleta de cores | Navy escuro (`rgb(14, 14, 26)`) + Teal (`rgb(80, 200, 210)`) |
| Input | Teclado (ESC para toggle, W/S para navegar, Space/E/Enter para confirmar) + Gamepad (Start para toggle, D-pad/Stick para navegar, A/Cruz para confirmar) |
| `global.gamepad_main` | Gerenciado por `oProcuraControle` (persistente) |
| Objeto responsável | `oController` (já existe — recebe as variáveis e lógica de pausa) |
| Evento de desenho | `Draw GUI` (Draw_64) — desenhado por cima de tudo |
| Rooms afetadas | Todas as rooms de gameplay (`room_01`, `room_02`, etc.) |

---

## 🏗️ Estrutura Geral

### Abordagem

O sistema de pausa é implementado **dentro do `oController`** já existente, sem criar objetos novos. Isso é possível porque:

1. O `oController` já gerencia o estado do jogo (vida, fome, inventário)
2. O `oController` já tem o evento `Draw_64` (Draw GUI) para desenhar HUD
3. Centralizar a pausa no controller evita conflitos de prioridade

### Como funciona o congelamento

Quando `global.pausado = true`:
- O `Step_0` do `oController` executa a lógica do menu e chama `exit;` — isso impede que fome diminua, interações aconteçam ou game over seja checado
- Cada objeto de gameplay (`oPlayer`, `oInimigo`, `oNpc`, `oComida`, `oSaida`) verifica `if (global.pausado) exit;` no início do seu `Step_0` — isso impede movimentação, IA, animações e colisões

### Layout Visual

```
┌──────────────────────────────────────────────────────┐
│                ═══════════════                        │  ← linha decorativa teal
│                                                      │
│                                                      │
│                   PAUSADO                             │  ← título teal claro
│                                                      │
│             ┌──────────────────────┐                  │
│             │▌   Continuar         │                  │  ← botão selecionado
│             └──────────────────────┘                  │
│             ┌──────────────────────┐                  │
│             │    Reiniciar Fase    │                  │  ← botão normal
│             └──────────────────────┘                  │
│             ┌──────────────────────┐                  │
│             │    Sair              │                  │  ← botão normal
│             └──────────────────────┘                  │
│                                                      │
│          W S para navegar   SPACE para confirmar      │  ← rodapé dinâmico
│                ═══════════════                        │  ← linha decorativa teal
└──────────────────────────────────────────────────────┘
```

### Opções do Menu

| Índice | Texto | Ação |
|--------|-------|------|
| 0 | Continuar | Despausa o jogo (`global.pausado = false`) |
| 1 | Reiniciar Fase | Despausa e reinicia a room (`room_restart()`) |
| 2 | Sair | Despausa e volta ao seletor (`room_goto(rm_SelecaoDeFases)`) |

---

## 📦 O Que Modificar

Nenhum recurso novo é criado. Tudo é adicionado em arquivos existentes:

| Arquivo | Tipo de Mudança |
|---|---|
| `oController/Create_0.gml` | Adicionar variáveis de pausa no final |
| `oController/Step_0.gml` | Adicionar toggle + lógica de menu **no início** (antes de tudo) |
| `oController/Draw_64.gml` | Adicionar desenho do menu **após** o HUD existente |
| `oPlayer/Step_0.gml` | Adicionar guard clause na linha 1 |
| `oInimigo/Step_0.gml` | Adicionar guard clause na linha 1 |
| `oNpc/Step_0.gml` | Adicionar guard clause na linha 1 |
| `oComida/Step_0.gml` | Adicionar guard clause na linha 1 |
| `oSaida/Step_0.gml` | Adicionar guard clause na linha 1 |

---

## 💻 Código

### Modificar `oController/Create_0.gml`

Adicionar **no final** do arquivo (após as variáveis existentes):

```gml
// pausa
global.pausado = false;
pause_selecionado = 0;
pause_opcoes = ["Continuar", "Reiniciar Fase", "Sair"];
pause_total = array_length(pause_opcoes);
pause_nav_cooldown = 0;
PAUSE_NAV_CD_MAX = 12;
```

**Variáveis explicadas:**

| Variável | Tipo | Descrição |
|---|---|---|
| `global.pausado` | bool | Estado global de pausa — lido por todos os objetos |
| `pause_selecionado` | int | Índice do botão atualmente focado (0–2) |
| `pause_opcoes` | array | Textos dos botões do menu |
| `pause_total` | int | Quantidade de opções (3) |
| `pause_nav_cooldown` | int | Cooldown para navegação via analógico (evita drift) |
| `PAUSE_NAV_CD_MAX` | int | Frames de cooldown entre inputs do analógico |

---

### Modificar `oController/Step_0.gml`

Adicionar **no início** do arquivo (antes de todo o código existente):

```gml
// ===============================================================
// PAUSA — toggle com ESC / Start
// ===============================================================
var _gp = global.gamepad_main;
var _gpStart = (_gp != undefined) && gamepad_button_check_pressed(_gp, gp_start);

if (keyboard_check_pressed(vk_escape) || _gpStart) {
    global.pausado = !global.pausado;
    pause_selecionado = 0;
    pause_nav_cooldown = 0;
}

// Se pausado, processar menu e sair do Step (congela o jogo)
if (global.pausado) {

    // cooldown de navegação
    if (pause_nav_cooldown > 0) pause_nav_cooldown--;

    // navegação vertical
    var _nav = 0;
    if (keyboard_check_pressed(ord("S"))) _nav = 1;
    if (keyboard_check_pressed(ord("W"))) _nav = -1;

    if (_gp != undefined && gamepad_is_connected(_gp) && pause_nav_cooldown == 0) {
        if (gamepad_button_check_pressed(_gp, gp_padd)) _nav = 1;
        if (gamepad_button_check_pressed(_gp, gp_padu)) _nav = -1;
        var _ay = gamepad_axis_value(_gp, gp_axislv);
        if (_ay >  0.5) _nav =  1;
        if (_ay < -0.5) _nav = -1;
        if (_nav != 0) pause_nav_cooldown = PAUSE_NAV_CD_MAX;
    }

    pause_selecionado = clamp(pause_selecionado + _nav, 0, pause_total - 1);

    // confirmar seleção
    var _confirmar = keyboard_check_pressed(vk_space)
                  || keyboard_check_pressed(ord("E"))
                  || keyboard_check_pressed(vk_enter);
    if (_gp != undefined) _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);

    if (_confirmar) {
        switch (pause_selecionado) {
            case 0: // Continuar
                global.pausado = false;
                break;
            case 1: // Reiniciar Fase
                global.pausado = false;
                room_restart();
                break;
            case 2: // Sair para seletor
                global.pausado = false;
                room_goto(rm_SelecaoDeFases);
                break;
        }
    }

    exit; // impede toda a lógica normal do Step (fome, interação, game over)
}
```

**Por que `exit;` no final?**
O comando `exit;` encerra a execução do evento atual. Isso significa que enquanto pausado, **nenhum** código abaixo será executado — a fome não diminui, a interação não é processada, o game over não é checado.

---

### Modificar `oController/Draw_64.gml`

Adicionar **após** as linhas existentes de HUD (scr_drawVida, scr_drawFome, scr_drawComida):

```gml
// ===============================================================
// MENU DE PAUSA (desenhado por cima do HUD)
// ===============================================================
if (global.pausado) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _cx = _gui_w / 2;
    var _cy = _gui_h / 2;

    // --- Fundo escuro semitransparente ---
    draw_set_alpha(0.75);
    draw_set_color(make_color_rgb(14, 14, 26));
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    // --- Calcular posições dos botões primeiro ---
    var _bw = 320;
    var _bh = 54;
    var _gap = 16;
    var _blocoH = _bh * pause_total + _gap * (pause_total - 1);
    var _startY = _cy - _blocoH / 2;
    var _footerY = _startY + _blocoH + 30;

    // --- Linhas decorativas teal (relativas ao conteúdo) ---
    draw_set_color(make_color_rgb(60, 160, 170));
    draw_set_alpha(0.35);
    draw_line_width(0, _startY - 120, _gui_w, _startY - 120, 2);
    draw_line_width(0, _footerY + 40, _gui_w, _footerY + 40, 2);
    draw_set_alpha(1);

    // --- Título "PAUSADO" ---
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(120, 220, 230));
    draw_text(_cx, _startY - 60, "PAUSADO");

    // --- Botões do menu ---

    for (var i = 0; i < pause_total; i++) {
        var _bx = _cx - _bw / 2;
        var _by = _startY + i * (_bh + _gap);
        var _sel = (i == pause_selecionado);

        // Fundo do botão
        draw_set_color(_sel
            ? make_color_rgb(30, 60, 80)
            : make_color_rgb(20, 35, 55));
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

        // Borda esquerda colorida (só no selecionado)
        if (_sel) {
            draw_set_color(make_color_rgb(80, 200, 210));
            draw_rectangle(_bx, _by, _bx + 5, _by + _bh, false);
        }

        // Borda geral
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(_sel ? 0.8 : 0.3);
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
        draw_set_alpha(1);

        // Texto do botão
        draw_set_color(_sel
            ? make_color_rgb(120, 225, 235)
            : make_color_rgb(80, 200, 210));
        draw_text(_cx, _by + _bh / 2, pause_opcoes[i]);
    }

    // --- Rodapé — dica de input dinâmica ---
    var _gp = global.gamepad_main;
    var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);
    draw_set_color(make_color_rgb(45, 80, 95));

    if (_temControle) {
        draw_text(_cx, _footerY, "D-pad  para navegar     A / Cruz  para confirmar");
    } else {
        draw_text(_cx, _footerY, "W S  para navegar     SPACE / E  para confirmar");
    }

    // Reset alinhamento
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
```

**Notas sobre o Draw_64:**
- `Draw_64` é o evento Draw GUI — desenhado em coordenadas da tela (GUI), não da room
- `display_get_gui_width/height()` retorna o tamanho real da superfície GUI
- O menu é desenhado **por cima** do HUD porque vem depois no código

---

### Guard Clauses nos Objetos de Gameplay

Adicionar a seguinte linha **no início** (linha 1) do `Step_0.gml` de cada objeto:

```gml
if (global.pausado) exit;
```

**Objetos que precisam do guard clause:**

| Objeto | Arquivo | Motivo |
|---|---|---|
| `oPlayer` | `oPlayer/Step_0.gml` | Impede movimentação e input |
| `oInimigo` | `oInimigo/Step_0.gml` | Congela IA (patrulha, perseguição) |
| `oNpc` | `oNpc/Step_0.gml` | Congela movimentação aleatória e interação |
| `oComida` | `oComida/Step_0.gml` | Congela animação flutuante e detecção de proximidade |
| `oSaida` | `oSaida/Step_0.gml` | Congela verificação de desbloqueio |

**Por que não usar `instance_deactivate_all()`?**
Porque `instance_deactivate_all()` desativa o próprio `oController`, impedindo que ele processe a lógica do menu de pausa. A abordagem com `exit;` é mais simples e previsível.

---

## 🧪 Como Testar

1. Abra o projeto no GameMaker
2. Rode qualquer fase (`room_01` ou `room_02`)
3. Pressione **ESC** — o jogo deve congelar e mostrar o menu
4. Navegue com **W/S** — o botão selecionado muda
5. Pressione **Space/E/Enter** em cada opção:
   - **Continuar** → fecha o menu, jogo volta ao normal
   - **Reiniciar Fase** → room reinicia do zero
   - **Sair** → volta ao seletor de fases
6. Teste com gamepad: **Start** para toggle, **D-pad** para navegar, **A** para confirmar
7. Verifique que enquanto pausado:
   - A barra de fome **não** diminui
   - O jogador **não** se move
   - Os inimigos **não** patrulham
   - NPCs **não** se movem

---

## ⚠️ Cuidados

- **Não pausar em rooms de menu** — o toggle só funciona em rooms de gameplay (onde oController existe). As rooms `rm_SelecaoDeFases`, `rm_gameOver` e `rm_Vitoria` não têm oController, então ESC não faz nada nelas.
- **Reset ao trocar de room** — quando `room_restart()` ou `room_goto()` é chamado, o `Create_0` do oController roda novamente e reseta `global.pausado = false`.
- **Ordem do código** — o bloco de pausa DEVE ser o primeiro no `Step_0.gml` do oController, antes de qualquer lógica de jogo.

---

## 🏆💀 Botões Horizontais nas Telas de Vitória e Game Over

As telas `oVitoria` e `oGameOver` atualmente têm um único botão "Voltar ao menu". Vamos substituir por **dois botões horizontais**: **Reiniciar Fase** e **Sair**.

### Pré-requisito: salvar a room atual

Antes de ir para a tela de vitória ou game over, o jogo precisa lembrar qual room reiniciar. Adicionar no `oController/Create_0.gml`:

```gml
global.fase_room_atual = room;
```

Isso salva a room de gameplay atual para que os botões de "Reiniciar" saibam para onde voltar.

### Layout Visual

```
┌──────────────────────────────────────────────────────┐
│                ═══════════════                        │
│                                                      │
│               VOCÊ VENCEU!                           │  ← ou "GAME OVER"
│              Mim de papai.                           │  ← ou motivo da morte
│                                                      │
│         ┌──────────────────┐  ┌──────────────────┐   │
│         │▌ Reiniciar Fase  │  │    Sair          │   │  ← botões lado a lado
│         └──────────────────┘  └──────────────────┘   │
│                                                      │
│          A D  para navegar    SPACE  para confirmar   │
│                ═══════════════                        │
└──────────────────────────────────────────────────────┘
```

### Modificar `oVitoria/Create_0.gml` (e `oGameOver/Create_0.gml`)

Adicionar as variáveis de navegação. O `oGameOver` já tem `motivo = global.motivoMorte;` — adicionar **após**:

```gml
// botões horizontais
btn_selecionado = 0;
btn_opcoes = ["Reiniciar Fase", "Sair"];
btn_total = array_length(btn_opcoes);
btn_nav_cooldown = 0;
BTN_NAV_CD_MAX = 12;
```

Para `oVitoria/Create_0.gml` (atualmente vazio), criar com:

```gml
// botões horizontais
btn_selecionado = 0;
btn_opcoes = ["Reiniciar Fase", "Sair"];
btn_total = array_length(btn_opcoes);
btn_nav_cooldown = 0;
BTN_NAV_CD_MAX = 12;
```

### Modificar `oVitoria/Step_0.gml` (e `oGameOver/Step_0.gml`)

Substituir todo o conteúdo por:

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
    switch (btn_selecionado) {
        case 0: // Reiniciar Fase
            room_goto(global.fase_room_atual);
            break;
        case 1: // Sair para seletor
            room_goto(rm_SelecaoDeFases);
            break;
    }
}
```

### Modificar `oVitoria/Draw_0.gml` (e `oGameOver/Draw_0.gml`)

Substituir o bloco do botão único (a partir de `// Botão` ou `// BOTÃO`) pelo bloco de dois botões horizontais:

```gml
// --- Botões horizontais ---
var _bw = 280;
var _bh = 54;
var _gap = 24;
var _blocoW = btn_total * _bw + (btn_total - 1) * _gap;
var _startX = _cx - _blocoW / 2;
var _by = _cy + 30;

for (var i = 0; i < btn_total; i++) {
    var _bx = _startX + i * (_bw + _gap);
    var _sel = (i == btn_selecionado);

    // Fundo do botão
    draw_set_color(_sel
        ? make_color_rgb(30, 60, 80)
        : make_color_rgb(20, 35, 55));
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

    // Borda esquerda colorida (só no selecionado)
    if (_sel) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_bx, _by, _bx + 5, _by + _bh, false);
    }

    // Borda geral
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(_sel ? 0.8 : 0.3);
    draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
    draw_set_alpha(1);

    // Texto do botão
    draw_set_color(_sel
        ? make_color_rgb(120, 225, 235)
        : make_color_rgb(80, 200, 210));
    draw_text(_bx + _bw / 2, _by + _bh / 2, btn_opcoes[i]);
}

// --- Rodapé ---
var _gp = global.gamepad_main;
var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);
draw_set_color(make_color_rgb(45, 80, 95));
var _footerY = _by + _bh + 36;

if (_temControle) {
    draw_text(_cx, _footerY, "D-pad  para navegar     A / Cruz  para confirmar");
} else {
    draw_text(_cx, _footerY, "A D  para navegar     SPACE / E  para confirmar");
}
```

**O que manter do código atual:** todo o bloco de fundo, linhas decorativas, título e mensagem (motivo) ficam iguais. Só substitui do comentário `// Botão` até o `// Reset`.

### Diferenças entre oVitoria e oGameOver

| | oVitoria | oGameOver |
|---|---|---|
| Título | `"VOCÊ VENCEU!"` (teal) | `"GAME OVER"` (vermelho) |
| Mensagem | `"Mim de papai."` | Motivo dinâmico (dano/fome) |
| Create_0 | Só botões | `motivo = global.motivoMorte;` + botões |
| Step_0 / Draw_0 (botões) | **Idênticos** | **Idênticos** |

### Linhas decorativas

As linhas decorativas atuais em ambos os objetos usam `_cy ± 140`. Para acomodar os botões, ajustar a linha de baixo:

```gml
// Trocar:
draw_line_width(0, _cy + 140, room_width, _cy + 140, 2);

// Por:
draw_line_width(0, _cy + 130, room_width, _cy + 130, 2);
```

Isso dá mais espaço entre a linha e os botões.

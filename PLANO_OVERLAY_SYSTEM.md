# 🎮 Plano de Implementação — Sistema de Overlays (Estilo Bloons TD6)

## 📌 Contexto do Projeto

| Item | Valor Atual |
|---|---|
| Engine | GameMaker 2024.14.4 (GML) |
| Resolução GUI | 1920×1080 |
| Room inicial | `rm_SelecaoDeFases` |
| Rooms de gameplay | `room_01`, `room_02` |
| Telas de fim (atuais) | `rm_gameOver`, `rm_Vitoria` (rooms separadas) |
| Input | Teclado (WASD/Arrows/Enter/E/Space) + Gamepad (D-pad/Stick/Face buttons) |
| `global.gamepad_main` | Gerenciado por `oProcuraControle` (persistente, singleton) |
| `global.motivoMorte` | `"dano"` ou `"fome"` — setado pelo `oController` antes de game over |
| `global.game_paused` | **NÃO EXISTE AINDA** — precisa ser criado |
| Estado do jogo | `oController` gerencia vida, fome, comida (não é persistente) |

---

## 🏗️ Arquitetura do Sistema de Overlays

### Diagrama de Camadas (Draw GUI)

```
┌─────────────────────────────────────────────────────┐
│                    DEPTH / ORDEM                    │
│                                                     │
│  ┌───────────────────────────────────────────────┐  │
│  │ Camada 5 (topo): Dica de Input                │  │ ← "A para confirmar" / "ENTER para confirmar"
│  ├───────────────────────────────────────────────┤  │
│  │ Camada 4: Botões do Painel                    │  │ ← Botões com estado focado/hover
│  ├───────────────────────────────────────────────┤  │
│  │ Camada 3: Conteúdo do Painel                  │  │ ← Título, stats, estrelas, etc.
│  ├───────────────────────────────────────────────┤  │
│  │ Camada 2: Painel Central (retângulo)          │  │ ← Retângulo com cantos arredondados
│  ├───────────────────────────────────────────────┤  │
│  │ Camada 1: Fundo escurecido (dim overlay)      │  │ ← Retângulo preto alpha 0.7
│  ├───────────────────────────────────────────────┤  │
│  │ Camada 0 (base): Jogo congelado               │  │ ← HUD + Gameplay parados
│  └───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Fluxo de Telas (Novo)

```
                    ┌──────────────────┐
                    │  rm_MenuPrincipal │  ← NOVA room (só fundo + oMenuPrincipal)
                    │  (Room inicial)   │
                    └────────┬─────────┘
                             │ "Jogar"
                    ┌────────▼─────────┐
                    │  OVERLAY:         │  ← Overlay sobre rm_MenuPrincipal
                    │  Seleção de Fases │
                    └────────┬─────────┘
                             │ Seleciona fase
                    ┌────────▼─────────┐
                    │  room_01/room_02  │  ← Gameplay
                    │  (oController)    │
                    └──┬────────────┬───┘
                       │            │
              Morreu   │            │  Coletou tudo + saiu
                    ┌──▼──┐    ┌───▼───┐
                    │OVER-│    │OVER-  │
                    │LAY: │    │LAY:   │
                    │Derr.│    │Vitória│
                    └──┬──┘    └───┬───┘
                       │           │
          ┌────────────┴───────────┘
          │ "Voltar ao Menu"
          ▼
   rm_MenuPrincipal (volta ao início)
```

---

## 📦 Objetos — Criar ou Modificar

### Objetos Novos

| Objeto | Sprite | Persistente | Responsabilidade |
|---|---|---|---|
| `oOverlayManager` | nenhum | **Sim** | Singleton que gerencia qual overlay está ativo, animação de entrada/saída, e `global.game_paused` |
| `oMenuPrincipal` | nenhum | Não | Tela inicial: botões Jogar / Configurações / Sair |
| `oOverlayFases` | nenhum | Não | Overlay de seleção de fases (substitui `oSeletorDeFases` atual) |
| `oOverlayDerrota` | nenhum | Não | Overlay de derrota (substitui `oGameOver` + `rm_gameOver`) |
| `oOverlayVitoria` | nenhum | Não | Overlay de vitória (substitui `oVitoria` + `rm_Vitoria`) |

### Objetos a Modificar

| Objeto | Modificação |
|---|---|
| `oController` | Checar `global.game_paused` antes de processar lógica. Em vez de `room_goto(rm_gameOver)`, criar overlay de derrota. Em vez de vitória por room, criar overlay de vitória. |
| `oPlayer` | Checar `global.game_paused` antes de processar movimento e input. |
| `oInimigo` / `oFreddy` | Checar `global.game_paused` antes de processar FSM. |
| `oNpc` | Checar `global.game_paused` antes de processar wander e interação. |
| `oComida` | Checar `global.game_paused` antes de processar flutuação e coleta. |
| `oSaida` | Checar `global.game_paused`. Em vez de `room_goto(rm_Vitoria)`, pedir overlay de vitória. |

### Rooms a Modificar

| Room | Mudança |
|---|---|
| `rm_SelecaoDeFases` | Renomear para `rm_MenuPrincipal`. Substituir `oSeletorDeFases` por `oMenuPrincipal`. Adicionar `oOverlayManager` e `oProcuraControle`. |
| `room_01`, `room_02` | Adicionar `oOverlayManager` como instância. |
| `rm_gameOver` | **Remover** — substituída por overlay. |
| `rm_Vitoria` | **Remover** — substituída por overlay. |

### Room Order Final

```
rm_MenuPrincipal → room_01 → room_02
```

---

## 🔧 Variáveis Globais Necessárias

```gml
// ===== Em oOverlayManager / Create_0.gml =====

// Sistema de pause
global.game_paused = false;

// Overlay ativo (string ou noone)
// Valores possíveis: "menu", "fases", "derrota", "vitoria", noone
global.overlay_ativo = noone;

// Stack de overlays (para permitir overlay sobre overlay)
global.overlay_stack = [];

// Motivo da morte (já existe)
// global.motivoMorte = "";  // "dano" ou "fome"

// Estatísticas da run (para tela de vitória)
global.run_tempo    = 0;     // segundos que levou para completar
global.run_comida   = 0;     // comida coletada
global.run_dano     = 0;     // dano total recebido
global.run_estrelas = 0;     // 1-3 estrelas baseado em performance

// Progresso de fases
global.fase_atual       = 0;       // índice da fase jogando
global.fases_concluidas = [];      // array de booleans [false, false, ...]
global.fases_estrelas   = [];      // array de ints [0, 0, ...] (0-3 estrelas cada)
global.total_fases      = 5;

// Configurações (para menu de configurações futuro)
global.volume_musica = 1.0;
global.volume_sfx    = 1.0;
global.fullscreen    = false;
```

---

## 🎬 Padrão de Animação de Entrada/Saída (Reutilizável)

Toda overlay segue o mesmo padrão de animação. Use estas variáveis em **todo objeto de overlay**:

### Create Event — Variáveis de Animação

```gml
// ===== Animação de Entrada =====
anim_alpha   = 0;         // alpha atual do painel (0 = invisível)
anim_alpha_alvo = 1;      // alpha alvo
anim_escala  = 0.85;      // escala atual do painel (começa menor)
anim_escala_alvo = 1.0;   // escala alvo
anim_vel     = 0.08;      // velocidade do lerp (0.08 = suave)
anim_pronto  = false;     // true quando animação terminou

// Dim do fundo
dim_alpha    = 0;
dim_alpha_alvo = 0.7;

// Estado
overlay_saindo = false;   // true quando está fechando
```

### Step Event — Lógica de Animação

```gml
// ===== Animação de Entrada =====
if (!overlay_saindo) {
    anim_alpha  = lerp(anim_alpha,  anim_alpha_alvo,  anim_vel);
    anim_escala = lerp(anim_escala, anim_escala_alvo, anim_vel);
    dim_alpha   = lerp(dim_alpha,   dim_alpha_alvo,   anim_vel);
    
    // Considerar "pronto" quando está perto o suficiente
    if (abs(anim_alpha - anim_alpha_alvo) < 0.01) {
        anim_alpha  = anim_alpha_alvo;
        anim_escala = anim_escala_alvo;
        dim_alpha   = dim_alpha_alvo;
        anim_pronto = true;
    }
}
// ===== Animação de Saída =====
else {
    anim_alpha  = lerp(anim_alpha,  0, anim_vel * 1.5);
    anim_escala = lerp(anim_escala, 0.85, anim_vel * 1.5);
    dim_alpha   = lerp(dim_alpha,   0,    anim_vel * 1.5);
    
    if (anim_alpha < 0.02) {
        // Overlay terminou de fechar
        overlay_fechar_callback();
        instance_destroy();
    }
}
```

### Draw GUI Event — Estrutura Base

```gml
// ===== 1. Fundo escurecido =====
draw_set_alpha(dim_alpha);
draw_set_colour(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// ===== 2. Painel central =====
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _cx = _gui_w / 2;
var _cy = _gui_h / 2;

var _painel_w = 700;  // largura do painel (ajustar por overlay)
var _painel_h = 500;  // altura do painel (ajustar por overlay)

// Aplicar escala da animação
var _w = _painel_w * anim_escala;
var _h = _painel_h * anim_escala;
var _x1 = _cx - _w/2;
var _y1 = _cy - _h/2;
var _x2 = _cx + _w/2;
var _y2 = _cy + _h/2;

draw_set_alpha(anim_alpha);

// Sombra
draw_set_colour(c_black);
draw_set_alpha(anim_alpha * 0.3);
draw_roundrect_ext(_x1+6, _y1+6, _x2+6, _y2+6, 16, 16, false);

// Painel
draw_set_alpha(anim_alpha);
draw_set_colour(make_colour_rgb(20, 22, 38));  // fundo dark navy
draw_roundrect_ext(_x1, _y1, _x2, _y2, 16, 16, false);

// Borda teal
draw_set_colour(make_colour_rgb(80, 200, 210));
draw_roundrect_ext(_x1, _y1, _x2, _y2, 16, 16, true);

// ===== 3. Conteúdo (implementar por overlay) =====
// ... título, botões, stats, etc.

// ===== 4. Dica de input no rodapé =====
overlay_draw_input_hint(_x1, _y2 - 40, _w);

draw_set_alpha(1);
```

---

## 🎮 Sistema de Navegação por Controle + Teclado

### Variáveis de Botão (em cada overlay)

```gml
// ===== Create Event =====
botao_focado = 0;        // índice do botão atualmente selecionado
total_botoes = 2;        // número de botões neste overlay
nav_cooldown = 0;        // cooldown entre navegações (evitar rapidez)
NAV_COOLDOWN_MAX = 12;   // frames entre inputs de navegação
input_mode = "teclado";  // "teclado" ou "controle"
```

### Lógica de Navegação (Step Event)

```gml
// ===== Só processar input quando animação terminou =====
if (!anim_pronto || overlay_saindo) exit;

var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

// ===== Detecção de modo de input =====
if (_tem_controle) {
    if (gamepad_button_check_pressed(_gp, gp_padu)
     || gamepad_button_check_pressed(_gp, gp_padd)
     || gamepad_button_check_pressed(_gp, gp_padl)
     || gamepad_button_check_pressed(_gp, gp_padr)
     || gamepad_button_check_pressed(_gp, gp_face1)
     || gamepad_button_check_pressed(_gp, gp_face2)
     || abs(gamepad_axis_value(_gp, gp_axislv)) > 0.5) {
        input_mode = "controle";
    }
}
if (keyboard_check_pressed(vk_anykey)) {
    input_mode = "teclado";
}

// ===== Navegação entre botões =====
if (nav_cooldown > 0) { nav_cooldown--; }
else {
    var _mover = 0;
    
    // Teclado
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S")))  _mover =  1;
    if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W")))  _mover = -1;
    
    // Gamepad D-pad
    if (_tem_controle) {
        if (gamepad_button_check_pressed(_gp, gp_padd)) _mover =  1;
        if (gamepad_button_check_pressed(_gp, gp_padu)) _mover = -1;
        
        // Analog stick
        var _axis = gamepad_axis_value(_gp, gp_axislv);
        if (_axis >  0.5) _mover =  1;
        if (_axis < -0.5) _mover = -1;
    }
    
    if (_mover != 0) {
        botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
        nav_cooldown = NAV_COOLDOWN_MAX;
        // TODO: tocar SFX de navegação aqui
    }
}

// ===== Confirmar =====
var _confirmar = keyboard_check_pressed(vk_enter)
              || keyboard_check_pressed(ord("E"))
              || (_tem_controle && gamepad_button_check_pressed(_gp, gp_face1));

if (_confirmar) {
    overlay_botao_acao(botao_focado);
    // TODO: tocar SFX de confirmação aqui
}

// ===== Cancelar / Voltar =====
var _cancelar = keyboard_check_pressed(vk_escape)
             || (_tem_controle && gamepad_button_check_pressed(_gp, gp_face2));

if (_cancelar) {
    overlay_voltar();
    // TODO: tocar SFX de cancelar aqui
}
```

### Desenho de Botão com Estado Focado (Função Reutilizável)

```gml
/// @function overlay_draw_botao(x, y, largura, altura, texto, focado, alpha)
/// Desenha um botão estilo Bloons TD6 com brilho quando focado
function overlay_draw_botao(_x, _y, _w, _h, _texto, _focado, _alpha) {
    draw_set_alpha(_alpha);
    
    if (_focado) {
        // Fundo do botão focado — teal brilhante
        draw_set_colour(make_colour_rgb(80, 200, 210));
        draw_roundrect_ext(_x, _y, _x+_w, _y+_h, 10, 10, false);
        
        // Brilho extra (glow) — retângulo maior semi-transparente
        draw_set_alpha(_alpha * 0.25);
        draw_set_colour(make_colour_rgb(80, 200, 210));
        draw_roundrect_ext(_x-4, _y-4, _x+_w+4, _y+_h+4, 12, 12, false);
        draw_set_alpha(_alpha);
        
        // Texto preto
        draw_set_colour(make_colour_rgb(20, 22, 38));
    } else {
        // Fundo do botão normal — cinza escuro
        draw_set_colour(make_colour_rgb(40, 42, 58));
        draw_roundrect_ext(_x, _y, _x+_w, _y+_h, 10, 10, false);
        
        // Borda sutil
        draw_set_colour(make_colour_rgb(60, 62, 78));
        draw_roundrect_ext(_x, _y, _x+_w, _y+_h, 10, 10, true);
        
        // Texto branco
        draw_set_colour(c_white);
    }
    
    // Texto centralizado
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_pixel);
    draw_text(_x + _w/2, _y + _h/2, _texto);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}
```

---

## 💡 Dica de Input Dinâmica (Rodapé de Cada Painel)

```gml
/// @function overlay_draw_input_hint(x, y, largura)
/// Desenha dica de input no rodapé do painel baseado no dispositivo ativo
function overlay_draw_input_hint(_x, _y, _largura) {
    var _gp = global.gamepad_main;
    var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_pixel);
    draw_set_colour(make_colour_rgb(140, 140, 160));
    
    var _cx = _x + _largura / 2;
    var _texto = "";
    
    if (_tem_controle && input_mode == "controle") {
        // Ícones de controle
        _texto = "D-pad: Navegar  |  A/Cruz: Confirmar  |  B/Círculo: Voltar";
    } else {
        // Teclas do teclado
        _texto = "↑↓ / WS: Navegar  |  ENTER / E: Confirmar  |  ESC: Voltar";
    }
    
    draw_text(_cx, _y, _texto);
    
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
```

---

## 📋 Plano de Implementação — Etapas Ordenadas

### Etapa 1 — Infraestrutura Base

- [ ] **1.1 Criar `global.game_paused`**
  - No `oOverlayManager/Create_0.gml`, inicializar `global.game_paused = false`
  
- [ ] **1.2 Adicionar guarda de pause em todos os objetos de gameplay**
  
  Em **cada objeto** abaixo, adicionar no **início** do `Step_0.gml`:
  ```gml
  if (global.game_paused) exit;
  ```
  
  Objetos que precisam da guarda:
  - `oPlayer/Step_0.gml`
  - `oController/Step_0.gml` (exceto a lógica de overlay!)
  - `oInimigo/Create_0.gml` (nas funções de estado do FSM)
  - `oNpc/Step_0.gml`
  - `oComida/Step_0.gml`
  - `oSaida/Step_0.gml`

- [ ] **1.3 Criar `oOverlayManager`**
  ```gml
  // Create_0.gml
  persistent = true;
  if (instance_number(oOverlayManager) > 1) { instance_destroy(); exit; }
  
  global.game_paused    = false;
  global.overlay_ativo  = noone;
  global.overlay_stack  = [];
  
  global.fase_atual       = 0;
  global.fases_concluidas = array_create(5, false);
  global.fases_estrelas   = array_create(5, 0);
  global.total_fases      = 5;
  
  global.run_tempo    = 0;
  global.run_comida   = 0;
  global.run_dano     = 0;
  global.run_estrelas = 0;
  ```

  ```gml
  // Step_0.gml
  // Nada aqui por enquanto — overlays gerenciam a si mesmos
  ```

- [ ] **1.4 Criar scripts auxiliares**

  ```gml
  /// scr_overlay_abrir(overlay_obj)
  /// Cria uma instância do overlay e pausa o jogo
  function scr_overlay_abrir(_obj) {
      if (global.overlay_ativo != noone) {
          // Empilhar overlay atual
          array_push(global.overlay_stack, global.overlay_ativo);
      }
      global.game_paused   = true;
      global.overlay_ativo = _obj;
      instance_create_depth(0, 0, -9999, _obj);
  }
  
  /// scr_overlay_fechar()
  /// Remove overlay atual e despausa (ou volta ao anterior)
  function scr_overlay_fechar() {
      global.overlay_ativo = noone;
      
      if (array_length(global.overlay_stack) > 0) {
          // Voltar ao overlay anterior
          global.overlay_ativo = array_pop(global.overlay_stack);
      } else {
          // Sem overlays — despausa o jogo
          global.game_paused = false;
      }
  }
  ```

---

### Etapa 2 — Menu Principal

- [ ] **2.1 Criar room `rm_MenuPrincipal`**
  - Tamanho: 1920×1080
  - Views: desligadas
  - Instâncias: `oMenuPrincipal`, `oOverlayManager`, `oProcuraControle`
  - Background: cor sólida escura ou imagem temática

- [ ] **2.2 Criar `oMenuPrincipal`**

  ```gml
  // Create_0.gml
  // Animação
  anim_alpha = 0;  anim_alpha_alvo = 1;
  anim_escala = 0.85;  anim_escala_alvo = 1.0;
  anim_vel = 0.08;  anim_pronto = false;
  dim_alpha = 0;  dim_alpha_alvo = 0;  // sem dim no menu principal
  overlay_saindo = false;
  
  // Botões
  botoes = ["Jogar", "Configurações", "Sair"];
  botao_focado = 0;
  total_botoes = 3;
  nav_cooldown = 0;  NAV_COOLDOWN_MAX = 12;
  input_mode = "teclado";
  ```

  ```gml
  // Step_0.gml
  // [Animação lerp — mesmo padrão da seção de animação]
  // [Navegação de botões — mesmo padrão da seção de navegação]
  
  // Ação dos botões:
  function overlay_botao_acao(_idx) {
      switch (_idx) {
          case 0: // Jogar → abrir overlay de seleção de fases
              scr_overlay_abrir(oOverlayFases);
              break;
          case 1: // Configurações
              // TODO: implementar overlay de configurações
              break;
          case 2: // Sair
              game_end();
              break;
      }
  }
  
  function overlay_voltar() {
      // No menu principal, não faz nada (não tem pra onde voltar)
  }
  ```

  ```gml
  // Draw_64.gml (Draw GUI)
  var _gui_w = display_get_gui_width();
  var _gui_h = display_get_gui_height();
  var _cx = _gui_w / 2;
  var _cy = _gui_h / 2;
  
  draw_set_alpha(anim_alpha);
  
  // Logo / Título
  draw_set_font(fnt_pixel);
  draw_set_halign(fa_center);
  draw_set_valign(fa_middle);
  draw_set_colour(make_colour_rgb(80, 200, 210));
  // TODO: trocar por sprite do logo quando tiver
  draw_text_transformed(_cx, _cy - 180, "LOBISOMEM PIDÃO", 2.5 * anim_escala, 2.5 * anim_escala, 0);
  
  // Subtítulo
  draw_set_colour(make_colour_rgb(180, 180, 200));
  draw_text(_cx, _cy - 100, "Um lobo faminto, uma cidade perigosa.");
  
  // Botões
  var _btn_w = 300;
  var _btn_h = 54;
  var _btn_gap = 20;
  var _btn_start_y = _cy - ((total_botoes * (_btn_h + _btn_gap)) / 2) + 40;
  
  for (var i = 0; i < total_botoes; i++) {
      var _bx = _cx - _btn_w/2;
      var _by = _btn_start_y + i * (_btn_h + _btn_gap);
      overlay_draw_botao(_bx, _by, _btn_w, _btn_h, botoes[i], (i == botao_focado), anim_alpha);
  }
  
  // Dica de input
  overlay_draw_input_hint(0, _gui_h - 60, _gui_w);
  
  draw_set_halign(fa_left);
  draw_set_valign(fa_top);
  draw_set_alpha(1);
  ```

---

### Etapa 3 — Overlay de Seleção de Fases

- [ ] **3.1 Criar `oOverlayFases`**

  Migrar toda a lógica visual de `oSeletorDeFases` para este overlay, mas com:
  - Animação de entrada (escala + alpha)
  - Fundo dim sobre o menu principal
  - Estado das fases (bloqueada/disponível/concluída + estrelas)
  - Botão "Voltar" que fecha o overlay (volta ao menu)
  - Navegação em grade (2D) para os cards

  ```gml
  // Create_0.gml
  // [Animação — padrão]
  dim_alpha_alvo = 0.7;  // dim sobre o menu principal
  
  // Fases
  fase_rooms = [room_01, room_02, room_01, room_02, room_01];
  fase_nomes = ["Fase 1", "Fase 2", "Fase 3", "Fase 4", "Fase 5"];
  fase_selecionada = 0;
  
  // Layout grade
  colunas = 3;
  card_w  = 280;
  card_h  = 200;
  card_gap = 30;
  
  // Botão voltar
  botao_voltar_focado = false;
  
  // Nav
  botao_focado = 0;
  total_botoes = global.total_fases;  // + 1 para voltar
  nav_cooldown = 0;  NAV_COOLDOWN_MAX = 12;
  input_mode = "teclado";
  ```

  ```gml
  // Step_0.gml — Navegação em Grade (2D)
  if (!anim_pronto || overlay_saindo) exit;
  
  // [Detecção de input_mode — padrão]
  
  var _gp = global.gamepad_main;
  var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);
  
  if (nav_cooldown > 0) { nav_cooldown--; }
  else {
      var _dx = 0, _dy = 0;
      
      // Teclado
      if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) _dx =  1;
      if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) _dx = -1;
      if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S"))) _dy =  1;
      if (keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W"))) _dy = -1;
      
      // Gamepad
      if (_tem_controle) {
          if (gamepad_button_check_pressed(_gp, gp_padr)) _dx =  1;
          if (gamepad_button_check_pressed(_gp, gp_padl)) _dx = -1;
          if (gamepad_button_check_pressed(_gp, gp_padd)) _dy =  1;
          if (gamepad_button_check_pressed(_gp, gp_padu)) _dy = -1;
          
          var _axh = gamepad_axis_value(_gp, gp_axislh);
          var _axv = gamepad_axis_value(_gp, gp_axislv);
          if (_axh >  0.5) _dx =  1;
          if (_axh < -0.5) _dx = -1;
          if (_axv >  0.5) _dy =  1;
          if (_axv < -0.5) _dy = -1;
      }
      
      if (_dx != 0 || _dy != 0) {
          var _col = fase_selecionada mod colunas;
          var _row = fase_selecionada div colunas;
          _col = clamp(_col + _dx, 0, colunas - 1);
          _row = clamp(_row + _dy, 0, ceil(global.total_fases / colunas) - 1);
          var _novo = _row * colunas + _col;
          fase_selecionada = clamp(_novo, 0, global.total_fases - 1);
          nav_cooldown = NAV_COOLDOWN_MAX;
      }
  }
  
  // Confirmar — entra na fase
  var _confirmar = keyboard_check_pressed(vk_enter)
                || keyboard_check_pressed(ord("E"))
                || (_tem_controle && gamepad_button_check_pressed(_gp, gp_face1));
  
  if (_confirmar) {
      var _idx = fase_selecionada;
      // Só entrar se fase estiver desbloqueada
      if (_idx == 0 || global.fases_concluidas[_idx - 1]) {
          global.fase_atual = _idx;
          global.comida = 0;
          global.comidaCheia = false;
          global.game_paused = false;
          global.overlay_ativo = noone;
          global.overlay_stack = [];
          room_goto(fase_rooms[_idx]);
      }
  }
  
  // Cancelar — voltar ao menu
  var _cancelar = keyboard_check_pressed(vk_escape)
               || (_tem_controle && gamepad_button_check_pressed(_gp, gp_face2));
  if (_cancelar) {
      overlay_saindo = true;
  }
  ```

  ```gml
  // Callback quando fecha
  function overlay_fechar_callback() {
      scr_overlay_fechar();
  }
  ```

  **Draw GUI**: Estilo de cards similar ao `oSeletorDeFases` atual, mas com:
  - Cards de fases bloqueadas em cinza escuro com ícone de cadeado
  - Cards disponíveis em azul/teal
  - Cards concluídas com estrelas douradas no canto
  - Card selecionado com borda brilhante animada

---

### Etapa 4 — Overlay de Derrota

- [ ] **4.1 Criar `oOverlayDerrota`**

  ```gml
  // Create_0.gml
  // [Animação — padrão]
  dim_alpha_alvo = 0.75;
  
  motivo = global.motivoMorte;
  
  botoes = ["Tentar Novamente", "Voltar ao Menu"];
  botao_focado = 0;
  total_botoes = 2;
  nav_cooldown = 0;  NAV_COOLDOWN_MAX = 12;
  input_mode = "teclado";
  ```

  ```gml
  // Ação dos botões:
  function overlay_botao_acao(_idx) {
      switch (_idx) {
          case 0: // Tentar Novamente — reiniciar a fase
              global.game_paused = false;
              global.overlay_ativo = noone;
              global.overlay_stack = [];
              global.comida = 0;
              global.comidaCheia = false;
              room_restart();
              break;
          case 1: // Voltar ao Menu
              global.game_paused = false;
              global.overlay_ativo = noone;
              global.overlay_stack = [];
              room_goto(rm_MenuPrincipal);
              break;
      }
  }
  ```

  **Draw GUI**: 
  - Título "GAME OVER" em vermelho com shake sutil
  - Mensagem baseada em `motivo`:
    - `"dano"` → "O lobisomem foi capturado!" + ícone de perigo
    - `"fome"` → "O lobisomem morreu de fome!" + ícone de comida
  - Dois botões verticais com navegação

- [ ] **4.2 Modificar `oController`** para usar overlay em vez de `room_goto`
  ```gml
  // ANTES:
  if (vida <= 0) { global.motivoMorte = "dano"; room_goto(rm_gameOver); }
  
  // DEPOIS:
  if (vida <= 0) {
      global.motivoMorte = "dano";
      scr_overlay_abrir(oOverlayDerrota);
  }
  
  // Mesma lógica para fome:
  if (tempoFome <= 0) {
      global.motivoMorte = "fome";
      scr_overlay_abrir(oOverlayDerrota);
  }
  ```

---

### Etapa 5 — Overlay de Vitória

- [ ] **5.1 Criar `oOverlayVitoria`**

  ```gml
  // Create_0.gml
  // [Animação — padrão]
  dim_alpha_alvo = 0.6;
  
  // Estatísticas
  tempo_fase  = global.run_tempo;
  comida_pega = global.run_comida;
  dano_total  = global.run_dano;
  
  // Calcular estrelas (1-3)
  estrelas = 3;
  if (dano_total > 2)   estrelas--;
  if (tempo_fase > 60)  estrelas--;
  estrelas = max(estrelas, 1);
  global.run_estrelas = estrelas;
  
  // Salvar progresso
  global.fases_concluidas[global.fase_atual] = true;
  var _melhor = global.fases_estrelas[global.fase_atual];
  if (estrelas > _melhor) global.fases_estrelas[global.fase_atual] = estrelas;
  
  // Animação das estrelas (aparecem uma por uma)
  estrela_timer = 0;
  estrela_mostrar = 0;  // quantas já apareceram
  estrela_delay = 30;   // frames entre cada estrela
  
  // Confetes
  confetes = [];
  for (var i = 0; i < 40; i++) {
      array_push(confetes, {
          x: irandom(1920),
          y: irandom_range(-200, -50),
          spd: random_range(1, 3),
          drift: random_range(-0.5, 0.5),
          cor: choose(c_yellow, c_lime, make_colour_rgb(80,200,210), c_orange, c_fuchsia),
          rot: random(360),
          rot_spd: random_range(-5, 5),
          sz: random_range(4, 10)
      });
  }
  
  botoes = ["Próxima Fase", "Voltar ao Menu"];
  botao_focado = 0;
  total_botoes = 2;
  nav_cooldown = 0;  NAV_COOLDOWN_MAX = 12;
  input_mode = "teclado";
  ```

  ```gml
  // Step_0.gml
  // [Animação — padrão]
  // [Navegação — padrão]
  
  // Animação de estrelas
  if (anim_pronto && estrela_mostrar < estrelas) {
      estrela_timer++;
      if (estrela_timer >= estrela_delay) {
          estrela_mostrar++;
          estrela_timer = 0;
          // TODO: tocar SFX de estrela aqui
      }
  }
  
  // Atualizar confetes
  for (var i = 0; i < array_length(confetes); i++) {
      confetes[i].y   += confetes[i].spd;
      confetes[i].x   += confetes[i].drift;
      confetes[i].rot  += confetes[i].rot_spd;
      if (confetes[i].y > 1100) confetes[i].y = irandom_range(-100, -20);
  }
  
  // Ações dos botões
  function overlay_botao_acao(_idx) {
      switch (_idx) {
          case 0: // Próxima Fase
              var _prox = global.fase_atual + 1;
              if (_prox < global.total_fases) {
                  global.fase_atual = _prox;
                  global.game_paused = false;
                  global.overlay_ativo = noone;
                  global.overlay_stack = [];
                  global.comida = 0;
                  global.comidaCheia = false;
                  room_goto(fase_rooms[_prox]);
              } else {
                  // Última fase — voltar ao menu
                  global.game_paused = false;
                  global.overlay_ativo = noone;
                  global.overlay_stack = [];
                  room_goto(rm_MenuPrincipal);
              }
              break;
          case 1: // Voltar ao Menu
              global.game_paused = false;
              global.overlay_ativo = noone;
              global.overlay_stack = [];
              room_goto(rm_MenuPrincipal);
              break;
      }
  }
  ```

  **Draw GUI**: 
  - Título "VOCÊ VENCEU!" em dourado/teal
  - Estrelas grandes animadas (aparecem uma por uma com scale bounce)
  - Estatísticas: tempo, comida coletada, dano recebido
  - Confetes caindo por cima de tudo
  - Dois botões

- [ ] **5.2 Modificar `oSaida`** para usar overlay em vez de `room_goto`
  ```gml
  // ANTES:
  if (global.comidaCheia) { room_goto(rm_Vitoria); }
  
  // DEPOIS:
  if (global.comidaCheia && place_meeting(x, y, oPlayer)) {
      scr_overlay_abrir(oOverlayVitoria);
  }
  ```

---

### Etapa 6 — Integração e Polimento

- [ ] **6.1 Atualizar Room Order**
  - Room inicial: `rm_MenuPrincipal`
  - Remover `rm_gameOver` e `rm_Vitoria` do projeto (ou manter como backup)

- [ ] **6.2 Ajustar `oController/Draw_64.gml`**
  - HUD continua desenhando normalmente (fica "congelada" atrás do overlay)
  - Nenhuma mudança necessária no draw da HUD

- [ ] **6.3 Adicionar tracking de estatísticas no `oController`**
  ```gml
  // No Step_0.gml, antes da guarda de pause:
  if (!global.game_paused) {
      global.run_tempo += delta_time / 1000000;
  }
  
  // Quando player toma dano (no collision event ou onde é processado):
  global.run_dano++;
  ```

- [ ] **6.4 Resetar stats no início de cada fase**
  ```gml
  // No oController/Create_0.gml, adicionar:
  global.run_tempo  = 0;
  global.run_comida = 0;
  global.run_dano   = 0;
  ```

- [ ] **6.5 Testar fluxo completo**
  - Menu → Seleção de Fases → Gameplay → Derrota → Tentar Novamente
  - Menu → Seleção de Fases → Gameplay → Vitória → Próxima Fase
  - Menu → Seleção de Fases → Voltar → Menu
  - Gamepad em todas as telas
  - Teclado em todas as telas
  - Troca dinâmica entre gamepad e teclado

---

## ⚠️ Problemas Comuns e Como Evitar

| Problema | Causa | Solução |
|---|---|---|
| **Mouse interfere na navegação por controle** | `device_mouse_x_to_gui()` retorna posição do mouse mesmo sem mover | Só processar hover do mouse se `input_mode == "teclado"`. Quando `input_mode == "controle"`, ignorar posição do mouse. |
| **Overlay aparece atrás da HUD** | `depth` do overlay maior que a HUD | Usar `instance_create_depth(0, 0, -9999, obj)` para garantir que overlay está acima de tudo. No Draw GUI, a ordem depende da **ordem de criação** — criar overlay DEPOIS da HUD. |
| **Jogo continua rodando atrás do overlay** | Objetos não checam `global.game_paused` | Adicionar `if (global.game_paused) exit;` no **início** do Step de TODOS os objetos de gameplay. Lista completa na Etapa 1.2. |
| **Coordenadas de mouse erradas no GUI** | Usar `mouse_x`/`mouse_y` em Draw GUI | Sempre usar `device_mouse_x_to_gui(0)` e `device_mouse_y_to_gui(0)` no evento Draw GUI. Nunca `mouse_x`/`mouse_y`. |
| **Conflito mouse vs controle** | Ambos ativos simultaneamente | Usar variável `input_mode` ("teclado" / "controle"). Trocar ao detectar input de cada tipo. O modo ativo define se usa hover (mouse) ou `botao_focado` (controle). |
| **Botão focado "pula" ao trocar de overlay** | `botao_focado` não resetado | Inicializar `botao_focado = 0` no Create de cada overlay. |
| **Overlay não fecha ao trocar de room** | Instância persiste ou referência fica suja | Sempre limpar `global.overlay_ativo = noone` e `global.overlay_stack = []` antes de `room_goto()`. |
| **D-pad repete rápido demais** | Sem cooldown entre navegações | Usar `nav_cooldown` com `NAV_COOLDOWN_MAX = 12` frames (~0.2s). Decrementar a cada step. |
| **Analog stick trava na navegação** | Stick com drift / zona morta baixa | Usar threshold de `0.5` (não `0.2`) para navegação de menu. A deadzone de `0.2` do `oProcuraControle` é para movimento, não menus. |
| **`game_paused` afeta animação do overlay** | Overlay checa `game_paused` sem querer | Overlays **NUNCA** devem checar `game_paused` — eles são a causa do pause, não afetados por ele. |
| **Múltiplos overlays se empilham infinitamente** | Apertar confirmar repetido abre várias instâncias | Checar `if (global.overlay_ativo != noone && global.overlay_ativo == oOverlayX) return;` antes de abrir um overlay que já está ativo. |
| **Estrelas/confetes animam antes do painel abrir** | Animação de conteúdo começa junto com a de entrada | Só iniciar animações de conteúdo (estrelas, confetes) quando `anim_pronto == true`. |

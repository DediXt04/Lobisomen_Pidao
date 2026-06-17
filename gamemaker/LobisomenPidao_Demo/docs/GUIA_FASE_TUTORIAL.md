# 🎓 Guia de Implementação — Fase Tutorial

> Guia completo para criar uma **fase tutorial** que ensina ao jogador todas as mecânicas básicas do jogo de forma progressiva e controlada, usando caixas de texto que aparecem conforme o player avança.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Resolução interna | 320×180 (view) / 1920×1080 (port) |
| Tile size | 16×16 |
| Fonte | `fnt_pixel` |
| Paleta de cores UI | Navy escuro `rgb(14,14,26)` + Teal `rgb(80,200,210)` |
| Room sugerida | `rm_tutorial` |

---

## 🎯 Objetivo da Fase Tutorial

Ensinar ao jogador as **7 mecânicas básicas** em ordem progressiva:

| # | Mecânica | O que o jogador aprende |
|---|---|---|
| 1 | **Movimento** | Andar com WASD / analógico |
| 2 | **Coleta de comida** | Chegar perto da comida e apertar interação para coletar |
| 3 | **Interação com NPC** | Pedir comida aos NPCs (probabilidade + paciência) |
| 4 | **Barra de fome** | Entender que o tempo de fome diminui e que precisa se apressar |
| 5 | **Chave e Portão** | Coletar a chave para desbloquear o portão e acessar nova área |
| 6 | **Inimigos** | Evitar ser visto pelo inimigo (stealth) |
| 7 | **Porta de saída** | Coletar toda a comida e entrar na saída para vencer |

---

## 🏗️ Estrutura Geral

### Como funciona

1. **`oTutorial`** — novo objeto controlador do tutorial; gerencia os passos e as caixas de texto
2. A fase é dividida em **zonas separadas por corredores**, cada zona ensina uma mecânica
3. **Triggers invisíveis** (`oTutorialTrigger`) detectam quando o player entra em uma zona e ativam a mensagem correspondente
4. O jogo **pausa brevemente** ao mostrar cada dica (o jogador aperta o botão de interação para continuar)
5. Configurações fáceis: pouca comida, poucos inimigos, tempo de fome generoso

### Fluxo

```
Room carrega (rm_tutorial)
  │
  ├─ Room Creation Code → config fácil (comidaMax=4, tempoFomeMax=180)
  │
  ├─ oTutorial/Create → inicializa lista de dicas
  │
  └─ Gameplay progressivo:
       │
       ├─ Zona 1: Player spawna → Trigger 1 ativa
       │     └─ Dica: "Use WASD para se mover!"
       │     └─ Player anda até a próxima zona
       │
       ├─ Zona 2: Player encontra comida no chão → Trigger 2 ativa
       │     └─ Dica: "Chegue perto e aperte E para coletar comida!"
       │     └─ Player coleta a comida
       │
       ├─ Zona 3: Player encontra um NPC → Trigger 3 ativa
       │     └─ Dica: "Chegue perto do NPC e aperte E para pedir comida!"
       │     └─ Player interage com o NPC
       │
       ├─ Zona 4: Corredor com aviso sobre fome → Trigger 4 ativa
       │     └─ Dica: "Fique de olho na barra de fome! Se acabar, é game over!"
       │
       ├─ Zona 5: Player encontra chave + portão bloqueando passagem → Trigger 5 ativa
       │     └─ Dica: "Pegue a chave e desbloqueie o portão para continuar!"
       │     └─ Player coleta oChave → global.temChave = true → oPorta abre
       │
       ├─ Zona 6: Player avista um inimigo → Trigger 6 ativa
       │     └─ Dica: "Cuidado com os guardas! Se eles te virem, vão te atacar!"
       │     └─ Player desvia do inimigo
       │
       └─ Zona 7: Player chega na saída → Trigger 7 ativa
             └─ Dica: "Colete toda a comida e entre na porta para vencer!"
             └─ Player entra na saída → vitória
```

---

## 🎨 Sprites Necessários

| Sprite | Tamanho sugerido | Descrição |
|---|---|---|
| `sTutorialBg` | 280×60 | Caixa de fundo da dica (retângulo arredondado semi-transparente) — **opcional**, pode desenhar com `draw_rectangle` |
| `sTutorialTrigger` | 16×16 | Quadrado invisível para a trigger zone (pode reutilizar um sprite vazio ou `sSpawnZone`) |

> **Dica:** Você pode pular a criação de sprites e desenhar tudo via código no Draw GUI (recomendado).

---

## 🎬 Parte 0 — Introdução Narrativa (Cutscene Inicial)

Ao entrar na fase tutorial, **antes do gameplay**, o jogador vê uma sequência de diálogos que apresenta a história do personagem. O tom é **cômico e auto-consciente**.

### Narrativa

O lobisomem sabe, no fundo, que é humano. Então ao invés de atacar e matar para comer, ele luta contra os instintos e faz a coisa mais constrangedora possível: **pede comida**. Pede, insiste, enche o saco — até a pessoa dar ou perder a paciência.

### Fluxo da Introdução

```
Room carrega (rm_tutorial)
  │
  ├─ oTutorial/Create → intro_ativa = true
  │
  └─ FRAME 1: Cutscene de introdução (jogo pausado)
       │
       ├─ Página 1: "..."
       ├─ Página 2: "Fome..."
       ├─ Página 3: "Muita fome..."
       ├─ Página 4: "Eu poderia simplesmente atacar alguém..."
       ├─ Página 5: "Mas não. Eu sei que no fundo... eu sou humano."
       ├─ Página 6: "Então vou fazer a coisa certa."
       ├─ Página 7: "Vou PEDIR comida."
       ├─ Página 8: "Pedir. Insistir. Encher o saco."
       ├─ Página 9: "Até alguém me dar algo ou me expulsar."
       ├─ Página 10: "...Esse é o meu destino como lobo pidão."
       │
       └─ Fim da intro → intro_ativa = false → gameplay começa
```

> **O jogador avança cada página com [E] / [Space] / [A no gamepad].** O jogo fica pausado durante toda a introdução.

### Layout Visual da Intro

```
+------------------------------------------------------+
|                                                      |
| .................................................... |  <-- tela escura
| .................................................... |
| .................................................... |
| .................................................... |
|                                                      |
|   +----------------------------------------------+   |
|   |                                              |   |
|   |  "Eu poderia simplesmente atacar alguem..."  |   |  <-- caixa de dialogo
|   |                                              |   |
|   |                          [E] para continuar  |   |
|   +----------------------------------------------+   |
+------------------------------------------------------+
```

### Código — Modificações no `oTutorial/Create_0.gml`

Adicionar **no início** do arquivo (antes do bloco de dicas):

```gml
// === INTRODUÇÃO NARRATIVA ===
intro_ativa = true;
intro_pagina = 0;
intro_timer = 30;       // anti-skip inicial
intro_alpha = 0;        // fade-in

intro_textos[0]  = "...";
intro_textos[1]  = "Fome...";
intro_textos[2]  = "Muita fome...";
intro_textos[3]  = "Eu poderia simplesmente atacar alguem...";
intro_textos[4]  = "Mas nao. Eu sei que no fundo...\neu sou humano.";
intro_textos[5]  = "Entao vou fazer a coisa certa.";
intro_textos[6]  = "Vou PEDIR comida.";
intro_textos[7]  = "Pedir. Insistir. Encher o saco.";
intro_textos[8]  = "Ate alguem me dar algo\nou me expulsar.";
intro_textos[9]  = "...Esse e o meu destino\ncomo lobo pidao.";
intro_total = array_length(intro_textos);

// Pausa o jogo durante a intro
global.pausado = true;
```

> **Nota:** Os textos não usam acentos porque `fnt_pixel` pode não ter todos os caracteres acentuados. Ajuste conforme sua fonte suportar.

### Código — Modificações no `oTutorial/Step_0.gml`

Adicionar **no início** do arquivo (antes do bloco `if (!mostrando_dica) exit;`):

```gml
// ===============================================================
// INTRODUÇÃO NARRATIVA
// ===============================================================
if (intro_ativa) {

    // Fade-in
    if (intro_alpha < 1) {
        intro_alpha = min(intro_alpha + 0.05, 1);
    }

    // Timer anti-skip
    if (intro_timer > 0) {
        intro_timer--;
        exit;
    }

    // Input para avançar página
    var _avancar = false;

    if (keyboard_check_pressed(ord("E"))
     || keyboard_check_pressed(vk_space)
     || keyboard_check_pressed(vk_enter))
    {
        _avancar = true;
    }

    if (global.gamepad_main != undefined) {
        if (gamepad_button_check_pressed(global.gamepad_main, gp_face1)) {
            _avancar = true;
        }
    }

    if (_avancar) {
        intro_pagina++;
        intro_timer = 10;  // cooldown curto entre páginas

        // Acabou a intro?
        if (intro_pagina >= intro_total) {
            intro_ativa = false;
            global.pausado = false;
        }
    }

    exit; // Bloqueia o resto do Step durante a intro
}
```

### Código — Modificações no `oTutorial/Draw_64.gml`

Adicionar **no início** do arquivo (antes do bloco `if (!mostrando_dica) exit;`):

```gml
// ===============================================================
// DESENHO DA INTRODUÇÃO NARRATIVA
// ===============================================================
if (intro_ativa) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _cx = _gui_w / 2;
    var _cy = _gui_h / 2;

    // Fundo totalmente escuro (fade-in)
    draw_set_alpha(intro_alpha * 0.95);
    draw_set_colour(make_colour_rgb(8, 8, 14));
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    // Caixa de diálogo centralizada
    var _box_w = _gui_w * 0.65;
    var _box_h = 160;
    var _box_x = (_gui_w - _box_w) / 2;
    var _box_y = _gui_h - _box_h - 80;

    // Fundo da caixa
    draw_set_alpha(intro_alpha * 0.85);
    draw_set_colour(make_colour_rgb(14, 14, 26));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

    // Borda teal
    draw_set_alpha(intro_alpha * 0.7);
    draw_set_colour(make_colour_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);

    // Linha superior decorativa
    draw_set_alpha(intro_alpha);
    draw_set_colour(make_colour_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + 3, false);

    // Texto da página atual
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(intro_alpha);
    draw_set_colour(c_white);

    if (intro_pagina < intro_total) {
        draw_text_ext(
            _cx,
            _box_y + _box_h / 2 - 15,
            intro_textos[intro_pagina],
            22,
            _box_w - 60
        );
    }

    // "Aperte E para continuar" (pisca)
    if (intro_timer <= 0) {
        var _pisca = (sin(current_time / 300) + 1) / 2;
        draw_set_alpha(intro_alpha * (0.4 + _pisca * 0.6));
        draw_set_colour(make_colour_rgb(80, 200, 210));
        draw_set_valign(fa_top);

        var _btn_texto = "[E] para continuar";
        if (global.gamepad_main != undefined) {
            _btn_texto = "[A] para continuar";
        }
        draw_text(_cx, _box_y + _box_h - 35, _btn_texto);
    }

    // Reset
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
    exit; // Não desenha dicas de gameplay durante a intro
}
```

### Extras Opcionais para a Intro

**6.5 — Skip da intro (para quem já viu):**

No bloco da intro no `Step_0.gml`, adicionar antes do `exit`:

```gml
// Pular intro inteira com ESC / Start
var _skip = keyboard_check_pressed(vk_escape);
if (global.gamepad_main != undefined) {
    _skip = _skip || gamepad_button_check_pressed(global.gamepad_main, gp_start);
}

if (_skip) {
    intro_ativa = false;
    intro_pagina = intro_total;
    global.pausado = false;
}
```

**6.6 — Indicador "Aperte ESC para pular" no canto:**

No bloco de Draw da intro, adicionar antes do `exit`:

```gml
// Indicador de skip (canto superior direito)
draw_set_alpha(intro_alpha * 0.4);
draw_set_colour(make_colour_rgb(100, 120, 130));
draw_set_halign(fa_right);
draw_set_valign(fa_top);
draw_set_font(fnt_pixel);

var _skip_texto = "ESC para pular";
if (global.gamepad_main != undefined) {
    _skip_texto = "START para pular";
}
draw_text(_gui_w - 30, 30, _skip_texto);
```

---

## 📐 Parte 1 — Layout da Room (rm_tutorial)

### Passo 1.1 — Criar a Room

1. No Asset Browser: **Rooms → Create Room** → nome: `rm_tutorial`
2. **Tamanho da room:** `1120×360` (maior na horizontal para um percurso linear de 7 zonas)
3. Configurar Viewport 0 igual às outras fases (ver `GUIA_CRIACAO_DE_FASES.md`)
4. Criar as 4 layers obrigatórias: `instancias`, `tiles`, `colisoes`, `Background`

### Passo 1.2 — Design do Mapa (Linear)

O mapa deve ser um **percurso linear** da esquerda para a direita, dividido em zonas:

```
+---------+---------+---------+---------+----------+---------+---------+
| ZONA 1  | ZONA 2  | ZONA 3  | ZONA 4  | ZONA 5   | ZONA 6  | ZONA 7  |
|         |         |         |         |          |         |         |
| P start | comida  |  NPC    | (vazio) | chave    | guarda  |  saida  |
|         |  [C]    |  [N]    |         |  [K] [C] |  [G]    |  [S]    |
|         |         |         |         |     |P|  |         |         |
| [T1]    | [T2]    | [T3]    | [T4]    | [T5]     | [T6]    | [T7]    |
+----+----+----+----+----+----+----+----+-----+----+----+----+---------+
     +=========+         +=========+          +=========+
       corredor            corredor             corredor

P   = oPlayer (posicao inicial)
T1-T7 = oTutorialTrigger (triggers invisiveis)
[C] = comida posicionada manualmente (oBurger/oPunk)
[N] = oNpc posicionado manualmente
[K] = oChave posicionada manualmente
|P| = oPorta (portao bloqueando passagem -- abre com chave)
[G] = oGuarda1 posicionado manualmente
[S] = oSaida (porta de saida da fase)
```

> **Importante:** Na fase tutorial, **NÃO use o oSpawner**. Posicione comida, NPCs e inimigos **manualmente** para controlar a experiência. Isso garante que cada item esteja exatamente na zona certa.

### Passo 1.3 — Room Creation Code

```gml
// === CONFIG DA FASE TUTORIAL ===
global.comidaMax    = 4;     // meta: 1 chão + 1 NPC + 1 atrás portão + 1 final
global.comidaSpawn  = 0;     // ZERO — não usa spawner, comida posicionada manualmente
global.npcSpawn     = 0;     // ZERO — NPC posicionado manualmente
global.tempoFomeMax = 180;   // 3 minutos — bem generoso para o tutorial
```

> ⚠️ **Atenção:** como `comidaSpawn` e `npcSpawn` são 0, o `oSpawner` não vai criar nada. Mas **ainda precisamos** colocar um `oSpawner` na room porque o `oController` pode depender dele. Alternativamente, se seu código permite, simplesmente não coloque o `oSpawner` e garanta que não há erros.

---

## 🔔 Parte 2 — oTutorialTrigger (Novo Objeto)

O trigger é uma **zona invisível** que detecta o player e envia um sinal para o `oTutorial`.

### Passo 2.1 — Criar o objeto

No GameMaker: **Assets → Create → Object** → nome: `oTutorialTrigger`, sprite: nenhum (ou um sprite invisível).

- **Visible:** `false` (não precisa ser desenhado)
- **Solid:** `false`

### Passo 2.2 — Variáveis na Creation Code (por instância)

Cada instância do `oTutorialTrigger` na room terá uma **Creation Code** individual (no Room Editor, clique duplo na instância):

```gml
// Creation Code da instância (definida no Room Editor)
dica_id = 1;   // número da dica que esta trigger ativa (1 a 6)
```

Mude o `dica_id` para cada trigger:
- Trigger na Zona 1: `dica_id = 1;`
- Trigger na Zona 2: `dica_id = 2;`
- Trigger na Zona 3: `dica_id = 3;`
- ... e assim por diante

### Passo 2.3 — Create Event

**`objects/oTutorialTrigger/Create_0.gml`:**

```gml
ativada = false;

// Tamanho da zona de trigger (redimensionar no Room Editor para cobrir a zona)
// O bbox será usado para detectar o player
```

### Passo 2.4 — Step Event

**`objects/oTutorialTrigger/Step_0.gml`:**

```gml
if (global.pausado) exit;

// Se já foi ativada, não faz nada
if (ativada) exit;

// Detecta se o player está dentro da zona
if (place_meeting(x, y, oPlayer))
{
    ativada = true;

    // Avisa o oTutorial para mostrar a dica correspondente
    with (oTutorial)
    {
        mostrar_dica(other.dica_id);
    }
}
```

> **Dica de posicionamento:** Coloque cada `oTutorialTrigger` na entrada de cada zona e **redimensione** (stretch) para cobrir o corredor/passagem. O player ativa a dica ao entrar na zona.

---

## 📝 Parte 3 — oTutorial (Novo Objeto — Controlador do Tutorial)

Este é o "cérebro" do tutorial. Gerencia quais dicas mostrar, pausa o jogo brevemente, e desenha a caixa de texto na tela.

### Passo 3.1 — Criar o objeto

No GameMaker: **Assets → Create → Object** → nome: `oTutorial`, sprite: nenhum.

- **Visible:** `true` (precisa do Draw GUI para renderizar as dicas)

### Passo 3.2 — Create Event

**`objects/oTutorial/Create_0.gml`:**

```gml
// === Estado do tutorial ===
dica_atual      = -1;      // qual dica está sendo exibida (-1 = nenhuma)
mostrando_dica  = false;   // se está exibindo uma dica na tela
dica_timer      = 0;       // tempo mínimo antes de poder fechar a dica (anti-skip)
dica_alpha      = 0;       // alpha para fade-in da caixa

// === Textos das dicas ===
// Índice 0 não é usado (dicas começam em 1)
dica_textos[0] = "";

dica_textos[1] = "Use WASD para se mover!\nExplore o mapa e encontre comida.";
dica_textos[2] = "Chegue perto da comida e aperte [E] para coletar!\nVocê precisa coletar toda a comida da fase.";
dica_textos[3] = "NPCs podem te dar comida!\nChegue perto e aperte [E] para pedir.\nMas cuidado: eles podem recusar!";
dica_textos[4] = "Fique de olho na barra de fome no canto da tela!\nSe ela acabar, é game over.\nSeja rápido!";
dica_textos[5] = "Vê aquela chave brilhando?\nPegue-a com [E] para abrir o portão à frente!";
dica_textos[6] = "Cuidado com os guardas!\nSe eles te virem, vão te perseguir e atacar.\nTente passar sem ser visto!";
dica_textos[7] = "Colete toda a comida e a porta de saída vai abrir!\nEntre nela para completar a fase. Boa sorte!";

// Textos com suporte a gamepad (troca "[E]" por "[A]" se gamepad conectado)
// Isso é feito dinamicamente no Draw

// === Visual ===
caixa_cor_fundo = make_colour_rgb(14, 14, 26);   // navy escuro
caixa_cor_borda = make_colour_rgb(80, 200, 210);  // teal
caixa_cor_texto = c_white;
caixa_cor_dica  = make_colour_rgb(80, 200, 210);  // teal para "aperte X para continuar"


/// @function mostrar_dica(_id)
/// @description Ativa a exibição de uma dica na tela
mostrar_dica = function(_id)
{
    if (_id < 1 || _id > array_length(dica_textos) - 1) exit;

    dica_atual     = _id;
    mostrando_dica = true;
    dica_timer     = 30;   // 30 frames (~0.5s) antes de poder fechar
    dica_alpha     = 0;    // começa invisível para fade-in

    // Pausa o jogo enquanto mostra a dica
    global.pausado = true;
};
```

### Passo 3.3 — Step Event

**`objects/oTutorial/Step_0.gml`:**

```gml
// Só processa se está mostrando uma dica
if (!mostrando_dica) exit;

// Fade-in da caixa
if (dica_alpha < 1)
{
    dica_alpha = min(dica_alpha + 0.08, 1);
}

// Timer anti-skip (evita fechar acidentalmente)
if (dica_timer > 0)
{
    dica_timer--;
    exit;
}

// Detecta input para fechar a dica
var _fechar = false;

// Teclado
if (keyboard_check_pressed(ord("E"))
 || keyboard_check_pressed(vk_space)
 || keyboard_check_pressed(vk_enter))
{
    _fechar = true;
}

// Gamepad
if (global.gamepad_main != undefined)
{
    if (gamepad_button_check_pressed(global.gamepad_main, gp_face1))
    {
        _fechar = true;
    }
}

// Fecha a dica e despausa
if (_fechar)
{
    mostrando_dica = false;
    dica_atual     = -1;
    dica_alpha     = 0;
    global.pausado = false;
}
```

### Passo 3.4 — Draw GUI Event (Draw_64)

**`objects/oTutorial/Draw_64.gml`:**

```gml
if (!mostrando_dica) exit;
if (dica_atual < 1) exit;

// === Dimensões da caixa ===
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

var _box_w = _gui_w * 0.7;      // 70% da largura da tela
var _box_h = 200;                // altura da caixa
var _box_x = (_gui_w - _box_w) / 2;  // centralizado horizontalmente
var _box_y = _gui_h - _box_h - 60;   // próximo ao rodapé da tela

// === Texto da dica ===
var _texto = dica_textos[dica_atual];

// Troca "[E]" por "[A]" se gamepad estiver conectado
if (global.gamepad_main != undefined)
{
    _texto = string_replace_all(_texto, "[E]", "[A]");
    _texto = string_replace_all(_texto, "WASD", "Analógico");
}

// === Desenha fundo semi-transparente da tela (escurece o jogo) ===
draw_set_alpha(dica_alpha * 0.4);
draw_set_colour(c_black);
draw_rectangle(0, 0, _gui_w, _gui_h, false);

// === Desenha caixa de diálogo ===
draw_set_alpha(dica_alpha * 0.9);

// Fundo da caixa
draw_set_colour(caixa_cor_fundo);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

// Borda da caixa (teal)
draw_set_colour(caixa_cor_borda);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);

// === Desenha texto da dica ===
draw_set_alpha(dica_alpha);
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(caixa_cor_texto);

// Texto principal (centralizado na caixa)
draw_text_ext(
    _box_x + _box_w / 2,
    _box_y + _box_h / 2 - 20,
    _texto,
    24,           // separação entre linhas
    _box_w - 40   // largura máxima do texto (com margem)
);

// === Texto "aperte para continuar" (pisca) ===
var _pisca = (sin(current_time / 300) + 1) / 2;  // valor entre 0 e 1
draw_set_colour(caixa_cor_dica);
draw_set_alpha(dica_alpha * (0.5 + _pisca * 0.5));
draw_set_halign(fa_center);
draw_set_valign(fa_top);

var _continuar_texto = "Aperte [E] para continuar";
if (global.gamepad_main != undefined)
{
    _continuar_texto = "Aperte [A] para continuar";
}

draw_text(
    _box_x + _box_w / 2,
    _box_y + _box_h - 40,
    _continuar_texto
);

// === Reset do draw state ===
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
```

---

## 🗺️ Parte 4 — Montagem da Room no Editor

### Passo 4.1 — Objetos obrigatórios na layer `instancias`

| Objeto | Qtd | Posição | Notas |
|---|---|---|---|
| `oController` | 1 | Canto superior esquerdo | Gerencia tudo |
| `oPlayer` | 1 | Zona 1 (extremo esquerdo) | Posição inicial |
| `oTutorial` | 1 | Canto superior esquerdo (junto do controller) | Controlador do tutorial |
| `oSaida` | 1 | Zona 7 (extremo direito) | Porta de saída |
| `oSpawner` | 1 | Canto (com spawn=0, não faz nada) | Ou remova se não causar erro |

### Passo 4.2 — Objetos posicionados manualmente

| Objeto | Qtd | Zona | Notas |
|---|---|---|---|
| `oBurger` | 1 | Zona 2 | Comida no chão para o player coletar |
| `oNpc` | 1 | Zona 3 | NPC para o player interagir |
| `oChave` | 1 | Zona 5 (antes do portão) | Chave posicionada manualmente |
| `oPorta` | 1 | Zona 5 (bloqueando passagem para Zona 6) | Portão que abre com a chave |
| `oBurger` ou `oPunk` | 1 | Zona 5 (atrás do portão) | Comida acessível só após abrir portão |
| `oGuarda1` | 1 | Zona 6 | Inimigo para o player desviar |
| `oBurger` ou `oPunk` | 1 | Zona 7 (perto da saída) | Última comida para completar a meta |

> **Conta da comida:** `comidaMax = 4`. O player coleta 1 na Zona 2, consegue 1 do NPC na Zona 3, coleta 1 atrás do portão na Zona 5, e coleta 1 na Zona 7 = 4 total. Ajuste conforme necessário.

> **Dica:** Se o NPC recusar dar comida (probabilidade), coloque uma comida extra escondida perto da Zona 3 como "backup" para que o player não fique preso.

### Passo 4.3 — Posicionar os Triggers

Coloque **7 instâncias** de `oTutorialTrigger` na layer `instancias`, uma em cada zona:

1. **Redimensione** cada trigger para cobrir a entrada/passagem da zona
2. **Clique duplo** em cada instância e defina a **Creation Code**:

| Trigger | Zona | Creation Code |
|---|---|---|
| Trigger 1 | Entrada da Zona 1 (spawn do player) | `dica_id = 1;` |
| Trigger 2 | Entrada da Zona 2 (perto da comida) | `dica_id = 2;` |
| Trigger 3 | Entrada da Zona 3 (perto do NPC) | `dica_id = 3;` |
| Trigger 4 | Entrada da Zona 4 (corredor) | `dica_id = 4;` |
| Trigger 5 | Entrada da Zona 5 (antes da chave) | `dica_id = 5;` |
| Trigger 6 | Entrada da Zona 6 (antes do inimigo) | `dica_id = 6;` |
| Trigger 7 | Entrada da Zona 7 (perto da saída) | `dica_id = 7;` |

### Passo 4.4 — Colisões e Paredes

Na layer `colisoes`:
- Use `oWall` para criar **corredores** que guiam o player linearmente da esquerda para a direita
- Use `oSolidWall` nas bordas do mapa
- Crie **passagens estreitas** entre as zonas para que o player siga o caminho correto
- Na Zona 5 (chave + portão), posicione o `oPorta` **bloqueando o corredor** entre Zona 5 e Zona 6
- Na Zona 6 (inimigo), crie **obstáculos** que permitam ao player se esconder

```
Exemplo de layout da Zona 5 (chave + portao):

+------------------------------+
|                              |
|   [T5]                       |
|          [K]                 |  <-- oChave posicionada manualmente
|                              |
|   [C] (atras do portao)      |  <-- comida so acessivel apos abrir
|                              |
|   ========| PORTAO |======== |  <-- oPorta bloqueando passagem
|                              |
|          ---------->         |  --> saida para Zona 6
+------------------------------+
```

```
Exemplo de layout da Zona 6 (stealth):

+--------------------------+
|  ####                    |
|  ####   ####   ####      |  <-- Paredes para se esconder
|         ####   ####      |
|  [T6]          [G]       |  <-- Inimigo patrulhando
|         ####   ####      |
|  ####   ####             |
|  ####          ------->  |  --> saida para Zona 7
+--------------------------+
```

---

## 📋 Parte 5 — Registrar no Seletor de Fases

### Passo 5.1 — Modificar `oSeletorDeFases/Create_0.gml`

A fase tutorial deve ser a **primeira** na lista:

```gml
fase_rooms = [
    rm_tutorial,     // ← TUTORIAL (primeira fase)
    room_01,
    room_02,
    // ...
];

fase_nomes = [
    "Tutorial",          // ← nome no seletor
    "Fase testes",
    "Fase testes tileset",
    // ...
];

fase_subtitulos = [
    "Aprenda a ser um lobo pidão!",  // ← subtítulo
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
    // ...
];
```

---

## 🔄 Fluxo Completo (o que acontece quando o jogador entra no tutorial)

```
rm_SelecaoDeFases
  │  jogador seleciona "Tutorial"
  ▼
rm_tutorial inicia
  │
  ├─ Room Creation Code:
  │   comidaMax=4, comidaSpawn=0, npcSpawn=0, tempoFomeMax=180
  │
  ├─ oController/Create → vida=6, tempoFome=180, cria grid, global.temChave=false
  │
  ├─ oTutorial/Create → carrega textos das 7 dicas
  │
  ├─ oSpawner/Alarm_0 → não spawna nada (spawn=0)
  │
  ├─ FRAME 1+: Player spawna na Zona 1
  │   │
  │   ├─ Player pisa no Trigger 1 → PAUSA
  │   │   └─ Dica: "Use WASD para se mover!"
  │   │   └─ Player aperta E → DESPAUSA
  │   │
  │   ├─ Player anda para Zona 2 → pisa no Trigger 2 → PAUSA
  │   │   └─ Dica: "Chegue perto e aperte E para coletar comida!"
  │   │   └─ Player aperta E → DESPAUSA
  │   │   └─ Player coleta oBurger → global.comida = 1
  │   │
  │   ├─ Player anda para Zona 3 → pisa no Trigger 3 → PAUSA
  │   │   └─ Dica: "NPCs podem te dar comida! Aperte E perto deles!"
  │   │   └─ Player interage com NPC → (chance) global.comida = 2
  │   │
  │   ├─ Player anda para Zona 4 → pisa no Trigger 4 → PAUSA
  │   │   └─ Dica: "Fique de olho na barra de fome!"
  │   │
  │   ├─ Player anda para Zona 5 → pisa no Trigger 5 → PAUSA
  │   │   └─ Dica: "Pegue a chave e desbloqueie o portão!"
  │   │   └─ Player coleta oChave → global.temChave = true
  │   │   └─ oPorta abre → player acessa comida atrás → global.comida = 3
  │   │
  │   ├─ Player anda para Zona 6 → pisa no Trigger 6 → PAUSA
  │   │   └─ Dica: "Cuidado com os guardas!"
  │   │   └─ Player desvia do oGuarda1
  │   │
  │   └─ Player anda para Zona 7 → pisa no Trigger 7 → PAUSA
  │       └─ Dica: "Colete toda a comida e entre na porta!"
  │       └─ Player coleta última comida → global.comida = 4 → oSaida abre
  │       └─ Player entra na saída → room_goto(rm_Vitoria)
  │
  ▼
rm_Vitoria → jogador venceu o tutorial!
```

---

## ⚠️ Detalhes Importantes de Implementação

### Pausa vs. Tutorial

O `oTutorial` usa `global.pausado = true` para congelar o jogo durante as dicas. Isso funciona porque **todos os objetos de gameplay** já checam `if (global.pausado) exit;` no início do Step.

Porém, o próprio `oTutorial` **NÃO deve** ter o guard clause de pausa no Step — ele precisa processar input mesmo quando pausado (para detectar o botão de fechar a dica).

### comidaSpawn = 0 e o Spawner

Como `global.comidaSpawn = 0` e `global.npcSpawn = 0`, o `oSpawner` vai rodar o `Alarm_0` mas o loop de spawn vai iterar 0 vezes para comida e NPCs.

Se preferir, pode simplesmente **não colocar `oSpawner`** na room do tutorial. Teste para garantir que o `oController` não gera erro por ausência do spawner.

### Comida posicionada manualmente

Ao colocar `oBurger` ou `oPunk` manualmente na room, o `oController` pode não contar essas instâncias no `global.comidaMax` automaticamente. O importante é que o **Room Creation Code** defina `global.comidaMax = 4` e que existam exatamente 4 comidas coletáveis na fase (contando comida no chão + comida do NPC + comida atrás do portão).

> **Atenção:** o `global.comida` começa em 0 e é incrementado pelo `oComida/Step` (quando o player coleta) e pelo `oNpc/Step` (quando o NPC dá comida). Garanta que as comidas posicionadas manualmente são filhos de `oComida` (ou seja, use `oBurger`/`oPunk`, não `oComida` direto).

### Chave e Portão no Tutorial

A chave (`oChave`) e o portão (`oPorta`) são posicionados **manualmente** na Zona 5 — não dependem do `oSpawner` nem de `global.faseTemChave`. O `oController/Create` já seta `global.temChave = false` por padrão, e o `oChave/Step` cuida de setar para `true` quando coletada. O `oPorta/Step` muda o sprite automaticamente ao detectar `global.temChave == true`.

> **Posicionamento:** Coloque a `oChave` **antes** do `oPorta` no percurso. O `oPorta` deve bloquear fisicamente o corredor, impedindo acesso à área com a comida extra.

### NPC com probabilidade

O `oNpc` tem probabilidade de dar comida (começa em 10%, sobe a cada tentativa). No tutorial, para evitar frustração, você pode:

**Opção A — Aceitar a probabilidade:** O jogador aprende que NPCs podem recusar. Coloque uma comida extra no mapa como backup.

**Opção B — Criar um NPC tutorial com 100% de chance:** Crie um filho de `oNpc` chamado `oNpcTutorial` que no Create seta `probabilidade = 100;` (ou o equivalente na variável do `oNpc`). Assim o NPC sempre dá comida na primeira tentativa.

---

## 🎨 Parte 6 — Extras Opcionais

### 6.1 — Setas visuais no chão

Coloque sprites de setas no tilemap da layer `tiles` apontando para a direita, guiando o player pelo caminho correto.

### 6.2 — Indicador de HUD destacado

Na primeira dica (movimento), você pode fazer o `oTutorial` desenhar setas apontando para os elementos da HUD (vida, fome, comida) durante a dica da Zona 4.

### 6.3 — Skip do tutorial

Adicione uma opção de pular o tutorial inteiro:

No `oTutorial/Step_0.gml`, adicione:

```gml
// Pular tutorial (ESC ou Start)
if (keyboard_check_pressed(vk_escape)
 || (global.gamepad_main != undefined
     && gamepad_button_check_pressed(global.gamepad_main, gp_start)))
{
    mostrando_dica = false;
    global.pausado = false;
    // Desativa todas as triggers restantes
    with (oTutorialTrigger) { ativada = true; }
}
```

### 6.4 — Salvar que o tutorial já foi feito

Para não forçar o jogador a repetir o tutorial toda vez:

```gml
// No oVitoria ou quando completa o tutorial:
global.tutorial_completo = true;

// No oSeletorDeFases, pode mostrar a fase tutorial com um ✓
```

---

## ✅ Checklist Final

### Sprites
- [ ] (Opcional) Criar `sTutorialTrigger` ou reutilizar sprite vazio

### Objetos novos
- [ ] Criar `oTutorialTrigger` (sem sprite / sprite invisível)
  - [ ] `Create_0.gml` → `ativada = false;`
  - [ ] `Step_0.gml` → detecta player + chama `oTutorial.mostrar_dica()`
- [ ] Criar `oTutorial` (sem sprite)
  - [ ] `Create_0.gml` → intro narrativa + dicas (7 textos) + função `mostrar_dica()`
  - [ ] `Step_0.gml` → intro + fade-in, timer anti-skip, input para fechar dica
  - [ ] `Draw_64.gml` → intro + caixa de diálogo, texto da dica, "aperte E"

### Room `rm_tutorial`
- [ ] Room criada (1120×360, viewport configurada)
- [ ] 4 layers: `instancias`, `tiles`, `colisoes`, `Background`
- [ ] Tilemap pintado (percurso linear com 7 zonas)
- [ ] Colisões posicionadas (corredores guiando o player)
- [ ] `oController` na layer `instancias`
- [ ] `oPlayer` na Zona 1
- [ ] `oTutorial` na layer `instancias`
- [ ] `oSaida` na Zona 7
- [ ] `oBurger` na Zona 2 (comida manual)
- [ ] `oNpc` na Zona 3 (NPC manual)
- [ ] `oChave` na Zona 5 (chave manual)
- [ ] `oPorta` na Zona 5 (portão bloqueando passagem para Zona 6)
- [ ] `oBurger`/`oPunk` na Zona 5 (atrás do portão — comida manual)
- [ ] `oGuarda1` na Zona 6 (inimigo manual)
- [ ] `oBurger`/`oPunk` na Zona 7 (última comida manual)
- [ ] 7× `oTutorialTrigger` com `dica_id` correto (Creation Code de cada instância)
- [ ] Room Creation Code com config fácil

### Seletor de Fases
- [ ] `rm_tutorial` adicionada como primeira entrada nos 3 arrays do `oSeletorDeFases`

### Teste
- [ ] Player spawna → Introdução narrativa aparece (10 páginas, tela escura)
- [ ] Apertar E/Space/A avança cada página da intro
- [ ] ESC/Start pula a intro inteira
- [ ] Após intro, player na Zona 1 → Dica 1 aparece automaticamente
- [ ] Apertar E/Space/A fecha a dica e despausa o jogo
- [ ] Caminhar para cada zona ativa a dica correspondente (7 triggers)
- [ ] Triggers só ativam uma vez (não repetem ao voltar)
- [ ] Comida manual é coletável normalmente
- [ ] NPC funciona normalmente (dá comida por interação)
- [ ] Chave coletável na Zona 5 → portão abre → área acessível
- [ ] Inimigo patrulha e persegue o player na Zona 6
- [ ] Coletar 4 comidas abre a saída
- [ ] Entrar na saída leva para `rm_Vitoria`
- [ ] Texto adapta para gamepad quando conectado ("[A]" em vez de "[E]")
- [ ] Timer de fome não causa game over durante tutorial normal (180s é suficiente)

---

## 📝 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `objects/oTutorialTrigger/Create_0.gml` | **NOVO** — `ativada = false;` |
| `objects/oTutorialTrigger/Step_0.gml` | **NOVO** — detecta player, chama `mostrar_dica()` |
| `objects/oTutorial/Create_0.gml` | **NOVO** — textos das dicas, cores, função `mostrar_dica()` |
| `objects/oTutorial/Step_0.gml` | **NOVO** — fade-in, timer, input de fechar |
| `objects/oTutorial/Draw_64.gml` | **NOVO** — caixa de diálogo + texto + "aperte E" |
| `objects/oSeletorDeFases/Create_0.gml` | **MODIFICAR** — adicionar `rm_tutorial` nos arrays |
| `rooms/rm_tutorial/RoomCreationCode.gml` | **NOVO** — config fácil da fase tutorial |

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Dica não aparece | `oTutorialTrigger` sem `dica_id` na Creation Code | Definir `dica_id` na Creation Code de cada instância |
| Dica aparece mas não fecha | `oTutorial/Step` tem guard clause de pausa | Remover `if (global.pausado) exit;` do `oTutorial/Step` |
| Jogo trava pausado | `oTutorial` não despausou | Verificar que `global.pausado = false` é setado ao fechar a dica |
| Comida não conta | Usou `oComida` direto em vez de filho | Usar `oBurger` ou `oPunk` (filhos de `oComida`) |
| NPC nunca dá comida | Probabilidade baixa (10%) | Colocar comida extra como backup ou usar NPC com probabilidade alta |
| Trigger ativa repetidamente | Faltou flag `ativada` | Verificar que `ativada = true` é setado na primeira ativação |
| Texto "[E]" aparece com gamepad | Faltou troca de texto | Verificar `string_replace_all` no `Draw_64` do `oTutorial` |
| Spawn aleatório de comida/NPC | `comidaSpawn`/`npcSpawn` não é 0 | Setar `global.comidaSpawn = 0` e `global.npcSpawn = 0` no Room Creation Code |
| Portão não abre | `oChave` não foi posicionada antes do `oPorta` no percurso | Garantir que o player coleta a chave antes de chegar ao portão |
| Player passa pelo portão sem chave | `oPorta` sem colisão no player | Verificar `oPlayer/Step` checa colisão com `oPorta` quando `!global.temChave` |

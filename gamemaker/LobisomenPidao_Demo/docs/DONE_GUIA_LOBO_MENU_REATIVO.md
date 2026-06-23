# 🐺 Guia de Implementação — Lobisomem Reativo no Menu Principal

> Guia para adicionar um **lobisomem animado e reativo** ao menu principal. Ele reage à navegação entre botões, à confirmação de cada opção (Play / Settings / Exit) e tem **três estágios de inatividade** com escalação cômica (revirando olhos → dormindo → envelhecendo).

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Room | `rm_MenuPrincipal` |
| Resolução da room | 1920×1080 |
| Spritesheet base | `sequencia_menu.png` (já criada — sprites **16×16 px**) |
| Posicionamento | Centro-esquerda da tela (canto inferior direito reservado pros botões) |
| Escala recomendada | `image_xscale = image_yscale = 20` → 320×320 px na tela |
| Input | Teclado (WASD/Arrows/Space/E/Enter) + Gamepad (D-pad/Stick/A) — **sem mouse** |
| Dependências | `oMenuPrincipal` já existente; `oProcuraControle` (persistente) |
| Novos objetos | `oLoboMenu` |
| Sprites a importar | 8 (a partir do recorte da `sequencia_menu.png`) |

> **Pré-requisitos:** o `oMenuPrincipal` já deve estar criado conforme o `DONE_GUIA_MENU_PRINCIPAL.md`. Os Settings (botão índice 1) abrem `rm_Settings` que está documentado nos guias `GUIA_VITORIA_E_SETTINGS.md` + `GUIA_AUDIO_E_MUSICA.md` + `GUIA_SETTINGS_EXTRA.md`.

---

## 🏗️ Visão Geral

### Por que ter um mascote reativo?

- **Personalidade:** o menu deixa de ser só botões e ganha vida.
- **Feedback visual:** o jogador vê a "personalidade" do lobo reagindo a cada opção antes mesmo de confirmar.
- **Aproveitamento:** já existe arte pronta (`sequencia_menu.png` + `sLoboMenu` no projeto).

### Layout final esperado

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                                                            │
│                                          LOBISOMEM         │
│         ╔════════════╗                    PIDÃO            │
│         ║            ║                                     │
│         ║   🐺       ║                  ┌──────────────┐   │
│         ║   (lobo    ║                  │ ▸ Play       │   │
│         ║   escalado ║                  └──────────────┘   │
│         ║   20x do   ║                  ┌──────────────┐   │
│         ║   16x16)   ║                  │   Settings   │   │
│         ║            ║                  └──────────────┘   │
│         ╚════════════╝                  ┌──────────────┐   │
│                                          │     Exit     │   │
│                                          └──────────────┘   │
│                                                            │
│     [WASD] Navegar    [E] Confirmar    Controle conectado  │
└────────────────────────────────────────────────────────────┘
```

### Princípio de design

> **Separação de responsabilidades:**
> - `oMenuPrincipal` continua dono do **input e da navegação** (botão focado, confirmação).
> - `oLoboMenu` é dono apenas das **reações visuais e do delay de transição**.
>
> Os dois se comunicam por **flags públicas** (`botao_focado`, `confirmou_neste_frame`).

---

## 🎨 Sprites — Recortando a `sequencia_menu.png`

A spritesheet `sequencia_menu.png` já contém **todas as 8 animações** necessárias. Você precisa **recortar cada animação** e importar como sprite separado no GameMaker.

### Mapa de animações na spritesheet

A spritesheet tem várias linhas com frames de 16×16 px cada. Identifique cada bloco de frames (mesma animação) e crie um sprite para cada:

| Sprite a criar | Conteúdo na spritesheet | Quando aparece no menu |
|---|---|---|
| `sLoboMenuPiscando` | Lobo piscando + olhando pros lados | **Idle ativo** (estado padrão) **e** quando o botão Play está focado |
| `sLoboMenuOculos` | Lobo com óculos de grau | Foco no botão **Settings** (combina semanticamente 🤓) |
| `sLoboMenuBravo` | Lobo bravo | Foco no botão **Exit** (não quer que você saia) |
| `sLoboMenuFeliz` | Lobo muito feliz | **Confirmou Play** (2s antes de ir pra fase) |
| `sLoboMenuTriste` | Lobo com lágrima | **Confirmou Exit** (2s antes de fechar) |
| `sLoboMenuRevirando` | Lobo revirando os olhos | **8s sem interação** — "tô esperando..." |
| `sLoboMenuDormindo` | Lobo dormindo (sprite isolado maior) | **15s sem interação** — "apaguei" |
| `sLoboMenuEnvelhecendo` | Lobo envelhecendo | **25s sem interação** — "esperei tanto que envelheci" |

> **`sLoboMenu` original** continua no projeto como sprite de fallback no `.yy` do objeto (caso algum estado não esteja setado por bug, ele desenha esse). Os estados específicos usam os novos.

### Como recortar no GameMaker

Pra cada animação:

1. **Asset Browser** → **Sprites** → clique direito → **Create Sprite**
2. Nomeie como na tabela acima (ex: `sLoboMenuFeliz`)
3. Abra o **Sprite Editor**
4. **Image** → **Import Strip Image...**
5. Selecione `sequencia_menu.png`
6. Configure:
   - **Frame Width**: 16
   - **Frame Height**: 16
   - **Number of frames**: quantos frames a animação tem (conte na spritesheet)
   - **Horizontal cells / Vertical cells**: ajuste conforme onde a animação começa
   - **Horizontal offset / Vertical offset**: pula até a linha/coluna correta na spritesheet
7. Clique em **Convert**
8. Configure **Origin** → **Middle Centre** (ou manualmente `xorigin = 8`, `yorigin = 8`)
9. Ajuste a velocidade da animação (FPS) no editor — sugestão: **6–8 fps** para animações idle, **10–12 fps** para reações

> **Alternativa mais simples:** abra a `sequencia_menu.png` num editor (Aseprite, Photoshop, GIMP, etc.), recorte cada animação em arquivos separados (`piscando.png`, `oculos.png`, etc.) e importe cada um.

### Sobre a origem (`xorigin = 8`, `yorigin = 8`)

Todos os sprites devem ter a **mesma origem central**. Isso garante que ao trocar de sprite, o lobo não "pula" de lugar na tela.

### Configurações de pixel art (importante!)

No GameMaker, vá em **Game Options → Graphics** e garanta:
- **Use Texture Page**: marcado
- **Interpolate colors between pixels**: **desmarcado**

Sem isso, o sprite escalado 20× fica borrado em vez de pixel art nítido.

Alternativa por código (em qualquer Create que rode no boot, ex: `oProcuraControle/Create`):
```gml
texture_set_interpolation(false);
```

---

## ⚙️ Máquina de Estados (State Machine)

### Diagrama

```
                          ┌──────────────────────┐
                          │   IDLE_ATIVO         │
                          │ (sLoboMenuPiscando)  │◄──── qualquer input
                          └──┬─────────────────┬─┘
                             │                 │
                  navegou    │                 │  8s sem
                  para X     │                 │  interação
                             │                 ▼
              ┌──────────────┴──┐    ┌──────────────────────┐
              │  FOCO_PLAY      │    │ INATIVO_1_REVIRANDO  │
              │  (sLoboMenu     │    │ (sLoboMenuRevirando) │
              │   Piscando)     │    └─────────┬────────────┘
              │  FOCO_SETTINGS  │              │ +7s sem
              │  (sLoboMenu     │              │ interação
              │   Oculos)       │              ▼
              │  FOCO_EXIT      │    ┌──────────────────────┐
              │  (sLoboMenu     │    │ INATIVO_2_DORMINDO   │
              │   Bravo)        │    │ (sLoboMenuDormindo)  │
              └────┬────────────┘    └─────────┬────────────┘
                   │ confirmou                 │ +10s sem
                   ▼                           │ interação
        ┌──────────────────────────┐           ▼
        │  CONF_PLAY               │ ┌──────────────────────┐
        │  (sLoboMenuFeliz)        │ │ INATIVO_3_VELHO      │
        │  → 2s + fade             │ │ (sLoboMenuEnvelhecendo)
        │  → room_goto(...)        │ └─────────┬────────────┘
        └──────────────────────────┘           │
        ┌──────────────────────────┐           │ qualquer
        │  CONF_SETTINGS           │           │ input
        │  (sLoboMenuOculos)       │           ▼
        │  → room_goto direto      │      volta pra IDLE_ATIVO
        └──────────────────────────┘
        ┌──────────────────────────┐
        │  CONF_EXIT               │
        │  (sLoboMenuTriste)       │
        │  → 2s + fade             │
        │  → game_end()            │
        └──────────────────────────┘
```

### Tabela de estados

| Estado | Sprite | Duração | O que faz |
|---|---|---|---|
| `IDLE_ATIVO` | `sLoboMenuPiscando` | Indefinida | Aguarda interação |
| `FOCO_PLAY` | `sLoboMenuPiscando` (mesmo) | Enquanto Play estiver focado | Sem reação extra |
| `FOCO_SETTINGS` | `sLoboMenuOculos` | Enquanto Settings focado | "Configurações? Deixa eu colocar meus óculos" |
| `FOCO_EXIT` | `sLoboMenuBravo` | Enquanto Exit focado | "Não, não vai embora!" |
| `INATIVO_1_REVIRANDO` | `sLoboMenuRevirando` | 8s a 15s sem input | "Tô esperando..." |
| `INATIVO_2_DORMINDO` | `sLoboMenuDormindo` | 15s a 25s sem input | "Apaguei" |
| `INATIVO_3_VELHO` | `sLoboMenuEnvelhecendo` | 25s+ sem input | "Esperei tanto que envelheci" |
| `CONF_PLAY` | `sLoboMenuFeliz` | 2 segundos | Anim feliz + fade-out + `room_goto(rm_SelecaoDeFases)` |
| `CONF_SETTINGS` | `sLoboMenuOculos` (mantém) | Instantâneo | Vai pra `rm_Settings` |
| `CONF_EXIT` | `sLoboMenuTriste` | 2 segundos | Anim triste + fade-out + `game_end()` |

---

## 🧱 Parte 1 — Criar o `oLoboMenu`

Asset Browser → Objects → Create Object:
- **Nome:** `oLoboMenu`
- **Sprite:** `sLoboMenuPiscando` (estado inicial)
- **Visible:** True
- **Persistent:** False (vive só no `rm_MenuPrincipal`)

### 1.1 `objects/oLoboMenu/Create_0.gml`

```gml
// ===== Estados (enum simulado por strings — legível e fácil de estender) =====
ESTADO_IDLE_ATIVO          = "idle_ativo";
ESTADO_FOCO_PLAY           = "foco_play";
ESTADO_FOCO_SETTINGS       = "foco_settings";
ESTADO_FOCO_EXIT           = "foco_exit";

ESTADO_INATIVO_1_REVIRANDO = "inativo_1";
ESTADO_INATIVO_2_DORMINDO  = "inativo_2";
ESTADO_INATIVO_3_VELHO     = "inativo_3";

ESTADO_CONF_PLAY           = "conf_play";
ESTADO_CONF_SETTINGS       = "conf_settings";
ESTADO_CONF_EXIT           = "conf_exit";

// ===== Estado inicial =====
estado = ESTADO_IDLE_ATIVO;
sprite_index = sLoboMenuPiscando;
image_speed  = 1;

// Escala 20x do sprite 16x16 (320x320 na tela)
image_xscale = 20;
image_yscale = 20;

// ===== Timers de inatividade (em frames; room_speed = 60 por padrão) =====
timer_inatividade            = 0;
TIMER_INATIVO_1_FRAMES       = room_speed * 8;    // 8s  → revirando os olhos
TIMER_INATIVO_2_FRAMES       = room_speed * 15;   // 15s → dormindo
TIMER_INATIVO_3_FRAMES       = room_speed * 25;   // 25s → envelhecendo

// ===== Timer de transição (Play/Exit) =====
timer_transicao              = 0;
TIMER_DELAY_CONFIRMACAO      = room_speed * 2;    // 2s

// ===== Fade-out durante transição =====
input_bloqueado              = false;
fade_alpha                   = 0;
FADE_VELOCIDADE              = 1 / (room_speed * 2);  // fade completo em 2s

// ===== Lembrar último foco para detectar mudança =====
ultimo_focado = -1;
```

### 1.2 `objects/oLoboMenu/Step_0.gml`

```gml
// =====================================================
// FASE A: Transição final (Play/Exit confirmados) — congela tudo
// =====================================================
if (input_bloqueado) {
    timer_transicao--;
    fade_alpha = min(1, fade_alpha + FADE_VELOCIDADE);

    if (timer_transicao <= 0) {
        switch (estado) {
            case ESTADO_CONF_PLAY: room_goto(rm_SelecaoDeFases); break;
            case ESTADO_CONF_EXIT: game_end();                   break;
        }
    }
    exit;
}

// =====================================================
// FASE B: Segurança — sair se o menu não existir
// =====================================================
if (!instance_exists(oMenuPrincipal)) exit;

var _focado = oMenuPrincipal.botao_focado;
var _confirmou = oMenuPrincipal.confirmou_neste_frame;

// =====================================================
// FASE C: Confirmação (apertou Enter/E/Space/A)
// =====================================================
if (_confirmou) {
    switch (_focado) {
        case 0: // Play → feliz + delay
            estado          = ESTADO_CONF_PLAY;
            sprite_index    = sLoboMenuFeliz;
            timer_transicao = TIMER_DELAY_CONFIRMACAO;
            input_bloqueado = true;
            break;

        case 1: // Settings → vai direto (sem delay), mantém o sprite de óculos
            estado       = ESTADO_CONF_SETTINGS;
            sprite_index = sLoboMenuOculos;
            room_goto(rm_Settings);
            break;

        case 2: // Exit → triste + delay
            estado          = ESTADO_CONF_EXIT;
            sprite_index    = sLoboMenuTriste;
            timer_transicao = TIMER_DELAY_CONFIRMACAO;
            input_bloqueado = true;
            break;
    }
    timer_inatividade = 0;
    ultimo_focado = _focado;
    exit;
}

// =====================================================
// FASE D: Mudança de foco (jogador navegou)
// =====================================================
var _mudou_foco = (_focado != ultimo_focado);

if (_mudou_foco) {
    timer_inatividade = 0;

    switch (_focado) {
        case 0: estado = ESTADO_FOCO_PLAY;     sprite_index = sLoboMenuPiscando; break;
        case 1: estado = ESTADO_FOCO_SETTINGS; sprite_index = sLoboMenuOculos;   break;
        case 2: estado = ESTADO_FOCO_EXIT;     sprite_index = sLoboMenuBravo;    break;
    }

    ultimo_focado = _focado;
    exit;
}

// =====================================================
// FASE E: Inatividade — escalação em 3 estágios
// =====================================================
timer_inatividade++;

// Verificar do estágio mais avançado pro mais inicial (evita "pular" estágios)
if (estado != ESTADO_INATIVO_3_VELHO && timer_inatividade >= TIMER_INATIVO_3_FRAMES) {
    estado = ESTADO_INATIVO_3_VELHO;
    sprite_index = sLoboMenuEnvelhecendo;
}
else if (estado != ESTADO_INATIVO_3_VELHO
      && estado != ESTADO_INATIVO_2_DORMINDO
      && timer_inatividade >= TIMER_INATIVO_2_FRAMES) {
    estado = ESTADO_INATIVO_2_DORMINDO;
    sprite_index = sLoboMenuDormindo;
}
else if (estado != ESTADO_INATIVO_3_VELHO
      && estado != ESTADO_INATIVO_2_DORMINDO
      && estado != ESTADO_INATIVO_1_REVIRANDO
      && timer_inatividade >= TIMER_INATIVO_1_FRAMES) {
    estado = ESTADO_INATIVO_1_REVIRANDO;
    sprite_index = sLoboMenuRevirando;
}
```

### 1.3 `objects/oLoboMenu/Draw_0.gml`

```gml
// Desenho normal (sprite atual escalado)
draw_self();
```

### 1.4 `objects/oLoboMenu/Draw_64.gml` (Draw GUI — fade overlay)

```gml
// Overlay de fade-out durante transição (Play/Exit)
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}
```

### 1.5 `objects/oLoboMenu/Other_4.gml` (Room Start — opcional)

Se o jogador voltar pro menu vindo de outra room, garante reset limpo:

```gml
timer_inatividade = 0;
estado            = ESTADO_IDLE_ATIVO;
sprite_index      = sLoboMenuPiscando;
fade_alpha        = 0;
input_bloqueado   = false;
ultimo_focado     = -1;
```

---

## 🔌 Parte 2 — Patch no `oMenuPrincipal`

O menu precisa expor duas informações públicas:
- `botao_focado` (**já existe** desde o `DONE_GUIA_MENU_PRINCIPAL.md`)
- `confirmou_neste_frame` (**NOVO** — flag resetada todo frame)

E precisa **deixar o lobo cuidar do `room_goto`/`game_end`** quando o lobo está presente.

### 2.1 Modificar `objects/oMenuPrincipal/Step_0.gml`

**No topo do Step:**

```gml
// Flag consultada pelo oLoboMenu — resetada todo frame
confirmou_neste_frame = false;
```

**No bloco existente que detecta confirmação** (procurar `if (_confirmar) {` no Step atual):

```gml
if (_confirmar) {
    confirmou_neste_frame = true;

    // Se o oLoboMenu existe, ele cuida da transição (delay de 2s no Play/Exit).
    if (instance_exists(oLoboMenu)) {
        exit;
    }

    // Fallback (oLoboMenu ausente — modo "menu puro"):
    switch (botao_focado) {
        case 0: room_goto(rm_SelecaoDeFases); break;
        case 1: room_goto(rm_Settings);       break;
        case 2: game_end();                   break;
    }
}
```

> O `oMenuPrincipal` ainda detecta e sinaliza confirmação; ele só não **executa** a troca quando o lobo está presente. Isso mantém o menu funcionando isolado pra testes.

---

## 🏠 Parte 3 — Posicionar no Room Editor

1. Abra `rm_MenuPrincipal`.
2. Na layer `instancias` (ou crie uma `Personagens`).
3. Arraste **uma** instância de `oLoboMenu`.
4. Posicione em **x ≈ 720, y ≈ 540** (terço esquerdo-centro, vertical centralizado).
5. Salve a room.

### 3.1 Ajuste fino da posição

Sprite com origem central + escala 20×:
- Imagem visual ocupa de `(x - 160, y - 160)` até `(x + 160, y + 160)` (320×320 px)
- Para `x = 720, y = 540` → lobo centrado entre x = 560–880 e y = 380–700

---

## ✅ Boas Práticas Aplicadas

| Prática | Como o guia aplica |
|---|---|
| **Separação de responsabilidades** | Menu cuida de input; lobo cuida de reações visuais |
| **State machine clara** | Estados nomeados como constantes, switch único |
| **Sem código monolítico** | Step dividido em 5 fases comentadas (A–E) |
| **Reuso de sprite** | `sLoboMenuPiscando` cobre IDLE_ATIVO e FOCO_PLAY (sem duplicar) |
| **Tolerância a falhas** | `if (!instance_exists(oMenuPrincipal)) exit;` evita crash |
| **Sem dependência circular** | Lobo lê do menu, menu não conhece o lobo |
| **Compatível com teclado + gamepad** | Toda lógica via `botao_focado` (input-agnóstico) |
| **Humor visual escalado** | 3 estágios de inatividade combinam com o tom "Lobisomem Pidão" |

---

## 🚀 Escalabilidade — Adicionar mais botões

Cenário: adicionar **"Créditos"** entre Settings e Exit.

### Passos
1. **`oMenuPrincipal/Create_0.gml`**: `botoes = ["Play","Settings","Creditos","Exit"];`
2. Criar/recortar sprite `sLoboMenuConfusoAprendendo` (ou outra reação que combine).
3. **`oLoboMenu/Step_0.gml`** fase D: `case 2: estado = "foco_creditos"; sprite_index = sLoboMenuConfuso; break;` e renumerar Exit para `case 3`.
4. Fase C (confirmação): novo `case 2` para `room_goto(rm_Creditos);` sem delay; renumerar Exit.
5. **`oMenuPrincipal` fallback:** `case 2: room_goto(rm_Creditos);` + renumerar.

**Pronto.** Nada muda no Draw, fade ou outros arquivos.

---

## ✅ Checklist Rápida

### Sprites — recortar da `sequencia_menu.png`
- [ ] `sLoboMenuPiscando` (idle + foco Play)
- [ ] `sLoboMenuOculos` (foco Settings + confirmou Settings)
- [ ] `sLoboMenuBravo` (foco Exit)
- [ ] `sLoboMenuFeliz` (confirmou Play)
- [ ] `sLoboMenuTriste` (confirmou Exit)
- [ ] `sLoboMenuRevirando` (inativo 8s)
- [ ] `sLoboMenuDormindo` (inativo 15s)
- [ ] `sLoboMenuEnvelhecendo` (inativo 25s)
- [ ] **Todos com origem central** (`xorigin = 8`, `yorigin = 8`)
- [ ] FPS da animação ajustado (sugestão: 6–8 para idle, 10–12 para reações)

### Objeto a criar
- [ ] `oLoboMenu` com Create, Step, Draw_0, Draw_64
- [ ] (Opcional) Other_4 (Room Start) para reset de timer

### Patches
- [ ] `oMenuPrincipal/Step_0.gml`: adicionar `confirmou_neste_frame = false` no topo
- [ ] `oMenuPrincipal/Step_0.gml`: ajustar bloco `if (_confirmar)` com early-return se `oLoboMenu` existir

### Room Editor
- [ ] Adicionar instância de `oLoboMenu` em `rm_MenuPrincipal` em (720, 540)

### Configurações do projeto
- [ ] Game Options → Graphics → **desmarcar** "Interpolate colors between pixels"
- [ ] OU adicionar `texture_set_interpolation(false);` no boot (ex: `oProcuraControle/Create`)

### Testes
- [ ] Lobo aparece piscando (`sLoboMenuPiscando`) ao abrir o menu
- [ ] Navegar para Settings → vira de óculos
- [ ] Navegar para Exit → fica bravo
- [ ] Voltar pra Play → volta a piscar (idle)
- [ ] Esperar 8s → revira os olhos
- [ ] Esperar mais 7s (total 15s) → dorme
- [ ] Esperar mais 10s (total 25s) → envelhece
- [ ] Qualquer input acorda o lobo
- [ ] Confirmar Play → fica feliz por 2s + fade + vai pra seleção de fases
- [ ] Confirmar Settings → abre `rm_Settings` instantâneo
- [ ] Confirmar Exit → fica triste por 2s + fade + fecha o jogo
- [ ] Durante os 2s de delay, input é bloqueado

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Sprite fica borrado no scale 20× | Interpolação ativa | Desligar em Game Options → Graphics OU `texture_set_interpolation(false)` |
| Lobo "pula de lugar" ao trocar sprite | Origem inconsistente entre sprites | Setar todos como Middle Centre (xorigin = 8, yorigin = 8) |
| Lobo dorme imediatamente após voltar pro menu | Timer não resetou | Adicionar evento Other_4 (Room Start) zerando `timer_inatividade` |
| Confirmar Play não troca pra rm_SelecaoDeFases | `confirmou_neste_frame` não foi setado / oLoboMenu não detectou | Verificar Step do menu (flag setada antes do `exit`) |
| Lobo continua reagindo ao foco depois de confirmar | Fase C sem `exit;` | Adicionar `exit;` no final do bloco de confirmação |
| Fade-out dura mais/menos que o delay | `FADE_VELOCIDADE` não bate com `TIMER_DELAY_CONFIRMACAO` | Ambos devem ser ~2s; com `room_speed = 60`, `FADE_VELOCIDADE = 1/120` |
| Settings também trava por 2s | `input_bloqueado = true` foi setado no case 1 por engano | Settings vai direto — só Play/Exit setam `input_bloqueado` |
| Sprite some quando troca | Sprite não foi criado ou nome errado | Conferir nomes no Asset Browser (`sLoboMenuPiscando`, etc.) |
| Lobo aparece atrás do fundo do menu | Layer com profundidade errada | Colocar em `instancias` (depth 0) ou layer com depth menor que o fundo |
| Lobo pula direto de IDLE pra DORMINDO sem passar pelo REVIRANDO | Fase E checada na ordem errada | Manter a ordem: VELHO → DORMINDO → REVIRANDO (do mais avançado pro inicial) |
| Animação muito rápida/lenta | `image_speed` global × FPS do sprite | Ajustar FPS no Sprite Editor (canto inferior) — não no código |

---

## 📁 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `sprites/sLoboMenuPiscando/` | **NOVO** (recortar da spritesheet) |
| `sprites/sLoboMenuOculos/` | **NOVO** |
| `sprites/sLoboMenuBravo/` | **NOVO** |
| `sprites/sLoboMenuFeliz/` | **NOVO** |
| `sprites/sLoboMenuTriste/` | **NOVO** |
| `sprites/sLoboMenuRevirando/` | **NOVO** |
| `sprites/sLoboMenuDormindo/` | **NOVO** |
| `sprites/sLoboMenuEnvelhecendo/` | **NOVO** |
| `sprites/sLoboMenu/` | **Existente** — mantido como fallback (não precisa mexer) |
| `objects/oLoboMenu/Create_0.gml` | **NOVO** |
| `objects/oLoboMenu/Step_0.gml` | **NOVO** |
| `objects/oLoboMenu/Draw_0.gml` | **NOVO** |
| `objects/oLoboMenu/Draw_64.gml` | **NOVO** |
| `objects/oLoboMenu/Other_4.gml` | **NOVO** (opcional) |
| `objects/oMenuPrincipal/Step_0.gml` | **MODIFICAR** — adicionar flag `confirmou_neste_frame` + ajustar bloco de confirmação |
| `rm_MenuPrincipal` | **MODIFICAR** — adicionar instância de `oLoboMenu` em (720, 540) |
| `sequencia_menu.png` (arquivo fonte) | Manter no repo como referência da arte original |

---

## 📝 TODOs Pós-Implementação

- [ ] Considerar adicionar **som** de reação a cada confirmação (ver `GUIA_AUDIO_E_MUSICA.md` — `audio_play_sound(snd_uiConfirma, 1, false);` antes do `room_goto`).
- [ ] Adicionar SFX específicos pros estados engraçados (snore quando dormindo, "argh!" quando bravo, etc.) — opcional.
- [ ] Aplicar o mesmo padrão de mascote reativo em `rm_Vitoria` (lobo comemorando) e `rm_gameOver` (lobo derrotado) — coesão visual.
- [ ] Documentar `oLoboMenu` na seção "Mapa de Objetos" do `CONTEXTO_GAMEMAKER.md`.
- [ ] Se quiser efeito ainda mais cômico no estágio de envelhecimento: depois de envelhecer, o lobo pode "desaparecer em pó" (alpha fade) — mas isso é polimento.

---

> **Resumo:** este guia transforma o menu principal de tela estática em uma cena com personalidade. As 8 animações da `sequencia_menu.png` se mapeiam diretamente em 8 estados visuais, e a separação `oMenuPrincipal` (input) + `oLoboMenu` (visual) mantém o código limpo, escalável e fácil de manter. A escalação cômica de inatividade (revirando → dormindo → envelhecendo) é uma piada visual que reforça o tom "Lobisomem Pidão" desde a tela de boas-vindas.

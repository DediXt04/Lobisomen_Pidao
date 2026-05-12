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

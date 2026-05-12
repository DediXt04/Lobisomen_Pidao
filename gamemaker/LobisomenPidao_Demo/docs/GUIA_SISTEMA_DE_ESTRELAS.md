# ⭐ Guia de Implementação — Sistema de Estrelas

> Sistema de pontuação por estrelas (1–3) exibido na tela de vitória. Baseado em 3 fatores: tempo de fome restante, vida restante e comida coletada. A melhor pontuação por fase é salva e exibida no seletor.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Estrelas | 1 ★ (ruim), 2 ★★ (bom), 3 ★★★ (excelente) |
| Fatores | Fome restante (40%), Vida restante (40%), Comida (20%) |
| Quando aparece | Somente na vitória (Game Over = 0 estrelas automático) |
| Persistência | Salva melhor pontuação por fase em `save_progresso.ini` |
| Exibição | Tela de vitória + seletor de fases (abaixo do card) |
| Sprite | `sEstrela` — 16×16, 2 frames: índice 0 = vazia, índice 1 = completa |

---

## 🏗️ Estrutura Geral

### Fórmula de Pontuação

```
pct_fome   = (tempoFome / tempoMax) * 100    ← % de fome restante
pct_vida   = (vida / vidaMax) * 100           ← % de vida restante
pct_comida = (comida / comidaMax) * 100       ← % de comida (sempre 100% hoje)

score = (pct_fome × 0.4) + (pct_vida × 0.4) + (pct_comida × 0.2)
```

| Score | Estrelas | Significado |
|-------|----------|-------------|
| ≥ 70  | ★★★     | Excelente — venceu com vida e fome sobrando |
| ≥ 40  | ★★      | Bom — venceu mas apanhou ou passou fome |
| < 40  | ★       | Sobreviveu por pouco |

> **Nota:** Como o jogador precisa coletar TODA a comida para vencer, `pct_comida` é sempre 100% atualmente, dando um piso de 20 pontos. Os fatores que realmente variam são fome e vida.

### Exemplos de Cenários

| Fome restante | Vida restante | Comida | Score | Estrelas |
|---------------|---------------|--------|-------|----------|
| 80% | 100% | 100% | 92 | ★★★ |
| 50% | 83% | 100% | 73 | ★★★ |
| 30% | 50% | 100% | 52 | ★★ |
| 10% | 33% | 100% | 37 | ★ |
| 5% | 17% | 100% | 29 | ★ |

### Fluxo

```
[Gameplay] → jogador chega na saída com comida cheia
                │
                ▼
         oController guarda stats em globals:
           global.resultado_fome  = tempoFome
           global.resultado_vida  = vida
           global.resultado_max_fome = tempoMax
           global.resultado_max_vida = vidaMax
                │
                ▼
         [rm_Vitoria]
           oVitoria/Create_0 calcula score + estrelas
           compara com save, atualiza se for melhor
           exibe estrelas no Draw_0
                │
                ▼
         [Seletor]
           carrega estrelas do save
           exibe abaixo de cada card
```

---

## 📦 O Que Criar / Modificar

### Recurso Novo

| Recurso | Tipo | Descrição |
|---|---|---|
| `sEstrela` | Sprite | 16×16 pixels, **2 frames**: índice 0 = estrela vazia, índice 1 = estrela completa. Origin: center (8, 8). |

> Crie o sprite `sEstrela` no GameMaker com 2 sub-imagens (frames). Frame 0 é a estrela apagada/vazia e frame 1 é a estrela acesa/completa. Tamanho 16×16 com origin no centro.

### Arquivos Modificados

| Arquivo | Tipo de Mudança |
|---|---|
| `oController/Step_0.gml` | Guardar stats em globals antes do room_goto vitória |
| `oVitoria/Create_0.gml` | Calcular score e estrelas, salvar se for melhor |
| `oVitoria/Draw_0.gml` | Desenhar estrelas e detalhes da pontuação |
| `oSeletorDeFases/Create_0.gml` | Carregar estrelas salvas do ini |
| `oSeletorDeFases/Draw_0.gml` | Desenhar estrelas abaixo de cada card |

---

## 💻 Código

### Modificar `oController/Step_0.gml`

No trecho onde o jogador toca a saída (dentro de `oPlayer/Step_0.gml`), os stats já estão disponíveis via `oController.vida`, `oController.tempoFome`, etc. Mas para garantir que os dados cheguem até `rm_Vitoria` (onde o oController não existe), precisamos salvar em globals.

Adicionar **no final** do `oController/Create_0.gml`:

```gml
// resultados para tela de vitória
global.resultado_fome = 0;
global.resultado_vida = 0;
global.resultado_max_fome = 0;
global.resultado_max_vida = 0;
```

No `oPlayer/Step_0.gml`, **antes** de cada `room_goto(rm_Vitoria)` (há 2 ocorrências — colisão horizontal e vertical com oSaida), adicionar:

```gml
        // Guardar stats para cálculo de estrelas
        global.resultado_fome = oController.tempoFome;
        global.resultado_vida = oController.vida;
        global.resultado_max_fome = oController.tempoMax;
        global.resultado_max_vida = oController.vidaMax;
```

Exemplo no contexto:
```gml
if place_meeting(x + xspd, y, oSaida)
{
    if global.comidaCheia
    {
        global.resultado_fome = oController.tempoFome;
        global.resultado_vida = oController.vida;
        global.resultado_max_fome = oController.tempoMax;
        global.resultado_max_vida = oController.vidaMax;
        room_goto(rm_Vitoria);
    }
    xspd = 0;
}
```

---

### Modificar `oVitoria/Create_0.gml`

Substituir todo o conteúdo por:

```gml
motivo = global.motivoMorte;

// ===============================================================
// CÁLCULO DE ESTRELAS
// ===============================================================
// Percentuais dos fatores (0–100)
var _pct_fome = 0;
var _pct_vida = 0;
var _pct_comida = 0;

if (global.resultado_max_fome > 0) {
    _pct_fome = (global.resultado_fome / global.resultado_max_fome) * 100;
}
if (global.resultado_max_vida > 0) {
    _pct_vida = (global.resultado_vida / global.resultado_max_vida) * 100;
}
if (global.comidaMax > 0) {
    _pct_comida = (global.comida / global.comidaMax) * 100;
}

// Score ponderado (fome 40%, vida 40%, comida 20%)
score = (_pct_fome * 0.4) + (_pct_vida * 0.4) + (_pct_comida * 0.2);
score = clamp(score, 0, 100);

// Determinar estrelas
if (score >= 70) {
    estrelas = 3;
} else if (score >= 40) {
    estrelas = 2;
} else {
    estrelas = 1;
}

// Detalhes para exibição
detalhe_fome  = round(_pct_fome);
detalhe_vida  = round(_pct_vida);
detalhe_score = round(score);

// ===============================================================
// SALVAR MELHOR PONTUAÇÃO
// ===============================================================
var _fase = global.fase_atual;
var _chave = "fase_" + string(_fase);

ini_open("save_progresso.ini");
var _melhor = ini_read_real("estrelas", _chave, 0);

if (estrelas > _melhor) {
    ini_write_real("estrelas", _chave, estrelas);
}
ini_close();
```

**Variáveis explicadas:**

| Variável | Tipo | Descrição |
|---|---|---|
| `score` | real | Pontuação final (0–100) |
| `estrelas` | int | Quantidade de estrelas (1–3) |
| `detalhe_fome` | int | % de fome restante (para exibir) |
| `detalhe_vida` | int | % de vida restante (para exibir) |
| `detalhe_score` | int | Score arredondado (para exibir) |

---

### Modificar `oVitoria/Draw_0.gml`

Substituir todo o conteúdo por:

```gml
var _cx = room_width  / 2;
var _cy = room_height / 2;

// -------------------------------------------------------
// FUNDO
// -------------------------------------------------------
draw_set_alpha(0.85);
draw_set_color(make_color_rgb(14, 14, 26));
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// Linhas decorativas
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.35);
draw_line_width(0, _cy - 200, room_width, _cy - 200, 2);
draw_line_width(0, _cy + 200, room_width, _cy + 200, 2);
draw_set_alpha(1);

// -------------------------------------------------------
// TÍTULO
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(80, 200, 210));
draw_text(_cx, _cy - 160, "VOCE VENCEU!");

// -------------------------------------------------------
// ESTRELAS (sprite sEstrela 16x16, frame 0 = vazia, frame 1 = completa)
// -------------------------------------------------------
var _star_gap = 40;
var _star_y = _cy - 100;
var _star_start_x = _cx - _star_gap;
var _star_scale = 3;

for (var i = 0; i < 3; i++) {
    var _sx = _star_start_x + i * _star_gap;
    var _frame = (i < estrelas) ? 1 : 0;

    draw_sprite_ext(sEstrela, _frame, _sx, _star_y, _star_scale, _star_scale, 0, c_white, 1);
}

// -------------------------------------------------------
// DETALHES DA PONTUAÇÃO
// -------------------------------------------------------
draw_set_color(make_color_rgb(130, 165, 180));
draw_text(_cx, _cy - 40, "Pontuacao: " + string(detalhe_score) + "%");

draw_set_color(make_color_rgb(90, 130, 145));
draw_text(_cx, _cy - 5, "Fome: " + string(detalhe_fome) + "%    Vida: " + string(detalhe_vida) + "%");

// -------------------------------------------------------
// BOTÃO — Voltar ao menu
// -------------------------------------------------------
var _bw = 280;
var _bh = 54;
var _bx = _cx - _bw / 2;
var _by = _cy + 50;

var _hover = (mouse_x > _bx && mouse_x < _bx + _bw &&
              mouse_y > _by && mouse_y < _by + _bh);

draw_set_color(_hover
    ? make_color_rgb(30, 60, 80)
    : make_color_rgb(20, 35, 55));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

draw_set_color(make_color_rgb(80, 200, 210));
draw_rectangle(_bx, _by, _bx + 5, _by + _bh, false);

draw_set_color(make_color_rgb(80, 200, 210));
draw_set_alpha(_hover ? 0.8 : 0.4);
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
draw_set_alpha(1);

draw_set_color(_hover
    ? make_color_rgb(120, 225, 235)
    : make_color_rgb(80, 200, 210));
draw_text(_cx, _by + _bh / 2, "Voltar ao menu");

// -------------------------------------------------------
// RODAPÉ
// -------------------------------------------------------
var _gp = global.gamepad_main;
var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);

draw_set_color(make_color_rgb(45, 80, 95));
if (_temControle) {
    draw_text(_cx, _by + _bh + 36, "A / Cruz  para voltar");
} else {
    draw_text(_cx, _by + _bh + 36, "SPACE para voltar");
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
```

### Layout Visual da Tela de Vitória

```
┌──────────────────────────────────────────────┐
│              ═══════════════                  │
│                                              │
│              VOCE VENCEU!                    │  ← teal
│                                              │
│              *    *    *                     │  ← dourado/escuro
│                                              │
│           Pontuacao: 73%                     │  ← cinza claro
│        Fome: 50%    Vida: 83%               │  ← cinza
│                                              │
│          ┌────────────────────┐              │
│          │▌  Voltar ao menu   │              │
│          └────────────────────┘              │
│                                              │
│           SPACE para voltar                  │
│              ═══════════════                  │
└──────────────────────────────────────────────┘
```

---

### Modificar `oSeletorDeFases/Create_0.gml`

Adicionar **após** o carregamento de `global.fase_desbloqueada` (se já implementado) ou após a linha `if (!variable_global_exists("comida")) global.comida = 0;`:

```gml
// --- Carregar estrelas salvas ---
fase_estrelas = array_create(total_fases, 0);

ini_open("save_progresso.ini");
for (var i = 0; i < total_fases; i++) {
    var _chave = "fase_" + string(i);
    fase_estrelas[i] = ini_read_real("estrelas", _chave, 0);
}
ini_close();
```

---

### Modificar `oSeletorDeFases/Draw_0.gml`

Dentro do loop de cards `for (var i = 0; i < total_fases; i++)`, **após** o bloco de borda do card e **antes** do `}` que fecha o loop, adicionar:

```gml
    // --- Estrelas abaixo do subtítulo (sprite sEstrela 16x16) ---
    var _estrelas_y = _info_y + 68;
    var _estrela_gap = 22;
    var _estrela_start = (_cx + card_w / 2) - _estrela_gap;

    for (var s = 0; s < 3; s++) {
        var _ex = _estrela_start + s * _estrela_gap;
        var _frame = (s < fase_estrelas[i]) ? 1 : 0;

        draw_sprite(sEstrela, _frame, _ex, _estrelas_y);
    }
```

---

## 🔧 Ajustando os Thresholds

Se achar que 3 estrelas está fácil ou difícil demais, ajuste os valores no `oVitoria/Create_0.gml`:

```gml
// Mais fácil (mais estrelas)
if (score >= 60) estrelas = 3;
else if (score >= 30) estrelas = 2;

// Mais difícil (menos estrelas)
if (score >= 80) estrelas = 3;
else if (score >= 50) estrelas = 2;
```

Também pode ajustar os **pesos** dos fatores:

```gml
// Priorizar vida
score = (_pct_fome * 0.3) + (_pct_vida * 0.5) + (_pct_comida * 0.2);

// Priorizar fome
score = (_pct_fome * 0.5) + (_pct_vida * 0.3) + (_pct_comida * 0.2);
```

---

## 🧪 Como Testar

1. Jogue uma fase e vença com vida e fome altas → deve dar 3 estrelas
2. Use os cheats de debug (R para tirar vida, U para tirar fome) e vença no limite → deve dar 1 estrela
3. Volte ao seletor — as estrelas devem aparecer no card da fase jogada
4. Feche e reabra o jogo — as estrelas devem estar salvas
5. Jogue a mesma fase e ganhe com nota pior — a pontuação salva NÃO deve ser substituída (só salva se for melhor)

---

## ⚠️ Cuidados

- **`global.fase_atual` precisa existir** — este guia depende do guia de desbloqueio de fases (`GUIA_DESBLOQUEIO_DE_FASES.md`) que define `global.fase_atual`
- **Stats antes do room_goto** — os globals de resultado DEVEM ser setados antes de `room_goto(rm_Vitoria)` no `oPlayer/Step_0.gml`, senão os valores ficam zerados
- **Comida sempre 100%** — atualmente o jogador precisa coletar toda a comida para vencer, então `pct_comida` é sempre 100%. Se mudar essa mecânica no futuro, o sistema já suporta
- **Sprite `sEstrela`** — Deve ser criado no GameMaker com 16×16 pixels, 2 sub-imagens (frame 0 = vazia, frame 1 = completa), origin no centro (8, 8). Na tela de vitória usa `draw_sprite_ext` com scale 3× para ficar maior; no seletor usa tamanho original 1×

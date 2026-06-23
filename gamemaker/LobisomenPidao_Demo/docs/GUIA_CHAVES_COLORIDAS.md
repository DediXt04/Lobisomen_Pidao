# 🔑🔑 Guia de Implementação — Múltiplas Chaves Coloridas

> Guia para expandir a mecânica de chave/portão existente para suportar **N tipos de chave** (azul, vermelha, etc.), onde cada chave abre apenas a porta da cor correspondente. Sistema genérico que escala sem refatoração.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Tile size | 16×16 |
| Pré-requisito | `DONE_GUIA_CHAVE_E_PORTAO.md` (mecânica básica de 1 chave já implementada) |
| Backward-compat | Sim — `rm_fase03` (1 chave única) continua funcionando |
| Variável central | `global.chaves` (struct indexado por cor) |
| Object Variables | `oChave.cor`, `oPorta.cor` (string) |
| Helper novo | `scr_podeAtravessarPorta(x, y)` |
| HUD | Mantido como está (sprite da porta) — opcional adicionar depois |

---

## 🏗️ Visão Geral

### Como funciona

1. **`global.chaves`** — struct global que armazena quais chaves o player coletou: `{ "azul": true, "vermelho": false, ... }`
2. **Cada `oChave`** tem uma propriedade `cor` (string). Ao coletar, marca `global.chaves[$ cor] = true`.
3. **Cada `oPorta`** também tem propriedade `cor`. Ela só destranca se `global.chaves[$ cor]` for `true`.
4. **`scr_podeAtravessarPorta`** verifica se o player/NPC/inimigo pode passar por uma porta específica baseado na cor dela.
5. **Adicionar nova cor** = só criar/ajustar sprite + setar `cor` em novas instâncias no editor. Sem refatoração.

### Fluxo

```
Room carrega
  │
  ├─ oController/Create:
  │     global.chaves = {}    ← reseta tudo
  │     global.temChave = false  (compat)
  │
  ├─ oChave/Create (cada instância):
  │     cor já vem do editor (azul, vermelho, ...)
  │
  ├─ oPorta/Create (cada instância):
  │     cor já vem do editor
  │
  Gameplay:
  ├─ Player encosta + E numa oChave:
  │     global.chaves[$ this.cor] = true
  │     chave some
  │
  ├─ oPorta/Step (toda frame):
  │     se global.chaves[$ this.cor] → destrancada (sprite muda)
  │
  └─ Player/NPC/Inimigo se move:
        scr_podeAtravessarPorta(x+xspd, y) → bloqueia se cor != coletada
```

### Diagrama visual

```
┌────────────────────────────────────────────┐
│                                            │
│   🔵 (chave azul)        🟦 (porta azul)   │
│                          ↓                 │
│   🔴 (chave vermelha)    🟥 (porta vermelha)
│                          ↓                 │
│   P (player)             [área final]      │
│                                            │
└────────────────────────────────────────────┘
   ↑
   Player precisa coletar AS DUAS chaves
   (cada uma libera a porta da mesma cor)
```

---

## 🎨 Sprites Necessários

Você tem duas opções — escolha uma:

### Opção A — Sprites coloridos individuais (mais polido)

| Sprite | Conteúdo |
|---|---|
| `sChaveAzul` | 16×16, chave azul com glow opcional |
| `sChaveVermelha` | 16×16, chave vermelha |
| `sPortaTrancadaAzul` | Porta trancada com detalhes azuis |
| `sPortaDestrancadaAzul` | Porta aberta azul |
| `sPortaTrancadaVermelha` | Porta trancada com detalhes vermelhos |
| `sPortaDestrancadaVermelha` | Porta aberta vermelha |

**Prós:** visual mais polido, mais nítido em pixel art.
**Contras:** N tipos × 4 sprites por tipo = muita arte pra criar quando escalar.

### Opção B — `image_blend` (mais escalável)

Manter os sprites originais (`sChave`, `sPortaTrancada`, `sPortaDestrancada`) e **tintar** via código baseado em `cor`:

```gml
image_blend = scr_corPorNome(cor);  // c_blue, c_red, c_white, ...
```

**Prós:** 1 sprite cobre todas as cores; adicionar cor nova = só atualizar a função `scr_corPorNome`.
**Contras:** visual menos detalhado; pixel art tintada pode ficar estranha se o sprite original tem muitas cores.

> **Recomendação:** começar com B (rápido de testar), migrar pra A depois se quiser polir.

---

## 📜 Parte 1 — Helper Functions

### 1.1 `scr_corPorNome` (só se usar Opção B com image_blend)

`scripts/scr_corPorNome/scr_corPorNome.gml`:

```gml
// scr_corPorNome(_cor)
// Converte string de cor em valor de cor do GameMaker.
// Use pra tintar sprites via image_blend.

function scr_corPorNome(_cor) {
    switch (_cor) {
        case "azul":     return c_blue;
        case "vermelho": return c_red;
        case "amarelo":  return c_yellow;
        case "verde":    return c_lime;
        case "roxo":     return make_color_rgb(160, 80, 200);
        case "padrao":
        default:         return c_white;  // sem tint
    }
}
```

### 1.2 `scr_podeAtravessarPorta` (sempre necessário)

`scripts/scr_podeAtravessarPorta/scr_podeAtravessarPorta.gml`:

```gml
// scr_podeAtravessarPorta(_x, _y)
// Retorna true se a posição (_x, _y) não tem oPorta OU se o player
// já tem a chave da cor da porta nessa posição.

function scr_podeAtravessarPorta(_x, _y) {
    var _porta = instance_place(_x, _y, oPorta);
    if (_porta == noone) return true;  // sem porta no caminho

    if (!variable_global_exists("chaves")) return false;

    var _cor = _porta.cor;
    return variable_struct_exists(global.chaves, _cor)
        && global.chaves[$ _cor];
}
```

---

## 🔑 Parte 2 — Refatorar `oChave`

### 2.1 Adicionar Object Variable `cor`

No GameMaker, abra `oChave`:

1. Aba **Variables** (botão à direita do editor de objeto)
2. **Add** → nome: `cor`, tipo: `String`, valor default: `"padrao"`
3. Salvar

> Isso permite cada **instância** no Room Editor sobrescrever o valor (azul, vermelho, etc.) sem precisar de objetos filhos.

### 2.2 `oChave/Create_0.gml`

```gml
base_y = y;

// Garante que o struct de chaves existe (caso oController ainda não tenha rodado)
if (!variable_global_exists("chaves")) {
    global.chaves = {};
}
```

### 2.3 `oChave/Step_0.gml`

Modificar o bloco de coleta:

```gml
// Pausar
if (global.pausado) exit;

// Profundidade baseada em Y
depth = -bbox_bottom;

// Distância até o player
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

// Animação de flutuação
y = base_y + sin(current_time / 200) * 1.5;
depth = -y;

// Coleta
if (_dist < 16 && oController.interagir
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
{
    global.chaves[$ cor] = true;

    // Compat com sistema antigo (se a fase ainda usa global.temChave em algum lugar)
    if (cor == "padrao") global.temChave = true;

    instance_destroy();
}
```

### 2.4 `oChave/Draw_0.gml` (Opção B — image_blend)

Adicione o tint antes do `draw_self()`:

```gml
// Desenha o sprite da chave com tint baseado na cor
var _time = current_time / 1000;
var _glow_alpha = 0.15 + sin(_time * 4) * 0.15;
var _cor_glow = scr_corPorNome(cor);

draw_set_alpha(_glow_alpha);
draw_set_colour(_cor_glow);
draw_circle(x+1, y-1, 5, false);

draw_set_alpha(1);
draw_set_colour(c_white);

// Tinta o sprite da chave
image_blend = scr_corPorNome(cor);
draw_self();
image_blend = c_white;

// "?" amarelo quando perto
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);
if (_dist < 16)
{
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(_cor_glow);
    draw_text_transformed(x + 0.5, y - 20, "?", 0.35, 0.35, 0);
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
```

### 2.4 Alternativa (Opção A — sprite por cor)

Em vez de `image_blend`, trocar `sprite_index` no Create:

```gml
switch (cor) {
    case "azul":     sprite_index = sChaveAzul;     break;
    case "vermelho": sprite_index = sChaveVermelha; break;
    // ...
    default:         sprite_index = sChave;
}
```

---

## 🚪 Parte 3 — Refatorar `oPorta`

### 3.1 Adicionar Object Variable `cor`

Mesmo processo do `oChave`:
- Aba **Variables** → Add → `cor` / String / default `"padrao"`

### 3.2 `oPorta/Create_0.gml` (NOVO)

```gml
// Cor herda do Object Variable (definido no editor)
// Nada a fazer aqui — só garante que o Create existe
```

> Se preferir, pode pular esse arquivo (a property `cor` funciona sem Create event).

### 3.3 `oPorta/Step_0.gml`

```gml
// Pausar
if (global.pausado) exit;

// Profundidade baseada em Y
depth = -bbox_bottom;

// Verifica se a chave dessa cor foi coletada
var _destrancada = variable_global_exists("chaves")
                && variable_struct_exists(global.chaves, cor)
                && global.chaves[$ cor];

// Muda sprite
if (_destrancada) {
    sprite_index = sPortaDestrancada;  // ou por cor — ver 3.4
} else {
    sprite_index = sPortaTrancada;
}
```

### 3.4 `oPorta/Draw_0.gml` (NOVO — Opção B)

```gml
image_blend = scr_corPorNome(cor);
draw_self();
image_blend = c_white;
```

> Se for Opção A (sprites por cor), pule este arquivo e use `sprite_index` no Step (igual `oChave`).

---

## 🚶 Parte 4 — Atualizar Colisões

### 4.1 `oPlayer/Step_0.gml`

Substituir o bloco antigo:

```gml
// ANTES
if (!global.temChave) {
    if place_meeting(x + xspd, y, oPorta) xspd = 0;
    if place_meeting(x, y + yspd, oPorta) yspd = 0;
}
```

```gml
// DEPOIS
if (!scr_podeAtravessarPorta(x + xspd, y)) xspd = 0;
if (!scr_podeAtravessarPorta(x, y + yspd)) yspd = 0;
```

### 4.2 `oNpc/Step_0.gml`

Mesma substituição (procure os 2 blocos `if(!global.temChave)`):

```gml
// ANTES
if(!global.temChave){
    if place_meeting(x + xspd, y, oPorta)  { pixels_walked = 0; xspd = 0; }
}
// DEPOIS
if (!scr_podeAtravessarPorta(x + xspd, y)) { pixels_walked = 0; xspd = 0; }
```

Mesmo padrão para o bloco do `yspd`.

### 4.3 `oInimigo/Step_0.gml`

```gml
// ANTES
if(!global.temChave){
    if (place_meeting(x + xspd, y, oPorta)) xspd = 0;
}
// DEPOIS
if (!scr_podeAtravessarPorta(x + xspd, y)) xspd = 0;
```

Idem pra `yspd`.

---

## 🎛️ Parte 5 — Reset entre Fases (`oController`)

Em `objects/oController/Create_0.gml`, atualize o bloco da chave:

```gml
// ANTES
//chave
global.temChave = false;
```

```gml
// DEPOIS
//chaves coletadas (struct indexado por cor)
global.chaves   = {};      // reseta todas as cores
global.temChave = false;   // compat com código antigo
```

---

## 🏠 Parte 6 — Configurar uma Fase com 2 Chaves

No Room Editor, pra criar uma fase com chave azul + chave vermelha + 2 portas correspondentes:

1. **Arraste `oChave`** na room → painel direito **Variables** → editar instância:
   - `cor`: `"azul"`
2. **Arraste outra `oChave`** → `cor`: `"vermelho"`
3. **Arraste `oPorta`** bloqueando a área que a chave azul libera → `cor`: `"azul"`
4. **Arraste outra `oPorta`** bloqueando outra área → `cor`: `"vermelho"`
5. Posicione as chaves em áreas acessíveis e as portas em corredores que façam sentido com o level design.

> **Importante:** as aspas em volta de `"azul"` são necessárias — é uma string.

### Layout sugerido

```
┌────────────────────────────────────────────┐
│  ████████████████████████████████████████  │
│  ██   🔴       ████████   🔵          ██  │
│  ██   (chave  )████████   (chave  )    ██  │
│  ██   (vermelha)████████   (azul)      ██  │
│  ██████  ↓     ████████        ↓   ██████  │
│  ██    🟥 porta vermelha   🟦 porta azul ██│
│  ██    (libera lado A)     (libera lado B)██│
│  ██████████████████████████████████████████│
│  ██  P            [área final + saída]   ██│
│  ████████████████████████████████████████  │
└────────────────────────────────────────────┘
```

---

## 🖥️ Parte 7 — HUD (Opcional)

Hoje **não existe HUD de chave** — o único feedback é o sprite da porta mudar. Com várias chaves, isso pode ficar confuso. Adicione uma HUD simples no `oController/Draw_64.gml`:

```gml
// === HUD de chaves coletadas ===
if (variable_global_exists("chaves")) {
    var _icon_x = 20;
    var _icon_y = 60;
    var _icon_size = 32;
    var _gap = 8;

    // Itera sobre todas as cores no struct
    var _cores = variable_struct_get_names(global.chaves);

    for (var i = 0; i < array_length(_cores); i++) {
        var _cor = _cores[i];
        if (!global.chaves[$ _cor]) continue;  // só mostra coletadas

        var _cx = _icon_x + i * (_icon_size + _gap);

        // Tinta o ícone com a cor da chave
        draw_sprite_ext(sChave, 0, _cx, _icon_y, 2, 2, 0,
                        scr_corPorNome(_cor), 1);
    }

    draw_set_color(c_white);
}
```

Resultado: chaves coletadas aparecem como ícones tintados na HUD, lado a lado.

---

## ✅ Checklist Rápida

### Scripts
- [ ] `scr_podeAtravessarPorta` criado
- [ ] `scr_corPorNome` criado (se usar image_blend)

### Object Variables (adicionar via aba "Variables" no Object Editor)
- [ ] `oChave.cor` (String, default `"padrao"`)
- [ ] `oPorta.cor` (String, default `"padrao"`)

### Sprites (escolher opção A ou B)
- [ ] **A:** criar `sChaveAzul`, `sChaveVermelha`, `sPortaTrancadaAzul`, `sPortaDestrancadaAzul`, `sPortaTrancadaVermelha`, `sPortaDestrancadaVermelha`
- [ ] **B:** manter sprites atuais, usar `image_blend` no Draw

### Modificações em objetos
- [ ] `oChave/Create_0.gml` — inicializar struct global
- [ ] `oChave/Step_0.gml` — setar `global.chaves[$ cor] = true`
- [ ] `oChave/Draw_0.gml` — aplicar tint (opção B)
- [ ] `oPorta/Step_0.gml` — usar `global.chaves[$ cor]`
- [ ] `oPorta/Draw_0.gml` — aplicar tint (opção B)
- [ ] `oPlayer/Step_0.gml` — `scr_podeAtravessarPorta`
- [ ] `oNpc/Step_0.gml` — `scr_podeAtravessarPorta`
- [ ] `oInimigo/Step_0.gml` — `scr_podeAtravessarPorta`
- [ ] `oController/Create_0.gml` — `global.chaves = {}`

### Room (configurar uma fase de teste)
- [ ] Adicionar 2 `oChave` com cores diferentes
- [ ] Adicionar 2 `oPorta` correspondentes

### Testes
- [ ] Coletar chave azul → porta azul destranca (não a vermelha)
- [ ] Coletar chave vermelha → porta vermelha destranca
- [ ] Coletar ambas → ambas portas abertas
- [ ] Inimigo bloqueado por portas trancadas (qualquer cor)
- [ ] NPC bloqueado por portas trancadas
- [ ] `rm_fase03` continua funcionando (chave default sem cor)
- [ ] Resetar fase via pausa → struct zera, portas voltam a trancar

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Todas as portas abrem ao coletar 1 chave | Esqueceu de adicionar Object Variable `cor` no `oPorta` | Adicionar via aba Variables |
| Erro "variable global.chaves not set" | `oController/Create` não rodou ainda | Adicionar guard `if (!variable_global_exists("chaves")) global.chaves = {};` |
| Chave azul abre porta vermelha | Esqueceu de setar `cor` na instância da porta no editor | Abrir Properties da instância → setar `cor: "vermelho"` |
| `rm_fase03` quebrou | Default `cor = "padrao"` não foi setado nos Object Variables | Conferir aba Variables — default tem que ser `"padrao"` |
| Tint não aparece (opção B) | Esqueceu de chamar `image_blend` antes do `draw_self()` | Verificar Draw_0 das chaves/portas |
| HUD não mostra ícone correto | Ícone usa sprite original sem tint | Passar `scr_corPorNome(_cor)` no parâmetro de cor do `draw_sprite_ext` |
| Player atravessa porta sem chave | Esqueceu de substituir `place_meeting(oPorta)` por `scr_podeAtravessarPorta` em algum objeto | Conferir os 3 arquivos (player, NPC, inimigo) |
| Cor inválida não bloqueia nada | `instance_place` retorna `noone` se a posição está livre, mas se houver porta com cor desconhecida, o struct retorna false → bloqueia corretamente | Comportamento esperado |

---

## 📁 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `scripts/scr_podeAtravessarPorta/scr_podeAtravessarPorta.gml` | **NOVO** |
| `scripts/scr_corPorNome/scr_corPorNome.gml` | **NOVO** (opção B) |
| `objects/oChave/Create_0.gml` | **MODIFICAR** |
| `objects/oChave/Step_0.gml` | **MODIFICAR** |
| `objects/oChave/Draw_0.gml` | **MODIFICAR** (opção B) |
| `objects/oChave/oChave.yy` | **MODIFICAR** — adicionar property `cor` |
| `objects/oPorta/Create_0.gml` | **NOVO** (opcional) |
| `objects/oPorta/Step_0.gml` | **MODIFICAR** |
| `objects/oPorta/Draw_0.gml` | **NOVO** (opção B) |
| `objects/oPorta/oPorta.yy` | **MODIFICAR** — adicionar property `cor` |
| `objects/oPlayer/Step_0.gml` | **MODIFICAR** — substituir colisão |
| `objects/oNpc/Step_0.gml` | **MODIFICAR** — substituir colisão |
| `objects/oInimigo/Step_0.gml` | **MODIFICAR** — substituir colisão |
| `objects/oController/Create_0.gml` | **MODIFICAR** — reset do struct |
| `objects/oController/Draw_64.gml` | **MODIFICAR** (opcional — HUD) |
| `sprites/sChaveAzul/`, `sChaveVermelha/`, `sPortaTrancada<Cor>/`, etc. | **NOVOS** (opção A) |

---

## 📝 Notas Finais

- **Backward-compat preservada:** instâncias antigas sem `cor` setada usam o default `"padrao"` e continuam funcionando como antes.
- **Escala pra N cores:** adicionar cor verde futuramente = só atualizar `scr_corPorNome` + setar `cor: "verde"` em novas instâncias. Zero refatoração.
- **Pode rodar em paralelo** com outras features (áudio, settings, etc.) — não tem dependência cruzada.
- **TODO pós-implementação:**
  - Atualizar `CONTEXTO_GAMEMAKER.md` com `global.chaves` e novo helper.
  - Atualizar `GUIA_CRIACAO_DE_FASES.md` mencionando como usar chaves coloridas.
  - Decidir se quer migrar `rm_fase03` pra usar `cor: "azul"` explicitamente em vez de `"padrao"` (cosmético).

---

> **Resumo:** este guia transforma o sistema atual de 1 chave em um sistema flexível de N chaves coloridas, mantendo total compatibilidade com a fase existente. A abstração via struct + property `cor` evita explosão de objetos (não precisa de `oChaveAzul`, `oChaveVermelha` separados) e permite que cada instância no editor configure sua própria cor sem mexer em código.

# 🛠️ Guia de Melhorias — Colisões e Campo de Visão do `oInimigo`

> Guia para corrigir 4 bugs no `oInimigo`: falta de colisão com outros inimigos, NPCs e portas, e campo de visão sem limite de distância.

---

## 📌 Problemas

| # | Problema | Causa Raiz |
|---|---|---|
| 1 | Inimigo não colide com ele mesmo | `Step_0` só checa `place_meeting` com `oWall` |
| 2 | Inimigo não colide com `oNpc` | Idem — falta `place_meeting` com `oNpc` |
| 3 | Inimigo não colide com `oSaida` | Idem — falta `place_meeting` com `oSaida` |
| 4 | Inimigo enxerga muito além do cone visual | `campo_visao()` recebe `_dist` mas **nunca usa** — não checa distância |

---

## 🏗️ Bug 1, 2, 3 — Colisões Faltando

### Contexto

O `oNpc` já implementa colisão com múltiplos objetos no seu `Step_0.gml`:

```gml
// oNpc/Step_0.gml — referência
if place_meeting(x + xspd, y, oWall)   { pixels_walked = 0; xspd = 0; }
if place_meeting(x + xspd, y, oPlayer) { pixels_walked = 0; xspd = 0; }
if place_meeting(x + xspd, y, oSaida)  { pixels_walked = 0; xspd = 0; }
```

Mas o `oInimigo/Step_0.gml` só checa `oWall`:

```gml
// oInimigo/Step_0.gml — código atual (INCOMPLETO)
// colisão X
if (place_meeting(x + xspd, y, oWall)) xspd = 0;

// colisão Y
if (place_meeting(x, y + yspd, oWall)) yspd = 0;
```

### Correção — `objects/oInimigo/Step_0.gml`

Substituir o bloco de colisão dentro da região `// MOVIMENTO` por:

```gml
// MOVIMENTO
#region
// colisão X
if (place_meeting(x + xspd, y, oWall))    xspd = 0;
if (place_meeting(x + xspd, y, oInimigo)) xspd = 0;
if (place_meeting(x + xspd, y, oNpc))     xspd = 0;
if (place_meeting(x + xspd, y, oSaida))   xspd = 0;

// colisão Y
if (place_meeting(x, y + yspd, oWall))    yspd = 0;
if (place_meeting(x, y + yspd, oInimigo)) yspd = 0;
if (place_meeting(x, y + yspd, oNpc))     yspd = 0;
if (place_meeting(x, y + yspd, oSaida))   yspd = 0;

// aplica movimento
x += xspd;
y += yspd;
#endregion
```

### O que mudou

| Antes | Depois |
|---|---|
| Só checa `oWall` | Checa `oWall` + `oInimigo` + `oNpc` + `oSaida` |
| Inimigos se sobrepõem | Inimigos bloqueiam uns aos outros |
| Inimigos atravessam NPCs | Inimigos param ao encontrar NPCs |
| Inimigos atravessam portas | Inimigos param ao encontrar portas |

### Notas Importantes

- `place_meeting(x + xspd, y, oInimigo)` funciona porque o GameMaker **ignora a própria instância** automaticamente — só detecta **outras** instâncias de `oInimigo` (e filhos como `oGuarda1`, `oFreddy`).
- Como `oGuarda1` e `oFreddy` herdam de `oInimigo`, checar `oInimigo` já cobre **todos os tipos de inimigo**.
- A ordem das checagens não afeta o resultado — cada uma zera `xspd`/`yspd` independentemente.

---

## 🏗️ Bug 4 — Campo de Visão Sem Limite de Distância

### Contexto

O `Draw_0.gml` desenha o cone de debug com `dist = 120`:

```gml
// oInimigo/Draw_0.gml
var dist = 120;
var ang = 60;
// ... desenha triângulo amarelo com esses valores
```

Mas a função `campo_visao` **recebe `_dist` e nunca usa**:

```gml
// oInimigo/Create_0.gml — código atual (BUG)
campo_visao = function(_dist, _angulo_visao)
{
    // direção atual
    var dir = point_direction(0, 0, xspd, yspd);

    // se parado, usa face
    if (xspd == 0 && yspd == 0)
    {
        switch(face)
        {
            case 0: dir = (image_xscale == 1) ? 0 : 180; break;
            case 1: dir = (image_xscale == 1) ? 315 : 225; break;
            case 2: dir = 270; break;
            case 3: dir = 90; break;
            case 4: dir = (image_xscale == 1) ? 45 : 135; break;
        }
    }

    // direção até o player
    var dir_player = point_direction(x, y, oPlayer.x, oPlayer.y);

    // diferença angular
    var diff = angle_difference(dir, dir_player);

    // dentro do cone?
    if (abs(diff) <= _angulo_visao / 2)
    {
        // verifica parede no caminho
        if (!collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
        {
            return true;  // ← RETORNA TRUE SEM CHECAR _dist!
        }
    }

    return false;
}
```

**Resultado:** O inimigo detecta o player a qualquer distância (até do outro lado do mapa), desde que esteja dentro do ângulo de 60° e sem paredes no caminho. O cone amarelo mostra 120px, mas a detecção real é **infinita**.

### Correção — `objects/oInimigo/Create_0.gml`

Adicionar **2 linhas** no início da função `campo_visao`, antes de qualquer outro cálculo:

```gml
campo_visao = function(_dist, _angulo_visao)
{
    // NOVO: checa distância primeiro
    var _dist_player = point_distance(x, y, oPlayer.x, oPlayer.y);
    if (_dist_player > _dist) return false;

    // direção atual (código existente — sem mudanças a partir daqui)
    var dir = point_direction(0, 0, xspd, yspd);

    // se parado, usa face
    if (xspd == 0 && yspd == 0)
    {
        switch(face)
        {
            case 0: dir = (image_xscale == 1) ? 0 : 180; break;
            case 1: dir = (image_xscale == 1) ? 315 : 225; break;
            case 2: dir = 270; break;
            case 3: dir = 90; break;
            case 4: dir = (image_xscale == 1) ? 45 : 135; break;
        }
    }

    // direção até o player
    var dir_player = point_direction(x, y, oPlayer.x, oPlayer.y);

    // diferença angular
    var diff = angle_difference(dir, dir_player);

    // dentro do cone?
    if (abs(diff) <= _angulo_visao / 2)
    {
        // verifica parede no caminho
        if (!collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
        {
            return true;
        }
    }

    return false;
}
```

### O que mudou

| Antes | Depois |
|---|---|
| `_dist` é ignorado | `_dist` limita a detecção |
| Detecção infinita | Detecção limitada a 120px (valor passado nas chamadas) |
| Cone debug não corresponde à detecção | Cone debug corresponde **exatamente** à detecção |

### Por que checar distância primeiro?

- `point_distance()` é muito mais leve que `collision_line()` e `angle_difference()`
- Se o player está longe, retorna `false` imediatamente sem cálculos extras
- Otimiza performance: o caso mais comum (player longe) sai mais rápido

---

## ✅ Checklist

### Colisões (oInimigo/Step_0.gml)
- [ ] Adicionar `place_meeting` com `oInimigo` no eixo X
- [ ] Adicionar `place_meeting` com `oInimigo` no eixo Y
- [ ] Adicionar `place_meeting` com `oNpc` no eixo X
- [ ] Adicionar `place_meeting` com `oNpc` no eixo Y
- [ ] Adicionar `place_meeting` com `oSaida` no eixo X
- [ ] Adicionar `place_meeting` com `oSaida` no eixo Y

### Campo de Visão (oInimigo/Create_0.gml)
- [ ] Adicionar `var _dist_player = point_distance(x, y, oPlayer.x, oPlayer.y);`
- [ ] Adicionar `if (_dist_player > _dist) return false;`

### Teste
- [ ] Dois inimigos lado a lado não se sobrepõem
- [ ] Inimigo para ao encontrar um NPC
- [ ] Inimigo para ao encontrar a porta (oSaida)
- [ ] Inimigo **NÃO** detecta o player além de 120px
- [ ] Inimigo **AINDA** detecta o player dentro de 120px e 60° de ângulo
- [ ] Cone de debug amarelo agora corresponde à distância real de detecção

---

## 📝 Resumo de Arquivos

| Arquivo | Ação | Linhas afetadas |
|---|---|---|
| `objects/oInimigo/Step_0.gml` | **MODIFICAR** | Região `// MOVIMENTO` (linhas 11–21) |
| `objects/oInimigo/Create_0.gml` | **MODIFICAR** | Início de `campo_visao()` (após linha 26) |

> **Nota:** Todas as mudanças são no `oInimigo` (objeto pai). Como `oGuarda1` e `oFreddy` herdam dele, as correções funcionam automaticamente em todos os tipos de inimigo.

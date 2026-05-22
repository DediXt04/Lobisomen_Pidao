# 🔍 Guia de Implementação — Estado de Investigação do Inimigo

> Guia para adicionar o estado de **investigação** ao `oInimigo`. Quando o guarda perde o player de vista durante a perseguição, ele vai até o **último ponto onde viu o player** e **olha ao redor** antes de voltar a patrulhar.

---

## 📌 Contexto

| Item | Valor Atual |
|---|---|
| Objeto base | `oInimigo` (pai de `oGuarda1` e `oFreddy`) |
| Estados atuais | `estado_parado` → `estado_passeando` → `estado_perseguindo` |
| Cone de visão | 120px distância, 60° ângulo |
| Timer de visão | `timer_see` = `room_speed * 2` (2 segundos de memória) |
| Problema | Ao perder o player, volta direto para `estado_parado` no lugar onde está |

---

## 🏗️ Estrutura Geral

### Estado atual (antes)

```
estado_parado ──(vê player)──► estado_perseguindo
     ▲                              │
     │                              │ (perde visão + timer_see = 0)
     │◄─────────────────────────────┘
     │
     │◄──(timer_estado = 0)── estado_passeando
     └──(chance 2%)──────────► estado_passeando
```

### Estado novo (depois)

```
estado_parado ──(vê player)──► estado_perseguindo
     ▲                              │
     │                              │ (perde visão + timer_see = 0)
     │                              ▼
     │                       estado_investigando
     │                         │         │
     │    (timer_investigar=0) │         │ (vê player!)
     │◄────────────────────────┘         │
     │                                   ▼
     │                          estado_perseguindo
     │
     │◄──(timer_estado = 0)── estado_passeando
     └──(chance 2%)──────────► estado_passeando
```

### Como funciona

1. O guarda está perseguindo o player (`estado_perseguindo`)
2. O player escapa do cone de visão → `timer_see` começa a diminuir
3. `timer_see` chega a 0 → guarda **salva a posição atual do player** em `ultimo_x` / `ultimo_y`
4. Muda para `estado_investigando`
5. O guarda **anda em linha reta** até `(ultimo_x, ultimo_y)`
6. Ao chegar perto (distância < 16px), **para e olha ao redor**
7. "Olhar ao redor" = a cada X frames, muda `face` para uma direção aleatória e checa `campo_visao()`
8. Se **vê o player** durante a investigação → volta a `estado_perseguindo`
9. Se o **timer de investigação** zera sem ver nada → volta a `estado_parado`

---

## 🛠️ Parte 1 — Variáveis Novas (oInimigo/Create_0.gml)

Adicionar **dentro da região `// VARIÁVEIS BÁSICAS`**, depois de `alt_visao = 1.5;`:

```gml
// investigação
ultimo_x = x;
ultimo_y = y;
timer_investigar = 0;
timer_girar = 0;
TEMPO_INVESTIGAR = room_speed * 4;   // 4 segundos olhando ao redor
TEMPO_GIRAR = room_speed * 0.6;      // gira a cabeça a cada 0.6 segundos
```

O bloco completo fica:

```gml
// VARIÁVEIS BÁSICAS
#region
vel = 1;
dano = 1;
flag_parado = false;
timer_see = room_speed * 2;

// movimento (igual player)
xspd = 0;
yspd = 0;

// estado
estado = undefined;
timer_estado = 0;

// visão
larg_visao = 80;
alt_visao = 1.5;

// investigação
ultimo_x = x;
ultimo_y = y;
timer_investigar = 0;
timer_girar = 0;
TEMPO_INVESTIGAR = room_speed * 4;
TEMPO_GIRAR = room_speed * 0.6;

// direção visual
xscale = 1;
#endregion
```

---

## 🛠️ Parte 2 — Novo Estado (oInimigo/Create_0.gml)

Adicionar a **nova função** dentro da região `// ESTADOS`, **depois** de `estado_perseguindo` e **antes** de `estado = estado_parado;`:

```gml
// INVESTIGANDO
estado_investigando = function()
{
    if (is_debug) image_blend = c_orange;

    // Se vê o player durante a investigação, volta a perseguir
    if (campo_visao(120, 60))
    {
        timer_see = room_speed * 2;
        estado = estado_perseguindo;
        exit;
    }

    // Calcular distância até o último ponto visto
    var _dist = point_distance(x, y, ultimo_x, ultimo_y);

    if (_dist > 16)
    {
        // FASE 1: Andando até o ponto
        flag_parado = false;

        var dir = point_direction(x, y, ultimo_x, ultimo_y);
        xspd = lengthdir_x(vel, dir);
        yspd = lengthdir_y(vel, dir);
    }
    else
    {
        // FASE 2: Chegou no ponto — olha ao redor
        xspd = 0;
        yspd = 0;
        flag_parado = true;

        // Timer de investigação
        timer_investigar--;

        if (timer_investigar <= 0)
        {
            // Acabou o tempo — não achou nada, volta ao normal
            flag_parado = false;
            estado = estado_parado;
            exit;
        }

        // Girar a cabeça periodicamente
        timer_girar--;

        if (timer_girar <= 0)
        {
            timer_girar = TEMPO_GIRAR;

            // Escolhe uma direção aleatória para olhar
            face = irandom(4);  // 0=lado, 1=diag-cima, 2=cima, 3=baixo, 4=diag-baixo

            // Alterna xscale aleatoriamente (olha pra esquerda ou direita)
            if (irandom(1) == 0) {
                image_xscale = 1;
            } else {
                image_xscale = -1;
            }
        }
    }
}
```

> **Cor debug laranja** (`c_orange`) diferencia visualmente dos outros estados: branco (parado), vermelho (passeando), magenta (perseguindo).

O trecho da região `// ESTADOS` fica assim:

```gml
// ESTADOS
#region
// PARADO
estado_parado = function()
{
    // ... (código existente, sem mudanças)
}

// PASSEANDO
estado_passeando = function()
{
    // ... (código existente, sem mudanças)
}

// PERSEGUINDO
estado_perseguindo = function()
{
    // ... (código MODIFICADO — ver Parte 3)
}

// INVESTIGANDO  ← NOVO
estado_investigando = function()
{
    // ... (código acima)
}

// estado inicial
estado = estado_parado;
#endregion
```

---

## 🛠️ Parte 3 — Modificar a Perseguição (oInimigo/Create_0.gml)

Modificar `estado_perseguindo` para **salvar a posição** e ir para `estado_investigando` em vez de `estado_parado`:

```gml
// ANTES (código atual):
estado_perseguindo = function()
{
    if (is_debug) image_blend = c_fuchsia;

    var dir = point_direction(x, y, oPlayer.x, oPlayer.y);

    xspd = lengthdir_x(vel, dir);
    yspd = lengthdir_y(vel, dir);

    timer_see--;

    // perdeu o player
    if (!campo_visao(120, 60) and timer_see <= 0)
    {
        estado = estado_parado;
    }

    if (campo_visao(120, 60)) timer_see = room_speed * 2;
}

// DEPOIS (modificado):
estado_perseguindo = function()
{
    if (is_debug) image_blend = c_fuchsia;

    var dir = point_direction(x, y, oPlayer.x, oPlayer.y);

    xspd = lengthdir_x(vel, dir);
    yspd = lengthdir_y(vel, dir);

    timer_see--;

    if (campo_visao(120, 60))
    {
        // Enquanto vê o player, atualiza a última posição conhecida
        timer_see = room_speed * 2;
        ultimo_x = oPlayer.x;
        ultimo_y = oPlayer.y;
    }

    // perdeu o player
    if (!campo_visao(120, 60) && timer_see <= 0)
    {
        // Em vez de parar, vai investigar o último ponto
        timer_investigar = TEMPO_INVESTIGAR;
        timer_girar = TEMPO_GIRAR;
        estado = estado_investigando;
    }
}
```

### O que mudou

| Antes | Depois |
|---|---|
| `timer_see = 0` → `estado_parado` | `timer_see = 0` → salva posição → `estado_investigando` |
| Não salva posição do player | Atualiza `ultimo_x/y` a cada frame que vê o player |
| — | Inicializa timers de investigação na transição |

> **Importante:** O `ultimo_x/y` é atualizado **continuamente** enquanto o guarda vê o player. Assim, quando perde a visão, o ponto salvo é o mais recente possível (não o primeiro ponto onde viu).

---

## 🛠️ Parte 4 — Indicador Visual no oGuarda1 (Opcional)

O `oGuarda1` já mostra um "!" vermelho quando vê o player. Podemos adicionar um **"?"** amarelo durante a investigação.

### Passo 4.1 — oGuarda1/Draw_0.gml (se existir) ou oGuarda1/Step_0.gml

Se o `oGuarda1` **não tem** um Draw event próprio, crie um:

**`objects/oGuarda1/Draw_0.gml`:**

```gml
// Herda o draw do pai (oInimigo — debug cone)
event_inherited();

// Indicador acima da cabeça
if (estado == estado_perseguindo)
{
    // "!" vermelho — perseguindo
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_red);
    draw_text_transformed(x + 0.5, y - 30, "!", 0.5, 0.5, 0);
}
else if (estado == estado_investigando)
{
    // "?" amarelo — investigando
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_yellow);
    draw_text_transformed(x + 0.5, y - 30, "?", 0.5, 0.5, 0);
}
```

> Se o `oGuarda1` já tem um Draw event com o "!", substitua a lógica pelo código acima que cobre ambos os estados.

> O `oFreddy` pode receber a mesma lógica (ajustar Y offset para `-45` conforme já usa).

---

## 🛠️ Parte 5 — Colisão com Paredes durante Investigação

O guarda anda em linha reta até `(ultimo_x, ultimo_y)`. Se houver uma parede no caminho, ele vai travar (mesma limitação da perseguição). Para mitigar:

### Opção A — Parar ao travar (simples)

Adicionar no `estado_investigando`, dentro do bloco `_dist > 16` (fase de andar):

```gml
if (_dist > 16)
{
    flag_parado = false;

    var dir = point_direction(x, y, ultimo_x, ultimo_y);
    xspd = lengthdir_x(vel, dir);
    yspd = lengthdir_y(vel, dir);

    // Se travou na parede, pula direto para olhar ao redor
    if (place_meeting(x + xspd, y, oWall) && place_meeting(x, y + yspd, oWall))
    {
        // Não consegue chegar — começa a investigar aqui mesmo
        ultimo_x = x;
        ultimo_y = y;
    }
}
```

> Essa é a opção mais simples. Se quiser pathfinding real, consulte o `mp_grid` do `oController` (requer um guia separado).

---

## ✅ Checklist Final

### Variáveis novas (oInimigo/Create_0.gml)
- [ ] Adicionar `ultimo_x = x;`
- [ ] Adicionar `ultimo_y = y;`
- [ ] Adicionar `timer_investigar = 0;`
- [ ] Adicionar `timer_girar = 0;`
- [ ] Adicionar `TEMPO_INVESTIGAR = room_speed * 4;`
- [ ] Adicionar `TEMPO_GIRAR = room_speed * 0.6;`

### Novo estado (oInimigo/Create_0.gml)
- [ ] Criar função `estado_investigando` (anda até ponto + olha ao redor)

### Modificar perseguição (oInimigo/Create_0.gml)
- [ ] Atualizar `ultimo_x/y` enquanto vê o player
- [ ] Mudar transição de `estado_parado` para `estado_investigando`
- [ ] Inicializar `timer_investigar` e `timer_girar` na transição

### Visual (oGuarda1/Draw_0.gml)
- [ ] Adicionar "?" amarelo acima da cabeça durante investigação
- [ ] (Opcional) Fazer o mesmo no `oFreddy`

### Teste
- [ ] Guarda persegue o player → player escapa do cone de visão
- [ ] Guarda continua andando até o último ponto onde viu o player
- [ ] Ao chegar no ponto, para e gira a cabeça (muda face aleatoriamente)
- [ ] Se o player reaparece no cone → guarda volta a perseguir
- [ ] Após 4 segundos sem ver nada → guarda volta ao estado parado
- [ ] "!" vermelho aparece durante perseguição
- [ ] "?" amarelo aparece durante investigação
- [ ] Guarda não trava infinitamente se parede bloqueia o caminho

---

## 📝 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `objects/oInimigo/Create_0.gml` | **MODIFICAR** — novas variáveis + `estado_investigando` + alterar `estado_perseguindo` |
| `objects/oGuarda1/Draw_0.gml` | **NOVO ou MODIFICAR** — indicador "?" durante investigação |
| `objects/oFreddy/Draw_0.gml` | **(Opcional)** — mesmo indicador "?" |

> **Nota:** Todas as mudanças são no `oInimigo` (objeto pai). Como `oGuarda1` e `oFreddy` herdam dele (`event_inherited()`), o novo estado funciona automaticamente em todos os tipos de inimigo.

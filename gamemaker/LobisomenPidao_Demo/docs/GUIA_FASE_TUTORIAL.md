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

Ensinar ao jogador as **6 mecânicas básicas** em ordem progressiva:

| # | Mecânica | O que o jogador aprende |
|---|---|---|
| 1 | **Movimento** | Andar com WASD / analógico |
| 2 | **Coleta de comida** | Chegar perto da comida e apertar interação para coletar |
| 3 | **Interação com NPC** | Pedir comida aos NPCs (probabilidade + paciência) |
| 4 | **Barra de fome** | Entender que o tempo de fome diminui e que precisa se apressar |
| 5 | **Inimigos** | Evitar ser visto pelo inimigo (stealth) |
| 6 | **Porta de saída** | Coletar toda a comida e entrar na saída para vencer |

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
  ├─ Room Creation Code → config fácil (comidaMax=3, tempoFomeMax=180)
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
       ├─ Zona 5: Player avista um inimigo → Trigger 5 ativa
       │     └─ Dica: "Cuidado com os guardas! Se eles te virem, vão te atacar!"
       │     └─ Player desvia do inimigo
       │
       └─ Zona 6: Player chega na saída → Trigger 6 ativa
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

## 📐 Parte 1 — Layout da Room (rm_tutorial)

### Passo 1.1 — Criar a Room

1. No Asset Browser: **Rooms → Create Room** → nome: `rm_tutorial`
2. **Tamanho da room:** `960×360` (maior na horizontal para um percurso linear)
3. Configurar Viewport 0 igual às outras fases (ver `GUIA_CRIACAO_DE_FASES.md`)
4. Criar as 4 layers obrigatórias: `instancias`, `tiles`, `colisoes`, `Background`

### Passo 1.2 — Design do Mapa (Linear)

O mapa deve ser um **percurso linear** da esquerda para a direita, dividido em zonas:

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌────┐  ┌─────┐  │
│  │  ZONA 1  │   │  ZONA 2  │   │  ZONA 3  │   │  ZONA 4  │   │Z.5 │  │ZONA6│  │
│  │          ├───┤          ├───┤          ├───┤          ├───┤    ├──┤     │  │
│  │ P (start)│   │ 🍔(comida)│   │ 👤(NPC)  │   │ (vazio)  │   │🛡️  │  │☆saída│  │
│  │  [T1]    │   │  [T2]    │   │  [T3]    │   │  [T4]    │   │[T5]│  │[T6] │  │
│  └─────────┘   └─────────┘   └─────────┘   └─────────┘   └────┘  └─────┘  │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

P = oPlayer (posição inicial)
T1-T6 = oTutorialTrigger (triggers invisíveis)
🍔 = comida posicionada manualmente (oBurger)
👤 = oNpc posicionado manualmente
🛡️ = oGuarda1 posicionado manualmente
☆ = oSaida
```

> **Importante:** Na fase tutorial, **NÃO use o oSpawner**. Posicione comida, NPCs e inimigos **manualmente** para controlar a experiência. Isso garante que cada item esteja exatamente na zona certa.

### Passo 1.3 — Room Creation Code

```gml
// === CONFIG DA FASE TUTORIAL ===
global.comidaMax    = 3;     // meta baixa para tutorial
global.comidaSpawn  = 0;     // ZERO — não usa spawner, comida posicionada manualmente
global.npcSpawn     = 0;     // ZERO — NPC posicionado manualmente
global.tempoFomeMax = 180;   // 3 minutos — bem generoso para o tutorial

// Sem chave nesta fase
global.faseTemChave = false;
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
dica_textos[5] = "Cuidado com os guardas!\nSe eles te virem, vão te perseguir e atacar.\nTente passar sem ser visto!";
dica_textos[6] = "Colete toda a comida e a porta de saída vai abrir!\nEntre nela para completar a fase. Boa sorte!";

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
| `oSaida` | 1 | Zona 6 (extremo direito) | Porta de saída |
| `oSpawner` | 1 | Canto (com spawn=0, não faz nada) | Ou remova se não causar erro |

### Passo 4.2 — Objetos posicionados manualmente

| Objeto | Qtd | Zona | Notas |
|---|---|---|---|
| `oBurger` | 1 | Zona 2 | Comida no chão para o player coletar |
| `oNpc` | 1 | Zona 3 | NPC para o player interagir |
| `oBurger` ou `oPunk` | 1 | Zona 6 (perto da saída) | Última comida para completar a meta |
| `oGuarda1` | 1 | Zona 5 | Inimigo para o player desviar |

> **Conta da comida:** `comidaMax = 3`. O player coleta 1 na Zona 2, consegue 1 do NPC na Zona 3, e coleta 1 na Zona 6 = 3 total. Ajuste conforme necessário.

> **Dica:** Se o NPC recusar dar comida (probabilidade), coloque uma comida extra escondida perto da Zona 3 como "backup" para que o player não fique preso.

### Passo 4.3 — Posicionar os Triggers

Coloque **6 instâncias** de `oTutorialTrigger` na layer `instancias`, uma em cada zona:

1. **Redimensione** cada trigger para cobrir a entrada/passagem da zona
2. **Clique duplo** em cada instância e defina a **Creation Code**:

| Trigger | Zona | Creation Code |
|---|---|---|
| Trigger 1 | Entrada da Zona 1 (spawn do player) | `dica_id = 1;` |
| Trigger 2 | Entrada da Zona 2 (perto da comida) | `dica_id = 2;` |
| Trigger 3 | Entrada da Zona 3 (perto do NPC) | `dica_id = 3;` |
| Trigger 4 | Entrada da Zona 4 (corredor) | `dica_id = 4;` |
| Trigger 5 | Entrada da Zona 5 (antes do inimigo) | `dica_id = 5;` |
| Trigger 6 | Entrada da Zona 6 (perto da saída) | `dica_id = 6;` |

### Passo 4.4 — Colisões e Paredes

Na layer `colisoes`:
- Use `oWall` para criar **corredores** que guiam o player linearmente da esquerda para a direita
- Use `oSolidWall` nas bordas do mapa
- Crie **passagens estreitas** entre as zonas para que o player siga o caminho correto
- Na Zona 5 (inimigo), crie **obstáculos** que permitam ao player se esconder

```
Exemplo de layout da Zona 5 (stealth):

┌──────────────────────────┐
│  ████                    │
│  ████   ████   ████      │  ← Paredes para se esconder
│         ████   ████      │
│  [T5]          🛡️        │  ← Inimigo patrulhando
│         ████   ████      │
│  ████   ████             │
│  ████          ──────►   │  → saída para Zona 6
└──────────────────────────┘
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
  │   comidaMax=3, comidaSpawn=0, npcSpawn=0, tempoFomeMax=180
  │
  ├─ oController/Create → vida=6, tempoFome=180, cria grid
  │
  ├─ oTutorial/Create → carrega textos das 6 dicas
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
  │   │   └─ Dica: "Cuidado com os guardas!"
  │   │   └─ Player desvia do oGuarda1
  │   │
  │   └─ Player anda para Zona 6 → pisa no Trigger 6 → PAUSA
  │       └─ Dica: "Colete toda a comida e entre na porta!"
  │       └─ Player coleta última comida → global.comida = 3 → oSaida abre
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

Ao colocar `oBurger` ou `oPunk` manualmente na room, o `oController` pode não contar essas instâncias no `global.comidaMax` automaticamente. O importante é que o **Room Creation Code** defina `global.comidaMax = 3` e que existam exatamente 3 comidas coletáveis na fase (contando comida no chão + comida do NPC).

> **Atenção:** o `global.comida` começa em 0 e é incrementado pelo `oComida/Step` (quando o player coleta) e pelo `oNpc/Step` (quando o NPC dá comida). Garanta que as comidas posicionadas manualmente são filhos de `oComida` (ou seja, use `oBurger`/`oPunk`, não `oComida` direto).

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
  - [ ] `Create_0.gml` → inicializa dicas, textos, cores, função `mostrar_dica()`
  - [ ] `Step_0.gml` → fade-in, timer anti-skip, input para fechar dica
  - [ ] `Draw_64.gml` → desenha caixa de diálogo, texto da dica, "aperte E"

### Room `rm_tutorial`
- [ ] Room criada (960×360, viewport configurada)
- [ ] 4 layers: `instancias`, `tiles`, `colisoes`, `Background`
- [ ] Tilemap pintado (percurso linear com 6 zonas)
- [ ] Colisões posicionadas (corredores guiando o player)
- [ ] `oController` na layer `instancias`
- [ ] `oPlayer` na Zona 1
- [ ] `oTutorial` na layer `instancias`
- [ ] `oSaida` na Zona 6
- [ ] `oBurger` na Zona 2 (comida manual)
- [ ] `oNpc` na Zona 3 (NPC manual)
- [ ] `oBurger`/`oPunk` na Zona 6 (comida manual)
- [ ] `oGuarda1` na Zona 5 (inimigo manual)
- [ ] 6× `oTutorialTrigger` com `dica_id` correto (Creation Code de cada instância)
- [ ] Room Creation Code com config fácil

### Seletor de Fases
- [ ] `rm_tutorial` adicionada como primeira entrada nos 3 arrays do `oSeletorDeFases`

### Teste
- [ ] Player spawna na Zona 1 → Dica 1 aparece automaticamente
- [ ] Apertar E/Space/A fecha a dica e despausa o jogo
- [ ] Caminhar para cada zona ativa a dica correspondente
- [ ] Triggers só ativam uma vez (não repetem ao voltar)
- [ ] Comida manual é coletável normalmente
- [ ] NPC funciona normalmente (dá comida por interação)
- [ ] Inimigo patrulha e persegue o player na Zona 5
- [ ] Coletar 3 comidas abre a saída
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

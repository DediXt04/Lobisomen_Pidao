# 🔊🎵 Guia de Implementação — Áudio (Música + Efeitos Sonoros)

> Guia completo para adicionar **trilha sonora de fundo** (BGM) gerenciada por um objeto persistente, **efeitos sonoros** (SFX) inline nos eventos do jogo, e **controles de volume separados** para música e SFX na tela de Settings (com persistência em `.ini`).

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Engine | GameMaker (GML) |
| Pasta de assets | `sounds/` (criada automaticamente ao criar o primeiro som) |
| Audio Groups | `agBgm` (música) e `agSfx` (efeitos) |
| Prefixos | `mus_` para música, `snd_` para efeitos |
| Persistência | `save_progresso.ini` seção `[audio]` |
| Volumes default | `global.volumeBgm = 0.7`, `global.volumeSfx = 0.7` |
| Objeto persistente novo | `oMusicManager` (em `rm_MenuPrincipal`, marcado Persistent) |
| Dependência | Tela `oSettings` criada pelo `GUIA_VITORIA_E_SETTINGS.md` |

---

## 🏗️ Visão Geral

### Como funciona

1. **`oMusicManager`** — objeto persistente que vive desde o `rm_MenuPrincipal`; toca a música apropriada para cada room e **não reinicia** se a próxima room usa a mesma faixa (ex: Menu → Seleção de Fases).
2. **SFX inline** — chamadas diretas a `audio_play_sound(snd_X, 1, false)` nos eventos que disparam o som. A guard clause `if (global.pausado) exit;` que já existe na maioria dos Steps de gameplay garante que o som não toque durante pausa.
3. **Audio Groups** — `agBgm` e `agSfx` permitem ajustar o volume de música e efeitos **separadamente** via `audio_group_set_gain`.
4. **Persistência** — volumes salvos no mesmo `save_progresso.ini` já usado pelo desbloqueio de fases, em uma nova seção `[audio]`.
5. **Tela de Settings** — estende o `oSettings` planejado no `GUIA_VITORIA_E_SETTINGS.md` com 2 controles de volume em estilo step bar (10 quadradinhos pixel art).

### Diagrama de fluxo

```
┌───────────────────────────────────────────────────────────┐
│  Jogo inicia                                              │
│       │                                                   │
│       ▼                                                   │
│  oProcuraControle/Create (persistente, em rm_MenuPrincipal)│
│       ├─ carrega global.volumeBgm e global.volumeSfx do ini│
│       └─ audio_group_set_gain(agBgm, volumeBgm, 0)        │
│         audio_group_set_gain(agSfx, volumeSfx, 0)         │
│                                                           │
│  oMusicManager/Create (persistente, em rm_MenuPrincipal)  │
│       └─ toca mus_menu_principal                          │
│                                                           │
│  Jogador navega entre rooms ──────────────────────────────│
│       └─ oMusicManager/Step                               │
│           ├─ detecta a room atual                         │
│           ├─ se nova música != atual: troca               │
│           └─ se igual: NÃO faz nada (continua tocando)    │
│                                                           │
│  Durante gameplay:                                        │
│       SFX inline disparam em eventos:                     │
│         - pegar comida → snd_pegarComida                  │
│         - tomar dano   → snd_dano                         │
│         - inimigo vê o player → snd_alerta                │
│         - etc.                                            │
│                                                           │
│  Jogador abre Settings:                                   │
│       └─ ajusta sliders → audio_group_set_gain em tempo   │
│           real → salva no ini ao sair                     │
└───────────────────────────────────────────────────────────┘
```

---

## 🎼 Parte 1 — Criar os Assets de Som

### 1.1 Lista completa de sons necessários

#### Músicas (BGM — Audio Group `agBgm`)

| Som | Onde toca | Características sugeridas |
|---|---|---|
| `mus_menu_principal` | `rm_MenuPrincipal` e `rm_Settings` | Calma, em loop |
| `mus_selecao_fases` | `rm_SelecaoDeFases` | Mais leve/anim, em loop |
| `mus_gameplay_01` | Fases (1 das 3 sorteada ao entrar em fase) | Tensa/stealth, em loop |
| `mus_gameplay_02` | Fases (idem) | Outra variação stealth |
| `mus_gameplay_03` | Fases (idem) | Outra variação stealth |
| `mus_vitoria` | `rm_Vitoria` | Curta, celebratória, em loop |
| `mus_gameover` | `rm_gameOver` | Sombria, em loop |

> **Como funciona o sorteio:** ao entrar em qualquer room de fase (`room_01`, `room_02`, `rm_fase03`, ...) o `oMusicManager` sorteia uma das 3 `mus_gameplay_*`. **Se o jogador morrer e reiniciar a fase, a mesma música continua tocando** (não troca). Só sorteia nova música quando o jogador volta ao menu, vence uma fase e entra na próxima, ou recomeça de outra room. Para adicionar mais músicas de gameplay no futuro, basta criar `mus_gameplay_04`, `_05` etc. e adicioná-las ao array `musicas_gameplay` no `oMusicManager/Create`.

#### Efeitos sonoros (SFX — Audio Group `agSfx`)

| Som | Disparado por |
|---|---|
| `snd_pegarComida` | Coletar comida (`oComida/Step`) |
| `snd_pegarChave` | Coletar chave (`oChave/Step`) |
| `snd_destrancar` | Portão destranca (`oPorta/Step`) |
| `snd_saidaAbriu` | Saída abre quando completa a meta (`oSaida/Step`) |
| `snd_dano` | Player toma dano (`oInimigo/Collision_oPlayer`) |
| `snd_alerta` | Inimigo percebe o player (`oInimigo/estado_passeando`) |
| `snd_morte` | Vida ou fome chega a 0 (`oController/Step`) |
| `snd_vitoria` | Player entra na saída aberta (`oPlayer/Step`) |
| `snd_pausa` | Pausar/despausar (`oController/Step`) |
| `snd_npcDeuComida` | NPC entrega comida (`oNpc/Step`) |
| `snd_npcRecusou` | NPC recusou educadamente (`oNpc/Step`) |
| `snd_npcSemPaciencia` | NPC sem paciência (`oNpc/Step`) |
| `snd_uiNav` | Mover seleção em menu |
| `snd_uiConfirma` | Confirmar opção em menu |
| `snd_uiCancel` | Cancelar/voltar em menu |

### 1.2 Como criar cada som no GameMaker

Para cada som da lista:

1. Coloque o arquivo `.wav` ou `.ogg` em uma pasta local.
2. No Asset Browser, **Sounds** → clique direito → **Create Sound**.
3. Nomeie exatamente como na tabela (ex: `mus_menu_principal`).
4. Em **File**, escolha o arquivo de áudio.
5. Em **Audio Group**, selecione `agBgm` (para músicas) ou `agSfx` (para efeitos).
6. **Conversion**: `Uncompressed` (para SFX curtos) ou `Compressed - Streamed` (para músicas longas, economiza RAM).
7. Salve.

> **Dica de licenciamento:** OpenGameArt, Freesound (CC0/CC-BY), itch.io são boas fontes de áudio gratuito. Para licenças CC-BY, crédite no `Resumo_Executivo` ou em algum `README`.

---

## 🎚️ Parte 2 — Audio Groups (volume separado)

### 2.1 Criar os Audio Groups

1. No Asset Browser, **AudioGroups** → clique direito → **Create AudioGroup**.
2. Crie dois:
   - `agBgm` (música)
   - `agSfx` (efeitos)
3. O `audiogroup_default` que já existe pode ficar para sons sem categoria.

### 2.2 Como volume separado funciona

O gain final de cada som é o **produto** de três fatores:

```
volume final = audio_master_gain × audio_group_gain × audio_play_sound(gain)
```

Como o jogo só usa `audio_group_set_gain`, ajustar `agBgm` afeta **apenas músicas** e `agSfx` afeta **apenas efeitos**.

### 2.3 Função para aplicar os volumes

Cria o script `scr_aplicarVolumes` (Asset Browser → Scripts → Create Script):

```gml
// scr_aplicarVolumes()
// Aplica os volumes globais aos audio groups. Chame ao iniciar e ao mudar o volume.

function scr_aplicarVolumes() {
    audio_group_set_gain(agBgm, global.volumeBgm, 0);
    audio_group_set_gain(agSfx, global.volumeSfx, 0);
}
```

---

## 🎵 Parte 3 — `oMusicManager` (Persistente)

Esse objeto vive desde `rm_MenuPrincipal` e troca de música automaticamente conforme a room.

### 3.1 Criar o objeto

Asset Browser → **Objects** → Create Object → nome `oMusicManager`, sem sprite, **Persistent: True**.

### 3.2 Eventos do `oMusicManager`

**`objects/oMusicManager/Create_0.gml`:**

```gml
musica_atual = noone;  // id da instância do som tocando
faixa_atual  = -1;     // asset id da música tocando

// Lista de músicas de gameplay (sorteadas aleatoriamente ao entrar numa fase)
musicas_gameplay = [
    mus_gameplay_01,
    mus_gameplay_02,
    mus_gameplay_03,
];

// Flag: se true, ao entrar em uma fase de gameplay, sortear nova música.
// Começa true (primeiro boot). Vira false ao sortear, vira true ao entrar em rm_Vitoria.
// Resultado: morrer + reiniciar → mantém música; vencer fase + ir pra próxima → sorteia nova.
proxima_fase_sortear_nova = true;
```

**`objects/oMusicManager/Step_0.gml`:**

```gml
// Decide qual faixa deve tocar baseado na room atual
var _alvo = -1;
var _eh_fase_de_gameplay = false;

switch (room) {
    case rm_MenuPrincipal:
        _alvo = mus_menu_principal;
        break;

    case rm_SelecaoDeFases:
        _alvo = mus_selecao_fases;
        break;

    case rm_Vitoria:
        _alvo = mus_vitoria;
        // Próxima fase deve sortear nova música
        proxima_fase_sortear_nova = true;
        break;

    case rm_gameOver:
        _alvo = mus_gameover;
        // Ao reiniciar a fase após morrer, manter a mesma música
        // (não setamos proxima_fase_sortear_nova = true aqui)
        break;

    default:
        // Qualquer outra room é considerada fase de gameplay
        _eh_fase_de_gameplay = true;
        break;
}

// Se já existe rm_Settings, adicione:
//   case rm_Settings: _alvo = mus_menu_principal; break;

// Lógica especial para fases de gameplay (com array de músicas)
if (_eh_fase_de_gameplay) {
    if (proxima_fase_sortear_nova) {
        _alvo = musicas_gameplay[irandom(array_length(musicas_gameplay) - 1)];
        proxima_fase_sortear_nova = false;
    } else {
        // Manter a música atual (caso de reinício após morte)
        // Se por algum motivo faixa_atual não é de gameplay, sortear de qualquer forma
        var _eh_gameplay_atual = false;
        for (var i = 0; i < array_length(musicas_gameplay); i++) {
            if (faixa_atual == musicas_gameplay[i]) {
                _eh_gameplay_atual = true;
                break;
            }
        }
        if (_eh_gameplay_atual) {
            _alvo = faixa_atual;
        } else {
            _alvo = musicas_gameplay[irandom(array_length(musicas_gameplay) - 1)];
        }
    }
}

// Só troca se a faixa for diferente da atual
if (_alvo != faixa_atual) {
    if (musica_atual != noone && audio_is_playing(musica_atual)) {
        audio_stop_sound(musica_atual);
    }
    musica_atual = audio_play_sound(_alvo, 5, true);  // priority 5, loop true
    faixa_atual  = _alvo;
}
```

> **Por que duas variáveis (flag + array)?**
> - O **array** `musicas_gameplay` permite adicionar/remover músicas sem mexer no código (só edita o array).
> - A **flag** `proxima_fase_sortear_nova` decide se sorteia ou mantém a atual. Ela vira `true` em `rm_Vitoria` (para a próxima fase ter música nova) e fica `false` em `rm_gameOver` (para reiniciar a fase manter a música).

### 3.3 Colocar no Room Editor

1. Abra `rm_MenuPrincipal`.
2. Na layer `instancias` (ou crie uma nova layer chamada `Managers`), arraste `oMusicManager`.
3. Como é Persistent, ele continua existindo entre rooms.

> **Importante:** Coloque **apenas em `rm_MenuPrincipal`** — não duplique em outras rooms.

---

## 🔊 Parte 4 — SFX Inline (Patches por Arquivo)

Cada patch abaixo adiciona o som no exato evento que dispara o feedback. **Não precisa proteger com `if (!global.pausado)`** — todos esses eventos já têm `if (global.pausado) exit;` no topo do Step.

### 4.1 Coletar comida — `objects/oComida/Step_0.gml`

Localize o `instance_destroy()` e adicione **antes** dele:

```gml
if (_dist < 24 && oController.interagir
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
{
    with (oController)
    {
        global.comida += other.valor;
    }
    audio_play_sound(snd_pegarComida, 1, false);  // ← NOVO
    instance_destroy();
}
```

### 4.2 Coletar chave — `objects/oChave/Step_0.gml`

```gml
if (_dist < 16 && oController.interagir
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
{
    global.temChave = true;
    audio_play_sound(snd_pegarChave, 1, false);  // ← NOVO
    instance_destroy();
}
```

### 4.3 Interação com NPC — `objects/oNpc/Step_0.gml`

No bloco de interação, adicione um som para cada `reacao_frame`:

```gml
if (_dist < 32 && oController.interagir && cooldown <= 0
 && !collision_line(_ncx, _ncy, _pcx, _pcy, oWall, false, true))
{
    // Sem paciência — reação 2
    if (paciencia <= 0) {
        reacao_frame = 2;
        reacao_timer = reacao_dur;
        audio_play_sound(snd_npcSemPaciencia, 1, false);  // ← NOVO

    } else {
        // Tem paciência — tenta dar comida
        if (irandom(99) <= chance_comida) {
            global.comida += valor_comida;
            reacao_frame = 0;   // deu comida
            paciencia = 0;
            audio_play_sound(snd_npcDeuComida, 1, false);  // ← NOVO
        } else {
            reacao_frame = 1;   // não deu nada
            audio_play_sound(snd_npcRecusou, 1, false);    // ← NOVO
        }

        reacao_timer   = reacao_dur;
        chance_comida += irandom_range(10, 15);
        chance_comida  = min(chance_comida, 100);
        paciencia--;
    }

    cooldown = cooldown_max;
}
```

### 4.4 Portão destrancar — `objects/oPorta/Step_0.gml`

O Step roda toda frame, então precisamos detectar a **borda** (frame em que `temChave` muda de false para true) com uma variável local.

Adicione no **Create_0** (criar se não existir):

```gml
chave_anterior = false;
```

E modifique o Step:

```gml
// Pausar
if (global.pausado) exit;

// Detecta borda: chave acabou de ser pega
if (global.temChave && !chave_anterior) {
    audio_play_sound(snd_destrancar, 1, false);
}
chave_anterior = global.temChave;

// Muda sprite baseado na chave
if (global.temChave) {
    sprite_index = sPortaDestrancada;
} else {
    sprite_index = sPortaTrancada;
}
```

### 4.5 Saída abre — `objects/oSaida/Step_0.gml`

Mesmo padrão de borda.

Adicione no **Create_0** (criar se não existir):

```gml
comida_cheia_anterior = false;
```

E modifique o Step:

```gml
//Pausar
if (global.pausado) exit;

// Detecta borda: completou a meta
if (global.comidaCheia && !comida_cheia_anterior) {
    audio_play_sound(snd_saidaAbriu, 1, false);
}
comida_cheia_anterior = global.comidaCheia;

// muda sprite
if (!global.comidaCheia) {
    sprite_index = sPortaFechada;
} else {
    sprite_index = sPortaAberta;
}
```

### 4.6 Player toma dano — `objects/oInimigo/Collision_oPlayer.gml`

```gml
//Calculo de dano
if (!oPlayer.invencivel){
    with (oController)
    {
        vida -= other.dano;
    }
    audio_play_sound(snd_dano, 1, false);  // ← NOVO
}


//Knockback
if (!oPlayer.invencivel)
{
    // ... (resto inalterado)
}
```

### 4.7 Inimigo percebe o player — `objects/oInimigo/Create_0.gml`

Modifique a função `estado_passeando` para tocar o alerta na borda de transição:

```gml
estado_passeando = function()
{
    if (is_debug) image_blend = c_white;

    // se ver o player
    if (campo_visao(120, 60))
    {
        audio_play_sound(snd_alerta, 5, false);  // ← NOVO (prioridade 5 para não ser cortado)
        estado = estado_perseguindo;
        exit;
    }

    // movimento aleatório
    timer++;
    if (timer >= timer_max) {
        timer = 0;
        scr_escolherDirecao();
    }
}
```

Faça o mesmo em `estado_investigando` (também transiciona para perseguir):

```gml
estado_investigando = function()
{
    if (is_debug) image_blend = c_orange;

    if (campo_visao(120, 60))
    {
        audio_play_sound(snd_alerta, 5, false);  // ← NOVO
        estado = estado_perseguindo;
        exit;
    }
    // ... (resto inalterado)
}
```

### 4.8 Pausa, morte e vitória — `objects/oController/Step_0.gml`

**Toggle de pausa:**

```gml
if (keyboard_check_pressed(vk_escape) || _gpStart) {
    global.pausado = !global.pausado;
    pause_selecionado = 0;
    pause_nav_cooldown = 0;
    audio_play_sound(snd_pausa, 1, false);  // ← NOVO
}
```

**Game over (dano):**

```gml
if (vida <= 0) {
    global.motivoMorte = "dano";
    audio_play_sound(snd_morte, 1, false);  // ← NOVO
    room_goto(rm_gameOver);
}
```

**Game over (fome):**

```gml
if (tempoFome <= 0) {
    global.motivoMorte = "fome";
    audio_play_sound(snd_morte, 1, false);  // ← NOVO
    room_goto(rm_gameOver);
}
```

### 4.9 Vitória — `objects/oPlayer/Step_0.gml`

No bloco de colisão com `oSaida`:

```gml
//colisao com oSaida
if place_meeting(x + xspd, y, oSaida)
{
    if global.comidaCheia
    {
        audio_play_sound(snd_vitoria, 5, false);  // ← NOVO
        room_goto(rm_Vitoria)
    }
    xspd = 0;
}
if place_meeting(x, y + yspd, oSaida)
{
    if global.comidaCheia
    {
        audio_play_sound(snd_vitoria, 5, false);  // ← NOVO
        room_goto(rm_Vitoria)
    }
    yspd = 0;
}
```

### 4.10 Sons de UI (menus)

Padrão a aplicar em **todos** os Steps de menu (`oMenuPrincipal`, `oSeletorDeFases`, `oVitoria`, `oGameOver`, `oSettings`, e o menu de pausa dentro de `oController`):

**Sempre que a seleção muda** — adicione logo após o `clamp`/atualização do índice:

```gml
if (_nav != 0) {
    // ... lógica de mudar seleção que já existe ...
    audio_play_sound(snd_uiNav, 1, false);
}
```

**Sempre que confirma** — dentro do `if (_confirmar)`:

```gml
if (_confirmar) {
    audio_play_sound(snd_uiConfirma, 1, false);
    // ... resto da lógica
}
```

**Sempre que cancela/volta** (no `oSeletorDeFases` e `oSettings`):

```gml
if (voltar) {
    audio_play_sound(snd_uiCancel, 1, false);
    room_goto(rm_MenuPrincipal);
}
```

> **Atenção no menu de pausa (`oController/Step`):** o controle aceita W/S em vez de A/D — aplique o som na mesma linha onde `_nav` muda (linhas 19-22 e 23-30 da função do menu pausado).

---

## 💾 Parte 5 — Persistência dos Volumes

### 5.1 Carregar volumes no `oProcuraControle/Create_0.gml`

`oProcuraControle` já é persistente e roda no `rm_MenuPrincipal` antes de qualquer outra coisa — perfeito para inicializar os volumes globais.

Abra `objects/oProcuraControle/Create_0.gml` e adicione no final:

```gml
// === ÁUDIO ===
// Carrega volumes do arquivo de save
ini_open("save_progresso.ini");
global.volumeBgm = ini_read_real("audio", "bgm", 0.7);
global.volumeSfx = ini_read_real("audio", "sfx", 0.7);
ini_close();

// Aplica aos audio groups
scr_aplicarVolumes();
```

### 5.2 Salvar volumes (chamado pela tela Settings ao sair)

Cria o script `scr_salvarVolumes`:

```gml
// scr_salvarVolumes()
// Salva os volumes atuais no save_progresso.ini

function scr_salvarVolumes() {
    ini_open("save_progresso.ini");
    ini_write_real("audio", "bgm", global.volumeBgm);
    ini_write_real("audio", "sfx", global.volumeSfx);
    ini_close();
}
```

---

## 🎛️ Parte 6 — Controles de Volume na Tela Settings

> **Pré-requisito:** o `oSettings` deve ter sido criado seguindo o `GUIA_VITORIA_E_SETTINGS.md` (com botões "Resetar Progresso" e "Voltar"). Esta parte **estende** o que aquele guia criou.

### 6.1 Layout final da tela Settings

```
┌──────────────────────────────────────────────────────┐
│                                                      │
│                        SETTINGS                      │
│                                                      │
│           Volume Música                              │
│           ▌▌▌▌▌▌▌░░░  70%                            │
│                                                      │
│           Volume SFX                                 │
│           ▌▌▌▌▌▌▌░░░  70%                            │
│                                                      │
│           ┌──────────────────────┐                   │
│           │  Resetar Progresso   │                   │
│           └──────────────────────┘                   │
│           ┌──────────────────────┐                   │
│           │      Voltar          │                   │
│           └──────────────────────┘                   │
│                                                      │
│   W S navegar    A D ajustar volume    SPACE confirmar│
│                                       ESC para voltar│
└──────────────────────────────────────────────────────┘
```

### 6.2 Modificações no `oSettings/Create_0.gml`

Substitua o array de opções para incluir os volumes no topo:

```gml
// Lista de opções (índice 0..3)
opcoes = ["Volume Música", "Volume SFX", "Resetar Progresso", "Voltar"];
total_opcoes = array_length(opcoes);
opcao_focada = 0;

// Quais opções são "sliders" (mudam com A/D)
opcao_eh_slider = [true, true, false, false];

// Resto da inicialização (cooldown de navegação, confirmação de reset, etc.)
// — manter o que o GUIA_VITORIA_E_SETTINGS.md já criou
```

### 6.3 Modificações no `oSettings/Step_0.gml`

Adicione o ajuste horizontal de volume — **antes** da lógica de confirmação:

```gml
// === AJUSTE DE VOLUME (A/D ou D-pad horizontal) ===
if (opcao_eh_slider[opcao_focada]) {

    var _dir = 0;
    if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) _dir =  1;
    if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))  _dir = -1;

    if (_gp != undefined) {
        if (gamepad_button_check_pressed(_gp, gp_padr)) _dir =  1;
        if (gamepad_button_check_pressed(_gp, gp_padl)) _dir = -1;
    }

    if (_dir != 0) {
        if (opcao_focada == 0) {
            global.volumeBgm = clamp(global.volumeBgm + _dir * 0.1, 0, 1);
        } else if (opcao_focada == 1) {
            global.volumeSfx = clamp(global.volumeSfx + _dir * 0.1, 0, 1);
        }

        scr_aplicarVolumes();
        audio_play_sound(snd_uiNav, 1, false);
    }
}
```

E quando o jogador sai (botão "Voltar" ou ESC), chamar `scr_salvarVolumes()` antes do `room_goto`:

```gml
if (voltar || (_confirmar && opcao_focada == 3)) {  // 3 = "Voltar"
    audio_play_sound(snd_uiCancel, 1, false);
    scr_salvarVolumes();  // ← NOVO: persiste antes de sair
    room_goto(rm_MenuPrincipal);
}
```

### 6.4 Modificações no `oSettings/Draw_0.gml` (ou Draw GUI)

Onde o guia base desenha os botões, troque para desenhar **sliders step** para os dois primeiros índices:

```gml
// Constantes da step bar
var _step_count = 10;          // 10 quadradinhos = 0% a 100%
var _step_w     = 30;          // largura de cada quadradinho
var _step_h     = 30;          // altura
var _step_gap   = 6;           // espaço entre quadradinhos
var _step_total_w = _step_count * _step_w + (_step_count - 1) * _step_gap;

// Cor base do projeto
var _navy = make_color_rgb(14, 14, 26);
var _teal = make_color_rgb(80, 200, 210);

// === Loop pelos botões/sliders ===
for (var i = 0; i < total_opcoes; i++) {

    var _y = base_y + i * espacamento;
    var _focado = (i == opcao_focada);

    if (opcao_eh_slider[i]) {
        // === DESENHA SLIDER STEP ===
        var _label = opcoes[i];
        var _valor = (i == 0) ? global.volumeBgm : global.volumeSfx;
        var _preenchidos = round(_valor * _step_count);

        // Label
        draw_set_font(fnt_pixel);
        draw_set_halign(fa_left);
        draw_set_colour(_focado ? _teal : c_white);
        draw_text(centro_x - _step_total_w / 2, _y - 40, _label);

        // Quadradinhos
        for (var s = 0; s < _step_count; s++) {
            var _sx = centro_x - _step_total_w / 2 + s * (_step_w + _step_gap);

            if (s < _preenchidos) {
                draw_set_colour(_teal);
                draw_rectangle(_sx, _y, _sx + _step_w, _y + _step_h, false);
            } else {
                draw_set_colour(_navy);
                draw_rectangle(_sx, _y, _sx + _step_w, _y + _step_h, false);
                draw_set_colour(_teal);
                draw_rectangle(_sx, _y, _sx + _step_w, _y + _step_h, true);
            }
        }

        // Porcentagem
        draw_set_halign(fa_left);
        draw_set_colour(c_white);
        draw_text(centro_x + _step_total_w / 2 + 16, _y + 4, string(round(_valor * 100)) + "%");

    } else {
        // === DESENHA BOTÃO NORMAL (Resetar Progresso, Voltar) ===
        // — manter o desenho que o GUIA_VITORIA_E_SETTINGS.md já fez
    }
}
```

> Ajuste `base_y`, `espacamento` e `centro_x` para encaixar nos seus valores reais do `Create`.

---

## 🔄 Fluxo Completo

```
Jogo inicia
  │
  ├─ rm_MenuPrincipal carrega
  │
  ├─ oProcuraControle/Create (persistente):
  │     - detecta gamepads
  │     - carrega global.volumeBgm e global.volumeSfx do save_progresso.ini
  │     - scr_aplicarVolumes() → audio_group_set_gain(agBgm/agSfx, ...)
  │
  ├─ oMusicManager/Create (persistente):
  │     - musica_atual = noone, faixa_atual = -1
  │     - musicas_gameplay = [mus_gameplay_01, _02, _03]
  │     - proxima_fase_sortear_nova = true
  │
  ├─ oMusicManager/Step (todo frame):
  │     - room atual = rm_MenuPrincipal → alvo = mus_menu_principal
  │     - faixa_atual (-1) != alvo → toca mus_menu_principal em loop
  │
  ├─ Jogador navega para rm_SelecaoDeFases
  │     - oMusicManager/Step: alvo = mus_selecao_fases
  │     - troca para mus_selecao_fases
  │
  ├─ Jogador entra em room_01 (fase de gameplay)
  │     - oMusicManager/Step: _eh_fase_de_gameplay = true
  │     - proxima_fase_sortear_nova = true → sorteia, ex: mus_gameplay_02
  │     - proxima_fase_sortear_nova = false (já sorteou)
  │
  ├─ GAMEPLAY:
  │     - oPlayer coleta comida → snd_pegarComida
  │     - oNpc dá comida → snd_npcDeuComida
  │     - oInimigo vê o player → snd_alerta + estado_perseguindo
  │     - oInimigo colide com player → snd_dano
  │     - player pausa → snd_pausa
  │     - player coleta toda comida → snd_saidaAbriu (borda)
  │     - player entra na saída → snd_vitoria → room_goto(rm_Vitoria)
  │
  ├─ rm_Vitoria
  │     - oMusicManager/Step: alvo = mus_vitoria → troca
  │     - proxima_fase_sortear_nova = true (próxima fase terá música nova)
  │
  ├─ Jogador clica "Próxima Fase" → room_02
  │     - oMusicManager/Step: _eh_fase_de_gameplay = true
  │     - proxima_fase_sortear_nova = true → sorteia outra, ex: mus_gameplay_01
  │
  ├─ Jogador morre em room_02 → rm_gameOver
  │     - oMusicManager/Step: alvo = mus_gameover → troca
  │     - proxima_fase_sortear_nova continua false (importante!)
  │
  ├─ Jogador clica "Reiniciar Fase" → volta pra room_02
  │     - oMusicManager/Step: _eh_fase_de_gameplay = true
  │     - proxima_fase_sortear_nova = false → mantém mus_gameplay_01
  │     - Como faixa_atual era mus_gameover, ele detecta que precisa
  │       trocar para algo de gameplay → reusa a última (faixa_atual era
  │       mus_gameplay_01 antes do gameover, mas mudou; o código de fallback
  │       sorteia novamente — ver nota abaixo)
  │
  └─ Jogador abre Settings:
        - alvo = mus_menu_principal (mesma do menu)
        - ajusta sliders → scr_aplicarVolumes (real-time)
        - sai com "Voltar" → scr_salvarVolumes() → escreve no .ini
```

> **Nota sobre reiniciar fase após gameover:** o `faixa_atual` muda pra `mus_gameover` durante a tela de game over, então ao voltar pra fase, o código detecta que `faixa_atual` não está mais no array `musicas_gameplay` e sorteia uma nova. Se quiser **garantir** que sempre toque a mesma música após reiniciar, adicione uma variável `ultima_musica_gameplay` no Create do `oMusicManager` que guarda a última escolhida e reusa em vez de re-sortear — fica como evolução opcional documentada no final do guia.

---

## ✅ Checklist Rápida

### Assets a criar
- [ ] 7 músicas: `mus_menu_principal`, `mus_selecao_fases`, `mus_gameplay_01`, `mus_gameplay_02`, `mus_gameplay_03`, `mus_vitoria`, `mus_gameover`
- [ ] 15 SFX: `snd_pegarComida`, `snd_pegarChave`, `snd_destrancar`, `snd_saidaAbriu`, `snd_dano`, `snd_alerta`, `snd_morte`, `snd_vitoria`, `snd_pausa`, `snd_npcDeuComida`, `snd_npcRecusou`, `snd_npcSemPaciencia`, `snd_uiNav`, `snd_uiConfirma`, `snd_uiCancel`
- [ ] 2 Audio Groups: `agBgm`, `agSfx`
- [ ] Atribuir cada som ao group correto

### Scripts a criar
- [ ] `scr_aplicarVolumes()` — aplica volumes aos groups
- [ ] `scr_salvarVolumes()` — escreve no .ini

### Objetos a criar
- [ ] `oMusicManager` (Persistent: True), com Create e Step
- [ ] Posicionar instância em `rm_MenuPrincipal`

### Objetos a modificar
- [ ] `oProcuraControle/Create` — carregar volumes do .ini
- [ ] `oComida/Step` — `snd_pegarComida`
- [ ] `oChave/Step` — `snd_pegarChave`
- [ ] `oNpc/Step` — `snd_npcDeuComida`, `snd_npcRecusou`, `snd_npcSemPaciencia`
- [ ] `oPorta/Create` + `Step` — variável `chave_anterior` + `snd_destrancar`
- [ ] `oSaida/Create` + `Step` — variável `comida_cheia_anterior` + `snd_saidaAbriu`
- [ ] `oInimigo/Collision_oPlayer` — `snd_dano`
- [ ] `oInimigo/Create` — `snd_alerta` nos estados passeando e investigando
- [ ] `oController/Step` — `snd_pausa`, `snd_morte` (dano), `snd_morte` (fome)
- [ ] `oPlayer/Step` — `snd_vitoria` antes de cada `room_goto(rm_Vitoria)`
- [ ] `oMenuPrincipal/Step` — sons de UI
- [ ] `oSeletorDeFases/Step` — sons de UI
- [ ] `oVitoria/Step` — sons de UI
- [ ] `oGameOver/Step` — sons de UI
- [ ] `oController/Step` (menu de pausa) — sons de UI

### Tela Settings (estender o `oSettings` do GUIA_VITORIA_E_SETTINGS.md)
- [ ] Adicionar "Volume Música" e "Volume SFX" no array de opções
- [ ] Adicionar array `opcao_eh_slider` para distinguir sliders de botões
- [ ] Lógica de ajuste horizontal (A/D, D-pad, em 10 steps de 10%)
- [ ] Chamar `scr_aplicarVolumes()` em tempo real ao mudar
- [ ] Chamar `scr_salvarVolumes()` ao sair (botão Voltar ou ESC)
- [ ] Desenho da step bar (10 quadradinhos pixel art)

### Testes
- [ ] Música toca no menu, continua na seleção de fases sem reiniciar
- [ ] Música muda ao entrar em fase de gameplay
- [ ] Música muda na vitória/game over
- [ ] Sons disparam nos eventos corretos (comida, dano, alerta, etc.)
- [ ] Pausa silencia SFX (não dispara mais sons de gameplay durante pausa)
- [ ] Slider de Volume Música altera só a música; Volume SFX altera só os efeitos
- [ ] Fechar e reabrir o jogo: volumes mantidos

---

## ⚠️ Erros Comuns

| Problema | Causa | Solução |
|---|---|---|
| Música reinicia ao trocar de room entre menus | `oMusicManager` não está marcado Persistent | Marcar Persistent: True no `.yy` |
| Música reinicia em todas as transições | Step do `oMusicManager` não compara `faixa_atual` antes de tocar | Garantir o `if (_alvo != faixa_atual)` |
| Música de gameplay troca toda vez que o jogador morre e reinicia | Não está controlando a flag `proxima_fase_sortear_nova` corretamente | Verificar que SÓ `rm_Vitoria` seta a flag pra `true`; `rm_gameOver` deve deixar como está |
| Mesma música de gameplay tocando em todas as fases seguidas | Flag `proxima_fase_sortear_nova` nunca volta pra true após sortear | Confirmar que `rm_Vitoria` seta a flag pra `true` |
| Música repete a mesma 2x seguidas ao avançar de fase | Random pode sortear a mesma | Opcional: filtrar `faixa_atual` da lista de candidatas antes de sortear (ver Notas Finais) |
| Som dispara várias vezes (loop) ao destrancar portão | Não verificou borda — Step roda toda frame | Usar variável `chave_anterior` (patch 4.4) |
| SFX continua durante pausa | O evento que dispara o som não tem `if (global.pausado) exit;` | Adicionar guard clause no topo do Step do objeto |
| Slider ajusta volume mas não persiste | Esqueceu de chamar `scr_salvarVolumes()` ao sair | Chamar antes de `room_goto(rm_MenuPrincipal)` no botão Voltar |
| Volume não muda em tempo real | Não chamou `scr_aplicarVolumes()` após mudar `global.volumeBgm`/`Sfx` | Chamar logo após atualizar a variável |
| Sons "abafados" mesmo no máximo | `audio_master_gain` foi setado em algum lugar | Não use `audio_master_gain` — use só `audio_group_set_gain` |
| Música cortada/distorcida no início | Conversão errada (Uncompressed para arquivo longo) | Mudar para `Compressed - Streamed` |
| `audio_play_sound` não toca nada | Som foi atribuído ao Audio Group errado e o gain está 0 | Verificar atribuição do som e os valores em `audio_group_set_gain` |
| Sons de UI em loop muito rápido | `_nav` continua não-zero por vários frames | Garantir cooldown de navegação ou usar `keyboard_check_pressed` (não `keyboard_check`) |

---

## 📁 Resumo de Arquivos

| Arquivo | Ação |
|---|---|
| `LobisomenPidao_Demo.yyp` | Adicionar `agBgm` e `agSfx` (criados via UI) |
| `sounds/mus_*` | **NOVO** — 7 músicas (`mus_menu_principal`, `mus_selecao_fases`, `mus_gameplay_01..03`, `mus_vitoria`, `mus_gameover`) |
| `sounds/snd_*` | **NOVO** — 15 SFX |
| `scripts/scr_aplicarVolumes/scr_aplicarVolumes.gml` | **NOVO** |
| `scripts/scr_salvarVolumes/scr_salvarVolumes.gml` | **NOVO** |
| `objects/oMusicManager/{Create_0,Step_0}.gml` + `.yy` | **NOVO** (Persistent) |
| `objects/oProcuraControle/Create_0.gml` | **MODIFICAR** — carregar volumes |
| `objects/oComida/Step_0.gml` | **MODIFICAR** — +`snd_pegarComida` |
| `objects/oChave/Step_0.gml` | **MODIFICAR** — +`snd_pegarChave` |
| `objects/oNpc/Step_0.gml` | **MODIFICAR** — +3 sons NPC |
| `objects/oPorta/{Create_0,Step_0}.gml` | **MODIFICAR** — borda + `snd_destrancar` |
| `objects/oSaida/{Create_0,Step_0}.gml` | **MODIFICAR** — borda + `snd_saidaAbriu` |
| `objects/oInimigo/Collision_oPlayer.gml` | **MODIFICAR** — +`snd_dano` |
| `objects/oInimigo/Create_0.gml` | **MODIFICAR** — +`snd_alerta` nos estados |
| `objects/oController/Step_0.gml` | **MODIFICAR** — +`snd_pausa`, +`snd_morte` x2 |
| `objects/oPlayer/Step_0.gml` | **MODIFICAR** — +`snd_vitoria` |
| `objects/oMenuPrincipal/Step_0.gml` | **MODIFICAR** — sons de UI |
| `objects/oSeletorDeFases/Step_0.gml` | **MODIFICAR** — sons de UI |
| `objects/oVitoria/Step_0.gml` | **MODIFICAR** — sons de UI |
| `objects/oGameOver/Step_0.gml` | **MODIFICAR** — sons de UI |
| `objects/oSettings/*` (criado pelo guia base) | **ESTENDER** — sliders + persistência |
| `save_progresso.ini` (runtime) | Nova seção `[audio]` com `bgm` e `sfx` |

---

> **Próximos passos sugeridos:** após implementar este guia, marcar "Adição de soundtrack e efeitos sonoros" como concluído no `TODO_LIST.md`, e atualizar `CONTEXTO_GAMEMAKER.md` adicionando `global.volumeBgm`, `global.volumeSfx` à tabela de variáveis globais e `oMusicManager` ao mapa de objetos.

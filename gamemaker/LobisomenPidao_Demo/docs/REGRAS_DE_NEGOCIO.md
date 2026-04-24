# 🐺 Regras de Negócio — Lobisomem Pidão

> Documentação completa das regras de negócio e mecânicas do jogo, extraídas do código-fonte do projeto GameMaker.

---

## 📌 1. Visão Geral do Jogo

**Lobisomem Pidão** é um jogo indie 2D top-down onde o jogador controla um lobisomem faminto que precisa explorar fases, pedir comida aos NPCs e escapar dos inimigos antes que a fome acabe ou que ele seja capturado.

**Gênero:** Gerenciamento de recursos + Stealth/Furtividade

**Objetivo principal:** Coletar **5 itens de comida** e alcançar a **porta de saída** para completar cada fase, evitando inimigos e administrando a fome.

---

## 🔄 2. Loop Principal de Gameplay

1. O jogador nasce com **6 pontos de vida** e **90 unidades de fome**
2. O jogador explora o mapa, desviando de inimigos
3. Interage com NPCs para pedir comida (chance aleatória com incremento)
4. Coleta itens de comida espalhados pelo mapa
5. Ao coletar **5/5 comidas**, a porta de saída é desbloqueada
6. O jogador deve alcançar a porta de saída para vencer

### Condições de Vitória

- Coletar **5 itens de comida** e alcançar a **porta de saída**

### Condições de Derrota

- **Vida chega a 0** — morte por dano de inimigo
- **Fome chega a 0** — morte por inanição

---

## 🗺️ 3. Fluxo de Telas

```
┌────────────────────────┐
│   rm_SelecaoDeFases    │  ← Tela inicial / Seleção de fases
│   (oSeletorDeFases)    │
└──────────┬─────────────┘
           │ Seleciona fase
           ▼
┌────────────────────────┐
│   room_01 / room_02    │  ← Gameplay
│   (oController)        │
└────┬──────────────┬────┘
     │              │
     │ Morreu       │ Coletou 5/5 + saiu
     ▼              ▼
┌──────────┐  ┌──────────┐
│rm_gameOver│  │rm_Vitoria│
│(oGameOver)│  │(oVitoria)│
└────┬──────┘  └────┬─────┘
     │              │
     └──────┬───────┘
            │ ENTER / Gamepad A
            ▼
   rm_SelecaoDeFases
   (volta ao início)
```

---

## ❤️ 4. Sistema de Vida

| Parâmetro | Valor |
|---|---|
| Vida máxima | **6 pontos** (3 corações cheios) |
| Dano por colisão com inimigo | **1 ponto** |
| Condição de game over | `vida ≤ 0` |

### Exibição na HUD

- Cada **coração** na HUD representa 2 pontos de vida
- Sprite `sVida` com 3 frames:
  - Frame 0 = coração vazio
  - Frame 1 = meio coração (1 ponto)
  - Frame 2 = coração cheio (2 pontos)
- Escala: **5.5x**
- Posição: canto superior esquerdo da tela

---

## 🍖 5. Sistema de Fome

| Parâmetro | Valor |
|---|---|
| Fome máxima | **90 unidades** |
| Decremento | Baseado em `delta_time / 1000000` (tempo real) |
| Condição de game over | `tempoFome ≤ 0` |
| Limiar do modo faminto | **≤ 25%** da fome máxima |

### Regras

- A fome diminui continuamente em **tempo real** (não depende de framerate)
- Quando a fome atinge **0**, o jogo acaba com motivo "fome"
- O valor é limitado (clamped) a no mínimo **0**

### Modo Faminto

Quando a fome cai para **≤ 25%** do máximo:

- O lobisomem **muda de aparência** (sprites "hungry")
- A velocidade de movimento **aumenta de 2.0 para 2.5** pixels/frame
- O efeito é revertido quando a fome volta acima de 25%

### Exibição na HUD

- Barra horizontal usando sprite `sFomeG`
- 9 frames de sprite para preenchimento parcial
- Escala: **5.5x**
- Posição: abaixo da barra de vida

---

## 🍕 6. Sistema de Coleta de Comida

| Parâmetro | Valor |
|---|---|
| Comida necessária para vencer | **5 itens** |
| Distância de coleta | **16 pixels** + tecla de interação |
| Valor por item | **1 unidade** |

### Regras

- Itens de comida (`oComida`) ficam espalhados pelo mapa
- O jogador deve estar a **≤ 16 pixels** de distância e pressionar a **tecla de interação** (E / Espaço / Gamepad A)
- Cada item coletado soma **+1** ao contador `global.comida`
- O item é destruído imediatamente após a coleta
- Quando `global.comida ≥ global.comidaMax` (5), a flag `global.comidaCheia` é ativada
- Não há cooldown na coleta de itens

### Animação dos Itens

- Itens flutuam verticalmente com uma onda senoidal
- Fórmula: `y = base_y + sin(current_time / 200) * 1.5`
- Período de oscilação: ~200ms

### Exibição na HUD

- Ícone de pizza (`sPizza`) + texto no formato **"X/5"**
- Posição: abaixo da barra de fome
- Fonte: `fnt_pixel`

---

## 🧑 7. Sistema de Interação com NPCs

| Parâmetro | Valor |
|---|---|
| Distância de interação | **32 pixels** |
| Paciência máxima | **5 tentativas** |
| Chance inicial de dar comida | **10%** |
| Incremento por tentativa falhada | **10–15%** (aleatório) |
| Chance máxima | **100%** |
| Cooldown entre interações | **120 frames** (~2 segundos) |
| Duração da reação visual | **90 frames** (~1.5 segundos) |

### Fluxo de Interação

1. O jogador se aproxima do NPC (distância < 32 px)
2. Pressiona a tecla de interação (E / Espaço / Gamepad A)
3. O sistema verifica:

```
SE paciência ≤ 0:
    → Exibe reação "sem paciência" (frame 2)
    → Nenhuma comida é dada
    → Sem cooldown

SE paciência > 0:
    → Rola chance: irandom(99) ≤ chance_comida
    
    SUCESSO:
        → Jogador recebe +1 comida
        → Exibe reação "deu comida" (frame 0)
    
    FALHA:
        → Nenhuma comida dada
        → Exibe reação "não deu" (frame 1)
    
    Em ambos os casos:
        → chance_comida += irandom_range(10, 15) [cap: 100%]
        → paciência--
        → Cooldown de 120 frames ativado
```

### Movimentação do NPC

- NPCs vagam aleatoriamente pelo mapa
- A cada **180 frames** (~3 segundos), escolhem nova direção
- Direção e distância aleatórias (16–64 pixels)
- Velocidade de movimento: **2 pixels/frame**
- NPCs colidem com paredes e com o jogador

### Sistema de Reações Visuais

| Frame do Sprite `sReacao` | Significado |
|---|---|
| 0 | Deu comida (feliz) |
| 1 | Não deu comida (neutro) |
| 2 | Sem paciência (irritado) |

- Reação exibida acima do NPC por **90 frames** (~1.5s)

---

## 👾 8. Sistema de Inimigos

| Parâmetro | Valor |
|---|---|
| Velocidade | **0.5 pixels/frame** |
| Dano por colisão | **1 ponto de vida** |
| Distância de visão | **120 pixels** |
| Ângulo do cone de visão | **60°** (total) |
| Knockback no jogador | **8 pixels** (direção oposta) |
| Invencibilidade pós-dano | **90 frames** (~1.5 segundos) |

### Máquina de Estados (IA)

O inimigo (`oInimigo`) possui **3 estados**:

#### Estado 1 — PARADO (Idle)

- O inimigo fica parado (`xspd = 0, yspd = 0`)
- Cor visual: **branca**
- A cada frame: **2% de chance** de começar a vagar
- Se detectar o jogador no campo de visão → transição para **PERSEGUINDO**

#### Estado 2 — PASSEANDO (Wandering)

- O inimigo vaga aleatoriamente
- Cor visual: **vermelha**
- Duração: **120 frames** (~2 segundos)
- A cada frame: **5% de chance** de mudar de direção
- Se detectar o jogador no campo de visão → transição para **PERSEGUINDO**
- Ao expirar o timer → retorna para **PARADO**

#### Estado 3 — PERSEGUINDO (Chasing)

- O inimigo se move diretamente em direção ao jogador
- Cor visual: **magenta**
- Velocidade de perseguição: **0.5 pixels/frame**
- Se perder o jogador de vista → retorna para **PARADO**

### Campo de Visão (Cone de Detecção)

```
Condições para detecção (TODAS devem ser verdadeiras):
1. Jogador está a ≤ 120 pixels de distância
2. Jogador está dentro do cone de 60° à frente do inimigo
3. Não há parede entre o inimigo e o jogador (collision_line)
```

### Colisão com o Jogador

```
SE jogador NÃO está invencível:
    → Aplica 1 de dano
    → Aplica knockback de 8 pixels (direção: inimigo → jogador)
    → Ativa invencibilidade de 90 frames no jogador

SE jogador ESTÁ invencível:
    → Colisão ignorada
```

### Knockback

- Direção: calculada com `point_direction(inimigo.x, inimigo.y, jogador.x, jogador.y)`
- Decaimento: `lerp(knock, 0, 0.2)` por frame (decaimento exponencial)
- Efeito visual: alpha do jogador flicker entre **0.2** e **1.0** durante invencibilidade

---

## 🐺 9. Sistema de Movimento do Jogador

| Parâmetro | Valor |
|---|---|
| Velocidade normal | **2 pixels/frame** |
| Velocidade faminto | **2.5 pixels/frame** |
| Deadzone do gamepad | **0.2** |
| Direções suportadas | 5 (direita, diagonal-cima, cima, baixo, diagonal-baixo) |
| Walk timer | **10 frames** (mantém animação após parar de andar) |

### Regras de Movimento

- Aceita input de **teclado** (WASD / setas) e **gamepad** (analógico esquerdo / D-pad)
- Movimentação diagonal calculada com `point_direction()`
- Velocidade limitada (clamped) entre 0 e 1 em cada eixo
- Colisão verificada **antes** do movimento (`place_meeting`)
- Jogador é bloqueado por `oWall` e `oNpc`

### Sprites Direcionais

O jogador possui **5 direções visuais** (variável `face`):

| Valor | Direção |
|---|---|
| 0 | Direita / Lado |
| 1 | Diagonal cima-direita |
| 2 | Cima |
| 3 | Baixo |
| 4 | Diagonal baixo-direita |

Cada direção possui versão **normal** e **faminta** (hungry).

---

## 🚪 10. Sistema de Saída

### Regras da Porta

- Quando o jogador **NÃO** coletou todas as comidas: porta exibe sprite `sPortaAberta`
- Quando o jogador **coletou 5/5** comidas: porta exibe sprite `sPortaFechada`
- A transição de fase ocorre no `oPlayer` ao colidir com a saída **com comida cheia**

### Seta Indicadora

- Quando `global.comidaCheia = true`, uma seta (`sSeta`) aparece sobre o jogador
- A seta aponta na direção da saída
- A seta flutua com onda senoidal: `sy += sin(current_time / 200) * 2`
- Distância da seta ao jogador: **32 pixels**

---

## 🎯 11. Seleção de Fases

| Parâmetro | Valor |
|---|---|
| Total de fases | **5** |
| Layout | Grid de **3 colunas** |
| Tamanho dos cards | **340 × 280 pixels** |
| Espaçamento | **40 pixels** |
| Deadzone de navegação | **0.5** |
| Cooldown de navegação | **18 frames** |

### Fases Disponíveis

| Índice | Room | Descrição |
|---|---|---|
| 0 | `room_01` | Fase 1 |
| 1 | `room_02` | Fase 2 |
| 2 | `room_01` | Fase 3 (repete room_01) |
| 3 | `room_02` | Fase 4 (repete room_02) |
| 4 | `rm_Vitoria` | Fase 5 (tela de vitória) |

### Regras de Navegação

- Navegação por **WASD / Setas / Gamepad D-pad / Analógico**
- Seleção limitada (clamped) às posições válidas do grid
- Confirmação: **ENTER / E / Gamepad A**
- Ao confirmar, `global.comida` é resetado para **0**
- O jogo transiciona para a room da fase selecionada

### Detecção de Modo de Input

- Sistema alterna automaticamente entre "teclado" e "controle"
- Qualquer botão do gamepad ativa o modo controle
- Qualquer tecla pressionada ativa o modo teclado

---

## 💀 12. Telas de Fim de Jogo

### Game Over (`oGameOver`)

| Motivo (`global.motivoMorte`) | Mensagem Exibida |
|---|---|
| `"dano"` | "Voce morreu por dano" |
| `"fome"` | "Voce morreu de fome" |
| outro | "Voce morreu" |

- Input para retornar: **ENTER** ou **Gamepad A**
- Retorna para `rm_SelecaoDeFases`
- Rodapé dinâmico mostra o método de input correto (teclado ou gamepad)

### Vitória (`oVitoria`)

- Exibe: **"VOCÊ VENCEU!"**
- Mensagem secundária: "Mim de papai"
- Mesmo sistema de input do Game Over
- Retorna para `rm_SelecaoDeFases`

---

## 🎮 13. Sistema de Input

### Teclado

| Ação | Teclas |
|---|---|
| Mover | **WASD** / Setas |
| Interagir | **E** / Espaço |
| Confirmar (menus) | **Enter** / E |
| Navegar (menus) | **WASD** / Setas |
| Debug: vida -1 | R |
| Debug: vida +1 | T |
| Debug: fome +15 | Y |
| Debug: fome -15 | U |
| Debug: comida +1 | I |
| Fullscreen | F11 |

### Gamepad

| Ação | Botão |
|---|---|
| Mover | Analógico esquerdo / D-pad |
| Interagir | **A** (gp_face1) |
| Confirmar (menus) | **A** (gp_face1) |
| Navegar (menus) | D-pad / Analógico |

### Detecção de Gamepad (`oProcuraControle`)

- Objeto **persistente** (sobrevive transições de room)
- Verifica gamepads 0–11 na inicialização
- Deadzone configurada em **0.2** para cada controle conectado
- Primeiro gamepad detectado é armazenado como `global.gamepad_main`
- Suporte a **hot-plug** (conexão/desconexão em tempo real)
- Previne duplicatas (auto-destrói se já existir uma instância)

---

## 🖥️ 14. HUD e Interface Visual

### Elementos da HUD (Draw GUI)

| Elemento | Sprite | Posição | Escala |
|---|---|---|---|
| Corações (vida) | `sVida` (3 frames) | Canto superior esquerdo | 5.5x |
| Barra de fome | `sFomeG` (9 frames) | Abaixo da vida | 5.5x |
| Contador de comida | `sPizza` + texto | Abaixo da fome | — |
| Seta da saída | `sSeta` | Sobre o jogador | — |

### Renderização

- HUD desenhada no evento **Draw GUI 64** (`oController`)
- Chamadas de scripts: `scr_drawVida()`, `scr_drawFome()`, `scr_drawComida()`
- Ordenação de profundidade (depth) baseada em posição Y: `depth = -y` ou `-bbox_bottom`

### Efeitos Visuais

| Efeito | Descrição |
|---|---|
| Invencibilidade | Alpha flicker entre 0.2 e 1.0 (aleatório) |
| Inimigo Parado | Cor: branca (`c_white`) |
| Inimigo Vagando | Cor: vermelha (`c_red`) |
| Inimigo Perseguindo | Cor: magenta (`c_fuchsia`) |
| Item flutuante | Onda senoidal vertical (amplitude 1.5px) |
| Seta da saída | Onda senoidal vertical (amplitude 2px) |

---

## 📊 15. Tabela Completa de Constantes

| Sistema | Parâmetro | Valor | Observação |
|---|---|---|---|
| **Jogador** | Velocidade base | 2 px/frame | Normal |
| | Velocidade faminto | 2.5 px/frame | Fome ≤ 25% |
| | Força do knockback | 8 px | Por colisão com inimigo |
| | Duração da invencibilidade | 90 frames | ~1.5s a 60fps |
| | Direções de sprite | 5 | 0–4 (com diagonais) |
| | Walk timer | 10 frames | Animação pós-input |
| **NPC** | Velocidade | 2 px/frame | Igual ao jogador |
| | Intervalo de mudança de direção | 180 frames | ~3 segundos |
| | Paciência máxima | 5 | Interações antes de recusar |
| | Chance inicial de comida | 10% | `irandom(99) <= 10` |
| | Incremento de chance | 10–15% | Aleatório por falha |
| | Chance máxima | 100% | Garantido neste ponto |
| | Distância de interação | 32 px | Para ativar interação |
| | Duração da reação | 90 frames | ~1.5 segundos |
| | Cooldown | 120 frames | Entre interações |
| | Distância de caminhada | 16–64 px | Aleatório por direção |
| **Inimigo** | Velocidade | 0.5 px/frame | Patrulha e perseguição |
| | Dano | 1 HP | Por colisão |
| | Distância de visão | 120 px | Alcance do cone |
| | Ângulo de visão | 60° | Abertura total do cone |
| | Duração do passeio | 120 frames | ~2 segundos |
| | Chance de vagar (idle) | 2% por frame | Do estado parado |
| | Chance de mudar direção | 5% por frame | Durante passeio |
| **Jogo** | Vida máxima | 6 | 3 corações cheios |
| | Fome máxima | 90 unidades | Tempo real via delta_time |
| | Comidas necessárias | 5 itens | Para desbloquear saída |
| | Deadzone (gameplay) | 0.2 | Sensibilidade de movimento |
| | Deadzone (menu) | 0.5 | Sensibilidade de navegação |
| | Cooldown de navegação | 18 frames | Entre inputs no menu |
| **Display** | Escala dos corações | 5.5x | Tamanho na HUD |
| | Escala da barra de fome | 5.5x | Tamanho na HUD |
| | Frames da barra de fome | 9 | Frames de animação |
| | Frames do coração | 3 | Vazio, meio, cheio |
| | Período de flutuação (comida) | 200ms | Ciclo da onda senoidal |
| | Distância da seta (saída) | 32 px | Do jogador |
| | Amplitude da seta | 2 px | Flutuação vertical |

---

## 🏗️ 16. Pathfinding e Colisão

### Grid de Pathfinding

- Tipo: `mp_grid` (nativo do GameMaker)
- Resolução: dimensões da room divididas por 4 (células de **4×4 pixels**)
- Obstáculos adicionados ao grid: `oWall`, `oSaida`

### Objetos de Colisão

| Objeto | Função |
|---|---|
| `oWall` | Parede sólida principal |
| `oSolidWall` | Parede sólida alternativa |
| `oParedeFina` | Parede fina/estreita |

### Sistema de Colisão

- Verificação **antes do movimento** com `place_meeting()`
- Verificação de linha de visão com `collision_line()` (inimigos)
- Sem amortecimento de velocidade entre colisões

---

> 📝 **Nota:** Esta documentação foi extraída diretamente do código-fonte GML do projeto. Constantes e valores podem ser alterados durante o desenvolvimento.

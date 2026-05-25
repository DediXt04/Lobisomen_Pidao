# Roteiro de Apresentação — Lobisomem Pidão (5 minutos)

## Contexto
- Apresentação acadêmica para professores no dia 29/06
- Foco em partes interessantes do código do jogo
- Duração: ~5 minutos

---

## ROTEIRO

### 🎬 ABERTURA (30s)

> "Bom dia! Somos a equipe do **Lobisomem Pidão** — um jogo indie 2D top-down de stealth e humor, feito no GameMaker. O jogador controla um lobisomem faminto que precisa pedir comida para NPCs e fugir dos guardas. Vamos mostrar os destaques técnicos do desenvolvimento."

---

### 🧠 1. MÁQUINA DE ESTADOS DO INIMIGO (1min)

> "O sistema mais complexo do jogo é a **IA dos guardas**. Usamos uma **máquina de estados** onde cada estado é uma função armazenada em variável:"

**Mostrar**: `oInimigo/Create_0.gml`

```gml
estado_parado = function() { ... }
estado_passeando = function() { ... }
estado_perseguindo = function() { ... }
estado = estado_parado;
```

> "No Step, basta chamar `estado()` — o GameMaker executa a função ativa. Isso é **polimorfismo sem herança**: trocar de comportamento é só reatribuir a variável. Escalável pra adicionar novos estados sem mexer em código existente."

---

### 👁️ 2. CONE DE VISÃO COM RAYCASTING (1min)

> "Os guardas não veem em 360° — eles têm um **campo de visão de 60° com alcance de 120px**. Usamos trigonometria e ray casting:"

**Mostrar**: `campo_visao()` function

```gml
var diff = angle_difference(dir, dir_player);
if (abs(diff) <= _angulo_visao / 2) {
    if (!collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true)) {
        return true;
    }
}
```

> "Primeiro verificamos se o jogador está dentro do **ângulo** do cone. Depois traçamos uma **linha de colisão** até o player — se bater em parede, o guarda não enxerga. É a mesma técnica usada em jogos como Hitman e Splinter Cell."

---

### 🎲 3. SISTEMA DE PACIÊNCIA DOS NPCs (1min)

> "A interação com NPCs usa **probabilidade escalante**. O NPC começa com 10% de chance de dar comida, e a cada tentativa a chance sobe 10-15% até estourar. Além disso, cada NPC tem um limite de paciência:"

**Mostrar**: `oNpc/Step_0.gml`

```gml
if (irandom(99) <= chance_comida) { ... }
chance_comida += irandom_range(10, 15);
paciencia--;
```

> "Isso cria uma tensão de **risco vs recompensa**: insistir pode dar comida, mas se a paciência acabar, o NPC não interage mais. É um padrão de game design inspirado em roguelikes."

---

### ⚡ 4. SPAWNER COM VALIDAÇÃO ROBUSTA (45s)

> "O sistema de spawn usa **configuração por fase** e validação em loop:"

**Mostrar**: `oSpawner/Alarm_0.gml`

```gml
// Até 200 tentativas para encontrar posição válida
// Checa 7 tipos de colisão (parede, saída, NPC, comida...)
// Usa collision_rectangle de 16px (não apenas ponto)
```

> "Cada room define quantos NPCs e comidas terá. O spawner tenta até 200 posições aleatórias dentro de zonas marcadas, verificando que não sobreponha nenhum objeto. É um **factory pattern com retry** — robusto e configurável."

---

### 🎯 5. DELTA TIME E KNOCKBACK (45s)

> "Dois detalhes de polimento: o timer de fome usa **delta_time** para ser independente de framerate:"

```gml
tempoFome -= delta_time / 1000000; // microsegundos → segundos
```

> "E o knockback ao levar dano usa **lerp** para desacelerar suavemente:"

```gml
knock_x = lerp(knock_x, 0, 0.2); // decai 20% por frame
```

> "Com isso temos um game feel responsivo e profissional."

---

### 🏁 ENCERRAMENTO (30s)

> "Resumindo: o projeto aplica **padrões de design** (state machine, factory), **matemática aplicada** (ângulos, vetores, raycasting), **algoritmos robustos** (spawn com retry), e **boas práticas** (delta_time, feedback visual). Tudo em GML, linguagem nativa do GameMaker. Obrigado!"

---

## DICAS DE APRESENTAÇÃO

- **Ter o GameMaker aberto** com o jogo rodando para demonstrar ao vivo
- **Mostrar o debug do cone de visão** (visual do Draw do oInimigo)
- Se sobrar tempo: mostrar o modo faminto (sprite muda + velocidade aumenta)
- Falar naturalmente — o texto acima é guia, não pra decorar

---

## RESUMO TÉCNICO (cola rápida)

| Padrão | Onde | Por que impressiona |
|---|---|---|
| State Machine | oInimigo | Design pattern sem boilerplate; IA escalável |
| Raycasting + Cone | oInimigo | Matemática aplicada (ângulos, vetores) |
| Probabilidade escalante | oNpc | Game design + algoritmo elegante |
| Factory + Retry | oSpawner | Robustez; configuração por fase |
| Delta Time | oController | Framerate independence; profissional |
| Lerp Knockback | oPlayer | Física suave; game feel |

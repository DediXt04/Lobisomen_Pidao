# 🎯 Guia de Implementação — Spawner Genérico + Configuração por Fase

> Guia completo para transformar o `oFoodSpawner` em um spawner genérico que cria comida e NPCs, com configuração por fase usando Room Creation Code.

---

## 📌 Contexto

| Item | Valor Atual | Problema |
|---|---|---|
| `global.comidaMax` | `5` (fixo no `oController`) | Todas as fases têm a mesma meta |
| Qtd de spawn | `global.comidaMax - 2` (fixo no spawner) | Não configurável por fase |
| NPCs | Colocados **manualmente** no room editor | Trabalhoso, não escala |
| Múltiplas zonas | Bug — só spawna na primeira zona | Ordem de criação no GameMaker |

---

## 🐛 Bug Conhecido — Múltiplas oSpawnZone

### Problema

Quando há mais de um `oSpawnZone` na room, o spawner só gera dentro da **primeira** zona.

### Causa

**Ordem de criação no GameMaker.** O `Create` de cada instância roda **imediatamente** quando ela é criada. Se o spawner é instanciado antes do segundo `oSpawnZone`:

```gml
var _num_zonas = instance_number(oSpawnZone);
// retorna 1 — só a primeira zona existe neste momento
```

`irandom(0)` sempre retorna `0` → todo spawn cai na zona de índice 0.

### Solução

Mover a lógica de spawn do `Create_0` para o `Alarm_0` com delay de **1 frame**. Isso garante que todas as instâncias da room já existem antes do spawn rodar.

```
ANTES (Create_0):
  Room começa → cria oSpawner → Create roda IMEDIATAMENTE
  → instance_number(oSpawnZone) = 1  ❌

DEPOIS (Alarm_0):
  Room começa → cria TODOS os objetos
  → 1 frame depois → Alarm_0 roda
  → instance_number(oSpawnZone) = 2  ✅
```

> O delay é imperceptível (~16ms a 60fps). O spawner se destrói logo após, igual antes.

Esta correção já está incluída no código abaixo.

---

## 🏗️ Parte 1 — Configuração por Fase (Room Creation Code)

Cada room de gameplay define seus próprios valores no **Room Creation Code**. Esse código roda **antes** dos Create events dos objetos — quando o `oController` e o spawner rodarem, os globals já existem.

### Passo 1.1 — Criar Room Creation Code para cada fase

No GameMaker, abra a room → no painel de propriedades → **Creation Code** (ícone de código da room).

**`rooms/room_01/RoomCreationCode.gml`:**

```gml
// === CONFIG DA FASE 1 ===
global.comidaMax   = 3;   // meta de comida para vencer a fase
global.comidaSpawn = 3;   // quantas comidas spawnar no mapa
global.npcSpawn    = 2;   // quantos NPCs spawnar
```

**`rooms/room_02/RoomCreationCode.gml`:**

```gml
// === CONFIG DA FASE 2 ===
global.comidaMax   = 5;
global.comidaSpawn = 5;
global.npcSpawn    = 3;
```

> Repita para cada room de gameplay, ajustando os valores.

### Passo 1.2 — Atualizar o `oController/Create_0.gml`

Remover o `global.comidaMax = 5` hardcoded e usar fallback:

```gml
// ANTES:
global.comida = 0;
global.comidaMax = 5;
global.comidaCheia = false;

// DEPOIS:
global.comida = 0;
if (!variable_global_exists("comidaMax"))   global.comidaMax   = 5;
if (!variable_global_exists("comidaSpawn")) global.comidaSpawn = 5;
if (!variable_global_exists("npcSpawn"))    global.npcSpawn    = 2;
global.comidaCheia = false;
```

> **Fallback** protege contra rodar a room direto pelo IDE sem passar pelo Room Creation Code.

### Ordem de Execução

```
Room carrega
  │
  ├─ 1. Room Creation Code roda ← globals setados aqui
  │
  ├─ 2. Instâncias criadas (Create events)
  │     ├─ oController/Create → lê global.comidaMax ✅
  │     └─ oSpawner/Create → alarm[0] = 1
  │
  └─ 3. Frame 1
        └─ oSpawner/Alarm_0 → lê global.comidaSpawn e global.npcSpawn ✅
```

---

## 🏗️ Parte 2 — Spawner Genérico (Comida + NPC)

### Passo 2.1 — Renomear o objeto (opcional)

No GameMaker, clique com botão direito no `oFoodSpawner` → **Rename** → `oSpawner`.

> Se preferir manter o nome `oFoodSpawner`, o código funciona igual.

### Passo 2.2 — Modificar o Create

**`objects/oSpawner/Create_0.gml`** — substituir todo o conteúdo por:

```gml
// Aguarda 1 frame para garantir que todos os oSpawnZone já existem na room
alarm[0] = 1;
```

### Passo 2.3 — Criar o evento Alarm 0

No GameMaker: `oSpawner` → **Add Event** → **Alarm** → **Alarm 0**.

**`objects/oSpawner/Alarm_0.gml`:**

```gml
// === CONFIGURAÇÃO ===
// Cada entrada: [quantidade, [tipos_aleatorios]]
var _config = [
    [global.comidaSpawn,  [oBurger, oPunk]],   // comida
    [global.npcSpawn,     [oNpc]],              // NPCs
];

var _tentativas_max = 200;
var _num_zonas = instance_number(oSpawnZone);

// Se não tem zonas, não spawna nada
if (_num_zonas == 0) {
    instance_destroy();
    exit;
}

// === SPAWN ===
for (var c = 0; c < array_length(_config); c++) {
    var _qtd   = _config[c][0];   // quantidade a spawnar
    var _tipos = _config[c][1];   // array de tipos aleatórios

    repeat (_qtd) {
        for (var _t = 0; _t < _tentativas_max; _t++) {
            // escolher uma zona aleatória
            var _zona = instance_find(oSpawnZone, irandom(_num_zonas - 1));

            // posição aleatória DENTRO da zona escolhida
            var _px = irandom_range(_zona.bbox_left, _zona.bbox_right);
            var _py = irandom_range(_zona.bbox_top, _zona.bbox_bottom);

            // verificar se a posição é válida
            if (!collision_point(_px, _py, oWall, false, true)
             && !collision_point(_px, _py, oSolidWall, false, true)
             && !collision_point(_px, _py, oParedeFina, false, true)
             && !collision_point(_px, _py, oSaida, false, true)
             && !collision_point(_px, _py, oComida, false, true)
             && !collision_point(_px, _py, oNpc, false, true)) {

                // escolher tipo aleatório
                var _tipo = _tipos[irandom(array_length(_tipos) - 1)];

                // criar a instância
                instance_create_layer(_px, _py, layer, _tipo);
                break;
            }
        }
    }
}

// o spawner já fez seu trabalho
instance_destroy();
```

### Passo 2.4 — Remover NPCs manuais das rooms

1. Abra cada room de gameplay
2. **Remova** todas as instâncias de `oNpc` colocadas manualmente
3. O spawner agora cria tudo

> **Dica:** Teste com os NPCs manuais ainda na room primeiro para confirmar que o spawner funciona. Depois remova.

---

## 📐 Como Funciona

### Fluxo Completo

```
Jogador seleciona Fase 2
  │ room_goto(room_02)
  ▼
room_02 carrega
  │
  ├─ Room Creation Code:
  │   global.comidaMax   = 5
  │   global.comidaSpawn = 5
  │   global.npcSpawn    = 3
  │
  ├─ oController/Create:
  │   lê global.comidaMax (meta = 5)
  │
  ├─ oSpawner/Create:
  │   alarm[0] = 1
  │
  └─ Frame 1 — oSpawner/Alarm_0:
      ├─ Spawna 5 comidas (oBurger ou oPunk aleatório)
      ├─ Spawna 3 NPCs
      └─ instance_destroy()
```

### Estrutura do Array `_config`

```gml
var _config = [
//   [quantidade,           [tipos aleatórios]    ]
    [global.comidaSpawn,    [oBurger, oPunk]      ],  // comida
    [global.npcSpawn,       [oNpc]                ],  // NPCs
];
```

Para adicionar mais categorias no futuro, basta expandir:

```gml
var _config = [
    [global.comidaSpawn,    [oBurger, oPunk, oDonut]],
    [global.npcSpawn,       [oNpc]                  ],
    [global.inimigoSpawn,   [oInimigo]              ],  // inimigos também!
];
```

### O que mudou em relação ao oFoodSpawner original

| Aspecto | Antes | Depois |
|---|---|---|
| Onde roda | `Create_0` | `Alarm_0` (fix múltiplas zonas) |
| O que spawna | Só comida | Comida + NPC (configurável) |
| Quantidade | `global.comidaMax - 2` (fixo) | `global.comidaSpawn` e `global.npcSpawn` (por fase) |
| Tipos | `[oBurger, oPunk]` (fixo) | Array configurável por categoria |
| Colisão extra | Não checa sobreposição | Checa `oComida` e `oNpc` para não sobrepor |
| Zonas | Bug com múltiplas | Fix com delay de 1 frame |

---

## ⚙️ Exemplos de Configuração por Fase

### Fase fácil (tutorial)

```gml
global.comidaMax   = 3;
global.comidaSpawn = 3;
global.npcSpawn    = 1;
```

### Fase média

```gml
global.comidaMax   = 5;
global.comidaSpawn = 5;
global.npcSpawn    = 3;
```

### Fase difícil (pouca comida no mapa, obriga interação com NPCs)

```gml
global.comidaMax   = 10;
global.comidaSpawn = 8;
global.npcSpawn    = 2;
```

### Fase caótica

```gml
global.comidaMax   = 7;
global.comidaSpawn = 10;  // mais comida que a meta — jogador escolhe
global.npcSpawn    = 6;
```

> `comidaSpawn` pode ser **maior ou menor** que `comidaMax`. Se menor, o jogador precisa de NPCs para conseguir comida extra.

---

## ⚠️ Observações

1. **Room Creation Code roda antes dos Creates** — Garantido pelo GameMaker. Os globals estarão prontos quando qualquer objeto tentar lê-los.

2. **Fallback no oController** — O `variable_global_exists` protege contra rodar a room direto pelo IDE sem ter os globals definidos.

3. **Colisão de spawn** — O spawner checa `oComida` e `oNpc` para evitar sobreposição. Para mais espaçamento, troque `collision_point` por `collision_circle` com raio:
   ```gml
   && !collision_circle(_px, _py, 24, oComida, false, true)
   && !collision_circle(_px, _py, 24, oNpc, false, true)
   ```

4. **Ordem de spawn** — Comida é spawnada primeiro, depois NPCs. Os NPCs não spawnam em cima da comida porque o check de `oComida` já vê as instâncias criadas anteriormente.

5. **Registrar Alarm_0 no .yy** — Se criar o Alarm pelo IDE (Add Event → Alarm → Alarm 0), o `.yy` é atualizado automaticamente. Se editar manualmente, adicione no `eventList`:
   ```json
   {"$GMEvent":"v1","%Name":"","collisionObjectId":null,"eventNum":0,"eventType":2,"isDnD":false,"name":"","resourceType":"GMEvent","resourceVersion":"2.0",},
   ```
   (`eventType:2` = Alarm, `eventNum:0` = Alarm 0)

6. **Testar incrementalmente:**
   1. Primeiro: Room Creation Code + fallback no oController
   2. Depois: Modificar o spawner (Create → Alarm)
   3. Por último: Remover NPCs manuais das rooms

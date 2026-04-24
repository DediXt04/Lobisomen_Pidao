# 🍔 Guia de Implementação — oFoodSpawner

> Guia para criar o objeto `oFoodSpawner` que spawna comidas aleatoriamente pelo mapa com sprites aleatórios.

---

## 📌 Contexto

| Item | Valor |
|---|---|
| Objeto base | `oComida` — lógica de coleta, flutuação, valor |
| Variantes | `oBurger` (sprite: `sBurguer`), `oPunk` (sprite: `sPunk`) |
| Herança | `oBurger` e `oPunk` herdam de `oComida` — sem eventos próprios |
| Comida necessária | `global.comidaMax = 5` (definido no `oController`) |
| Estado atual | Comidas colocadas **manualmente** no room editor |

---

## 🏗️ Criar os Objetos

### Objeto 1 — `oSpawnZone` (zona de spawn)

| Propriedade | Valor |
|---|---|
| Nome | `oSpawnZone` |
| Sprite | Um sprite **quadrado branco** de 1×1 pixel (ex: `sSpawnZone`) |
| Visível | **Não** (desmarcar "Visible" no GameMaker) |
| Persistente | Não |

> **Como criar o sprite:** Crie um sprite de **1×1 pixel** branco. Na room, você vai **escalar** a instância para cobrir a área jogável. Exemplo: para cobrir 160×160, escale `image_xscale = 160` e `image_yscale = 160`.

**Sem código** — o oSpawnZone não precisa de nenhum evento. Ele só serve como referência de área.

### Objeto 2 — `oFoodSpawner` (spawner de comida)

| Propriedade | Valor |
|---|---|
| Nome | `oFoodSpawner` |
| Sprite | **Nenhum** (sem sprite) |
| Persistente | **Não** |
| Parent | Nenhum |
| Visível | Não importa (sem sprite) |

---

## 💻 Código

### `objects/oFoodSpawner/Create_0.gml`

```gml
// === CONFIGURAÇÃO ===
var _tipos_comida = [oBurger, oPunk];  // tipos de comida disponíveis
var _qtd = global.comidaMax;            // quantidade a spawnar
var _tentativas_max = 200;              // tentativas por comida (evitar loop infinito)

// === PEGAR AS ZONAS DE SPAWN ===
var _num_zonas = instance_number(oSpawnZone);

// === SPAWN ===
repeat (_qtd) {
    for (var _t = 0; _t < _tentativas_max; _t++) {
        // escolher uma zona aleatória (suporta múltiplas zonas)
        var _zona = instance_find(oSpawnZone, irandom(_num_zonas - 1));

        // posição aleatória DENTRO da zona escolhida
        var _px = irandom_range(_zona.bbox_left, _zona.bbox_right);
        var _py = irandom_range(_zona.bbox_top, _zona.bbox_bottom);

        // verificar se a posição é válida (não colide com parede/saída)
        if (!collision_point(_px, _py, oWall, false, true)
         && !collision_point(_px, _py, oSolidWall, false, true)
         && !collision_point(_px, _py, oParedeFina, false, true)
         && !collision_point(_px, _py, oSaida, false, true)) {

            // escolher tipo aleatório
            var _tipo = _tipos_comida[irandom(array_length(_tipos_comida) - 1)];

            // criar a comida
            instance_create_layer(_px, _py, layer, _tipo);
            break;
        }
    }
}

// o spawner já fez seu trabalho — pode se destruir
instance_destroy();
```

---

## 📐 Como Funciona

### Fluxo

```
1. oFoodSpawner é criado (junto com a room)
2. Conta quantos oSpawnZone existem na room
3. Lê global.comidaMax para saber quantas comidas spawnar
4. Para cada comida:
   a. Escolhe uma zona aleatória (suporta 1 ou mais zonas)
   b. Tenta até 200 posições aleatórias DENTRO da zona escolhida
   c. Verifica se a posição NÃO colide com paredes/saída
   d. Escolhe aleatoriamente entre oBurger e oPunk
   e. Cria a instância na posição válida
5. Se auto-destrói (trabalho concluído)
```

### Verificação de Colisão

Usa `collision_point` em vez de `place_meeting` porque:
- `oFoodSpawner` não tem sprite/máscara
- `collision_point` verifica um **ponto específico** no mapa
- Checa todos os tipos de parede: `oWall`, `oSolidWall`, `oParedeFina`
- Também evita spawnar em cima da saída (`oSaida`)

### Por que Funciona em Qualquer Formato de Mapa

O `oSpawnZone` limita a área de spawn ao **retângulo jogável**, e o `collision_point` descarta posições dentro de paredes. Juntos, garantem spawn correto em qualquer layout:

```
Room 400×400 com fase 160×160 no centro:

┌──────────────────────────┐
│    vazio (fora da room)  │
│                          │
│    ┌──── oSpawnZone ───┐ │
│    │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │
│    │ ▓  área livre    ▓ │ │  ← spawn ✅ (dentro da zona + sem parede)
│    │ ▓   (spawn ✅)   ▓ │ │
│    │ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │ │
│    └───────────────────┘ │
│                          │  ← ignorado (fora do oSpawnZone)
└──────────────────────────┘

Mapa em formato T dentro da zona:

    ┌──── oSpawnZone ─────────┐
    │ ████████████████████████ │
    │ ████  área livre  ██████ │  ← spawn ✅
    │ ████████████████████████ │
    │ █████████    ███████████ │
    │ █████████    ███████████ │  ← spawn ✅ (área livre no pé do T)
    │ █████████    ███████████ │
    └─────────────────────────┘

  ✅ Dentro da zona + sem parede → comida criada
  ❌ Dentro da zona + com parede → descartado
  ❌ Fora da zona → nunca testado
```

---

### Escolha Aleatória de Tipo

```gml
var _tipos_comida = [oBurger, oPunk];
var _tipo = _tipos_comida[irandom(array_length(_tipos_comida) - 1)];
```

- `irandom(1)` retorna 0 ou 1 → escolhe `oBurger` ou `oPunk`
- Para adicionar mais tipos no futuro, basta expandir o array:
  ```gml
  var _tipos_comida = [oBurger, oPunk, oNovoTipo];
  ```

---

## 🛠️ Instruções de Uso

### Passo 1 — Criar o oSpawnZone

1. **Criar o sprite** `sSpawnZone`: 1×1 pixel, qualquer cor (branco)
2. **Criar o objeto** `oSpawnZone`: atribuir `sSpawnZone`, desmarcar **Visible**
3. **Sem código** — nenhum evento necessário

### Passo 2 — Criar o oFoodSpawner

1. No GameMaker, clique com botão direito em **Objects** → **Create Object**
2. Nomeie como `oFoodSpawner`
3. **Não** atribua sprite
4. Crie o evento **Create** e cole o código acima

### Passo 3 — Colocar na room

1. Abra a room de gameplay (`room_01`, `room_02`, etc.)
2. Arraste `oSpawnZone` para a room → **escale** para cobrir a área jogável:
   - Exemplo: se a área jogável é 160×160, ajuste `image_xscale = 160` e `image_yscale = 160`
   - Posicione o canto superior-esquerdo do oSpawnZone no início da área jogável
   - **Pode usar múltiplas zonas** — coloque quantos `oSpawnZone` quiser para cobrir áreas separadas (ex: mapa em L)
3. Arraste `oFoodSpawner` para **qualquer lugar** da room (posição não importa — ele se destrói após spawnar)
4. Coloque **uma instância** de `oFoodSpawner` por room

### Passo 4 — Remover comidas manuais

1. Na room, **remova** todas as instâncias de `oComida`, `oBurger` e `oPunk` que foram colocadas manualmente
2. O `oFoodSpawner` agora cuidará de criar todas as comidas

### Passo 5 — Garantir ordem de criação

O `oFoodSpawner` precisa de `global.comidaMax` que é definido no `oController/Create_0.gml`. Para garantir que o `oController` seja criado **antes** do `oFoodSpawner`:

- **Opção A:** Definir `global.comidaMax` no `oController` e colocar o `oFoodSpawner` em uma layer **abaixo** do `oController` na room (GameMaker cria instâncias de cima para baixo nas layers)
- **Opção B:** Definir `global.comidaMax = 5` diretamente no `oFoodSpawner` antes de usar, removendo a dependência

---

## ⚙️ Configuração

### Ajustar Quantidade de Comida

A quantidade é controlada por `global.comidaMax` (definido no `oController`). Para mudar, altere o valor no `oController/Create_0.gml`:

```gml
global.comidaMax = 7;  // por exemplo, 7 comidas em vez de 5
```

### Ajustar Área de Spawn

Para mudar a área onde comida pode spawnar, basta **reposicionar ou reescalar** o `oSpawnZone` na room. Não precisa alterar código.

### Adicionar Novos Tipos de Comida

1. Crie um novo objeto (ex: `oDonut`) com parent `oComida`
2. Atribua o sprite desejado ao novo objeto
3. Adicione ao array no `oFoodSpawner`:
   ```gml
   var _tipos_comida = [oBurger, oPunk, oDonut];
   ```

---

## ⚠️ Observações

1. **Herança** — `oBurger` e `oPunk` herdam toda a lógica de `oComida` (flutuação, coleta, `valor = 1`, `base_y = y`). Não precisam de código próprio.

2. **`base_y`** — O `oComida/Create_0.gml` define `base_y = y` para a flutuação senoidal funcionar. Como `instance_create_layer` dispara o Create do objeto filho, isso já é tratado automaticamente.

3. **`instance_destroy()`** — O spawner se destrói após criar todas as comidas. Ele existe por apenas 1 frame.

4. **Tentativas** — O limite de 200 tentativas por comida evita loop infinito em mapas muito cheios. Se um mapa tem pouco espaço livre, considere aumentar esse valor ou diminuir a quantidade de comida.

5. **Repetição de posição** — Duas comidas podem spawnar próximas uma da outra. Se quiser evitar isso, adicione uma verificação de distância mínima entre comidas:
   ```gml
   // adicionar dentro do if de validação:
   && !collision_circle(_px, _py, 32, oComida, false, true)
   ```

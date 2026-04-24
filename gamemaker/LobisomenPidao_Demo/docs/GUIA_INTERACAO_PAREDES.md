# 🧱 Guia — Bloquear Interação Através de Paredes

> Como impedir que o jogador interaja com NPCs e comida através de paredes.

---

## 📌 Problema

O jogador consegue interagir com NPCs e coletar comida **através de paredes** porque o código atual verifica apenas **distância** (`point_distance`), sem checar se há obstáculo no caminho.

---

## 🔧 Solução

Adicionar `collision_line` como condição extra nas interações. Essa função traça uma **linha reta** entre dois pontos e verifica se algum objeto (parede) está no caminho.

```gml
// Retorna true se NÃO há parede entre o NPC/comida e o player
!collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true)
```

**Parâmetros:**
| Parâmetro | Valor | Significado |
|---|---|---|
| x1, y1 | `x, y` | Posição do NPC/comida |
| x2, y2 | `oPlayer.x, oPlayer.y` | Posição do jogador |
| obj | `oWall` | Objeto a verificar no caminho |
| prec | `false` | Colisão por bounding box (mais rápido) |
| notme | `true` | Ignora a própria instância |

---

## 📁 Arquivos a Modificar

### 1. `objects/oNpc/Step_0.gml` — Interação com NPC

**Antes (linha 59):**
```gml
if (_dist < 32 && oController.interagir && cooldown <= 0)
```

**Depois:**
```gml
if (_dist < 32 && oController.interagir && cooldown <= 0
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
```

---

### 2. `objects/oComida/Step_0.gml` — Coleta de comida

**Antes (linha 11):**
```gml
if (_dist < 16 && oController.interagir)
```

**Depois:**
```gml
if (_dist < 16 && oController.interagir
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
```

---

## ⚠️ Observações

1. **Outros tipos de parede** — Se quiser bloquear também por `oSolidWall` e `oParedeFina`, adicione verificações extras:
   ```gml
   && !collision_line(x, y, oPlayer.x, oPlayer.y, oSolidWall, false, true)
   && !collision_line(x, y, oPlayer.x, oPlayer.y, oParedeFina, false, true)
   ```
   Ou crie um objeto **parent** para todas as paredes (ex: `oParede`) e use apenas:
   ```gml
   && !collision_line(x, y, oPlayer.x, oPlayer.y, oParede, false, true)
   ```

2. **Performance** — `collision_line` é leve e já é usada pelo `oInimigo` no campo de visão. Sem impacto perceptível.

3. **Indicador visual (!)** — O `oComida/Draw_0.gml` mostra um `"!"` quando o player está a menos de 16px. Se quiser que o indicador também desapareça quando há parede, adicione a mesma verificação no Draw_0:
   ```gml
   if (_dist < 16 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
   ```

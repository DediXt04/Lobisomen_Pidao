// === CONFIGURAÇÃO ===
var _tipos_comida = [oBurger, oPunk];  // tipos de comida disponíveis
var _qtd = global.comidaMax - 2;            // quantidade a spawnar
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
var _config = [
    [global.comidaSpawn,  [oBurger, oPunk]],
    [global.npcSpawn,     [oNpc]],
];
var _tentativas_max = 200;
var _num_zonas = instance_number(oSpawnZone);

if (_num_zonas == 0) {
    instance_destroy();
    exit;
}

// Folga mínima em pixels em relação a qualquer obstáculo/borda
var _margem = 16;

// === SPAWN ===
for (var c = 0; c < array_length(_config); c++) {
    var _qtd   = _config[c][0];
    var _tipos = _config[c][1];

    repeat (_qtd) {
        for (var _t = 0; _t < _tentativas_max; _t++) {
            var _zona = instance_find(oSpawnZone, irandom(_num_zonas - 1));

            // Já restringe o sorteio respeitando a margem interna da zona
            var _px = irandom_range(_zona.bbox_left  + _margem, _zona.bbox_right  - _margem);
            var _py = irandom_range(_zona.bbox_top   + _margem, _zona.bbox_bottom - _margem);

            // Checa um retângulo ao redor do ponto em vez de só 1 pixel
            var _x1 = _px - _margem;
            var _y1 = _py - _margem;
            var _x2 = _px + _margem;
            var _y2 = _py + _margem;

            if (!collision_rectangle(_x1, _y1, _x2, _y2, oWall,      false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oSolidWall, false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oParedeFina,false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oSaida,     false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oComida,    false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oNpc,       false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oPlayer,    false, true)
			&& !collision_rectangle(_x1, _y1, _x2, _y2, oPorta,    false, true)) {
                var _tipo = _tipos[irandom(array_length(_tipos) - 1)];
                instance_create_layer(_px, _py, layer, _tipo);
                break;
            }
        }
    }
}

instance_destroy();
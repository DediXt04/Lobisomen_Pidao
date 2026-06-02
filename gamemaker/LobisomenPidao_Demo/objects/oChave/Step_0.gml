// Pausar
if (global.pausado) exit;

// Profundidade baseada em Y
depth = -bbox_bottom;

// Distância até o player
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

// Animação de flutuação (sobe e desce suavemente)
y = base_y + sin(current_time / 200) * 1.5;
depth = -y;

// Coleta: perto + botão de interação + sem parede entre os dois
if (_dist < 16 && oController.interagir
 && !collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
{
    global.temChave = true;
    instance_destroy();
}
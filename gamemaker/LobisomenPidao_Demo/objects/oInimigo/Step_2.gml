// Colisão Horizontal
if (place_meeting(x + hspeed, y, oWall)) {
    var _sinal = sign(hspeed);
    while (!place_meeting(x + _sinal, y, oWall)) {
        x += _sinal;
    }
    hspeed = 0;
}

// Colisão Vertical
if (place_meeting(x, y + vspeed, oWall)) {
    var _sinal = sign(vspeed);
    while (!place_meeting(x, y + _sinal, oWall)) {
        y += _sinal;
    }
    vspeed = 0;
}
// Movimentação
#region
timer++;
if (timer >= timer_max) {
    timer = 0;
    scr_escolherDirecao();
}

if (pixels_walked > 0) {

    if (vx != 0) {
        if place_meeting(x + vx, y, oWall)   { pixels_walked = 0; vx = 0; }
        if place_meeting(x + vx, y, oPlayer) { pixels_walked = 0; vx = 0; }
        if (vx != 0) { x += vx; pixels_walked -= abs(vx); }
    }

    if (vy != 0) {
        if place_meeting(x, y + vy, oWall)   { pixels_walked = 0; vy = 0; }
        if place_meeting(x, y + vy, oPlayer) { pixels_walked = 0; vy = 0; }
        if (vy != 0) { y += vy; pixels_walked -= abs(vy); }
    }
}
#endregion

// Cooldown
if (cooldown > 0) cooldown--;

// Interação
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

if (_dist < 32 && oController.interagir && paciencia > 0 && cooldown <= 0)
{
    if (irandom(99) < chance_comida)
    {
        global.comida += valor_comida;
    }

    chance_comida += irandom_range(10, 15);
    chance_comida  = min(chance_comida, 100);

    paciencia--;
    cooldown = cooldown_max;
}
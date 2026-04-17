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

// Controle de sprite
#region
depth = -y;
var _movendo = (pixels_walked > 0);

if (_movendo) {
    if (vy > 0) {
        if (sprite_index != sNpcDown) { sprite_index = sNpcDown; image_index = 0; }
    } else if (vy < 0) {
        if (sprite_index != sNpcUp)   { sprite_index = sNpcUp;   image_index = 0; }
    } else if (vx != 0) {
        if (sprite_index != sNpcSide) { sprite_index = sNpcSide; image_index = 0; }
        image_xscale = (vx > 0) ? 1 : -1;
    }
    image_speed = 1;
} else {
    image_speed = 0;
    image_index = 0;
}
#endregion

// Cooldown
if (cooldown > 0) cooldown--;

// Timer da reação
if (reacao_timer > 0) {
    reacao_timer--;
    if (reacao_timer <= 0) reacao_frame = -1;
}

// Interação
#region
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

if (_dist < 32 && oController.interagir && cooldown <= 0)
{
    // Sem paciência — reação 2
    if (paciencia <= 0) {
        reacao_frame = 2;
        reacao_timer = reacao_dur;

    } else {
        // Tem paciência — tenta dar comida
        if (irandom(99) <= chance_comida) {
            global.comida += valor_comida;
            reacao_frame = 0;   // deu comida
        } else {
            reacao_frame = 1;   // não deu nada
        }

        reacao_timer   = reacao_dur;
        chance_comida += irandom_range(10, 15);
        chance_comida  = min(chance_comida, 100);
        paciencia--;
    }

    cooldown = cooldown_max;
}
#endregion

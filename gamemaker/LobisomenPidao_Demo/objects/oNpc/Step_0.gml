//Pausar
if (global.pausado) exit;

// Movimentação
#region
timer++;
if (timer >= timer_max) {
    timer = 0;
    scr_escolherDirecao(moveSpd, 16, 64, true);
}

if (pixels_walked > 0) {

    if (xspd != 0) {
        if place_meeting(x + xspd, y, oWall)   { pixels_walked = 0; xspd = 0; }
        if place_meeting(x + xspd, y, oPlayer) { pixels_walked = 0; xspd = 0; }
		if place_meeting(x + xspd, y, oInimigo) { pixels_walked = 0; xspd = 0; }
        if place_meeting(x + xspd, y, oSaida)  { pixels_walked = 0; xspd = 0; }
		if(!global.temChave){
			if place_meeting(x + xspd, y, oPorta)  { pixels_walked = 0; xspd = 0; }
		}
        if (xspd != 0) { x += xspd; pixels_walked -= abs(xspd); }
    }

    if (yspd != 0) {
        if place_meeting(x, y + yspd, oWall)   { pixels_walked = 0; yspd = 0; }
        if place_meeting(x, y + yspd, oPlayer) { pixels_walked = 0; yspd = 0; }
		if place_meeting(x, y + yspd, oInimigo) { pixels_walked = 0; yspd = 0; }
        if place_meeting(x, y + yspd, oSaida)  { pixels_walked = 0; yspd = 0; }
		if(!global.temChave){
			if place_meeting(x, y + yspd, oPorta)  { pixels_walked = 0; yspd = 0; }
		}
        if (yspd != 0) { y += yspd; pixels_walked -= abs(yspd); }
    }
}
#endregion

// sprite control
#region
var _movendo = (pixels_walked > 0);

if (_movendo) {
    walk_timer = 10;

    var _h = (xspd != 0); // tem componente horizontal
    var _v = (yspd != 0); // tem componente vertical

    if (_h && _v) {
        // Diagonal: prioridade sobre movimento puro
        face = (yspd < 0) ? 5 : 4;
        image_xscale = (xspd > 0) ? 1 : -1;
    } else if (_h) {
        // Movimento puramente horizontal
        face = 0;
        image_xscale = (xspd > 0) ? 1 : -1;
    } else if (_v) {
        // Movimento puramente vertical
        face = (yspd < 0) ? 2 : 3;
        image_xscale = 1;
    }
}

if (walk_timer > 0) walk_timer--;
if (walk_timer == 0) image_index = 0;

mask_index   = sprite[3];
sprite_index = sprite[face];
depth = -y;
#endregion

// Interação
#region
// Cooldown
if (cooldown > 0) cooldown--;

// Timer da reação
if (reacao_timer > 0) {
    reacao_timer--;
    if (reacao_timer <= 0) reacao_frame = -1;
}

// Centro do bbox para não cair dentro de parede adjacente
var _ncx = (bbox_left + bbox_right) * 0.5;
var _ncy = (bbox_top + bbox_bottom) * 0.5;
var _pcx = (oPlayer.bbox_left + oPlayer.bbox_right) * 0.5;
var _pcy = (oPlayer.bbox_top + oPlayer.bbox_bottom) * 0.5;

var _dist = point_distance(_ncx, _ncy, _pcx, _pcy);

if (_dist < 32 && oController.interagir && cooldown <= 0
 && !collision_line(_ncx, _ncy, _pcx, _pcy, oWall, false, true))
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
			paciencia = 0;
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

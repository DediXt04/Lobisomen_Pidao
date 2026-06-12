// VARIÁVEIS BÁSICAS
#region
//moveSpd = 1;
scr_initMovimento(1, 90, 300);
dano = 1;
flag_parado = false;
timer_see = room_speed * 2;

//// movimento
//xspd = 0;
//yspd = 0;

// estado
estado = undefined;
timer_estado = 0;

// visão
larg_visao = 80;
alt_visao = 1.5;

// direção visual
xscale = 1;
#endregion

// FUNÇÃO CAMPO DE VISÃO
campo_visao = function(_dist, _angulo_visao)
{
    // NOVO: checa distância primeiro
    var _dist_player = point_distance(x, y, oPlayer.x, oPlayer.y);
    if (_dist_player >= _dist) return false;

    // direção atual
    var dir = point_direction(0, 0, xspd, yspd);

    // se parado, usa face
    if (xspd == 0 && yspd == 0)
    {
        switch(face)
        {
            case 0: dir = (image_xscale == 1) ? 0 : 180; break;
            case 1: dir = (image_xscale == 1) ? 315 : 225; break;
            case 2: dir = 270; break;
            case 3: dir = 90; break;
            case 4: dir = (image_xscale == 1) ? 45 : 135; break;
        }
    }

    // direção até o player
    var dir_player = point_direction(x, y, oPlayer.x, oPlayer.y);

    // diferença angular
    var diff = angle_difference(dir, dir_player);

    // dentro do cone?
    if (abs(diff) <= _angulo_visao / 2)
    {
        // verifica parede no caminho
        if (!collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, true))
        {
            return true;
        }
    }

    return false;
}

// ESTADOS
#region
// PARADO
estado_parado = function()
{
    xspd = 0;
    yspd = 0;
	flag_parado = true;

    if (is_debug) image_blend = c_green;

    // vê o player
    if (campo_visao(120, 60))
    {
		flag_parado = false;
        estado = estado_perseguindo;
        exit;
    }

    // chance de começar a andar
    if (irandom(100) < 2)
    {
		flag_parado = false;
        estado = estado_passeando;
        timer_estado = room_speed * 2;
    }
}

// PASSEANDO
estado_passeando = function()
{
    if (is_debug) image_blend = c_white;

    // se ver o player
    if (campo_visao(120, 60))
    {
        estado = estado_perseguindo;
        exit;
    }

    //if (timer_estado <= 0)
    //{
    //    estado = estado_parado;
    //    exit;
    //}

    timer_estado--;

    // movimento aleatório
    if (irandom(100) < 2)
    {
		scr_escolherDirecao();
        //var dir = irandom(359);
        //xspd = lengthdir_x(moveSpd, dir);
        //yspd = lengthdir_y(moveSpd, dir);
    }
}

// PERSEGUINDO
estado_perseguindo = function()
{
    if (is_debug) image_blend = c_red;

    var dir = point_direction(x, y, oPlayer.x, oPlayer.y);

    xspd = lengthdir_x(moveSpd, dir);
    yspd = lengthdir_y(moveSpd, dir);
	
	timer_see--;

    // perdeu o player
    if (!campo_visao(120, 60))
    {
        estado = estado_passeando;
    }
	
	if (campo_visao(120, 60)) timer_see = room_speed * 2;
}

// DEFINE ESTADO INICIAL
estado = estado_passeando;
#endregion

// DEFINE AS SPRITES INICIAIS
face = 3;

sprite[0] = sFreddyFasbear;
sprite[1] = sFreddyFasbear;
sprite[2] = sFreddyFasbear;
sprite[3] = sFreddyFasbear;
sprite[4] = sFreddyFasbear;
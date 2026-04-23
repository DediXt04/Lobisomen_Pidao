// Variáveis Básicas
#region
vel = 0.5;
dano = 1;
path = path_add();
path_timer = 0;
timer_see = room_speed * 3;

// movimento
xspd = 0;
yspd = 0;

// estado
estado = undefined;
timer_estado = 0;
#endregion

// Função Campo Visão
campo_visao = function(_dist, _angulo_visao)
{
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

// Estados do Inimigo
#region
// PARADO
estado_parado = function()
{
    xspd = 0;
    yspd = 0;

    if (is_debug) image_blend = c_white;

    // vê o player
    if (campo_visao(120, 60))
    {
        estado = estado_perseguindo;
        exit;
    }

    // chance de começar a andar
    if (irandom(100) < 2)
    {
        estado = estado_passeando;
        timer_estado = room_speed * 2;
    }
}

// PASSEANDO
estado_passeando = function()
{
     if (is_debug) image_blend = c_red;

    // se ver o player
    if (campo_visao(120, 60))
    {
        estado = estado_perseguindo;
        exit;
    }

    if (timer_estado <= 0)
    {
        estado = estado_parado;
        exit;
    }

    timer_estado--;

    // movimento aleatório
    if (irandom(100) < 5)
    {
        var dir = irandom(359);
        xspd = lengthdir_x(vel, dir);
        yspd = lengthdir_y(vel, dir);
    }
}

// PERSEGUINDO
estado_perseguindo = function()
{
    if (is_debug) image_blend = c_fuchsia;

    // atualiza o path a cada X frames
    if (path_timer <= 0)
    {
        path_timer = 20; // recalcula a cada 20 frames (~0.3s)

        path_delete(path);
        path = path_add();

        var target_x = oPlayer.x;
        var target_y = oPlayer.y;

        if (mp_grid_path(oController.grid, path, x, y, target_x, target_y, 1))
        {
            path_start(path, vel, path_action_stop, true);
        }
    }
    else
    {
        path_timer--;
    }
	
	// seta tempo para que continue perseguindo
	if (campo_visao(120, 60)) timer_see = room_speed * 3;
	timer_see--;

    // perdeu o player
    if (!campo_visao(120, 60) and timer_see <= 0)
    {
        path_end(); // IMPORTANTE
        estado = estado_parado;
    }
}
#endregion

// Setando Estado Inicial
estado = estado_parado;

// Controle de Sprite
#region
face = 3;

sprite[0] = sFreddyFasbear;
sprite[1] = sFreddyFasbear;
sprite[2] = sFreddyFasbear;
sprite[3] = sFreddyFasbear;
sprite[4] = sFreddyFasbear;
#endregion
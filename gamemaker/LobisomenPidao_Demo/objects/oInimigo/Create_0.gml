// VARIÁVEIS BÁSICAS
#region
//moveSpd = 1;
scr_initMovimento(1, 90, 300);
dano = 1;
//flag_parado = false;
timer_see = room_speed * 2;

//// movimento
//xspd = 0;
//yspd = 0;

// estado
estado = undefined;
//timer_estado = 0;

// visão
larg_visao = 80;
alt_visao = 1.5;

// investigação
ultimo_x = x;
ultimo_y = y;
timer_investigar = 0;
timer_girar = 0;
TEMPO_INVESTIGAR = room_speed * 4;   // 4 segundos olhando ao redor
TEMPO_GIRAR = room_speed * 0.6;      // gira a cabeça a cada 0.6 segundos
// pathfinding (investigação)
caminho = path_add();      // path dinâmico, reaproveitado a cada investigação
indice_caminho = 0;        // índice do próximo waypoint a seguir

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

    //timer_estado--;

    // movimento aleatório
	timer++;
	if (timer >= timer_max) {
	    timer = 0;
	    scr_escolherDirecao();
	}
}

// INVESTIGANDO
estado_investigando = function()
{
    if (is_debug) image_blend = c_orange;

    // Se vê o player durante a investigação, abandona o caminho e volta a perseguir
    if (campo_visao(120, 60))
    {
        timer_see = room_speed * 2;
        estado = estado_perseguindo;
        exit;
    }

    // FASE 1: seguindo o caminho calculado pelo grid
    if (indice_caminho < path_get_number(caminho))
    {
        var _px = path_get_point_x(caminho, indice_caminho);
        var _py = path_get_point_y(caminho, indice_caminho);

        var dir = point_direction(x, y, _px, _py);
        xspd = lengthdir_x(moveSpd, dir);
        yspd = lengthdir_y(moveSpd, dir);

        if (point_distance(x, y, _px, _py) <= moveSpd)
        {
            indice_caminho++;
        }
    }
    else
    {
        // FASE 2: chegou no ponto (ou não havia caminho) — olha ao redor
        xspd = 0;
        yspd = 0;

        timer_investigar--;

        if (timer_investigar <= 0)
        {
            estado = estado_passeando;
            exit;
        }

        timer_girar--;

        if (timer_girar <= 0)
        {
            timer_girar = TEMPO_GIRAR;
            face = irandom(4);
            image_xscale = (irandom(1) == 0) ? 1 : -1;
        }
    }
}

// PERSEGUINDO
estado_perseguindo = function()
{
    if (is_debug) image_blend = c_red;

    var dir = point_direction(x, y, oPlayer.x, oPlayer.y);

    xspd = lengthdir_x(moveSpd, dir);
    yspd = lengthdir_y(moveSpd, dir);
	

    if (campo_visao(120, 60))
    {
        // Enquanto vê o player, atualiza a última posição conhecida
        timer_see = room_speed * 2;
        ultimo_x = oPlayer.x;
        ultimo_y = oPlayer.y;
    }

    // perdeu o player
	if (!campo_visao(120, 60))
	{
	    timer_investigar = TEMPO_INVESTIGAR;
	    timer_girar      = TEMPO_GIRAR;

	    // calcula o caminho até o último ponto visto, evitando paredes
	    path_clear_points(caminho);
	    mp_grid_path(oController.grid, caminho, x, y, ultimo_x, ultimo_y, true); // true = permite diagonal
	    indice_caminho = 1; // ponto 0 é a posição atual; já começamos indo pro próximo

	    estado = estado_investigando;
	}
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
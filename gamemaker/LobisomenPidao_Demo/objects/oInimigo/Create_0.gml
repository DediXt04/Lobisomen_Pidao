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

    // Se vê o player durante a investigação, volta a perseguir
    if (campo_visao(120, 60))
    {
        timer_see = room_speed * 2;
        estado = estado_perseguindo;
        exit;
    }

    // Calcular distância até o último ponto visto
    var _dist = point_distance(x, y, ultimo_x, ultimo_y);

    if (_dist > 16)
    {
        // FASE 1: Andando até o ponto
        flag_parado = false;

        var dir = point_direction(x, y, ultimo_x, ultimo_y);
        xspd = lengthdir_x(vel, dir);
        yspd = lengthdir_y(vel, dir);
    }
    else
    {
        // FASE 2: Chegou no ponto — olha ao redor
        xspd = 0;
        yspd = 0;

        // Timer de investigação
        timer_investigar--;

        if (timer_investigar <= 0)
        {
            // Acabou o tempo — não achou nada, volta ao normal
            estado = estado_passeando;
            exit;
        }

        // Girar a cabeça periodicamente
        timer_girar--;

        if (timer_girar <= 0)
        {
            timer_girar = TEMPO_GIRAR;

            // Escolhe uma direção aleatória para olhar
            face = irandom(4);  // 0=lado, 1=diag-cima, 2=cima, 3=baixo, 4=diag-baixo

            // Alterna xscale aleatoriamente (olha pra esquerda ou direita)
            if (irandom(1) == 0) {
                image_xscale = 1;
            } else {
                image_xscale = -1;
            }
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
	
	timer_see--;

    if (campo_visao(120, 60))
    {
        // Enquanto vê o player, atualiza a última posição conhecida
        timer_see = room_speed * 2;
        ultimo_x = oPlayer.x;
        ultimo_y = oPlayer.y;
    }

    // perdeu o player
    if (!campo_visao(120, 60) && timer_see <= 0)
    {
        // Em vez de parar, vai investigar o último ponto
        timer_investigar = TEMPO_INVESTIGAR;
        timer_girar = TEMPO_GIRAR;
        estado = estado_passeando;
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
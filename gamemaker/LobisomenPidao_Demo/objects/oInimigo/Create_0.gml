//Setando Variaveis
#region
vel = 0.5;
dano = 1;
alvo = noone;
estado = noone;
ultimo_estado = noone;
tempo_max_estado = room_speed * 5;
timer_estado = 0;
xscale = 1;
yscale = 1;
perseguindo_iniciado = false;

//coordenadas passeando
destino_x = x;
destino_y = y;
path_passeio_ativo = false;

// "update" path
path = path_add();
#endregion

//Função que defini o tempo de troca de estado
muda_estado = function(_estado){
	//Define um tempo máximo para troca de estado
	tempo_max_estado--;
	
	//Define timer do estado aleatóriamente com base no tempo máximo
	timer_estado = irandom(tempo_max_estado);
	
	//Muda de estado se o tempo max acabar ou timer tiver o mesmo tempo que o tempo max
	if (timer_estado == tempo_max_estado or tempo_max_estado <= 0) {
		//Define aleatoraimente 1 estado da lista
		estado = _estado[irandom(array_length(_estado)-1)];
		tempo_max_estado = room_speed * 5;
	}
}
	
//Função para fazer o campo de visão
campo_visao = function(_largura, _altura, _xscale){
	var _x1, _y1, _x2, _y2;
	_x1 = x;
	_y1 = y + _altura / 2 - sprite_height / 2;
	_x2 = _x1 + _largura * _xscale;
	_y2 = _y1 - _altura;
	//Desenhando o quadrado:
	if (is_debug) draw_rectangle(_x1, _y1, _x2, _y2, false);
	
	//Checando se o player está no campo de visão
	var _alvo = collision_rectangle(_x1, _y1, _x2, _y2, oPlayer, 0, 1);
	
	return _alvo
}

//Estados do Inimigo
estado_parado = function(){
	//Verifica se está vendo o player
    alvo = campo_visao(larg_visao, sprite_height * alt_visao, xscale);
    if (alvo) {
        estado = estado_perseguindo;
    }
	perseguindo_iniciado = false;

    image_blend = c_white;

    // Para o path imediatamente ao entrar no estado
    if (path_passeio_ativo) {
        path_end();
        path_passeio_ativo = false;
    }

    muda_estado([estado_parado, estado_passeando]);
}

estado_passeando = function(){
	//Verifica se está vendo o player
    alvo = campo_visao(larg_visao, sprite_height * alt_visao, xscale);
    if (alvo) {
        path_end(); // Para o path de passeio
        path_passeio_ativo = false;
        estado = estado_perseguindo;
        exit;
    }
	perseguindo_iniciado = false;

    image_blend = c_red;

    // Se ainda não tem um destino ativo, escolhe um novo
    if (!path_passeio_ativo) {
        var destino = scr_pegar_destino_valido(x, y);
        destino_x = destino[0];
        destino_y = destino[1];

        path_delete(path);
        path = path_add();
        // Cria o caminho pelo grid até o destino
        var _achou = mp_grid_path(oController.grid, path, x, y, destino_x, destino_y, 1);

        if (_achou) {
            path_start(path, vel, path_action_stop, true);
            path_passeio_ativo = true;
        }
        // Se não achou caminho válido, tenta de novo no próximo frame
    }

    // Quando chega no destino, libera para escolher outro
    if (path_position >= 1) {
        path_passeio_ativo = false;
    }

    // Olhando para onde anda
    if (speed != 0) {
        image_xscale = sign(hspeed);
        xscale = image_xscale;
    }

    muda_estado([estado_parado, estado_passeando]);
}

estado_perseguindo = function(){
	image_blend = c_fuchsia;
	// Só aciona o alarme uma vez ao entrar no estado
    if (!perseguindo_iniciado) {
        perseguindo_iniciado = true;
        alarm[0] = 1; // Dispara já no próximo frame
    }
}

//Definindo estado inicial dele
estado = estado_parado;
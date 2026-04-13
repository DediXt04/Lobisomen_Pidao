//Setando Variaveis
#region
vel = 0.5;
velh = 0;
velv = 0;
dano = 1;
estado = noone;
tempo_max_estado = room_speed * 5;
timer_estado = 0;
sprite = sprite_index;
xscale = 1;
yscale = 1;
alvo = noone;

//coordenadas jogador
target_x = oPlayer.x;
target_y = oPlayer.y;

//coordenadas passeando
destino_x = x;
destino_y = y;

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
	//draw_rectangle(_x1, _y1, _x2, _y2, false);
	
	//Checando se o player está no campo de visão
	var _alvo = collision_rectangle(_x1, _y1, _x2, _y2, oPlayer, 0, 1);
	
	return _alvo
}

//Estados do Inimigo
estado_parado = function(){
	// Verifica se avistou ou não o player
	alvo = campo_visao(larg_visao, sprite_height * alt_visao, xscale);
	if (alvo) {
		estado = estado_perseguindo;
	}
	
	show_debug_message("Estou Parado!");
	
	image_blend = c_white;
	
	//Zerando a velocidade
	velh = 0;
	velv = 0;
	
	muda_estado([estado_parado, estado_passeando]);
}

estado_passeando = function(){
	// Verifica se avistou ou não o player
	alvo = campo_visao(larg_visao, sprite_height * alt_visao, xscale);
	if (alvo) {
		estado = estado_perseguindo;
	}
	
	//Condição de troca de destino
	var _dist = point_distance(x, y, destino_x, destino_y);
	
	//Ele escolhe um destino aleatorio da sala e se move pra ele
	if (_dist < 100) {
		var destino = scr_pegar_destino_valido(x, y);
		destino_x = destino[0];
		destino_y = destino[1];
	}
	
	//Acha a direção do destino
	var _dir = point_direction(x, y, destino_x, destino_y);
	//Vai até o destino
	velh = lengthdir_x(vel, _dir);
	velv = lengthdir_y(vel, _dir);
	
	//Olhando para onde anda
	if (velh != 0) {
		xscale = sign(velh);
	}
	
	image_blend = c_red;
	
	muda_estado([estado_parado, estado_passeando]);
}

estado_perseguindo = function(){
	image_blend = c_fuchsia;
	alarm[0] = 120; // atualiza a cada 2s por ser 60 frames
}

//Definindo estado inicial dele
estado = estado_parado;
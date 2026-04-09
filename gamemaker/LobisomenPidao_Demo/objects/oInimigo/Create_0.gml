//Setando Variaveis
#region
vel = 0.5;
dano = 1;
estado = noone;
tempo_max_estado = room_speed * 5;
timer_estado = 0;

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

//Estados do Inimigo
estado_parado = function(){
	show_debug_message("Estou Parado!");
	
	image_blend = c_white;
	
	muda_estado([estado_parado, estado_passeando]);
}

estado_passeando = function(){
	//Condição de troca de destino
	var _dist = point_distance(x, y, destino_x, destino_y);
	
	//Ele escolhe um destino aleatorio da sala e se move pra ele
	if (_dist < 100) {
		destino_x = random(room_width);
		destino_y = random(room_height);
	}
	
	//Acha a direção do destino
	var _dir = point_direction(x, y, destino_x, destino_y);
	//Vai até o destino
	x += lengthdir_x(vel, _dir);
	y += lengthdir_y(vel, _dir);
	
	image_blend = c_red;
	
	muda_estado([estado_parado, estado_passeando]);
}

estado_perseguindo = function(){
	alarm[0] = 120; // atualiza a cada 2s por ser 60 frames
}

//Definindo estado inicial dele
estado = estado_parado;
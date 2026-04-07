//Setando Variaveis
#region
dano = 1;
estado = noone;
tempo_max_estado = room_speed * 10;
timer_estado = 0;

//coordenadas jogador
target_x = oPlayer.x;
target_y = oPlayer.y;

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
		estado = _estado;
		tempo_max_estado = room_speed * 10;
	}
}

//Estados do Inimigo
estado_parado = function(){
	show_debug_message("Estou Parado!");
	
	image_blend = c_white;
	
	muda_estado(estado_passeando);
}

estado_passeando = function(){
	show_debug_message("Estou Passeando!");
	
	image_blend = c_red;
	
	muda_estado(estado_parado);
}

estado_perseguindo = function(){
	alarm[0] = 120; // atualiza a cada 2s por ser 60 frames
}

//Definindo estado inicial dele
estado = estado_parado;
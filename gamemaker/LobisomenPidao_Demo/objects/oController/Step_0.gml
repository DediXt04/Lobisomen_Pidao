// --- testes (remover depois) ---
if keyboard_check_pressed(ord("R")) vida   -= 1;
if keyboard_check_pressed(ord("T")) vida   += 1;
if keyboard_check_pressed(ord("Y")) tempoFome += 30;
if keyboard_check_pressed(ord("U")) tempoFome -= 30;


// fome diminuindo
tempoFome -= delta_time / 1000000;
tempoFome  = max(tempoFome, 0);


//Interação
if keyboard_check_pressed(ord("E")){
	interagir = true;
}else{
	interagir = false;
}

// checagem de game over
if (vida <= 0) {
    global.motivoMorte = "dano";
    room_goto(rm_gameOver);
}

if (tempoFome <= 0) {
    global.motivoMorte = "fome";
    room_goto(rm_gameOver);
}

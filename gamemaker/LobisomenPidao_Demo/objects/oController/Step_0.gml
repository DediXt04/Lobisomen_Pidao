// --- testes (remover depois) ---
if keyboard_check_pressed(ord("R")) vida -= 1;
if keyboard_check_pressed(ord("T")) vida += 1;
if keyboard_check_pressed(ord("Y")) tempoFome += 15;
if keyboard_check_pressed(ord("U")) tempoFome -= 15;
if keyboard_check_pressed(ord("I")) global.comida += 1;
if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}
// fome diminuindo
tempoFome -= delta_time / 1000000;
tempoFome  = max(tempoFome, 0);

// interação - teclado OU controle
var _gp = global.gamepad_main;
var _gpInteragir = (_gp != undefined) && gamepad_button_check_pressed(_gp, gp_face1); // botão A (Xbox) / X (PS)

if keyboard_check_pressed(ord("E")) || _gpInteragir || keyboard_check_pressed(vk_space)
{
    interagir = true;
}
else
{
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

// checagem se pegou todas as comidas
if global.comida >= global.comidaMax
{
	global.comidaCheia = true;
}
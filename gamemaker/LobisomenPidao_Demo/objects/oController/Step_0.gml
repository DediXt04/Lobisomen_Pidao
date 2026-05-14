//pausa
#region
var _gp = global.gamepad_main;
var _gpStart = (_gp != undefined) && gamepad_button_check_pressed(_gp, gp_start);

if (keyboard_check_pressed(vk_escape) || _gpStart) {
    global.pausado = !global.pausado;
    pause_selecionado = 0;
    pause_nav_cooldown = 0;
}

// Se pausado, processar menu e sair do Step (congela o jogo)
if (global.pausado) {

    // cooldown de navegação
    if (pause_nav_cooldown > 0) pause_nav_cooldown--;

    // navegação vertical
    var _nav = 0;
    if (keyboard_check_pressed(ord("S"))) _nav = 1;
    if (keyboard_check_pressed(ord("W"))) _nav = -1;

    if (_gp != undefined && gamepad_is_connected(_gp) && pause_nav_cooldown == 0) {
        if (gamepad_button_check_pressed(_gp, gp_padd)) _nav = 1;
        if (gamepad_button_check_pressed(_gp, gp_padu)) _nav = -1;
        var _ay = gamepad_axis_value(_gp, gp_axislv);
        if (_ay >  0.5) _nav =  1;
        if (_ay < -0.5) _nav = -1;
        if (_nav != 0) pause_nav_cooldown = PAUSE_NAV_CD_MAX;
    }

    pause_selecionado = clamp(pause_selecionado + _nav, 0, pause_total - 1);

    // confirmar seleção
    var _confirmar = keyboard_check_pressed(vk_space)
                  || keyboard_check_pressed(ord("E"))
                  || keyboard_check_pressed(vk_enter);
    if (_gp != undefined) _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);

    if (_confirmar) {
        switch (pause_selecionado) {
            case 0: // Continuar
                global.pausado = false;
                break;
            case 1: // Reiniciar Fase
                global.pausado = false;
                room_restart();
                break;
            case 2: // Sair para seletor
                global.pausado = false;
                room_goto(rm_SelecaoDeFases);
                break;
        }
    }

    exit; // impede toda a lógica normal do Step (fome, interação, game over)
}
#endregion

// --- testes (remover depois) ---
if keyboard_check_pressed(ord("I")) global.comida += 1;

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
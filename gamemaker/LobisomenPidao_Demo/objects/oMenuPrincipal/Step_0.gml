// Flag consultada pelo oLoboMenu — resetada todo frame
confirmou_neste_frame = false;

// ===============================================================
// DETECTAR MODO DE INPUT (teclado vs controle)
// ===============================================================
var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

if (_tem_controle) {
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    var _btn_any = gamepad_button_check_pressed(_gp, gp_face1)
                || gamepad_button_check_pressed(_gp, gp_padu)
                || gamepad_button_check_pressed(_gp, gp_padd);

    if (abs(_ay) > DEADZONE || _btn_any) {
        input_mode = "controle";
    }
}

if (keyboard_check_pressed(vk_anykey)) {
    input_mode = "teclado";
}

// ===============================================================
// COOLDOWN DE NAVEGAÇÃO
// ===============================================================
if (nav_cooldown > 0) nav_cooldown--;

// ===============================================================
// NAVEGAÇÃO VERTICAL ENTRE BOTÕES
// ===============================================================
var _mover = 0;

// Teclado
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) _mover =  1;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) _mover = -1;

// Gamepad
if (_tem_controle && nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padd)) _mover =  1;
    if (gamepad_button_check_pressed(_gp, gp_padu)) _mover = -1;

    var _ay = gamepad_axis_value(_gp, gp_axislv);
    if (_ay >  DEADZONE) _mover =  1;
    if (_ay < -DEADZONE) _mover = -1;

    if (_mover != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Aplica navegação (com wrap-around)
if (_mover != 0) {
    botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
}

// ===============================================================
// CONFIRMAR — SPACE / E / botão A
// ===============================================================
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (_tem_controle) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(_gp, gp_face1);
}

if (_confirmar) {
    confirmou_neste_frame = true;

    // Se o oLoboMenu existe, ele cuida da transição (delay de 2s no Play/Exit).
    if (instance_exists(oLoboMenu)) {
        exit;
    }

    // Fallback (oLoboMenu ausente — modo "menu puro"):
    switch (botao_focado) {
        case 0: room_goto(rm_SelecaoDeFases); break;
        case 1: room_goto(rm_Settings);       break;
        case 2: game_end();                   break;
    }
}
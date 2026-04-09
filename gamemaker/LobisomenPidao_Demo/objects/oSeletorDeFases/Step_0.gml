// -------------------------------------------------------
// DETECTAR MODO DE INPUT (para o rodapé dinâmico)
// -------------------------------------------------------
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    var _ax = gamepad_axis_value(global.gamepad_main, gp_axislh);
    var _ay = gamepad_axis_value(global.gamepad_main, gp_axislv);
    var _btn_any = gamepad_button_check_pressed(global.gamepad_main, gp_face1)
                || gamepad_button_check_pressed(global.gamepad_main, gp_padu)
                || gamepad_button_check_pressed(global.gamepad_main, gp_padd);

    if (abs(_ax) > DEADZONE || abs(_ay) > DEADZONE || _btn_any) {
        input_mode = "controle";
    }
}

if (keyboard_check_pressed(vk_anykey)) {
    input_mode = "teclado";
}

// -------------------------------------------------------
// COOLDOWN DE NAVEGAÇÃO
// -------------------------------------------------------
if (nav_cooldown > 0) nav_cooldown--;

// -------------------------------------------------------
// NAVEGAÇÃO — TECLADO
// -------------------------------------------------------
var _nav = 0;

if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) _nav =  1;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) _nav = -1;

// -------------------------------------------------------
// NAVEGAÇÃO — CONTROLE
// -------------------------------------------------------
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main) && nav_cooldown == 0) {

    // D-pad
    if (gamepad_button_check_pressed(global.gamepad_main, gp_padd)) _nav =  1;
    if (gamepad_button_check_pressed(global.gamepad_main, gp_padu)) _nav = -1;

    // Analógico esquerdo
    var _ay = gamepad_axis_value(global.gamepad_main, gp_axislv);
    if (_ay >  DEADZONE) _nav =  1;
    if (_ay < -DEADZONE) _nav = -1;

    if (_nav != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Aplica navegação
if (_nav != 0) {
    fase_selecionada += _nav;
    if (fase_selecionada >= total_fases) fase_selecionada = 0;
    if (fase_selecionada < 0)            fase_selecionada = total_fases - 1;
}

// -------------------------------------------------------
// CONFIRMAR — TECLADO (ENTER ou E)
// -------------------------------------------------------
var _confirmar = keyboard_check_pressed(vk_enter)
              || keyboard_check_pressed(ord("E"));

// CONFIRMAR — CONTROLE (botão Sul = A no Xbox / Cruz no PS)
if (global.gamepad_main != undefined &&gamepad_is_connected(global.gamepad_main)) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(global.gamepad_main, gp_face1);
}

if (_confirmar) {
    global.comida = 0;
    room_goto(fase_rooms[fase_selecionada]);
}

// -------------------------------------------------------
// DETECTAR MODO DE INPUT
// -------------------------------------------------------
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    var _ax = gamepad_axis_value(global.gamepad_main, gp_axislh);
    var _ay = gamepad_axis_value(global.gamepad_main, gp_axislv);
    var _btn_any = gamepad_button_check_pressed(global.gamepad_main, gp_face1)
                || gamepad_button_check_pressed(global.gamepad_main, gp_padu)
                || gamepad_button_check_pressed(global.gamepad_main, gp_padd)
                || gamepad_button_check_pressed(global.gamepad_main, gp_padl)
                || gamepad_button_check_pressed(global.gamepad_main, gp_padr);

    if (abs(_ax) > DEADZONE || abs(_ay) > DEADZONE || _btn_any) {
        input_mode = "controle";
    }
}

if (keyboard_check_pressed(vk_anykey)) {
    input_mode = "teclado";
}

// -------------------------------------------------------
// COOLDOWN
// -------------------------------------------------------
if (nav_cooldown > 0) nav_cooldown--;

// -------------------------------------------------------
// NAVEGAÇÃO EM GRADE — horizontal e vertical
// -------------------------------------------------------
var _nav_h = 0; // movimento horizontal (-1 esq, +1 dir)
var _nav_v = 0; // movimento vertical   (-1 cima, +1 baixo)

// Teclado
if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) _nav_h =  1;
if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) _nav_h = -1;
if (keyboard_check_pressed(vk_down)  || keyboard_check_pressed(ord("S"))) _nav_v =  1;
if (keyboard_check_pressed(vk_up)    || keyboard_check_pressed(ord("W"))) _nav_v = -1;

// Controle
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main) && nav_cooldown == 0) {

    if (gamepad_button_check_pressed(global.gamepad_main, gp_padr)) _nav_h =  1;
    if (gamepad_button_check_pressed(global.gamepad_main, gp_padl)) _nav_h = -1;
    if (gamepad_button_check_pressed(global.gamepad_main, gp_padd)) _nav_v =  1;
    if (gamepad_button_check_pressed(global.gamepad_main, gp_padu)) _nav_v = -1;

    var _ax = gamepad_axis_value(global.gamepad_main, gp_axislh);
    var _ay = gamepad_axis_value(global.gamepad_main, gp_axislv);
    if (_ax >  DEADZONE) _nav_h =  1;
    if (_ax < -DEADZONE) _nav_h = -1;
    if (_ay >  DEADZONE) _nav_v =  1;
    if (_ay < -DEADZONE) _nav_v = -1;

    if (_nav_h != 0 || _nav_v != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Aplica navegação na grade
if (_nav_h != 0 || _nav_v != 0) {

    var _novo = fase_selecionada;

    // Navegação horizontal: avança/volta 1 card (muda linha e página automaticamente)
    if (_nav_h != 0) {
        _novo = fase_selecionada + _nav_h;
        _novo = clamp(_novo, 0, global.total_fases - 1);
    }

    // Navegação vertical: pula uma linha inteira
    if (_nav_v != 0) {
        _novo = fase_selecionada + (_nav_v * colunas);
        _novo = clamp(_novo, 0, global.total_fases - 1);
    }

    fase_selecionada = _novo;

    // Atualiza página com base na fase selecionada
    pagina = fase_selecionada div por_pagina;
}

// -------------------------------------------------------
// CONFIRMAR — SPACE / E / botão A
// -------------------------------------------------------
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    _confirmar = _confirmar
              || gamepad_button_check_pressed(global.gamepad_main, gp_face1);
}

if (_confirmar && fase_selecionada <= global.fase_desbloqueada) {
    global.fase_atual = fase_selecionada;
    global.comida = 0;
    room_goto(global.fase_rooms[fase_selecionada]);
}


var voltar = keyboard_check_pressed(vk_escape);

if (!is_undefined(global.gamepad_main) && gamepad_is_connected(global.gamepad_main)) {
    voltar = voltar || gamepad_button_check_pressed(global.gamepad_main, gp_face2);
}

if (voltar) {
    room_goto(rm_MenuPrincipal);
}
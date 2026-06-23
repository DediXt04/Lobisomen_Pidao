// ===============================================================
// DETECTAR MODO DE INPUT
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
// ESTADO: CONFIRMAÇÃO ATIVA
// ===============================================================
if (confirmando) {

    // Cooldown
    if (conf_nav_cooldown > 0) conf_nav_cooldown--;

    // Navegação horizontal (A/D ou D-pad)
    var _nav = 0;
    if (keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) _nav = 1;
    if (keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left))  _nav = -1;

    if (_tem_controle && conf_nav_cooldown == 0) {
        if (gamepad_button_check_pressed(_gp, gp_padr)) _nav = 1;
        if (gamepad_button_check_pressed(_gp, gp_padl)) _nav = -1;
        var _ax = gamepad_axis_value(_gp, gp_axislh);
        if (_ax >  DEADZONE) _nav =  1;
        if (_ax < -DEADZONE) _nav = -1;
        if (_nav != 0) conf_nav_cooldown = NAV_COOLDOWN_MAX;
    }

    conf_selecionado = clamp(conf_selecionado + _nav, 0, conf_total - 1);

    // Confirmar
    var _confirmar = keyboard_check_pressed(vk_space)
                  || keyboard_check_pressed(ord("E"))
                  || keyboard_check_pressed(vk_enter);
    if (_tem_controle) _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);

    // Cancelar (ESC / B = equivale a "Não")
    var _cancelar = keyboard_check_pressed(vk_escape);
    if (_tem_controle) _cancelar = _cancelar || gamepad_button_check_pressed(_gp, gp_face2);

    if (_cancelar) {
        confirmando = false;
        conf_selecionado = 1;
    }

    if (_confirmar) {
        if (conf_selecionado == 0) {
            // "Sim" — resetar progresso
            global.fase_desbloqueada = 0;
            ini_open("save_progresso.ini");
            ini_write_real("progresso", "fase_desbloqueada", 0);
            ini_close();

            confirmando = false;
            conf_selecionado = 1;
        } else {
            // "Não" — cancelar
            confirmando = false;
            conf_selecionado = 1;
        }
    }

    exit; // Bloqueia navegação normal enquanto confirma
}

// ===============================================================
// ESTADO NORMAL — NAVEGAÇÃO DO MENU
// ===============================================================

// Cooldown
if (nav_cooldown > 0) nav_cooldown--;

// Navegação vertical
var _mover = 0;
if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) _mover =  1;
if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) _mover = -1;

if (_tem_controle && nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padd)) _mover =  1;
    if (gamepad_button_check_pressed(_gp, gp_padu)) _mover = -1;
    var _ay = gamepad_axis_value(_gp, gp_axislv);
    if (_ay >  DEADZONE) _mover =  1;
    if (_ay < -DEADZONE) _mover = -1;
    if (_mover != 0) nav_cooldown = NAV_COOLDOWN_MAX;
}

// Wrap-around
if (_mover != 0) {
    botao_focado = (botao_focado + _mover + total_botoes) % total_botoes;
}

// ===============================================================
// CONFIRMAR
// ===============================================================
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"));

if (_tem_controle) {
    _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);
}

if (_confirmar) {
    switch (botao_focado) {
        case 0:  // Resetar Progresso → abre confirmação
            confirmando = true;
            conf_selecionado = 1;  // padrão em "Não"
            break;

        case 1:  // Voltar → menu principal
            room_goto(rm_MenuPrincipal);
            break;
    }
}

// ===============================================================
// VOLTAR COM ESC / B
// ===============================================================
var _voltar = keyboard_check_pressed(vk_escape);
if (_tem_controle) _voltar = _voltar || gamepad_button_check_pressed(_gp, gp_face2);

if (_voltar) {
    room_goto(rm_MenuPrincipal);
}
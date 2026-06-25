var _gp = global.gamepad_main;

// cooldown de navegação (para analógico)
if (btn_nav_cooldown > 0) btn_nav_cooldown--;

// navegação horizontal: A/D no teclado
var _nav = 0;
if (keyboard_check_pressed(ord("D"))) _nav = 1;
if (keyboard_check_pressed(ord("A"))) _nav = -1;

// navegação horizontal: D-pad / analógico no gamepad
if (_gp != undefined && gamepad_is_connected(_gp) && btn_nav_cooldown == 0) {
    if (gamepad_button_check_pressed(_gp, gp_padr)) _nav = 1;
    if (gamepad_button_check_pressed(_gp, gp_padl)) _nav = -1;
    var _ax = gamepad_axis_value(_gp, gp_axislh);
    if (_ax >  0.5) _nav =  1;
    if (_ax < -0.5) _nav = -1;
    if (_nav != 0) btn_nav_cooldown = BTN_NAV_CD_MAX;
}

btn_selecionado = clamp(btn_selecionado + _nav, 0, btn_total - 1);

// confirmar seleção
var _confirmar = keyboard_check_pressed(vk_space)
              || keyboard_check_pressed(ord("E"))
              || keyboard_check_pressed(vk_enter);
if (_gp != undefined) _confirmar = _confirmar || gamepad_button_check_pressed(_gp, gp_face1);

if (_confirmar) {
    // Identifica ação pelo texto do botão (independente do índice)
    var _acao = btn_opcoes[btn_selecionado];

    switch (_acao) {
        case "Próxima Fase":
            // Desbloqueia próxima fase
            if (global.fase_atual >= global.fase_desbloqueada) {
                global.fase_desbloqueada = min(global.fase_atual + 1, global.total_fases - 1);
                ini_open("save_progresso.ini");
                ini_write_real("progresso", "fase_desbloqueada", global.fase_desbloqueada);
                ini_close();
            }
            // Vai direto para a próxima fase
            var _prox = global.fase_atual + 1;
            global.fase_atual = _prox;
            global.comida = 0;
            room_goto(global.fase_rooms[_prox]);
            break;

        case "Reiniciar Fase":
            room_goto(global.fase_room_atual);
            break;

        case "Voltar ao Menu":
            // Desbloqueia próxima fase antes de sair
            if (global.fase_atual >= global.fase_desbloqueada) {
                global.fase_desbloqueada = min(global.fase_atual + 1, global.total_fases - 1);
                ini_open("save_progresso.ini");
                ini_write_real("progresso", "fase_desbloqueada", global.fase_desbloqueada);
                ini_close();
            }
            room_goto(rm_SelecaoDeFases);
            break;
    }
}
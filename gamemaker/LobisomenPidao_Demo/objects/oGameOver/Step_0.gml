var _gp = global.gamepad_main;
var _gpConfirmar = (_gp != undefined) && gamepad_button_check_pressed(_gp, gp_face1);

// BUG CORRIGIDO: parêntese estava errado no original
if (keyboard_check_pressed(vk_enter) || _gpConfirmar) {
    room_goto(rm_SelecaoDeFases);
}

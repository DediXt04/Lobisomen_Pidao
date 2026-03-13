// botão reiniciar — clique com mouse
var _cx = room_width  / 2;
var _cy = room_height / 2;
var _bw = 200; // largura do botão
var _bh = 50;  // altura do botão
var _bx = _cx - _bw / 2;
var _by = _cy + 60;

if (mouse_check_button_pressed(mb_left)) {
    if (mouse_x > _bx && mouse_x < _bx + _bw &&
        mouse_y > _by && mouse_y < _by + _bh)
    {
        room_goto(room_01);
    }
}


var _gp = global.gamepad_main;
var _gpInteragir = (_gp != undefined) && gamepad_button_check_pressed(_gp, gp_face1);

// reiniciar com teclado também (Enter)
if (keyboard_check_pressed(vk_enter)) || _gpInteragir {
    room_goto(room_01);
}

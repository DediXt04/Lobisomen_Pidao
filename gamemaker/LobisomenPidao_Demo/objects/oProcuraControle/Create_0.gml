persistent = true;

// Evita duplicata
if (instance_number(oProcuraControle) > 1) {
    instance_destroy();
    exit;
}

// Inicializa o gamepad
global.gamepads = [];
global.gamepad_main = undefined;

for (var i = 0; i < 12; i++) {
    if (gamepad_is_connected(i)) {
        array_push(global.gamepads, i);
        gamepad_set_axis_deadzone(i, 0.2);
    }
}

if (array_length(global.gamepads) > 0)
    global.gamepad_main = global.gamepads[0];
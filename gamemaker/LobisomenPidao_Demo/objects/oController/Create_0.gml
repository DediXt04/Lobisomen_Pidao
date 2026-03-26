window_set_caption("Lobisomem pidão")

// crir um grid
grid = mp_grid_create(0, 0, room_width/4, room_height/4, 4, 4)

// acrescentar as paredes no grid
mp_grid_add_instances(grid, oWall, 0)

// vida
vida    = 6;
vidaMax = 6;

// fome
tempoFome = 90;
tempoMax  = 90;

// inventário
global.comida = 0;
global.comidaMax = 5;
global.comidaCheia = false;

//Interagir
interagir = false;

// game over
global.motivoMorte = "";

//gamepad
global.gamepads = [];
global.gamepad_main = undefined;

for (var i = 0; i < 12; i++)
{
    if (gamepad_is_connected(i))
    {
        array_push(global.gamepads, i);
        gamepad_set_axis_deadzone(i, 0.2);
    }
}
if (array_length(global.gamepads) > 0)
{
    global.gamepad_main = global.gamepads[0];
}


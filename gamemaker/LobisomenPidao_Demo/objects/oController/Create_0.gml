window_set_caption("Lobisomem pidão")

// crir um grid
grid = mp_grid_create(0, 0, room_width/4,room_height/4, 4, 4)

// acrescentar as paredes no grid
mp_grid_add_instances(grid, oWall, 0);
mp_grid_add_instances(grid, oSaida, 0);

// vida
vida    = 6;
vidaMax = 6;

// inventário
global.comida = 0;
if (!variable_global_exists("comidaMax"))    global.comidaMax    = 5;
if (!variable_global_exists("comidaSpawn"))  global.comidaSpawn  = 5;
if (!variable_global_exists("npcSpawn"))     global.npcSpawn     = 2;
if (!variable_global_exists("tempoFomeMax")) global.tempoFomeMax = 90;
global.comidaCheia = false;

// fome
tempoFome = global.tempoFomeMax;
tempoMax  = global.tempoFomeMax;

//Interagir
interagir = false;

// game over
global.motivoMorte = "";


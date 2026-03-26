path_delete(path);
path = path_add();

//coordenadas jogador
target_x = oPlayer.x;
target_y = oPlayer.y;

// usando o grid, crie um caminho(path) e ande nele
mp_grid_path(oController.grid, path, x, y, target_x, target_y, 1);

// andando no path
path_start(path, 0.5, path_action_stop, true);

//loop
alarm_set(0, 100)
dano = 1;

// coordenadas jogador
target_x = oPlayer.x;
target_y = oPlayer.y;

// "update" path
path = path_add();

// --- Campo de visão ---
fov_range  = 50;   // distância máxima do cone
fov_angle  = 90;    // ângulo total do cone (45° pra cada lado)
can_see_player = false;

alarm[0] = 1;
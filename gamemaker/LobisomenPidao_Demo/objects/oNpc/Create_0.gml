moveSpd = 2;
xspd = 0;
yspd = 0;

timer = 0;
timer_max = 180;

pixels_walked = 0;

// Interação
chance_comida = 10;
valor_comida  = 1;
paciencia     = 5;
paciencia_max = 5;

cooldown      = 0;
cooldown_max  = 120;

// sprite control (mesmo padrão do oPlayer)
walk_timer = 0;

face = 3;              // 3 = baixo (mesmo valor inicial do Player)
sprite[0] = sNpcSide;  // face 0 = lado
sprite[2] = sNpcUp;    // face 2 = cima
sprite[3] = sNpcDown;  // face 3 = baixo

sprite_index = sprite[face];
image_speed  = 0;
mask_index   = sprite[3];

// Reação (balão acima da cabeça)
// frame 0 = deu comida | frame 1 = não deu nada | frame 2 = sem paciência
reacao_frame  = -1;
reacao_timer  = 0;
reacao_dur    = 90;
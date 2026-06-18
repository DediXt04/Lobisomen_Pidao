scr_initMovimento(2, 90, 300);

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
sprite[0] = sNpc2Side;  // face 0 = lado
sprite[2] = sNpc2Up;    // face 2 = cima
sprite[3] = sNpc2Down;  // face 3 = baixo
sprite[4] = sNpc2DDown; // face 4 = diagonal pra baixo
sprite[5] = sNpc2DUp;   // face 4 = diagonal pra cima

sprite_index = sprite[face];
image_speed  = 0;
mask_index   = sprite[3];

// Reação (balão acima da cabeça)
// frame 0 = deu comida | frame 1 = não deu nada | frame 2 = sem paciência
reacao_frame  = -1;
reacao_timer  = 0;
reacao_dur    = 90;
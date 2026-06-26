scr_initMovimento(2, 90, 300);

// Interação
chance_comida = 10;
valor_comida  = 1;
paciencia     = 5;
paciencia_max = 5;

cooldown      = 0;
cooldown_max  = 120;

// sprite control — dois arrays paralelos (walk + idle)
walk_timer = 0;

face = 3;              // 3 = baixo

// Array de sprites de WALK
sprite_walk[0] = sNpcSide;
sprite_walk[2] = sNpcUp;
sprite_walk[3] = sNpcDown;
sprite_walk[4] = sNpcDDown;
sprite_walk[5] = sNpcDUp;

// Array de sprites de IDLE (NOVO)
sprite_idle[0] = sNpcSideIdle;
sprite_idle[2] = sNpcUpIdle;
sprite_idle[3] = sNpcDownIdle;
sprite_idle[4] = sNpcDDownIdle;
sprite_idle[5] = sNpcDUpIdle;

// Por padrão começa parado → idle
sprite = sprite_idle;

sprite_index = sprite[face];
image_speed  = 1;             // ← MUDOU: idle anima desde o início
mask_index   = sprite_walk[3]; // mask sempre do walk (silhueta consistente)

// Reação (balão acima da cabeça)
// frame 0 = deu comida | frame 1 = não deu nada | frame 2 = sem paciência
reacao_frame  = -1;
reacao_timer  = 0;
reacao_dur    = 90;
vx = 0;
vy = 0;
move_speed = 2;

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

// Direção do sprite
direcao_sprite = 0;

sprite_index = sNpcDown;
image_speed  = 0;
mask_index   = sNpcDown;

// Reação (balão acima da cabeça)
// frame 0 = deu comida | frame 1 = não deu nada | frame 2 = sem paciência
reacao_frame  = -1;   // -1 = nenhuma reação ativa
reacao_timer  = 0;
reacao_dur    = 90;   // frames que o balão fica (~1.5s a 60fps)

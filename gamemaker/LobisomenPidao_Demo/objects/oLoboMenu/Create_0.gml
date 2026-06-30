
// ===== Estados (enum simulado por strings — legível e fácil de estender) =====
ESTADO_IDLE_ATIVO          = "idle_ativo";
ESTADO_FOCO_PLAY           = "foco_play";
ESTADO_FOCO_SETTINGS       = "foco_settings";
ESTADO_FOCO_EXIT           = "foco_exit";

ESTADO_INATIVO_1_REVIRANDO = "inativo_1";
ESTADO_INATIVO_2_DORMINDO  = "inativo_2";
ESTADO_INATIVO_3_VELHO     = "inativo_3";

ESTADO_CONF_PLAY           = "conf_play";
ESTADO_CONF_SETTINGS       = "conf_settings";
ESTADO_CONF_EXIT           = "conf_exit";

// ===== Estado inicial =====
estado = ESTADO_IDLE_ATIVO;
sprite_index = sLoboMenuPiscando;
image_speed  = 1;

// Escala 20x do sprite 16x16 (320x320 na tela)
image_xscale = 20;
image_yscale = 20;

// ===== Timers de inatividade (em frames; room_speed = 60 por padrão) =====
timer_inatividade            = 0;
TIMER_INATIVO_1_FRAMES       = room_speed * 8;    // 8s  → revirando os olhos
TIMER_INATIVO_2_FRAMES       = room_speed * 15;   // 15s → dormindo
TIMER_INATIVO_3_FRAMES       = room_speed * 25;   // 25s → envelhecendo

// ===== Timer de transição (Play/Exit) =====
timer_transicao              = 0;
TIMER_DELAY_CONFIRMACAO      = room_speed * 2;    // 2s

// ===== Fade-out durante transição =====
input_bloqueado              = false;
fade_alpha                   = 0;
FADE_VELOCIDADE              = 1 / (room_speed * 2);  // fade completo em 2s

// ===== Lembrar último foco para detectar mudança =====
ultimo_focado = -1;

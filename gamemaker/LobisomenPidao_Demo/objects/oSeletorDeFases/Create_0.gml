 fase_rooms = [
    room_01,
	room_02
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset"
    
];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos"
    
];

fase_descricoes = [
    "01",
    "02"
];

total_fases      = array_length(fase_rooms);
fase_selecionada = 0;

// Inicializa global
if (!variable_global_exists("comida")) global.comida = 0;

// --- Layout (1920x1080) ---
card_w   = 480;
card_h   = 140;
card_gap = 36;

var total_h = total_fases * card_h + (total_fases - 1) * card_gap;
start_x  = (1920 - card_w) / 2;
start_y  = (1080 - total_h) / 2 + 60;
cx       = 1920 / 2;

// --- Controle ---
DEADZONE = 0.5;

// Cooldown para não trocar de fase muito rápido
// ao segurar o direcional
nav_cooldown     = 0;
NAV_COOLDOWN_MAX = 18; // frames (~0.3s em 60fps)

// Qual método de input está sendo usado (para o rodapé)
// "teclado" ou "controle"
input_mode = "teclado";
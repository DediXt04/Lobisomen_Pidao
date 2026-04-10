fase_rooms = [
    room_01,
    room_02,
	room_01,
    room_02,
	rm_Vitoria
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset",
	"teste",
	"teste2",
	"teste3"
];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
	"teste",
	"teste2",
	"teste3"
];

total_fases      = array_length(fase_rooms);
fase_selecionada = 0;

if (!variable_global_exists("comida")) global.comida = 0;

// --- Layout em grade (1920x1080) ---
colunas  = 3;           // cards por linha
card_w   = 340;
card_h   = 280;
card_gap = 40;          // espaço entre cards

// Largura total da grade
var grade_w = colunas * card_w + (colunas - 1) * card_gap;
grade_x = (1920 - grade_w) / 2;  // x do primeiro card
grade_y = 160;                    // y do primeiro card

// Área de thumbnail dentro do card
thumb_h = 160;   // altura da imagem/preview no topo do card

cx = 1920 / 2;

// --- Controle ---
DEADZONE         = 0.5;
nav_cooldown     = 0;
NAV_COOLDOWN_MAX = 18;
input_mode       = "teclado";

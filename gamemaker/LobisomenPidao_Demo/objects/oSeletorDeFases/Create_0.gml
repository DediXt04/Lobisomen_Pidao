fase_rooms = [
    room_01,
    room_02,
    room_01,  // mockup — remover depois
    room_02,  // mockup — remover depois
    room_01,  // mockup — remover depois
    room_02,  // mockup — remover depois
    room_01,  // mockup — remover depois
    room_02,  // mockup — remover depois
];

fase_nomes = [
    "Fase testes",
    "Fase testes tileset",
    "Mockup 3",
    "Mockup 4",
    "Mockup 5",
    "Mockup 6",
    "Mockup 7",
    "Mockup 8",
];

fase_subtitulos = [
    "Ai! Ui! Um lobo me mordeu!",
    "Me jogue aos lobos",
    "Teste de paginação",
    "Teste de paginação",
    "Teste de paginação",
    "Ultima da pagina 1",
    "Primeira da pagina 2",
    "Teste de paginação",
];

total_fases      = array_length(fase_rooms);
fase_selecionada = 0;

if (!variable_global_exists("comida")) global.comida = 0;

// --- Layout em grade (1920x1080) ---
colunas  = 3;           // cards por linha
linhas   = 2;           // linhas por página
por_pagina = colunas * linhas;  // 6 cards por página
pagina   = 0;           // página atual (começa em 0)
total_paginas = max(1, ceil(total_fases / por_pagina));
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

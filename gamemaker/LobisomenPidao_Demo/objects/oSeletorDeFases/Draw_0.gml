// -------------------------------------------------------
// FUNDO
// -------------------------------------------------------
draw_set_color(make_color_rgb(20, 22, 38));
draw_rectangle(0, 0, 1920, 1080, false);

// Linha decorativa topo e rodapé
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.35);
draw_line_width(0, 120, 1920, 120, 2);
draw_line_width(0, 980, 1920, 980, 2);
draw_set_alpha(1);

// -------------------------------------------------------
// TÍTULO
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(120, 220, 230));
draw_text(cx, 70, "Escolha sua Fase");

// -------------------------------------------------------
// GRADE DE CARDS (só os da página atual)
// -------------------------------------------------------
var _inicio = pagina * por_pagina;
var _fim    = min(_inicio + por_pagina, total_fases);

for (var i = _inicio; i < _fim; i++) {

    var _local = i - _inicio;  // índice local na página (0 a 5)
    var _col = _local mod colunas;
    var _row = _local div colunas;

    var _cx = grade_x + _col * (card_w + card_gap);
    var _cy = grade_y + _row * (card_h + card_gap);
    var _sel = (i == fase_selecionada);

    var _sel      = (i == fase_selecionada);
    var _bloqueada = (i > global.fase_desbloqueada); // ← linha que estava faltando

    // --- Sombra do card (deslocamento simples) ---
    draw_set_color(make_color_rgb(10, 10, 20));
    draw_set_alpha(0.5);
    draw_rectangle(_cx + 6, _cy + 6, _cx + card_w + 6, _cy + card_h + 6, false);
    draw_set_alpha(1);

    // --- Fundo do card ---
    if (_sel) {
        draw_set_color(make_color_rgb(22, 45, 70));
    } else {
        draw_set_color(make_color_rgb(18, 22, 42));
    }
    draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, false);

    // --- Área de thumbnail (topo do card) ---
    if (_bloqueada) {
        draw_set_color(make_color_rgb(12, 14, 25));
    } else if (_sel) {
        draw_set_color(make_color_rgb(25, 55, 85));
    } else {
        draw_set_color(make_color_rgb(20, 28, 55));
    }
    draw_rectangle(_cx, _cy, _cx + card_w, _cy + thumb_h, false);

    // Número ou cadeado no thumbnail (bloco único — sem duplicata abaixo)
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    if (_bloqueada) {
        draw_set_color(make_color_rgb(50, 30, 30));
        draw_text(_cx + card_w / 2, _cy + thumb_h / 2, "X");
    } else {
        draw_set_color(_sel
            ? make_color_rgb(80, 200, 210)
            : make_color_rgb(35, 70, 90));
        draw_text(_cx + card_w / 2, _cy + thumb_h / 2, string(i + 1));
    }

    // Divisória entre thumbnail e info
    draw_set_color(make_color_rgb(40, 80, 100));
    draw_set_alpha(0.6);
    draw_line_width(_cx, _cy + thumb_h, _cx + card_w, _cy + thumb_h, 1);
    draw_set_alpha(1);

    // --- Área de info (parte de baixo do card) ---
    var _info_y = _cy + thumb_h + 12;
    var _max_text_w = card_w - 24;
    var _info_bottom = _cy + card_h - 8;

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    if (_bloqueada) {
        draw_set_color(make_color_rgb(50, 55, 65));
        draw_text_ext(_cx + card_w / 2, _info_y, "Bloqueada", -1, card_w - 24);

        draw_set_color(make_color_rgb(35, 40, 50));
        draw_text_ext(_cx + card_w / 2, _info_y + 30, "Venca a fase anterior", -1, card_w - 24);
    } else {
        draw_set_color(_sel
            ? make_color_rgb(210, 240, 245)
            : make_color_rgb(130, 160, 175));
        draw_text_ext(_cx + card_w / 2, _info_y, fase_nomes[i], -1, card_w - 24);

        var _nome_h = string_height_ext(fase_nomes[i], -1, _max_text_w);
        var _sub_y = _info_y + _nome_h + 6;

        if (_sub_y < _info_bottom) {
            draw_set_color(_sel
                ? make_color_rgb(80, 180, 195)
                : make_color_rgb(50, 75, 95));
            draw_text_ext(_cx + card_w / 2, _sub_y, fase_subtitulos[i], -1, _max_text_w);
        }
    }

    // --- Borda do card ---
    if (_bloqueada) {
        draw_set_color(make_color_rgb(25, 20, 20));
        draw_set_alpha(0.4);
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, true);
        draw_set_alpha(1);
    } else if (_sel) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(0.9);
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, true);
        draw_set_alpha(1);

        // Borda superior mais grossa como destaque
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + 4, false);
    } else {
        draw_set_color(make_color_rgb(35, 55, 80));
        draw_set_alpha(0.6);
        draw_rectangle(_cx, _cy, _cx + card_w, _cy + card_h, true);
        draw_set_alpha(1);
    }
}

// -------------------------------------------------------
// INDICADOR DE PÁGINA (pontinhos na base)
// -------------------------------------------------------
if (total_paginas > 1) {
    var _dot_r   = 7;
    var _dot_gap = 24;
    var _dot_total_w = total_paginas * (_dot_r * 2 + _dot_gap) - _dot_gap;
    var _dot_x   = cx - _dot_total_w / 2 + _dot_r;
    var _dot_y   = 960;

    for (var d = 0; d < total_paginas; d++) {
        if (d == pagina) {
            draw_set_color(make_color_rgb(80, 200, 210));
        } else {
            draw_set_color(make_color_rgb(35, 55, 80));
        }
        draw_circle(_dot_x + d * (_dot_r * 2 + _dot_gap), _dot_y, _dot_r, false);
    }
}

// -------------------------------------------------------
// RODAPÉ DINÂMICO
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(130, 180, 195));

if (input_mode == "controle") {
    draw_text(cx, 1055, "[D-pad] Navegar    [A] Confirmar    [B] Voltar");
} else {
    draw_text(cx, 1055, "[WASD] Navegar    [E] Confirmar    [ESC] Voltar");
}

// Indicador de controle
draw_set_halign(fa_right);
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    draw_set_color(make_color_rgb(50, 110, 120));
    draw_text(1900, 1055, "Controle conectado");
} else {
    draw_set_color(make_color_rgb(150, 60, 60));
    draw_text(1900, 1055, "Nenhum controle encontrado");
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);

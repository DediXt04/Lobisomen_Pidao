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
// GRADE DE CARDS
// -------------------------------------------------------
for (var i = 0; i < total_fases; i++) {

    var _col = i mod colunas;
    var _row = i div colunas;

    var _cx = grade_x + _col * (card_w + card_gap);
    var _cy = grade_y + _row * (card_h + card_gap);
    var _sel = (i == fase_selecionada);

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
    // Troque o draw_rectangle abaixo por draw_sprite_stretched quando tiver sprites de preview
    if (_sel) {
        draw_set_color(make_color_rgb(25, 55, 85));
    } else {
        draw_set_color(make_color_rgb(20, 28, 55));
    }
    draw_rectangle(_cx, _cy, _cx + card_w, _cy + thumb_h, false);

    // Número da fase centralizado no thumbnail (placeholder visual)
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_sel
        ? make_color_rgb(80, 200, 210)
        : make_color_rgb(35, 70, 90));
    draw_text(_cx + card_w / 2, _cy + thumb_h / 2, string(i + 1));

    // Divisória entre thumbnail e info
    draw_set_color(make_color_rgb(40, 80, 100));
    draw_set_alpha(0.6);
    draw_line_width(_cx, _cy + thumb_h, _cx + card_w, _cy + thumb_h, 1);
    draw_set_alpha(1);

    // --- Área de info (parte de baixo do card) ---
    var _info_y = _cy + thumb_h + 20;

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    // Nome da fase
    draw_set_color(_sel
    ? make_color_rgb(210, 240, 245)
    : make_color_rgb(130, 160, 175));
	draw_text_ext(_cx + card_w / 2, _info_y, fase_nomes[i], -1, card_w - 24);

    // Subtítulo
    draw_set_color(_sel
    ? make_color_rgb(80, 180, 195)
    : make_color_rgb(50, 75, 95));
	draw_text_ext(_cx + card_w / 2, _info_y + 30, fase_subtitulos[i], -1, card_w - 24);

    // --- Borda do card ---
    if (_sel) {
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
// INDICADOR DE POSIÇÃO (pontinhos na base — estilo BTD6)
// -------------------------------------------------------
var _dot_r   = 7;
var _dot_gap = 24;
var _linhas  = ceil(total_fases / colunas);
var _dot_total_w = _linhas * (_dot_r * 2 + _dot_gap) - _dot_gap;
var _dot_x   = cx - _dot_total_w / 2 + _dot_r;
var _dot_y   = 960;

var _linha_sel = fase_selecionada div colunas;

for (var d = 0; d < _linhas; d++) {
    if (d == _linha_sel) {
        draw_set_color(make_color_rgb(80, 200, 210));
    } else {
        draw_set_color(make_color_rgb(35, 55, 80));
    }
    draw_circle(_dot_x + d * (_dot_r * 2 + _dot_gap), _dot_y, _dot_r, false);
}

// -------------------------------------------------------
// RODAPÉ DINÂMICO
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(50, 90, 110));

if (input_mode == "controle") {
    draw_text(cx, 1055, "D-pad / Analogico  para navegar     A / Cruz  para entrar");
} else {
    draw_text(cx, 1055, "A D W S  ou  setas  para navegar     SPACE / E  para entrar");
}

// Indicador de controle conectado
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    draw_set_color(make_color_rgb(50, 110, 120));
    draw_set_halign(fa_right);
    draw_text(1900, 1055, "Controle conectado");
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);

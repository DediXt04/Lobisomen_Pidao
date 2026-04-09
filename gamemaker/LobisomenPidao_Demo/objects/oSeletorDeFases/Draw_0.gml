// -------------------------------------------------------
// FUNDO — navy escuro igual ao fundo dos tiles
// -------------------------------------------------------
draw_set_color(make_color_rgb(20, 22, 38));
draw_rectangle(0, 0, 1920, 1080, false);

// Linhas decorativas — teal médio do tileset
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.35);
draw_line_width(0, 120, 1920, 120, 2);
draw_line_width(0, 960, 1920, 960, 2);
draw_set_alpha(1);

// -------------------------------------------------------
// TÍTULO — ciano claro (highlight dos tiles)
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(120, 220, 230));
draw_text(cx, 70, "Escolha sua Fase");

// -------------------------------------------------------
// CARDS
// -------------------------------------------------------
for (var i = 0; i < total_fases; i++) {

    var cx2 = start_x;
    var cy  = start_y + i * (card_h + card_gap);
    var sel = (i == fase_selecionada);

    // Fundo do card
    if (sel) {
        draw_set_color(make_color_rgb(30, 50, 80));   // navy levemente azulado
    } else {
        draw_set_color(make_color_rgb(24, 26, 45));   // navy bem escuro
    }
    draw_rectangle(cx2, cy, cx2 + card_w, cy + card_h, false);

    // Borda esquerda colorida
    if (sel) {
        draw_set_color(make_color_rgb(80, 200, 210)); // ciano vivo
        draw_rectangle(cx2, cy, cx2 + 6, cy + card_h, false);
    } else {
        draw_set_color(make_color_rgb(40, 80, 100));  // teal apagado
        draw_rectangle(cx2, cy, cx2 + 4, cy + card_h, false);
    }

    // Borda geral do card
    if (sel) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(0.6);
    } else {
        draw_set_color(make_color_rgb(40, 60, 90));
        draw_set_alpha(0.4);
    }
    draw_rectangle(cx2, cy, cx2 + card_w, cy + card_h, true);
    draw_set_alpha(1);

    // Número da fase
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(sel
        ? make_color_rgb(80, 200, 210)   // ciano vivo
        : make_color_rgb(50, 90, 110));  // teal escuro
    draw_text(cx2 + 30, cy + card_h / 2, string(i + 1));

    // Nome da fase
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(sel
        ? make_color_rgb(210, 240, 245)  // branco frio
        : make_color_rgb(130, 160, 175)); // cinza azulado
    draw_text(cx2 + 110, cy + card_h / 2 - 18, fase_nomes[i]);

    // Subtítulo
    draw_set_color(sel
        ? make_color_rgb(80, 180, 195)   // teal médio
        : make_color_rgb(55, 80, 100));  // teal bem apagado
    draw_text(cx2 + 112, cy + card_h / 2 + 14, fase_subtitulos[i]);

    // Seta indicadora
    if (sel) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_halign(fa_right);
        draw_text(cx2 + card_w - 28, cy + card_h / 2, ">");
    }
}

// -------------------------------------------------------
// RODAPÉ DINÂMICO
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_color(make_color_rgb(50, 90, 110));
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

if (input_mode == "controle") {
    draw_text(cx, 1055, "D-pad / Analogico  para navegar     A / Cruz  para entrar");
} else {
    draw_text(cx, 1055, "W / S  ou  setas  para navegar     ENTER / E  para entrar");
}

// Controle conectado (canto inferior direito)
if (global.gamepad_main != undefined && gamepad_is_connected(global.gamepad_main)) {
    draw_set_color(make_color_rgb(50, 110, 120));
    draw_set_halign(fa_right);
    draw_text(1900, 1055, "Controle conectado");
}

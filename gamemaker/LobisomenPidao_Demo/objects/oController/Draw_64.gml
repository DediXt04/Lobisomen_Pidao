scr_drawVida(vida, vidaMax);
scr_drawFome(tempoFome, tempoMax);

scr_drawComida(global.comida, global.comidaMax);

//menu pausa
#region
if (global.pausado) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _cx = _gui_w / 2;
    var _cy = _gui_h / 2;

    // --- Fundo escuro semitransparente ---
    draw_set_alpha(0.75);
    draw_set_color(make_color_rgb(14, 14, 26));
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    // --- Calcular posições dos botões primeiro ---
    var _bw = 320;
    var _bh = 54;
    var _gap = 16;
    var _blocoH = _bh * pause_total + _gap * (pause_total - 1);
    var _startY = _cy - _blocoH / 2;
    var _footerY = _startY + _blocoH + 30;

    // --- Linhas decorativas teal (relativas ao conteúdo) ---
    draw_set_color(make_color_rgb(60, 160, 170));
    draw_set_alpha(0.35);
    draw_line_width(0, _startY - 120, _gui_w, _startY - 120, 2);
    draw_line_width(0, _footerY + 40, _gui_w, _footerY + 40, 2);
    draw_set_alpha(1);

    // --- Título "PAUSADO" ---
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(120, 220, 230));
    draw_text(_cx, _startY - 60, "PAUSADO");

    // --- Botões do menu ---

    for (var i = 0; i < pause_total; i++) {
        var _bx = _cx - _bw / 2;
        var _by = _startY + i * (_bh + _gap);
        var _sel = (i == pause_selecionado);

        // Fundo do botão
        draw_set_color(_sel
            ? make_color_rgb(30, 60, 80)
            : make_color_rgb(20, 35, 55));
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

        // Borda esquerda colorida (só no selecionado)
        if (_sel) {
            draw_set_color(make_color_rgb(80, 200, 210));
            draw_rectangle(_bx, _by, _bx + 5, _by + _bh, false);
        }

        // Borda geral
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(_sel ? 0.8 : 0.3);
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
        draw_set_alpha(1);

        // Texto do botão
        draw_set_color(_sel
            ? make_color_rgb(120, 225, 235)
            : make_color_rgb(80, 200, 210));
        draw_text(_cx, _by + _bh / 2, pause_opcoes[i]);
    }

    // --- Rodapé — dica de input dinâmica ---
    var _gp = global.gamepad_main;
    var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);
    draw_set_color(make_color_rgb(130, 180, 195));

    if (_temControle) {
        draw_text(_cx, _footerY, "[D-pad] Navegar  |  [A] Confirmar");
    } else {
        draw_text(_cx, _footerY, "[W/S] Navegar  |  [E] Confirmar");
    }

    // Reset alinhamento
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
#endregion
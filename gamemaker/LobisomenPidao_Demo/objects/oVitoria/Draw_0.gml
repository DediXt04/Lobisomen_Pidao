var _cx = room_width  / 2;
var _cy = room_height / 2;

//Fundo
draw_set_alpha(0.85);
draw_set_color(make_color_rgb(14, 14, 26));
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

//Linhas decorativas
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.35);
draw_line_width(0, _cy - 140, room_width, _cy - 140, 2);
draw_line_width(0, _cy + 140, room_width, _cy + 140, 2);
draw_set_alpha(1);

//Titulo
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(80, 200, 210));
draw_text(_cx, _cy - 80, "VOCÊ VENCEU!");

//Mensagem
draw_set_color(make_color_rgb(130, 165, 180));
draw_text(_cx, _cy - 30, "Mim de papai.");

//Botao
var _bw = 280;
var _bh = 54;
var _gap = 24;
var _blocoW = btn_total * _bw + (btn_total - 1) * _gap;
var _startX = _cx - _blocoW / 2;
var _by = _cy + 30;

for (var i = 0; i < btn_total; i++) {
    var _bx = _startX + i * (_bw + _gap);
    var _sel = (i == btn_selecionado);

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
    draw_text(_bx + _bw / 2, _by + _bh / 2, btn_opcoes[i]);
}

// --- Rodapé ---
var _gp = global.gamepad_main;
var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);
draw_set_color(make_color_rgb(130, 180, 195));
var _footerY = _by + _bh + 36;

if (_temControle) {
    draw_text(_cx, _footerY, "[D-pad] Navegar    [A] Confirmar");
} else {
    draw_text(_cx, _footerY, "[A/D] Navegar    [E] Confirmar");
}


// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);

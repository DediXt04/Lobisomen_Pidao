// ===============================================================
// FUNDO
// ===============================================================
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _cx = _gw / 2;
var _cy = _gh / 2;

draw_set_color(make_color_rgb(20, 22, 38));
draw_rectangle(0, 0, _gw, _gh, false);

// Linha decorativa
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.2);
draw_line_width(0, _gh - 100, _gw, _gh - 100, 2);
draw_line_width(0, 100, _gw, 100, 2);
draw_set_alpha(1);

// ===============================================================
// TÍTULO
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Sombra
draw_set_color(make_color_rgb(10, 10, 20));
draw_text_transformed(_cx + 3, 180 + 3, "SETTINGS", 2, 2, 0);
// Principal
draw_set_color(make_color_rgb(80, 200, 210));
draw_text_transformed(_cx, 180, "SETTINGS", 2, 2, 0);

// ===============================================================
// BOTÕES (centralizados verticalmente)
// ===============================================================
var _btn_w = 360;
var _btn_h = 60;
var _btn_gap = 16;
var _altura_total = total_botoes * _btn_h + (total_botoes - 1) * _btn_gap;
var _btn_y_inicio = _cy - _altura_total / 2 + 40;

for (var i = 0; i < total_botoes; i++) {
    var _bx = _cx - _btn_w / 2;
    var _by = _btn_y_inicio + i * (_btn_h + _btn_gap);
    var _focado = (i == botao_focado);

    // Fundo
    draw_set_color(_focado ? make_color_rgb(25, 55, 75) : make_color_rgb(18, 22, 42));
    draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, false);

    // Indicador lateral
    if (_focado) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_bx, _by, _bx + 6, _by + _btn_h, false);
    }

    // Borda
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(_focado ? 0.8 : 0.3);
    draw_rectangle(_bx, _by, _bx + _btn_w, _by + _btn_h, true);
    draw_set_alpha(1);

    // Texto
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_focado ? make_color_rgb(120, 230, 240) : make_color_rgb(80, 130, 150));
    draw_text(_bx + _btn_w / 2, _by + _btn_h / 2, botoes[i]);
}

// ===============================================================
// RODAPÉ
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(130, 180, 195));

var _gp = global.gamepad_main;
var _tem_controle = (_gp != undefined) && gamepad_is_connected(_gp);

if (_tem_controle && input_mode == "controle") {
    draw_text(_gw / 2, _gh - 25, "[D-pad] Navegar    [A] Confirmar    [B] Voltar");
} else {
    draw_text(_gw / 2, _gh - 25, "[WASD] Navegar    [E] Confirmar    [ESC] Voltar");
}

// ===============================================================
// OVERLAY DE CONFIRMAÇÃO (por cima de tudo)
// ===============================================================
if (confirmando) {

    // Fundo escuro semitransparente
    draw_set_alpha(0.8);
    draw_set_color(make_color_rgb(10, 10, 18));
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);

    // Caixa de diálogo
    var _box_w = 500;
    var _box_h = 200;
    var _box_x = _cx - _box_w / 2;
    var _box_y = _cy - _box_h / 2;

    // Fundo da caixa
    draw_set_color(make_color_rgb(20, 30, 50));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

    // Borda da caixa
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(0.8);
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);
    draw_set_alpha(1);

    // Linha superior decorativa
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + 4, false);

    // Título "Tem certeza?"
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(210, 230, 235));
    draw_text(_cx, _box_y + 55, "Tem certeza?");

    // Subtítulo
    draw_set_color(make_color_rgb(130, 150, 165));
    draw_text(_cx, _box_y + 90, "Todo progresso sera perdido.");

    // Botões Sim / Não (horizontais)
    var _cbw = 160;
    var _cbh = 50;
    var _cgap = 30;
    var _cblocoW = conf_total * _cbw + (conf_total - 1) * _cgap;
    var _cstartX = _cx - _cblocoW / 2;
    var _cby = _box_y + 130;

    for (var j = 0; j < conf_total; j++) {
        var _cbx = _cstartX + j * (_cbw + _cgap);
        var _csel = (j == conf_selecionado);

        // Fundo
        draw_set_color(_csel
            ? make_color_rgb(30, 60, 80)
            : make_color_rgb(20, 35, 55));
        draw_rectangle(_cbx, _cby, _cbx + _cbw, _cby + _cbh, false);

        // Borda esquerda (selecionado)
        if (_csel) {
            draw_set_color(make_color_rgb(80, 200, 210));
            draw_rectangle(_cbx, _cby, _cbx + 5, _cby + _cbh, false);
        }

        // Borda
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_set_alpha(_csel ? 0.8 : 0.3);
        draw_rectangle(_cbx, _cby, _cbx + _cbw, _cby + _cbh, true);
        draw_set_alpha(1);

        // Texto
        draw_set_color(_csel
            ? make_color_rgb(120, 225, 235)
            : make_color_rgb(80, 200, 210));
        draw_text(_cbx + _cbw / 2, _cby + _cbh / 2, conf_opcoes[j]);
    }
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
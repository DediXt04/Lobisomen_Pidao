// ===============================================================
// FUNDO
// ===============================================================
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

draw_set_color(make_color_rgb(20, 22, 38));
draw_rectangle(0, 0, _gw, _gh, false);

// Linha decorativa
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.2);
draw_line_width(0, _gh - 100, _gw, _gh - 100, 2);
draw_set_alpha(1);

// ===============================================================
// CONFIG LAYOUT
// ===============================================================
var margem = 60;

// BOTÕES
btn_w = 320;
btn_h = 60;
btn_gap = 16;

// posição direita
btn_x = _gw - btn_w - margem;

// altura total
var altura_total = total_botoes * btn_h + (total_botoes - 1) * btn_gap;

// sobe mais pra não bater no rodapé
btn_y_inicio = _gh - altura_total - 160;

// ===============================================================
// TÍTULO (AJUSTADO)
// ===============================================================
draw_set_font(fnt_pixel);
draw_set_halign(fa_right);
draw_set_valign(fa_middle);

var titulo_scale = 3;

// alinhado com os botões
var titulo_x_local = btn_x + btn_w;

// 🔥 espaçamento dinâmico (melhor solução)
var titulo_y_local = btn_y_inicio - (btn_h * 2.5);

// sombra
draw_set_color(make_color_rgb(10, 10, 20));
draw_text_transformed(titulo_x_local + 4, titulo_y_local + 4, "LOBISOMEM", titulo_scale, titulo_scale, 0);
draw_text_transformed(titulo_x_local + 4, titulo_y_local + 64, "PIDAO", titulo_scale, titulo_scale, 0);

// principal
draw_set_color(make_color_rgb(80, 200, 210));
draw_text_transformed(titulo_x_local, titulo_y_local, "LOBISOMEM", titulo_scale, titulo_scale, 0);
draw_text_transformed(titulo_x_local, titulo_y_local + 64, "PIDAO", titulo_scale, titulo_scale, 0);

// ===============================================================
// BOTÕES
// ===============================================================
for (var i = 0; i < total_botoes; i++) {
    var _bx = btn_x;
    var _by = btn_y_inicio + i * (btn_h + btn_gap);
    var _focado = (i == botao_focado);

    // fundo
    draw_set_color(_focado ? make_color_rgb(25, 55, 75) : make_color_rgb(18, 22, 42));
    draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, false);

    // indicador lateral
    if (_focado) {
        draw_set_color(make_color_rgb(80, 200, 210));
        draw_rectangle(_bx, _by, _bx + 6, _by + btn_h, false);
    }

    // borda
    draw_set_color(make_color_rgb(80, 200, 210));
    draw_set_alpha(_focado ? 0.8 : 0.3);
    draw_rectangle(_bx, _by, _bx + btn_w, _by + btn_h, true);
    draw_set_alpha(1);

    // texto
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_focado ? make_color_rgb(120, 230, 240) : make_color_rgb(80, 130, 150));

    draw_text(_bx + btn_w / 2, _by + btn_h / 2, botoes[i]);
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
    draw_text(_gw / 2, _gh - 25, "[D-pad] Navegar    [A] Confirmar");
} else {
    draw_text(_gw / 2, _gh - 25, "[WASD] Navegar    [E] Confirmar");
}

// Indicador de controle
draw_set_halign(fa_right);
if (_tem_controle) {
    draw_set_color(make_color_rgb(50, 110, 120));
    draw_text(_gw - 20, _gh - 25, "Controle conectado");
} else {
    draw_set_color(make_color_rgb(150, 60, 60));
    draw_text(_gw - 20, _gh - 25, "Nenhum controle encontrado");
}

// reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
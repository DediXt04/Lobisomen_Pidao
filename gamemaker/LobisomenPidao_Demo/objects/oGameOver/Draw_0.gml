var _cx = room_width  / 2;
var _cy = room_height / 2;

// -------------------------------------------------------
// FUNDO — navy escuro semitransparente
// -------------------------------------------------------
draw_set_alpha(0.85);
draw_set_color(make_color_rgb(14, 14, 26));
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// Linhas decorativas — teal
draw_set_color(make_color_rgb(60, 160, 170));
draw_set_alpha(0.35);
draw_line_width(0, _cy - 140, room_width, _cy - 140, 2);
draw_line_width(0, _cy + 140, room_width, _cy + 140, 2);
draw_set_alpha(1);

// -------------------------------------------------------
// TÍTULO — vermelho do tileset (acento pontual)
// -------------------------------------------------------
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(210, 60, 60));
draw_text(_cx, _cy - 80, "GAME OVER");

// -------------------------------------------------------
// MOTIVO
// -------------------------------------------------------
draw_set_color(make_color_rgb(130, 165, 180));
if (motivo == "dano") {
    draw_text(_cx, _cy - 30, "Voce morreu por dano.");
} else if (motivo == "fome") {
    draw_text(_cx, _cy - 30, "Voce morreu de fome.");
} else {
    draw_text(_cx, _cy - 30, "Voce morreu.");
}

// -------------------------------------------------------
// BOTÃO — voltar ao menu
// -------------------------------------------------------
var _bw = 280;
var _bh = 54;
var _bx = _cx - _bw / 2;
var _by = _cy + 30;

var _hover = (mouse_x > _bx && mouse_x < _bx + _bw &&
              mouse_y > _by && mouse_y < _by + _bh);

// Fundo do botão
draw_set_color(_hover
    ? make_color_rgb(30, 60, 80)
    : make_color_rgb(20, 35, 55));
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

// Borda esquerda colorida
draw_set_color(make_color_rgb(80, 200, 210));
draw_rectangle(_bx, _by, _bx + 5, _by + _bh, false);

// Borda geral
draw_set_color(make_color_rgb(80, 200, 210));
draw_set_alpha(_hover ? 0.8 : 0.4);
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
draw_set_alpha(1);

// Texto do botão
draw_set_color(_hover
    ? make_color_rgb(120, 225, 235)
    : make_color_rgb(80, 200, 210));
draw_text(_cx, _by + _bh / 2, "Voltar ao menu");

// -------------------------------------------------------
// RODAPÉ — dica de input dinâmica
// -------------------------------------------------------
var _gp = global.gamepad_main;
var _temControle = (_gp != undefined) && gamepad_is_connected(_gp);

draw_set_color(make_color_rgb(45, 80, 95));
if (_temControle) {
    draw_text(_cx, _by + _bh + 36, "A / Cruz  para voltar");
} else {
    draw_text(_cx, _by + _bh + 36, "SPACE para voltar");
}

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);

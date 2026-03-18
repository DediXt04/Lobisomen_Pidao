var _cx = room_width  / 2;
var _cy = room_height / 2;

// fundo escuro semitransparente
draw_set_alpha(0.7);
draw_set_color(c_black);
draw_rectangle(0, 0, room_width, room_height, false);
draw_set_alpha(1);

// título VOCÊ VENCEU!
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_yellow);
draw_set_font(fnt_pixel); // troque pelo nome da sua font, ou delete essa linha para usar a padrão
draw_text(_cx, _cy - 60, "VOCÊ VENCEU!");

// subtítulo / mensagem
draw_set_color(c_white);
draw_set_font(fnt_pixel); // troque pelo nome da sua font, ou delete essa linha para usar a padrão
draw_text(_cx, _cy, "Todas as comidas coletadas!");

// botão continuar
var _bw = 200;
var _bh = 50;
var _bx = _cx - _bw / 2;
var _by = _cy + 60;

// hover no botão
var _hover = (mouse_x > _bx && mouse_x < _bx + _bw &&
              mouse_y > _by && mouse_y < _by + _bh);

draw_set_color(_hover ? c_yellow : c_white);
draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, true);
draw_set_color(_hover ? c_yellow : c_white);
draw_text(_cx, _by + _bh / 2, "Continuar");

// dica teclado
draw_set_color(c_gray);
draw_text(_cx, _by + _bh + 30, "ou pressione Enter");

// reset alinhamento
draw_set_halign(fa_left);
draw_set_valign(fa_top);

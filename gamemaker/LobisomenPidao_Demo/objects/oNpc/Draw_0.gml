draw_self();

var _tx = x;
var _ty = y - 24;

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

draw_set_color(paciencia > 0 ? c_white : c_red);
draw_text_transformed(_tx, _ty,      "P:" + string(paciencia) + "/" + string(paciencia_max), 0.3, 0.3, 0);

draw_set_color(c_yellow);
draw_text_transformed(_tx, _ty + 8,  "C:" + string(chance_comida) + "%", 0.3, 0.3, 0);

draw_set_color(c_aqua);
draw_text_transformed(_tx, _ty + 16, cooldown > 0 ? string(cooldown) : "ok", 0.3, 0.3, 0);

draw_set_halign(fa_left);
draw_set_color(c_white);
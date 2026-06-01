// Desenha o sprite da chave
var _time = current_time / 1000;
var _glow_alpha = 0.15 + sin(_time * 4) * 0.15;

draw_set_alpha(_glow_alpha);
draw_set_colour(c_yellow);
draw_circle(x+1, y-1, 5, false);

draw_set_alpha(1);
draw_set_colour(c_white);

draw_self();

var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);
if (_dist < 16)
{
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_yellow);
    draw_text_transformed(x + 0.5, y - 20, "?", 0.35, 0.35, 0);
}

draw_set_alpha(1);
draw_set_colour(c_white);
draw_set_halign(fa_left);
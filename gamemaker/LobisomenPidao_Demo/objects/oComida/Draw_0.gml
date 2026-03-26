//draw
draw_self();

var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);


if (_dist < 16)
{
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_white);
    draw_text_transformed(x + 0.5 , y - 20, "!", 0.35, 0.35, 0);
}
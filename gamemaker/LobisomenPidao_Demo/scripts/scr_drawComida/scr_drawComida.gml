function scr_drawComida(_comida)
{
    draw_sprite_ext(sPizza, 0, 20, 125, 5, 5, 0, c_white, 1);
    draw_set_font(fnt_pixel);
    draw_set_colour(c_white);
    draw_text(100, 135, "x" + string(_comida));
}
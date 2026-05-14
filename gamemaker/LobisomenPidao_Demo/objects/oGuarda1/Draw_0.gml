// Inherit the parent event
event_inherited();

if (campo_visao(120, 60)) {
	draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_white);
    draw_text_transformed(x + 0.5 , y - 30, "!", 0.35, 0.35, 0);
}
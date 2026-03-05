function scr_drawComida(_comida, _comidaMax)
{
    draw_sprite_ext(sPizza, 0, 20, 125, 5, 5, 0, c_white, 1);

    draw_set_font(fnt_pixel);
    draw_set_colour(c_white);
    draw_set_halign(fa_left);   
    draw_set_valign(fa_top);    

    draw_text(105, 135, string(_comida) + "/" + string(_comidaMax));
	
}
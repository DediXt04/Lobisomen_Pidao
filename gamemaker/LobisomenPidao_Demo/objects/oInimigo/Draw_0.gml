draw_self();

// debug
if (is_debug)
{
    var dist = 120;
	var ang = 60;

	// direção base
	var dir = point_direction(0, 0, xspd, yspd);

	// fallback se parado
	if (xspd == 0 && yspd == 0)
	{
	    switch(face)
	    {
	        case 0: dir = (image_xscale == 1) ? 0 : 180; break;
	        case 1: dir = (image_xscale == 1) ? 315 : 225; break;
	        case 2: dir = 270; break;
	        case 3: dir = 90; break;
	        case 4: dir = (image_xscale == 1) ? 45 : 135; break;
	    }
	}

	// limites do cone
	var dir1 = dir - ang/2;
	var dir2 = dir + ang/2;

	// pontos
	var x1 = x + lengthdir_x(dist, dir1);
	var y1 = y + lengthdir_y(dist, dir1);

	var x2 = x + lengthdir_x(dist, dir2);
	var y2 = y + lengthdir_y(dist, dir2);

	// desenha cone
	draw_set_alpha(0.2);
	draw_set_color(c_yellow);

	draw_triangle(x, y, x1, y1, x2, y2, false);

	draw_set_alpha(1);

	// bordas
	draw_line(x, y, x1, y1);
	draw_line(x, y, x2, y2);
}

if (campo_visao(120, 60)) {
	draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_colour(c_red);
    draw_text_transformed(x + 0.5 , y - 30, "!", 0.35, 0.35, 0);
}
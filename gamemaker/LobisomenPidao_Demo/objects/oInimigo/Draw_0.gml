draw_self();

// debug
if (is_debug)
{
	if (timer_investigar > 0) draw_path(caminho, x, y, 1);
    var dist = dist_visao;
	var ang = grau_visao;

	// direção base
	var dir = point_direction(0, 0, xspd, yspd);

	// fallback se parado
	if (xspd == 0 && yspd == 0)
	{
	    switch(face)
	    {
	        case 0: dir = (image_xscale == 1) ? 0 : 180; break;
            case 1: dir = (image_xscale == 1) ? 45 : 135; break;
            case 2: dir = 90; break;
            case 3: dir = 270; break;
            case 4: dir = (image_xscale == 1) ? 315 : 225; break;
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

	// bordasd
	draw_line(x, y, x1, y1);
	draw_line(x, y, x2, y2);

	// desenha raio de percepção (círculo)
	draw_set_alpha(0.2);
	draw_set_color(c_red);
	draw_circle(x, y, raio_percepcao, false);

	draw_set_alpha(1);
	draw_set_color(c_red);
	draw_circle(x, y, raio_percepcao, true);

	draw_set_color(c_white); // reseta a cor pro resto do jogo
}
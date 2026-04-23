draw_self();


if (invencivel)
{
    image_alpha = 0.2 + random(0.8);
}
else
{
    image_alpha = 1;
}


if (global.comidaCheia) {

    var porta = instance_nearest(x, y, oSaida);

    if (porta != noone) {

        var dir = point_direction(x, y, porta.x, porta.y);

        var dist = 32; // distância da seta do player

        var sx = x + lengthdir_x(dist, dir);
        var sy = y + lengthdir_y(dist, dir);

        // efeito flutuando
        sy += sin(current_time / 200) * 2;

        // desenha rotacionada
        draw_sprite_ext(sSeta, 0, sx, sy, 1, 1, dir, c_white, 1);
    }
}

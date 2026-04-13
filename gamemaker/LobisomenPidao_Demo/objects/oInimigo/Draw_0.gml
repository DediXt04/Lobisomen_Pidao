//Ele desenha ele mesmo
draw_sprite_ext(sprite_index, image_index, x, y, xscale, yscale, image_angle, image_blend, image_alpha);

if (is_debug) {
	draw_path(path, x, y, 1);
	// Printa no log só quando o estado muda
    if (estado != ultimo_estado) {
        show_debug_message("oInimigo mudou de estado: " + string(estado));
        ultimo_estado = estado;
    }
	campo_visao(larg_visao, sprite_height * alt_visao, xscale);
}
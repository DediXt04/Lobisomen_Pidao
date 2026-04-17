draw_self();

// -------------------------------------------------------
// Reação — balão acima da cabeça
// -------------------------------------------------------
if (reacao_frame >= 0) {
    var _bx = x;
    var _by = y - sprite_height - 6;   // acima do topo do sprite

    draw_sprite_ext(
        sReacao,   // seu sprite de reações (3 frames)
        reacao_frame, // 0 = comida | 1 = nada | 2 = sem paciência
        _bx, _by,
        1, 1,         // scale
        0,            // rotação
        c_white,      // cor
        1             // alpha
    );
}

// -------------------------------------------------------
// Debug — bem acima da cabeça
// -------------------------------------------------------
var _tx = x;
var _ty = y - sprite_height - 28;   // subiu bastante

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

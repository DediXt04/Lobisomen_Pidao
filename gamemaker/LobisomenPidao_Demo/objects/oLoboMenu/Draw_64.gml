// ===============================================================
// SPRITE DO LOBO (em coordenadas GUI, não de room)
// ===============================================================
var _escala = 30;
var _sw = sprite_get_width(sprite_index) * _escala;
var _sh = sprite_get_height(sprite_index) * _escala;

// posição: lado esquerdo da tela, centralizado verticalmente
var _sx = display_get_gui_width() * 0.63 - _sw * 0.5;
var _sy = display_get_gui_height() * 0.70  - _sh * 0.5;

draw_sprite_ext(
    sprite_index,   // sprite atual (controlado pelos estados)
    image_index,    // frame atual da animação
    _sx, _sy,
    _escala, _escala,
    0,              // rotação
    c_white,
    1               // alpha
);


// Overlay de fade-out durante transição (Play/Exit)
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
}
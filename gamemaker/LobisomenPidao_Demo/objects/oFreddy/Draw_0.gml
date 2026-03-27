draw_self();
draw_path(path, x, y, 1);

// --- Desenha cone de visão ---
var _steps      = 24;                  // suavidade do arco
var _half       = fov_angle / 2;
var _facing     = image_angle;
var _col        = can_see_player ? c_red : c_yellow;

// Preenchimento semi-transparente
draw_set_alpha(0.15);
draw_set_color(_col);
draw_primitive_begin(pr_trianglefan);
    draw_vertex(x, y);
    for (var i = 0; i <= _steps; i++) {
        var _ang = _facing - _half + (fov_angle * i / _steps);
        draw_vertex(
            x + lengthdir_x(fov_range, _ang),
            y + lengthdir_y(fov_range, _ang)
        );
    }
draw_primitive_end();

// Borda do cone
draw_set_alpha(0.6);
draw_set_color(_col);
draw_primitive_begin(pr_linestrip);
    draw_vertex(x, y);
    draw_vertex(x + lengthdir_x(fov_range, _facing - _half),
                y + lengthdir_y(fov_range, _facing - _half));
    for (var i = 0; i <= _steps; i++) {
        var _ang = _facing - _half + (fov_angle * i / _steps);
        draw_vertex(
            x + lengthdir_x(fov_range, _ang),
            y + lengthdir_y(fov_range, _ang)
        );
    }
    draw_vertex(x + lengthdir_x(fov_range, _facing + _half),
                y + lengthdir_y(fov_range, _facing + _half));
    draw_vertex(x, y);
draw_primitive_end();

// Restaura valores padrão
draw_set_alpha(1);
draw_set_color(c_white);
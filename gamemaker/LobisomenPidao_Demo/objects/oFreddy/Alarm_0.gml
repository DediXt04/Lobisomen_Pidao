path_delete(path);
path = path_add();

// --- Checa campo de visão ---
var _dist       = point_distance(x, y, oPlayer.x, oPlayer.y);
var _dir_player = point_direction(x, y, oPlayer.x, oPlayer.y);
var _diff       = abs(angle_difference(image_angle, _dir_player));

var _no_wall    = (collision_line(x, y, oPlayer.x, oPlayer.y, oWall, false, false) == noone);

can_see_player = (_dist <= fov_range) && (_diff <= fov_angle / 2) && _no_wall;

// Só persegue se o player estiver no campo de visão
if (can_see_player) {
    target_x = oPlayer.x;
    target_y = oPlayer.y;

    mp_grid_path(oController.grid, path, x, y, target_x, target_y, 1);
    path_start(path, 1.3, path_action_stop, true);
}

alarm_set(0, 10);
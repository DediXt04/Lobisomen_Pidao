function scr_pegar_destino_valido(_x, _y) {
    var _path = path_add();
    
    repeat (20) {
        var _tx = random(room_width);
        var _ty = random(room_height);
        
        if (mp_grid_path(oController.grid, _path, _x, _y, _tx, _ty, 1)) {
            path_delete(_path);
            return [_tx, _ty];
        }
    }
    
    path_delete(_path);
    return [_x, _y];
}
function scr_escolherDirecao(_spd = moveSpd, _min_px = 16, _max_px = 64, _diagonal = false) {
    var _h = 0;
    var _v = 0;

    if (_diagonal) {
        // 8 direções (4 cardinais + 4 diagonais)
        var d = irandom(7);

        switch (d) {
            case 0: _h =  1;          break; // direita
            case 1: _h = -1;          break; // esquerda
            case 2: _v =  1;          break; // baixo
            case 3: _v = -1;          break; // cima
            case 4: _h =  1; _v = -1; break; // ↗ direita-cima
            case 5: _h = -1; _v = -1; break; // ↖ esquerda-cima
            case 6: _h =  1; _v =  1; break; // ↘ direita-baixo
            case 7: _h = -1; _v =  1; break; // ↙ esquerda-baixo
        }
    } else {
        // 4 direções (comportamento original)
        var d = irandom(3);

        switch (d) {
            case 0: _h =  1; break; // direita
            case 1: _h = -1; break; // esquerda
            case 2: _v =  1; break; // baixo
            case 3: _v = -1; break; // cima
        }
    }

    // Normalização (mesmo padrão do oPlayer)
    var _dir   = point_direction(0, 0, _h, _v);
    var _level = clamp(point_distance(0, 0, _h, _v), 0, 1);

    xspd = lengthdir_x(_spd * _level, _dir);
    yspd = lengthdir_y(_spd * _level, _dir);

    pixels_walked = irandom_range(_min_px, _max_px);

    // re-sorteia o timer para a próxima mudança de direção
    timer_max = irandom_range(timer_min, timer_max_base);
}
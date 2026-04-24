function scr_drawVida(_vida, _vidaMax)
{
    var _totalHeart   = _vidaMax / 2;
    var _currentHeart = floor(_vida / 2);
    var _partHeart    = _vida - (_currentHeart * 2);
    var _scale        = 5.5;
    var _spriteW      = sprite_get_width(sVida);
    var _marginx      = 5;
    var _marginy      = 15;
    var _spacing      = _spriteW * _scale + 4;

    for (var i = 0; i < _totalHeart; i++)
    {
        var _x = _marginx + (_spacing * i);
        var _y = _marginy;

        if (i < _currentHeart)
            draw_sprite_ext(sVida, 2, _x, _y, _scale, _scale, 0, c_white, 1);
        else if (i == _currentHeart && _partHeart != 0)
            draw_sprite_ext(sVida, _partHeart, _x, _y, _scale, _scale, 0, c_white, 1);
        else
            draw_sprite_ext(sVida, 0, _x, _y, _scale, _scale, 0, c_white, 1);
    }
	
}
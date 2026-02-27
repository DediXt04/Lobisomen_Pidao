function scr_drawFome(_fome, _fomeMax)
{
    var _barraTotal  = 1;
    var _segPorBarra = _fomeMax / _barraTotal;
    var _barraCheias = floor(_fome / _segPorBarra);
    var _parteBarra  = (_fome mod _segPorBarra) / _segPorBarra;
    var _framesTotal = 9;
    var _scale       = 5.5;
    var _spriteW     = sprite_get_width(sFomeG);
	var _spriteWVida     = sprite_get_width(sVida);
    var _marginx     = 20;
    var _marginy     = 60;  
    var _spacing     = _spriteWVida * _scale + 4;

    for (var i = 0; i < _barraTotal; i++)
    {
        var _x = _marginx + (_spacing * i);
        var _y = _marginy;

        if (i < _barraCheias)
            draw_sprite_ext(sFomeG, _framesTotal, _x, _y, _scale, _scale, 0, c_white, 1);
        else if (i == _barraCheias && _fome > 0)
            draw_sprite_ext(sFomeG, round(_parteBarra * _framesTotal), _x, _y, _scale, _scale, 0, c_white, 1);
        else
            draw_sprite_ext(sFomeG, 0, _x, _y, _scale, _scale, 0, c_white, 1);
    }
    
}
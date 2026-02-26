//Draw vida
#region
var _totalHeart = vidaMax/2;
var _currentHeart = floor(vida /2);
var _partHeart = vida - (_currentHeart * 2);
var _remainingHeart = _totalHeart - _currentHeart;

var _marginx = 5;
var _marginy = 15;
var _spacing = 20;

var _scale = 5.5;

var _spriteW = sprite_get_width(sVida);
var _spacing = _spriteW * _scale + 4; // 4 = espacinho extra

for(var i = 0; i < _totalHeart; i++)
{
    var _x = _marginx + (_spacing * i);
    var _y = _marginy;
    
    if (i < _currentHeart)
    {
        draw_sprite_ext(sVida, 2, _x, _y, _scale, _scale, 0, c_white, 1);
    }
    else if (i == _currentHeart && _partHeart != 0)
    {
        draw_sprite_ext(sVida, _partHeart, _x, _y, _scale, _scale, 0, c_white, 1);
    }
    else
    {
        draw_sprite_ext(sVida, 0, _x, _y, _scale, _scale, 0, c_white, 1);
    }
}
#endregion

//Draw comida
#region
draw_sprite_ext(sPizza, 0, 20, 95, 5, 5, 0, c_white,1);

draw_set_font(fnt_pixel);

draw_set_colour(c_white);

draw_text(100, 105, "x" + string(comida));

#endregion

//Draw fome
draw_text_transformed(20,200,string(tempoFome) + "s",2,2,0);

//input teclado e gamepad
#region
// input
var _right = keyboard_check(ord("D"));
var _left  = keyboard_check(ord("A"));
var _up    = keyboard_check(ord("W"));
var _down  = keyboard_check(ord("S"));

// gamepad
var _gp = global.gamepad_main;
if (_gp != undefined)
{
    var _horizontalGp = gamepad_axis_value(_gp, gp_axislh);  // era gp_axislh0; (erro de sintaxe)
    var _verticalGp   = gamepad_axis_value(_gp, gp_axislv);

    // dead zone para evitar drift do analógico
    var _deadzone = 0.2;
    if (abs(_horizontalGp) < _deadzone) _horizontalGp = 0;
    if (abs(_verticalGp)   < _deadzone) _verticalGp   = 0;

    // sobrescreve teclado se o analógico estiver sendo usado
    _right = _right || (_horizontalGp > 0);
    _left  = _left  || (_horizontalGp < 0);
    _down  = _down  || (_verticalGp   > 0);
    _up    = _up    || (_verticalGp   < 0);
}
#endregion

// escolher sprites lobo
#region
var _novoEstado = (oController.tempoFome <= oController.tempoMax * 0.25);

if (_novoEstado != faminto)
{
    faminto = _novoEstado;

    if (faminto)
    {
		moveSpd = 2.5;
        sprite[0] = sLoboSideHungry;
        sprite[1] = sLoboDUpHungry;
        sprite[2] = sLoboUpHungry;
        sprite[3] = sLoboDownHungry;
        sprite[4] = sLoboDDownHungry;
    }
    else
    {
        sprite[0] = sLoboSide;
        sprite[1] = sLoboDUp;
        sprite[2] = sLoboUp;
        sprite[3] = sLoboDown;
        sprite[4] = sLoboDDown;
    }
}
#endregion

// movimento
#region
var _horizKey = _right - _left;
var _vertKey  = _down  - _up;
moveDir = point_direction(0, 0, _horizKey, _vertKey);

var _inputLevel = clamp(point_distance(0, 0, _horizKey, _vertKey), 0, 1);

var move_x = lengthdir_x(moveSpd * _inputLevel, moveDir);
var move_y = lengthdir_y(moveSpd * _inputLevel, moveDir);

xspd = move_x + knock_x;
yspd = move_y + knock_y;


if place_meeting(x + xspd, y, oWall) xspd = 0;
if place_meeting(x, y + yspd, oWall) yspd = 0;

x += xspd;
y += yspd;
knock_x = lerp(knock_x, 0, 0.2);
knock_y = lerp(knock_y, 0, 0.2);

depth = -bbox_bottom;
#endregion

// sprite control
#region
if _horizKey != 0 || _vertKey != 0
{
    if _horizKey != 0 && _vertKey == 0  { face = 0; image_xscale = (_horizKey == 1) ? 1 : -1; }
    if _horizKey == 0 && _vertKey != 0  { face = (_vertKey == -1) ? 2 : 3; image_xscale = 1; }
    if _horizKey != 0 && _vertKey == -1 { face = 1; image_xscale = (_horizKey == 1) ? 1 : -1; }
    if _horizKey != 0 && _vertKey == 1  { face = 4; image_xscale = (_horizKey == 1) ? 1 : -1; }
}

if xspd == 0 && yspd == 0 image_index = 0;

mask_index   = sprite[3];
sprite_index = sprite[face];
#endregion

// invencibilidade
#region
if (invencivel)
{
    tempo_invencivel--;
	
    if (tempo_invencivel <= 0)
    {
        invencivel       = false;
        tempo_invencivel = 0;
    }
}
#endregion

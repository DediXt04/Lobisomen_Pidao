//Pausar
if (global.pausado) exit;

// Setando a profundidade de acordo com y
depth = -bbox_bottom;

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
    var _horizontalGp = gamepad_axis_value(_gp, gp_axislh);
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
if place_meeting(x + xspd, y, oNpc)  xspd = 0;

if place_meeting(x, y + yspd, oWall) yspd = 0;
if place_meeting(x, y + yspd, oNpc)  yspd = 0;

if (!global.temChave) {
    if place_meeting(x + xspd, y, oPorta) xspd = 0;
    if place_meeting(x, y + yspd, oPorta) yspd = 0;
}

//colisao com oSaida
if place_meeting(x + xspd, y, oSaida)
{
	if global.comidaCheia
	{
		room_goto(rm_Vitoria)
	}
	xspd = 0;
}
if place_meeting(x, y + yspd, oSaida)
{ 
	if global.comidaCheia
	{
		room_goto(rm_Vitoria)
	}
	yspd = 0;
}

x += xspd;
y += yspd;
knock_x = lerp(knock_x, 0, 0.2);
knock_y = lerp(knock_y, 0, 0.2);

#endregion

// escolher sprites lobo
#region
var _temInput = (_horizKey != 0 || _vertKey != 0);

if (oController.tempoFome <= oController.tempoMax * 0.25)
{
    faminto = true;
    moveSpd = 2.5;

    if (!_temInput)
    {
        sprite[0] = sLoboSideIdleH;
        sprite[1] = sLoboDUpIdleH;
        sprite[2] = sLoboUpIdleH;
        sprite[3] = sLoboDownIdleH;
        sprite[4] = sLoboDDownIdleH;
    }
    else
    {
        sprite[0] = sLoboSideHungry;
        sprite[1] = sLoboDUpHungry;
        sprite[2] = sLoboUpHungry;
        sprite[3] = sLoboDownHungry;
        sprite[4] = sLoboDDownHungry;
    }
}
else
{
    faminto = false;
    moveSpd = 2;

    if (!_temInput)
    {
        sprite[0] = sLoboSideIdle;
        sprite[1] = sLoboDUpIdle;
        sprite[2] = sLoboUpIdle;
        sprite[3] = sLoboDownIdle;
        sprite[4] = sLoboDDownIdle;
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

// sprite control
#region
// Se há input, atualiza direção e "acende" o timer de walk
if (_horizKey != 0 || _vertKey != 0)
{
    walk_timer = 10; // mantém animação de walk por 10 steps após soltar

    if _horizKey != 0 && _vertKey == 0  { face = 0; image_xscale = (_horizKey == 1) ? 1 : -1; }
    if _horizKey == 0 && _vertKey != 0  { face = (_vertKey == -1) ? 2 : 3; image_xscale = 1; }
    if _horizKey != 0 && _vertKey == -1 { face = 1; image_xscale = (_horizKey == 1) ? 1 : -1; }
    if _horizKey != 0 && _vertKey == 1  { face = 4; image_xscale = (_horizKey == 1) ? 1 : -1; }
}
else
{
    switch (face)
    {
        case 0: sprite[0] = faminto ? sLoboSideIdleH  : sLoboSideIdle;   break;
        case 1: sprite[1] = faminto ? sLoboDUpIdleH   : sLoboDUpIdle;    break;
        case 2: sprite[2] = faminto ? sLoboUpIdleH    : sLoboUpIdle;     break;
        case 3: sprite[3] = faminto ? sLoboDownIdleH  : sLoboDownIdle;   break;
        case 4: sprite[4] = faminto ? sLoboDDownIdleH : sLoboDDownIdle;  break;
    }
    image_speed = 1;
}

// Decrementa timer
if (walk_timer > 0) walk_timer--;

if (walk_timer == 0)
{
    image_speed = 1; // deixa a animação correr
}
mask_index   = sprite[3];
sprite_index = sprite[face];
depth = -y;
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

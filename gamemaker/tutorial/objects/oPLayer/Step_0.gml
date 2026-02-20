//get inputs
rightKey = keyboard_check(ord("D"));
leftKey  = keyboard_check(ord("A"));
upKey    = keyboard_check(ord("W"));
downKey  = keyboard_check(ord("S"));

//player movement
#region
//get the direction
var _horizKey = rightKey - leftKey;
var _vertKey  = downKey - upKey;
moveDir = point_direction( 0, 0, _horizKey, _vertKey );

//get the x and y speeds
var _spd = 0;
_inputLevel = point_distance( 0, 0, _horizKey, _vertKey );
_inputLevel = clamp(_inputLevel, 0 , 1);
_spd = moveSpd * _inputLevel;

xspd = lengthdir_x( _spd, moveDir );
yspd = lengthdir_y( _spd, moveDir );

//collision
if place_meeting(x + xspd, y, oWall)
{
	xspd = 0
}
if place_meeting(x, y + yspd, oWall)
{
	yspd = 0
}

//move the player

x += xspd;
y += yspd;

depth = -bbox_bottom;
#endregion

//player aiming
centerY = y + centerYOffset;

aimDir = point_direction(x, centerY, mouse_x, mouse_y);


//sprite control
#region
face = round(aimDir/90);
if face == 4{
	face = 0;
	};
	
//animate
if xspd == 0 && yspd == 0{
	image_index=0;
}



//set player sprite
mask_index = sprite[3];
sprite_index = sprite[face];
#endregion
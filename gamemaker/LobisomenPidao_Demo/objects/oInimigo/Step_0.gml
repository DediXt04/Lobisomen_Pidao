// Setando a profundidade de acordo com y
depth = -bbox_bottom;
 
// Executa Estado
estado();

// Movimento
#region
// colisão X
if (place_meeting(x + xspd, y, oWall)) xspd = 0;

// colisão Y
if (place_meeting(x, y + yspd, oWall)) yspd = 0;

// só usa movimento manual se NÃO estiver em path
if (!path_index)
{
    x += xspd;
    y += yspd;
}
#endregion

// Direção Visual
#region
if (xspd != 0)
{
    xscale = sign(xspd);
    image_xscale = xscale;
}
#endregion

//Trocar sprite
#region
if (path_index != -1)
{
    var dir = point_direction(xprevious, yprevious, x, y);

    var _h = sign(lengthdir_x(1, dir));
    var _v = sign(lengthdir_y(1, dir));

    if (_h != 0 && _v == 0)  { face = 0; image_xscale = _h; }
    if (_h == 0 && _v != 0)  { face = (_v == -1) ? 2 : 3; image_xscale = 1; }
    if (_h != 0 && _v == -1) { face = 1; image_xscale = _h; }
    if (_h != 0 && _v == 1)  { face = 4; image_xscale = _h; }

    sprite_index = sprite[face];
}
#endregion
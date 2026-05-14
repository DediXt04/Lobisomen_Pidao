// depth (ordem de desenho)
depth = -bbox_bottom;

// executa estado
estado();

// =======================
// MOVIMENTO (IGUAL PLAYER)
// =======================

// colisão X
if (place_meeting(x + xspd, y, oWall)) xspd = 0;

// colisão Y
if (place_meeting(x, y + yspd, oWall)) yspd = 0;

// aplica movimento
x += xspd;
y += yspd;

// =======================
// DIREÇÃO VISUAL
// =======================
if (xspd != 0)
{
    xscale = sign(xspd);
    image_xscale = xscale;
}


// sprite control
#region
var _h = sign(xspd);
var _v = sign(yspd);

// mesma lógica do player
if (_h != 0 && _v == 0)  { face = 0; image_xscale = _h; }
if (_h == 0 && _v != 0)  { face = (_v == -1) ? 2 : 3; image_xscale = 1; }
if (_h != 0 && _v == -1) { face = 1; image_xscale = _h; }
if (_h != 0 && _v == 1)  { face = 4; image_xscale = _h; }

// aplica sprite
sprite_index = sprite[face];
#endregion
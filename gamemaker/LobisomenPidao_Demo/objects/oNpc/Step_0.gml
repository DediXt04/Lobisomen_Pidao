timer++;
if (timer >= timer_max) {
    timer = 0;
    scr_escolherDirecao();
}

if (pixels_walked > 0) {

    if (vx != 0) {
        if place_meeting(x + vx, y, oWall)   { pixels_walked = 0; vx = 0; }
        if place_meeting(x + vx, y, oPlayer) { pixels_walked = 0; vx = 0; }
        if (vx != 0) { x += vx; pixels_walked -= abs(vx); }
    }

    if (vy != 0) {
        if place_meeting(x, y + vy, oWall)   { pixels_walked = 0; vy = 0; }
        if place_meeting(x, y + vy, oPlayer) { pixels_walked = 0; vy = 0; }
        if (vy != 0) { y += vy; pixels_walked -= abs(vy); }
    }
}
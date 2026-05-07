function scr_initMovimento(_spd = 2, _timer_min = 90, _timer_max = 300) {
    moveSpd        = _spd;
    xspd           = 0;
    yspd           = 0;
    timer          = 0;
    timer_min      = _timer_min;
    timer_max_base = _timer_max;
    timer_max      = irandom_range(_timer_min, _timer_max);
    pixels_walked  = 0;
}
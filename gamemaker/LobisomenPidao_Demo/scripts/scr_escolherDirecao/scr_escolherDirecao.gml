function scr_escolherDirecao() {
    var d = irandom(3);
    xspd = 0;
    yspd = 0;

    switch (d) {
        case 0: xspd =  moveSpd; break; // direita
        case 1: xspd = -moveSpd; break; // esquerda
        case 2: yspd =  moveSpd; break; // baixo
        case 3: yspd = -moveSpd; break; // cima
    }

    pixels_walked = irandom_range(16, 64);
}
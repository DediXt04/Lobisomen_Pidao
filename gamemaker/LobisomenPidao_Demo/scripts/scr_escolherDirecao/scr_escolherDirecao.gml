function scr_escolherDirecao() {
    var d = irandom(3);
    vx = 0;
    vy = 0;

    switch (d) {
        case 0: vx =  move_speed; break; // direita
        case 1: vx = -move_speed; break; // esquerda
        case 2: vy =  move_speed; break; // baixo
        case 3: vy = -move_speed; break; // cima
    }

    pixels_walked = irandom_range(16, 64); // distância aleatória entre 16 e 64 pixels
}
//Pausar
if (global.pausado) exit;

// muda sprite
if (!global.comidaCheia) {
    sprite_index = sPorta2Fechada;
} else {
    sprite_index = sPorta2Aberta;
}
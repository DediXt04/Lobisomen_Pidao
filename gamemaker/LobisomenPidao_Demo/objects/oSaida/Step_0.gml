//Pausar
if (global.pausado) exit;

// muda sprite
if (!global.comidaCheia) {
    sprite_index = sPortaFechada;
} else {
    sprite_index = sPortaAberta;
}
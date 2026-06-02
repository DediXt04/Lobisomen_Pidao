// Pausar
if (global.pausado) exit;

// Muda sprite baseado na chave
if (global.temChave) {
    sprite_index = sPortaDestrancada;
} else {
    sprite_index = sPortaTrancada;
}
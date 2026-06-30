// Pausar
if (global.pausado) exit;

// Profundidade baseada em Y (mesmo padrão dos outros objetos de gameplay)
depth = -bbox_bottom;

// Muda sprite baseado na chave
if (global.temChave) {
    sprite_index = sPortaDestrancada;
} else {
    sprite_index = sPortaTrancada;
}
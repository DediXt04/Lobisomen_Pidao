// === INTRODUÇÃO NARRATIVA ===
intro_ativa = true;
intro_pagina = 0;
intro_timer = 30;       // anti-skip inicial
intro_alpha = 0;        // fade-in

intro_textos[0]  = "...";
intro_textos[1]  = "Fome...";
intro_textos[2]  = "Muita fome...";
intro_textos[3]  = "Eu poderia simplesmente atacar alguém...";
intro_textos[4]  = "Mas não. Eu sei que no fundo...\neu sou humano.";
intro_textos[5]  = "Então vou fazer a coisa certa.";
intro_textos[6]  = "Vou PEDIR comida.";
intro_textos[7]  = "Pedir. Insistir. Encher o saco.";
intro_textos[8]  = "Até alguém me dar algo\nou me expulsar.";
intro_textos[9]  = "...Esse é o meu destino\ncomo lobo pidão.";
intro_total = array_length(intro_textos);

// Pausa o jogo durante a intro
global.pausado = true;


// === Estado do tutorial ===
dica_atual      = -1;      // qual dica está sendo exibida (-1 = nenhuma)
mostrando_dica  = false;   // se está exibindo uma dica na tela
dica_timer      = 0;       // tempo mínimo antes de poder fechar a dica (anti-skip)
dica_alpha      = 0;       // alpha para fade-in da caixa

// === Textos das dicas ===
// Índice 0 não é usado (dicas começam em 1)
dica_textos[0] = "";

dica_textos[1] = "Use WASD para se mover!\nExplore o mapa e encontre comida.";
dica_textos[2] = "Chegue perto da comida e aperte [E]/[Espaço] para coletar!\nVocê precisa coletar toda a comida da fase.";
dica_textos[3] = "NPCs podem te dar comida!\nChegue perto e aperte [E]/[Espaço] para pedir.\nMas cuidado: eles podem recusar!";
dica_textos[4] = "Fique de olho na barra de fome no canto da tela!\nSe ela acabar, é game over.\nSeja rápido!";
dica_textos[5] = "Vê aquela chave brilhando?\nPegue-a com [E]/[Espaço] para abrir o portão à frente!";
dica_textos[6] = "Cuidado com os guardas!\nSe eles te virem, vão te perseguir e atacar.\nTente passar sem ser visto!";
dica_textos[7] = "Colete toda a comida e a porta de saída vai abrir!\nEntre nela para completar a fase. Boa sorte!";

// Textos com suporte a gamepad (troca "[E]/[Espaço]" por "[A]" se gamepad conectado)
// Isso é feito dinamicamente no Draw

// === Visual ===
caixa_cor_fundo = make_colour_rgb(14, 14, 26);   // navy escuro
caixa_cor_borda = make_colour_rgb(80, 200, 210);  // teal
caixa_cor_texto = c_white;
caixa_cor_dica  = make_colour_rgb(80, 200, 210);  // teal para "aperte X para continuar"


/// @function mostrar_dica(_id)
/// @description Ativa a exibição de uma dica na tela
mostrar_dica = function(_id)
{
    if (_id < 1 || _id > array_length(dica_textos) - 1) exit;

    dica_atual     = _id;
    mostrando_dica = true;
    dica_timer     = 30;   // 30 frames (~0.5s) antes de poder fechar
    dica_alpha     = 0;    // começa invisível para fade-in

    // Pausa o jogo enquanto mostra a dica
    global.pausado = true;
};
// =====================================================
// FASE A: Transição final (Play/Exit confirmados) — congela tudo
// =====================================================
if (input_bloqueado) {
    timer_transicao--;
    fade_alpha = min(1, fade_alpha + FADE_VELOCIDADE);

    if (timer_transicao <= 0) {
        switch (estado) {
            case ESTADO_CONF_PLAY: room_goto(rm_SelecaoDeFases); break;
            case ESTADO_CONF_EXIT: game_end();                   break;
        }
    }
    exit;
}

// =====================================================
// FASE B: Segurança — sair se o menu não existir
// =====================================================
if (!instance_exists(oMenuPrincipal)) exit;

var _focado = oMenuPrincipal.botao_focado;
var _confirmou = instance_exists(oMenuPrincipal)
               ? oMenuPrincipal.confirmou_neste_frame
               : false;

// =====================================================
// FASE C: Confirmação (apertou Enter/E/Space/A)
// =====================================================
if (_confirmou) {
    switch (_focado) {
        case 0: // Play → feliz + delay
            estado          = ESTADO_CONF_PLAY;
            sprite_index    = sLoboMenuFeliz;
            timer_transicao = TIMER_DELAY_CONFIRMACAO;
            input_bloqueado = true;
            break;

        case 1: // Settings → vai direto (sem delay), mantém o sprite de óculos
            estado       = ESTADO_CONF_SETTINGS;
            sprite_index = sLoboMenuOculos;
            room_goto(rm_Settings);
            break;

        case 2: // Exit → triste + delay
            estado          = ESTADO_CONF_EXIT;
            sprite_index    = sLoboMenuTriste;
            timer_transicao = TIMER_DELAY_CONFIRMACAO;
            input_bloqueado = true;
            break;
    }
    timer_inatividade = 0;
    ultimo_focado = _focado;
    exit;
}

// =====================================================
// FASE D: Mudança de foco (jogador navegou)
// =====================================================
var _mudou_foco = (_focado != ultimo_focado);

if (_mudou_foco) {
    timer_inatividade = 0;

    switch (_focado) {
        case 0: estado = ESTADO_FOCO_PLAY;     sprite_index = sLoboMenuPiscando; break;
        case 1: estado = ESTADO_FOCO_SETTINGS; sprite_index = sLoboMenuOculos;   break;
        case 2: estado = ESTADO_FOCO_EXIT;     sprite_index = sLoboMenuBravo;    break;
    }

    ultimo_focado = _focado;
    exit;
}

// =====================================================
// FASE E: Inatividade — escalação em 3 estágios
// =====================================================
timer_inatividade++;

// Verificar do estágio mais avançado pro mais inicial (evita "pular" estágios)
if (estado != ESTADO_INATIVO_3_VELHO && timer_inatividade >= TIMER_INATIVO_3_FRAMES) {
    estado = ESTADO_INATIVO_3_VELHO;
    sprite_index = sLoboMenuEnvelhecendo;
}
else if (estado != ESTADO_INATIVO_3_VELHO
      && estado != ESTADO_INATIVO_2_DORMINDO
      && timer_inatividade >= TIMER_INATIVO_2_FRAMES) {
    estado = ESTADO_INATIVO_2_DORMINDO;
    sprite_index = sLoboMenuDormindo;
}
else if (estado != ESTADO_INATIVO_3_VELHO
      && estado != ESTADO_INATIVO_2_DORMINDO
      && estado != ESTADO_INATIVO_1_REVIRANDO
      && timer_inatividade >= TIMER_INATIVO_1_FRAMES) {
    estado = ESTADO_INATIVO_1_REVIRANDO;
    sprite_index = sLoboMenuRevirando;
}
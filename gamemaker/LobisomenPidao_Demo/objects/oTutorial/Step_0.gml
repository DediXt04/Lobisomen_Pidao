// ===============================================================
// INTRODUÇÃO NARRATIVA
// ===============================================================
if (intro_ativa) {

    // Fade-in
    if (intro_alpha < 1) {
        intro_alpha = min(intro_alpha + 0.05, 1);
    }

    // Timer anti-skip
    if (intro_timer > 0) {
        intro_timer--;
        exit;
    }

    // Input para avançar página
    var _avancar = false;

    if (keyboard_check_pressed(ord("E"))
     || keyboard_check_pressed(vk_space)
     || keyboard_check_pressed(vk_enter))
    {
        _avancar = true;
    }

    if (global.gamepad_main != undefined) {
        if (gamepad_button_check_pressed(global.gamepad_main, gp_face1)) {
            _avancar = true;
        }
    }

    if (_avancar) {
        intro_pagina++;
        intro_timer = 10;  // cooldown curto entre páginas

        // Acabou a intro?
        if (intro_pagina >= intro_total) {
            intro_ativa = false;
            global.pausado = false;
        }
    }
	// Pular intro inteira com ESC / Start
	var _skip = keyboard_check_pressed(vk_escape);
	if (global.gamepad_main != undefined) {
		_skip = _skip || gamepad_button_check_pressed(global.gamepad_main, gp_start);
	}

	if (_skip) {
		intro_ativa = false;
		intro_pagina = intro_total;
		global.pausado = false;
	}

    exit; // Bloqueia o resto do Step durante a intro
}

// Só processa se está mostrando uma dica
if (!mostrando_dica) exit;

// Fade-in da caixa
if (dica_alpha < 1)
{
    dica_alpha = min(dica_alpha + 0.08, 1);
}

// Timer anti-skip (evita fechar acidentalmente)
if (dica_timer > 0)
{
    dica_timer--;
    exit;
}

// Detecta input para fechar a dica
var _fechar = false;

// Teclado
if (keyboard_check_pressed(ord("E"))
 || keyboard_check_pressed(vk_space)
 || keyboard_check_pressed(vk_enter))
{
    _fechar = true;
}

// Gamepad
if (global.gamepad_main != undefined)
{
    if (gamepad_button_check_pressed(global.gamepad_main, gp_face1))
    {
        _fechar = true;
    }
}

// Fecha a dica e despausa
if (_fechar)
{
    mostrando_dica = false;
    dica_atual     = -1;
    dica_alpha     = 0;
    global.pausado = false;
}
if (!intro_ativa && !mostrando_dica) exit;

// ===============================================================
// DESENHO DA INTRODUÇÃO NARRATIVA
// ===============================================================
if (intro_ativa) {
    var _gui_w = display_get_gui_width();
    var _gui_h = display_get_gui_height();
    var _cx = _gui_w / 2;
    var _cy = _gui_h / 2;

    // Fundo totalmente escuro (fade-in)
    draw_set_alpha(intro_alpha * 0.95);
    draw_set_colour(make_colour_rgb(8, 8, 14));
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);

    // Caixa de diálogo centralizada
    var _box_w = _gui_w * 0.65;
    var _box_h = 160;
    var _box_x = (_gui_w - _box_w) / 2;
    var _box_y = _gui_h - _box_h - 80;

    // Fundo da caixa
    draw_set_alpha(intro_alpha * 0.85);
    draw_set_colour(make_colour_rgb(14, 14, 26));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

    // Borda teal
    draw_set_alpha(intro_alpha * 0.7);
    draw_set_colour(make_colour_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);

    // Linha superior decorativa
    draw_set_alpha(intro_alpha);
    draw_set_colour(make_colour_rgb(80, 200, 210));
    draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + 3, false);

    // Texto da página atual
    draw_set_font(fnt_pixel);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_alpha(intro_alpha);
    draw_set_colour(c_white);

    if (intro_pagina < intro_total) {
        draw_text_ext(
            _cx,
            _box_y + _box_h / 2 - 15,
            intro_textos[intro_pagina],
            22,
            _box_w - 60
        );
    }

    // "Aperte E para continuar" (pisca)
    if (intro_timer <= 0) {
        var _pisca = (sin(current_time / 300) + 1) / 2;
        draw_set_alpha(intro_alpha * (0.4 + _pisca * 0.6));
        draw_set_colour(make_colour_rgb(80, 200, 210));
        draw_set_valign(fa_top);

        var _btn_texto = "[E]/[Espaço] para continuar";
        if (global.gamepad_main != undefined) {
            _btn_texto = "[A] para continuar";
        }
        draw_text(_cx, _box_y + _box_h - 35, _btn_texto);
    }

    // Reset
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_colour(c_white);
	
	// Indicador de skip (canto superior direito)
	draw_set_alpha(intro_alpha * 0.4);
	draw_set_colour(make_colour_rgb(100, 120, 130));
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	draw_set_font(fnt_pixel);

	var _skip_texto = "ESC para pular";
	if (global.gamepad_main != undefined) {
		_skip_texto = "START para pular";
	}
	draw_text(_gui_w - 30, 30, _skip_texto);
    exit; // Não desenha dicas de gameplay durante a intro
}


if (!mostrando_dica) exit;
if (dica_atual < 1) exit;

// === Dimensões da caixa ===
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

var _box_w = _gui_w * 0.7;      // 70% da largura da tela
var _box_h = 200;                // altura da caixa
var _box_x = (_gui_w - _box_w) / 2;  // centralizado horizontalmente
var _box_y = _gui_h - _box_h - 60;   // próximo ao rodapé da tela

// === Texto da dica ===
var _texto = dica_textos[dica_atual];

// Troca "[E]/[Espaço]" por "[A]" se gamepad estiver conectado
if (global.gamepad_main != undefined)
{
    _texto = string_replace_all(_texto, "[E]/[Espaço]", "[A]");
    _texto = string_replace_all(_texto, "WASD", "Analógico");
}

// === Desenha fundo semi-transparente da tela (escurece o jogo) ===
draw_set_alpha(dica_alpha * 0.4);
draw_set_colour(c_black);
draw_rectangle(0, 0, _gui_w, _gui_h, false);

// === Desenha caixa de diálogo ===
draw_set_alpha(dica_alpha * 0.9);

// Fundo da caixa
draw_set_colour(caixa_cor_fundo);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, false);

// Borda da caixa (teal)
draw_set_colour(caixa_cor_borda);
draw_rectangle(_box_x, _box_y, _box_x + _box_w, _box_y + _box_h, true);

// === Desenha texto da dica ===
draw_set_alpha(dica_alpha);
draw_set_font(fnt_pixel);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_colour(caixa_cor_texto);

// Texto principal (centralizado na caixa)
draw_text_ext(
    _box_x + _box_w / 2,
    _box_y + _box_h / 2 - 20,
    _texto,
    24,           // separação entre linhas
    _box_w - 40   // largura máxima do texto (com margem)
);

// === Texto "aperte para continuar" (pisca) ===
var _pisca = (sin(current_time / 300) + 1) / 2;  // valor entre 0 e 1
draw_set_colour(caixa_cor_dica);
draw_set_alpha(dica_alpha * (0.5 + _pisca * 0.5));
draw_set_halign(fa_center);
draw_set_valign(fa_top);

var _continuar_texto = "Aperte [E]/[Espaço] para continuar";
if (global.gamepad_main != undefined)
{
    _continuar_texto = "Aperte [A] para continuar";
}

draw_text(
    _box_x + _box_w / 2,
    _box_y + _box_h - 40,
    _continuar_texto
);

// === Reset do draw state ===
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_colour(c_white);
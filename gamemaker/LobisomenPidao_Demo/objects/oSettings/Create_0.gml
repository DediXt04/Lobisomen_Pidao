// === BOTÕES ===
botoes = ["Resetar Progresso", "Voltar"];
total_botoes = array_length(botoes);
botao_focado = 0;

// === NAVEGAÇÃO ===
nav_cooldown = 0;
NAV_COOLDOWN_MAX = 12;
input_mode = "teclado";
DEADZONE = 0.5;

// === CONFIRMAÇÃO ===
confirmando = false;
conf_selecionado = 1;  // padrão em "Não" (mais seguro)
conf_opcoes = ["Sim", "Não"];
conf_total = 2;
conf_nav_cooldown = 0;

// === LAYOUT ===
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();
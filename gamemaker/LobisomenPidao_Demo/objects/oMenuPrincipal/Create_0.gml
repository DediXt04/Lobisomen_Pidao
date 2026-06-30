confirmou_neste_frame = false;

// === BOTÕES ===
botoes = ["Jogar", "Configurações", "Sair"];
total_botoes = array_length(botoes);
botao_focado = 0;

// === LAYOUT (canto inferior direito) ===
// Resolução base da GUI (fixa, independente de câmera)
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

// Margem a partir do canto inferior direito da tela
margem_direita = 120;   // distância da borda direita
margem_inferior = 100;  // distância da borda inferior

// Dimensões dos botões
btn_w = 280;
btn_h = 50;
btn_gap = 16;  // espaço vertical entre botões

// Posição X dos botões (alinhados à direita)
btn_x = gui_w - margem_direita - btn_w;

// Posição Y do grupo (calculada de baixo para cima)
// Altura total: 3 botões + 2 gaps + espaço pro título
var _altura_botoes = total_botoes * btn_h + (total_botoes - 1) * btn_gap;
var _espaco_titulo = 80;  // espaço entre título e primeiro botão

btn_y_inicio = gui_h - margem_inferior - _altura_botoes;

// Posição do título (acima dos botões)
titulo_x = btn_x + btn_w / 2;  // centralizado com os botões
titulo_y = btn_y_inicio - _espaco_titulo;

// === NAVEGAÇÃO ===
nav_cooldown = 0;
NAV_COOLDOWN_MAX = 12;  // frames entre inputs (evita rapidez)
input_mode = "teclado";
DEADZONE = 0.5;

// === CONFIRMAÇÃO DE SAÍDA ===
confirmando = false;
conf_selecionado = 1;            // padrão em "Não" (mais seguro)
conf_opcoes = ["Sim", "Não"];
conf_total = array_length(conf_opcoes);
conf_nav_cooldown = 0;
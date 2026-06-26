// Verifica se existe próxima fase
tem_proxima = (global.fase_atual < global.total_fases - 1);

// Botões dinâmicos
btn_selecionado = 0;
if (tem_proxima) {
    btn_opcoes = ["Próxima Fase", "Reiniciar Fase", "Voltar ao Menu"];
} else {
    btn_opcoes = ["Reiniciar Fase", "Voltar ao Menu"];
}
btn_total = array_length(btn_opcoes);
btn_nav_cooldown = 0;
BTN_NAV_CD_MAX = 12;
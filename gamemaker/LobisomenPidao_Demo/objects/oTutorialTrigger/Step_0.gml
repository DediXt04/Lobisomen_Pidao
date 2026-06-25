if (global.pausado) exit;

// Se já foi ativada, não faz nada
if (ativada) exit;

// Detecta se o player está dentro da zona
if (place_meeting(x, y, oPlayer))
{
    ativada = true;

    // Avisa o oTutorial para mostrar a dica correspondente
    with (oTutorial)
    {
        mostrar_dica(other.dica_id);
    }
}
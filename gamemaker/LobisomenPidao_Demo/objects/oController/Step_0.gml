// --- testes (remover depois) ---
if keyboard_check_pressed(ord("E")) comida += 1;
if keyboard_check_pressed(ord("R")) vida   -= 1;
if keyboard_check_pressed(ord("T")) vida   += 1;

// fome diminuindo
tempoFome -= delta_time / 1000000;
tempoFome  = max(tempoFome, 0);


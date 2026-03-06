//Calculo de dano
if (!oPlayer.invencivel){

	with (oController)
		{
			vida -= other.dano;
		}
}


//Knockback
if (!oPlayer.invencivel)
{
    var dir = point_direction(x, y, oPlayer.x, oPlayer.y);

    with (oPlayer)
    {
        // knockback
        knock_x = lengthdir_x(8, dir);
        knock_y = lengthdir_y(8, dir);

        // ativa invencibilidade
		invencivel       = true;
        tempo_invencivel = 90;	
    }
	
}
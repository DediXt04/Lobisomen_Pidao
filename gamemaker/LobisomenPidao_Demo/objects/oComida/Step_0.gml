//step
var _dist = point_distance(x, y, oPlayer.x, oPlayer.y);

//Flutuar
y = base_y + sin(current_time / 200) * 1.5;

if (_dist < 16 && oController.interagir)
{
    with (oController)
    {
        comida += other.valor;
    }
    instance_destroy();
}
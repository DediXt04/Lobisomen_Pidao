// Inherit the parent event
event_inherited();

// ESCOLHE AS SPRITES DE ACORDO COM FLAG
#region
if (xspd == 0 and yspd == 0)
{
	sprite[0] = sGuardaStopSide;
	sprite[1] = sGuardaStopDUp;
	sprite[2] = sGuardaStopUp;
	sprite[3] = sGuardaStopDown;
	sprite[4] = sGuardaStopDDown;
}
else
{
	sprite[0] = sGuardaSide;
	sprite[1] = sGuardaDUp;
	sprite[2] = sGuardaUp;
	sprite[3] = sGuardaDown;
	sprite[4] = sGuardaDDown;
}
#endregion
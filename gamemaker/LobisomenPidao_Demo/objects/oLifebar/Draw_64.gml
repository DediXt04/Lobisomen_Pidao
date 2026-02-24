//Draw lifebar
var amount = (life / life_max) * lifebar_w;
var amount_fixed = (life_max / life_max) * lifebar_w;//formula fixa
var amount_feedback = (life_feedback / life_max) * lifebar_w;//formula feedback
var x1 = (view_w / 2) - (lifebar_w / 2) ;
var y1 = view_h / 2;

var x2 = x1 + amount;
var x2_fixed = x1 + amount_fixed;//x2 fixo
var x2_feedback = x1 + amount_feedback;
var y2 = y1 + lifebar_h;


if (life > 0){
	//background
	draw_set_colour(color_2);
	draw_rectangle(x1,y1,x2_fixed,y2,false);
	
	//feedback
	draw_set_colour(color_4);
	draw_rectangle(x1,y1,x2_feedback,y2,false);

	//desenhando barra de vida
	draw_set_colour(color_1); //cor principal
	draw_rectangle(x1,y1,x2,y2,false);
	
	//borda
	draw_set_colour(color_2);
	draw_rectangle(x1,y1,x2_fixed,y2,true);
}
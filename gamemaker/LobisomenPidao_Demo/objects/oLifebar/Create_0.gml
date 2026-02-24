//camera display
view_w = camera_get_view_width(view_camera[0]);
view_h = camera_get_view_height(view_camera[0]);
display_set_gui_size(view_w, view_h)

//lifebar
life_max = 6;
life = life_max;
life_feedback = life_max;
lifebar_w = 80;
lifebar_h = 10;


color_1 = make_colour_rgb(255,0,64); // cor principal
color_2 = make_colour_rgb(19,19,19); // cor fundo
color_3 = make_colour_rgb(19,19,19); // borda
color_4 = c_white; //cor feeback
// Herda toda a lógica do oNpc (timers, interação, etc.)
event_inherited();

// Sobrescreve os arrays de sprite com a skin 2
sprite_walk[0] = sNpc2Side;
sprite_walk[2] = sNpc2Up;
sprite_walk[3] = sNpc2Down;
sprite_walk[4] = sNpc2DDown;
sprite_walk[5] = sNpc2DUp;

sprite_idle[0] = sNpc2SideIdle;
sprite_idle[2] = sNpc2UpIdle;
sprite_idle[3] = sNpc2DownIdle;
sprite_idle[4] = sNpc2DDownIdle;
sprite_idle[5] = sNpc2DUpIdle;

// Reset visual baseado nos novos arrays
sprite = sprite_idle;
sprite_index = sprite[face];
mask_index = sprite_walk[3];
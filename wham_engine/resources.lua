function resourceLoad()
--FONTS
	defaultFont = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 16)
	defaultFontBold = love.graphics.newFont("resources/fonts/Biryani-Bold.ttf", 16)
	defaultFontHuge = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 96)
	defaultFontSmol = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 10)
	--sets our default font on game launch
	love.graphics.setFont(defaultFont)
--CURSORS
	default_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_default.png", 0, 0)
	selection_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_selection.png", 0, 0)
	draw_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_draw.png", 0, 0)
	eraser_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_eraser.png", 0, 0)
	dropper_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_dropper.png", 0, 0)
--TEXTURES
	--Images
	block_all_IMG = love.graphics.newImage("resources/textures/block/block_sheet.png")
	ui_buttons_all_IMG = love.graphics.newImage("resources/textures/ui/button_sheet.png")
	ui_panels_all_IMG = love.graphics.newImage("resources/textures/ui/panel_sheet.png")
	--SpriteBatches
	block_SB = love.graphics.newSpriteBatch(block_all_IMG)
	button_SB = love.graphics.newSpriteBatch(ui_buttons_all_IMG)
	panel_SB = love.graphics.newSpriteBatch(ui_panels_all_IMG)
	--Quads
	--*blockQDs
	air_block_QD = love.graphics.newQuad(0, 0, 32, 32, block_all_IMG:getDimensions())
	dirt_block_QD = love.graphics.newQuad(34, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_QD = love.graphics.newQuad(68, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_r_QD = love.graphics.newQuad(102, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_l_QD = love.graphics.newQuad(136, 0, 32, 32, block_all_IMG:getDimensions())
	highlight_block_QD = love.graphics.newQuad(0, 34, 32, 32, block_all_IMG:getDimensions())
	player_spawn_QD = love.graphics.newQuad(34, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_u_QD = love.graphics.newQuad(68, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_r_QD = love.graphics.newQuad(102, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_d_QD = love.graphics.newQuad(136, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_l_QD = love.graphics.newQuad(170, 34, 32, 32, block_all_IMG:getDimensions())
	wooden_plat_QD = love.graphics.newQuad(204, 34, 32, 32, block_all_IMG:getDimensions())
	dev_block_QD = love.graphics.newQuad(0, 68, 32, 32, block_all_IMG:getDimensions())
	air_block_old_QD = love.graphics.newQuad(34, 68, 32, 32, block_all_IMG:getDimensions())
	item_block_QD = love.graphics.newQuad(68, 68, 32, 32, block_all_IMG:getDimensions())
	--*buttonQDS
	--**Long buttons
	resume_button_QD = love.graphics.newQuad(0, 0, 194, 49, ui_buttons_all_IMG:getDimensions())
	resume_button_QD_2 = love.graphics.newQuad(0, 49, 194, 49, ui_buttons_all_IMG:getDimensions())
	save_level_button_QD = love.graphics.newQuad(0, 98, 194, 49, ui_buttons_all_IMG:getDimensions())
	save_level_button_QD_2 = love.graphics.newQuad(0, 147, 194, 49, ui_buttons_all_IMG:getDimensions())
	load_level_button_QD = love.graphics.newQuad(0, 196, 194, 49, ui_buttons_all_IMG:getDimensions())
	load_level_button_QD_2 = love.graphics.newQuad(0, 245, 194, 49, ui_buttons_all_IMG:getDimensions())
	options_button_QD = love.graphics.newQuad(0, 294, 194, 49, ui_buttons_all_IMG:getDimensions())
	options_button_QD_2 = love.graphics.newQuad(0, 343, 194, 49, ui_buttons_all_IMG:getDimensions())
	quit_sesh_button_QD = love.graphics.newQuad(0, 392, 194, 49, ui_buttons_all_IMG:getDimensions())
	quit_sesh_button_QD_2 = love.graphics.newQuad(0, 441, 194, 49, ui_buttons_all_IMG:getDimensions())
	--**Small buttons
	select_button_QD = love.graphics.newQuad(194, 0, 50, 50, ui_buttons_all_IMG:getDimensions())
	select_button_QD_2 = love.graphics.newQuad(194, 50, 50, 50, ui_buttons_all_IMG:getDimensions())
	draw_button_QD = love.graphics.newQuad(194, 100, 50, 50, ui_buttons_all_IMG:getDimensions())
	draw_button_QD_2 = love.graphics.newQuad(194, 150, 50, 50, ui_buttons_all_IMG:getDimensions())
	eraser_button_QD = love.graphics.newQuad(194, 200, 50, 50, ui_buttons_all_IMG:getDimensions())
	eraser_button_QD_2 = love.graphics.newQuad(194, 250, 50, 50, ui_buttons_all_IMG:getDimensions())
	dropper_button_QD = love.graphics.newQuad(194, 300, 50, 50, ui_buttons_all_IMG:getDimensions())
	dropper_button_QD_2 = love.graphics.newQuad(194, 350, 50, 50, ui_buttons_all_IMG:getDimensions())
	--*panelQDS
	--**Saving/Loading
	saving_panel_QD = love.graphics.newQuad(0, 0, 298, 98, ui_panels_all_IMG:getDimensions())
	loading_panel_QD = love.graphics.newQuad(0, 98, 298, 98, ui_panels_all_IMG:getDimensions())
	browse_button_QD = love.graphics.newQuad(269, 401, 74, 24, ui_panels_all_IMG:getDimensions())
	browse_button_QD_2 = love.graphics.newQuad(269, 425, 74, 24, ui_panels_all_IMG:getDimensions())
	save_button_QD = love.graphics.newQuad(194, 401, 74, 24, ui_panels_all_IMG:getDimensions())
	save_button_QD_2 = love.graphics.newQuad(194, 425, 74, 24, ui_panels_all_IMG:getDimensions())
	load_button_QD = love.graphics.newQuad(194, 451, 74, 24, ui_panels_all_IMG:getDimensions())
	load_button_QD_2 = love.graphics.newQuad(194, 476, 74, 24, ui_panels_all_IMG:getDimensions())
	back_button_QD = love.graphics.newQuad(269, 451, 74, 24, ui_panels_all_IMG:getDimensions())
	back_button_QD_2 = love.graphics.newQuad(269, 476, 74, 24, ui_panels_all_IMG:getDimensions())
--ANIMATIONS
	--must initialize each animation table before adding indices to it
	player_idle = {}
	player_run = {}
	player_jump = {}
	player_front_flip = {}
	player_fall = {}
	player_crouch = {}
	player_crouch_walk = {}
	--Animation Tables
	player_idle[1] = love.graphics.newImage("resources/textures/player/idle/1.png")
		player_idle[2] = love.graphics.newImage("resources/textures/player/idle/2.png")
		player_idle[3] = love.graphics.newImage("resources/textures/player/idle/3.png")
		player_idle[4] = love.graphics.newImage("resources/textures/player/idle/4.png")
		player_idle[5] = love.graphics.newImage("resources/textures/player/idle/5.png")
		player_idle[6] = love.graphics.newImage("resources/textures/player/idle/6.png")
		player_idle[7] = love.graphics.newImage("resources/textures/player/idle/7.png")
	player_run[1] = love.graphics.newImage("resources/textures/player/run/1.png")
		player_run[2] = love.graphics.newImage("resources/textures/player/run/2.png")
		player_run[3] = love.graphics.newImage("resources/textures/player/run/3.png")
		player_run[4] = love.graphics.newImage("resources/textures/player/run/4.png")
		player_run[5] = love.graphics.newImage("resources/textures/player/run/5.png")
		player_run[6] = love.graphics.newImage("resources/textures/player/run/6.png")
		player_run[7] = love.graphics.newImage("resources/textures/player/run/7.png")
		player_run[8] = love.graphics.newImage("resources/textures/player/run/8.png")
	player_jump[1] = love.graphics.newImage("resources/textures/player/jump/1.png")
		player_jump[2] = love.graphics.newImage("resources/textures/player/jump/2.png")
		player_jump[3] = love.graphics.newImage("resources/textures/player/jump/3.png")
	player_front_flip[1] = love.graphics.newImage("resources/textures/player/front_flip/1.png")
		player_front_flip[2] = love.graphics.newImage("resources/textures/player/front_flip/2.png")
		player_front_flip[3] = love.graphics.newImage("resources/textures/player/front_flip/3.png")
		player_front_flip[4] = love.graphics.newImage("resources/textures/player/front_flip/4.png")
		player_front_flip[5] = love.graphics.newImage("resources/textures/player/front_flip/5.png")
		player_front_flip[6] = love.graphics.newImage("resources/textures/player/front_flip/6.png")
		player_front_flip[7] = love.graphics.newImage("resources/textures/player/front_flip/7.png")
		player_front_flip[8] = love.graphics.newImage("resources/textures/player/front_flip/8.png")
		player_front_flip[9] = love.graphics.newImage("resources/textures/player/front_flip/9.png")
		player_front_flip[10] = love.graphics.newImage("resources/textures/player/front_flip/10.png")
		player_front_flip[11] = love.graphics.newImage("resources/textures/player/front_flip/11.png")
		player_front_flip[12] = love.graphics.newImage("resources/textures/player/front_flip/12.png")
		player_front_flip[13] = love.graphics.newImage("resources/textures/player/front_flip/13.png")
	player_fall[1] = love.graphics.newImage("resources/textures/player/jump_fall/1.png")
	player_crouch[1] = love.graphics.newImage("resources/textures/player/crouch/1.png")
		player_crouch[2] = love.graphics.newImage("resources/textures/player/crouch/2.png")
		player_crouch[3] = love.graphics.newImage("resources/textures/player/crouch/3.png")
		player_crouch[4] = love.graphics.newImage("resources/textures/player/crouch/4.png")
		player_crouch[5] = love.graphics.newImage("resources/textures/player/crouch/5.png")
		player_crouch[6] = love.graphics.newImage("resources/textures/player/crouch/6.png")
	player_crouch_walk[1] = love.graphics.newImage("resources/textures/player/crawl/1.png")
		player_crouch_walk[2] = love.graphics.newImage("resources/textures/player/crawl/2.png")
		player_crouch_walk[3] = love.graphics.newImage("resources/textures/player/crawl/3.png")
		player_crouch_walk[4] = love.graphics.newImage("resources/textures/player/crawl/4.png")
		player_crouch_walk[5] = love.graphics.newImage("resources/textures/player/crawl/5.png")
		player_crouch_walk[6] = love.graphics.newImage("resources/textures/player/crawl/6.png")
		player_crouch_walk[7] = love.graphics.newImage("resources/textures/player/crawl/7.png")
		player_crouch_walk[8] = love.graphics.newImage("resources/textures/player/crawl/8.png")
--SOUNDS
	masterVolume = 1.0
	soundsVolume = 1.0
	jump_exert_SND = love.audio.newSource("resources/sounds/jump/exert.ogg", "static")
	footstep_hard_floor_SND = love.audio.newSource("resources/sounds/footsteps/hard_floor.ogg", "static")
	place_block_SND = love.audio.newSource("resources/sounds/ui/pop.ogg", "static")
	remove_block_SND = love.audio.newSource("resources/sounds/ui/erase_pop.ogg", "static")
	
	jump_exert_SND:setVolume(masterVolume * soundsVolume)
	footstep_hard_floor_SND:setVolume(masterVolume * soundsVolume)
	place_block_SND:setVolume(masterVolume * soundsVolume)
	remove_block_SND:setVolume(masterVolume * soundsVolume)
end
function fontLoad()
	--UI Fonts
	defaultFont = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 16)
	defaultFontHuge = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 96)
	--MENU Fonts
	font_panel_title = love.graphics.newFont("resources/fonts/Biryani-Bold.ttf", 64)
	font_panel_subtitle = love.graphics.newFont("resources/fonts/Biryani-Bold.ttf", 36)
	font_panel_subtitle2 = love.graphics.newFont("resources/fonts/Biryani-Bold.ttf", 18)
	defaultFontBold = love.graphics.newFont("resources/fonts/Biryani-Bold.ttf", 22)
	defaultFontSmol = love.graphics.newFont("resources/fonts/Biryani-Bold.ttf", 18)
	--KEYBIND BUTTON Font
	defaultKeyBindFont = love.graphics.newFont("resources/fonts/Blockletter.otf", 20)
	love.graphics.setFont(defaultFont)
end

function cursorLoad()
	default_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_default.png", 0, 0)
	selection_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_selection.png", 0, 0)
	draw_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_draw.png", 0, 0)
	eraser_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_eraser.png", 0, 0)
	dropper_cursor = love.mouse.newCursor("resources/textures/ui/cursors/cursor_dropper.png", 0, 0)
end

function resourceLoad()
	fontLoad()
	cursorLoad()
--TEXTURES
	--Images
	block_all_IMG = love.graphics.newImage("resources/textures/block/block_sheet.png")
	objects_all_IMG = love.graphics.newImage("resources/textures/objects/objects_sheet.png")
	ui_buttons_all_IMG = love.graphics.newImage("resources/textures/ui/button_sheet_redux.png")
	ui_panels_all_IMG = love.graphics.newImage("resources/textures/ui/panel_sheet_redux.png")
	--SpriteBatches
	block_SB = love.graphics.newSpriteBatch(block_all_IMG)
	objects_SB = love.graphics.newSpriteBatch(objects_all_IMG)
	button_SB = love.graphics.newSpriteBatch(ui_buttons_all_IMG)
	panel_SB = love.graphics.newSpriteBatch(ui_panels_all_IMG)
	--Quads
	--*blockQDs
	air_block_QD = love.graphics.newQuad(0, 0, 32, 32, block_all_IMG:getDimensions())
	dirt_block_QD = love.graphics.newQuad(34, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_QD = love.graphics.newQuad(68, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_r_QD = love.graphics.newQuad(102, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_l_QD = love.graphics.newQuad(136, 0, 32, 32, block_all_IMG:getDimensions())
	grass_block_d_QD = love.graphics.newQuad(170, 0, 32, 32, block_all_IMG:getDimensions())
	highlight_block_QD = love.graphics.newQuad(0, 34, 32, 32, block_all_IMG:getDimensions())
	player_spawn_QD = love.graphics.newQuad(34, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_u_QD = love.graphics.newQuad(68, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_r_QD = love.graphics.newQuad(102, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_d_QD = love.graphics.newQuad(136, 34, 32, 32, block_all_IMG:getDimensions())
	spike_block_l_QD = love.graphics.newQuad(170, 34, 32, 32, block_all_IMG:getDimensions())
	wooden_plat_QD = love.graphics.newQuad(204, 34, 32, 32, block_all_IMG:getDimensions())
	dev_block_QD = love.graphics.newQuad(0, 68, 32, 32, block_all_IMG:getDimensions())
	dev_block2_QD = love.graphics.newQuad(0, 102, 32, 32, block_all_IMG:getDimensions())
	air_block_old_QD = love.graphics.newQuad(34, 68, 32, 32, block_all_IMG:getDimensions())
	item_block_QD = love.graphics.newQuad(68, 68, 32, 32, block_all_IMG:getDimensions())
	water_block_QD = love.graphics.newQuad(102, 68, 32, 32, block_all_IMG:getDimensions())
	--*buttonQDS
	button_QD = love.graphics.newQuad(0, 0, 64, 64, ui_buttons_all_IMG:getDimensions())
	button_QD_2 = love.graphics.newQuad(0, 65, 64, 64, ui_buttons_all_IMG:getDimensions())
	--**Editor buttons
	select_button_QD = love.graphics.newQuad(0, 130, 64, 64, ui_buttons_all_IMG:getDimensions())
	select_button_QD_2 = love.graphics.newQuad(0, 195, 64, 64, ui_buttons_all_IMG:getDimensions())
	draw_button_QD = love.graphics.newQuad(65, 130, 64, 64, ui_buttons_all_IMG:getDimensions())
	draw_button_QD_2 = love.graphics.newQuad(65, 195, 64, 64, ui_buttons_all_IMG:getDimensions())
	dropper_button_QD = love.graphics.newQuad(130, 130, 64, 64, ui_buttons_all_IMG:getDimensions())
	dropper_button_QD_2 = love.graphics.newQuad(130, 195, 64, 64, ui_buttons_all_IMG:getDimensions())
	eraser_button_QD = love.graphics.newQuad(195, 130, 64, 64, ui_buttons_all_IMG:getDimensions())
	eraser_button_QD_2 = love.graphics.newQuad(195, 195, 64, 64, ui_buttons_all_IMG:getDimensions())
	--*panelQDS
	--**Saving/Loading
	options_panel_QD = love.graphics.newQuad(0, 0, 705, 505, ui_panels_all_IMG:getDimensions())
	generic_panel_QD = love.graphics.newQuad(706, 0, 506, 307, ui_panels_all_IMG:getDimensions())
	dialogue_panel_QD = generic_panel_QD
	lvlwarn_panel_QD = generic_panel_QD
	lvlselection_panel_QD = generic_panel_QD
	--*objectsQDS
	--**Cogs
	cog_object_QD = love.graphics.newQuad(0, 0, 32, 32, objects_all_IMG:getDimensions())
	medkit_object_QD = love.graphics.newQuad(34, 0, 32, 32, objects_all_IMG:getDimensions())
	object1_object_QD = love.graphics.newQuad(0, 34, 32, 32, objects_all_IMG:getDimensions())
	object2_object_QD = love.graphics.newQuad(34, 34, 32, 32, objects_all_IMG:getDimensions())
--ANIMATIONS
	--must initialize each animation table before adding indices to it
	--*Player/Enemy
	player_idle = {}
	player_run = {}
	player_jump = {}
	player_front_flip = {}
	player_fall = {}
	player_crouch = {}
	player_crouch_walk = {}
	player_interact = {}
	--*Objects
	cog_idle = {}
	cog_spin = {}
	button_idle = {}
	door_idle = {}
	door_open = {}
	--Animation Tables
	--*Player/Enemy
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
	player_interact[1] = love.graphics.newImage("resources/textures/player/idle/1.png")
		player_interact[2] = love.graphics.newImage("resources/textures/player/run/2.png")
		player_interact[3] = love.graphics.newImage("resources/textures/player/run/2.png")
		player_interact[4] = love.graphics.newImage("resources/textures/player/run/6.png")
		player_interact[5] = love.graphics.newImage("resources/textures/player/run/6.png")
		player_interact[6] = love.graphics.newImage("resources/textures/player/run/6.png")
		player_interact[7] = love.graphics.newImage("resources/textures/player/run/2.png")
		player_interact[8] = love.graphics.newImage("resources/textures/player/run/2.png")
		player_interact[9] = love.graphics.newImage("resources/textures/player/idle/1.png")
	--*Objects
	cog_idle[1] = love.graphics.newImage("resources/textures/objects/anims/cog/1.png")
	cog_spin[1] = love.graphics.newImage("resources/textures/objects/anims/cog/1.png")
		cog_spin[2] = love.graphics.newImage("resources/textures/objects/anims/cog/2.png")
		cog_spin[3] = love.graphics.newImage("resources/textures/objects/anims/cog/3.png")
		cog_spin[4] = love.graphics.newImage("resources/textures/objects/anims/cog/4.png")
		cog_spin[5] = love.graphics.newImage("resources/textures/objects/anims/cog/5.png")
		cog_spin[6] = love.graphics.newImage("resources/textures/objects/anims/cog/6.png")
		cog_spin[7] = love.graphics.newImage("resources/textures/objects/anims/cog/7.png")
		cog_spin[8] = love.graphics.newImage("resources/textures/objects/anims/cog/8.png")
		cog_spin[9] = love.graphics.newImage("resources/textures/objects/anims/cog/9.png")
		cog_spin[10] = love.graphics.newImage("resources/textures/objects/anims/cog/10.png")
	button_idle[1] = love.graphics.newImage("resources/textures/objects/anims/cog/1.png")
	door_idle[1] = love.graphics.newImage("resources/textures/objects/anims/cog/1.png")
	door_open[1] = love.graphics.newImage("resources/textures/objects/anims/cog/5.png")
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
--LEVELS
--[[
******ADD LEVELS******
1.Insert  entry into game_level_data here
2.Move level into resources/level
--]]
	game_level_data = {}
	game_level_data[1] = {title = "garden", path = "resources/levels/garden.lvl"}
	game_level_data[2] = {title = "level_01", path = "resources/levels/level_01.lvl"}
	game_level_data[3] = {title = "level_00", path = "resources/levels/level_00.lvl"}
end
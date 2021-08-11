function resourceLoad()
--FONTS
	defaultFont = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 16)
	defaultFontHuge = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 96)
	defaultFontSmol = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 10)
	love.graphics.setFont(defaultFont)
--TEXTURES
	--Images
	block_all_IMG = love.graphics.newImage("resources/textures/block/block_all.png")
	ui_all_IMG = love.graphics.newImage("resources/textures/ui/greySheet.png")
	ui_hover_all_IMG = love.graphics.newImage("resources/textures/ui/redSheet.png")
	--SpriteBatches
	block_SB = love.graphics.newSpriteBatch(block_all_IMG)
	button_SB = love.graphics.newSpriteBatch(ui_all_IMG)
	--Quads
	--*blockQDs
	ground_block_QD = love.graphics.newQuad(0, 0, 32, 32, block_all_IMG:getDimensions())
	air_block_QD = love.graphics.newQuad(32, 0, 32, 32, block_all_IMG:getDimensions())
	item_block_QD = love.graphics.newQuad(0, 32, 32, 32, block_all_IMG:getDimensions())
	highlight_block_QD = love.graphics.newQuad(32, 32, 32, 32, block_all_IMG:getDimensions())
	--*buttonQDS
	long_button_QD = love.graphics.newQuad(0, 0, 190, 49, ui_all_IMG:getDimensions())
	long_button_QD_2 = love.graphics.newQuad(0, 0, 190, 49, ui_hover_all_IMG:getDimensions())

--ANIMATIONS
	--must initialize each animation table before adding indices to it
	player_idle = {}
	player_run = {}
	player_jump = {}
	player_front_flip = {}
	player_fall = {}
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
--SOUNDS
	masterVolume = 1.0
	soundsVolume = 1.0
	--heartPickup = love.audio.newSource("resources/sounds/score.ogg", "static")
	--heartPickup:setVolume(masterVolume * soundsVolume)
end
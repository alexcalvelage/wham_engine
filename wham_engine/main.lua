local gamera = require "resources/libraries/gamera"
local bump = require "resources/libraries/bump"
require "resources/libraries/TSerial"
require "utilities"
require "resources"
require "status_text"
require "button"
require "block"
require "player"
require "enemy"

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	--Load our textures, sounds, etc
	resourceLoad()
	love.graphics.setBackgroundColor(0, 0, 0)
	gwidth, gheight = 1280, 720
	love.window.setMode(gwidth, gheight, {vsync = 0})
--sets coordinates for camera
	cam = gamera.new(0, 0, 8000, 720)
	cam:setScale(1.25)
	cam:setWorld(0, 0, 8000, 1000)
	cam:setWindow(0, 0, 1280, 720)
	--sets the collisions cell space to 32
	--smaller values make collision more accurate
	world = bump.newWorld(32)
	gridWorldCreated = false
	gridRowsX = 158
	gridColsY = 31

--BEGIN GAME
	--initialize some 'constants' first
	CONST_FPS = 0
	CONST_DEBUG_M = false
	CONST_WORLD_LIMIT = 1800
	CONST_GRAVITY = 1800
	LET_TIME_DILATION = 1
	LET_CUR_GAME_STATE = "create_state"
	LET_PREV_GAME_STATE = ""
	LET_GAME_PAUSED = false

	--Editor Vars
	LET_EDITOR_DEFAULT_TOOL = "editor_tool_select"
	editor_change_mode("editor_tool_select", selection_cursor)
	LET_EDITOR_BLOCKTYPE_SELECTED = "ground_block"
	LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = 1

	--begins game logic
	createGridWorld()
	--ground]]
	--block.spawn("ground_block", -300, (gheight - 62) - gridColsY, 2000, 32)
	--block.spawn("ground_block", -300, gheight-48, 2000, 32)
	--items]]
	--item.spawn(600, gheight - 215)
	--ents]]
	player.spawn(32, gheight - (32 * gridColsY))
	--Menu buttons
	button.spawn("resume_button_QD", "resume_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * .5)
	button.spawn("save_level_button_QD", "save_level_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 2.5)
	button.spawn("load_level_button_QD", "load_level_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 4.5)
	button.spawn("options_button_QD", "options_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 6.5)
	button.spawn("quit_sesh_button_QD", "exit_session_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 8.5)
	--Editor Mode buttons
	button.spawn("select_button_QD", "tool_selection_action", "create_state", gwidth - 50, gheight / 2 -  105, 50, 50)
	button.spawn("draw_button_QD", "tool_draw_action", "create_state", gwidth - 50, gheight / 2 - 50, 50, 50)
	--button.spawn("eraser_button_QD", "tool_eraser", "create_state", gwidth - 50, gheight / 2 + 5, 50, 50)
	button.spawn("dropper_button_QD", "tool_dropper_action", "create_state", gwidth - 50, gheight / 2 + 5, 50, 50)
	--enemy.spawn("goon", 1600, gheight - love.math.random(200, 1000), "right")
	--enemy.spawn("goon", 1200, gheight - love.math.random(200, 1000), "left")
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "`" then
		if CONST_DEBUG_M then
			CONST_DEBUG_M = false
		else
			CONST_DEBUG_M = true
		end
	elseif key == "f" then
		if LET_GAME_PAUSED then
			LET_GAME_PAUSED = false
		else
			LET_GAME_PAUSED = true
		end
	elseif key == "o" then
		saveLevel("level_test", block)
	elseif key == "p" then
		loadLevel("level_test")
	elseif key == "t" then
		status_text.create("Test string")
	end
end

function love.mousepressed(x, y, mButton)
	for i = 1, #player do
		block.clickAction(player[i], mButton)
	end
end

function love.mousereleased(x, y, mButton)
	for i = 1, #player do
		button.clickAction(mButton)
	end
end

function love.wheelmoved(x, y)
	block.cycleSelectedBlock(y)
end

function love.update(dt)
	--dt = .002 --slows down time
	--Grabs game FPS
	CONST_FPS = love.timer.getFPS()
	mouseX, mouseY = love.mouse.getPosition()
	worldMouseX, worldMouseY = cam:toWorld(mouseX, mouseY)
	button.update(dt)
	status_text.update(dt)

	if not LET_GAME_PAUSED then
		player.update(dt)
		enemy.update(dt)
		block.update(dt)
		item.update(dt)
	end
	print(#status_text)
end

function love.draw()
	--Draws to worldspace
	cam:draw(function()
	block.draw()
	player.draw()
	enemy.draw()
	item.draw()
	debugDraw()
	end)

	--Draws to camera
	love.graphics.setColor(1, 1, 1)
	button.draw()
	debugMenuDraw()
	editorHUDDraw()

	if LET_GAME_PAUSED then
		love.graphics.setFont(defaultFontHuge)
		love.graphics.printf("PAUSED", 0, (gheight / 2) - 200, gwidth, "center")
		love.graphics.setFont(defaultFont)
	end

	status_text.draw()
end

function createGridWorld() --Called in block.lua
	if not gridWorldCreated then
		--Begins index at 0 so that the blocks spawn at the very edges of the screen
		for i = 0, gridRowsX do
			for j = 0, gridColsY do
				block.spawn("air_block", 32 * i, 32 * j)
				gridWorldCreated = true
			end
		end

		status_text.create("World created")

		--Blocks that spawn underneath the player at spawn
		block.typeChange(block[15], "grass_block_l")
		block.typeChange(block[47], "grass_block")
		block.typeChange(block[79], "grass_block")
		block.typeChange(block[111], "grass_block_r")
	end
end

function saveLevel(name, t, t_collision)
	local success, message = love.filesystem.write(name  .. ".txt", TSerial.pack(t, true))
	if success then
		status_text.create("Level Saved!")
	else
		print("LEVEL SAVE FAILED (Unable to write to directory)")
	end
end

function loadLevel(name)
	local file = love.filesystem.getInfo(name .. ".txt")

	if file then
		local data_string = love.filesystem.read(name .. ".txt")
		data_string = TSerial.unpack(data_string, true)

		for i = 1, #block do
			block[i].id = data_string[i].id
			block[i].subtype = data_string[i].subtype
			block[i].quad = data_string[i].quad

			if not world:hasItem(block[i]) then
				world:add(block[i], block[i].x, block[i].y, block[i].width, block[i].height)
			end
		end

		status_text.create("Level Loaded!")
	else
		print("LEVEL LOAD FAILED (Level file does not exist)")
	end
end

function switchGameState(newState) --Used for button.lua actions
	if LET_CUR_GAME_STATE ~= newState then
		LET_PREV_GAME_STATE = LET_CUR_GAME_STATE
		LET_CUR_GAME_STATE = newState
	end
end

function editorHUDDraw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", gwidth - 128, gheight / 2 - 320, 96, 96)
	love.graphics.draw(block_all_IMG, _G[LET_EDITOR_BLOCKTYPE_SELECTED .. "_QD"], gwidth - 48, gheight / 2 - 240, 0, 2, 2, 32, 32)
	--love.graphics.print("AD - Movement\nSPACE- Jump\nLMB - Select Blocks/Draw\nRMB - Fill Selected/Erase\nMouse Wheel - Change Block", 20, 20)
end

function debugMenuDraw()
	if CONST_DEBUG_M then
		local CONST_DEBUG_W = 350
		local CONST_DEBUG_H = 215
		local CONST_DEBUG_X = gwidth - CONST_DEBUG_W
		local CONST_DEBUG_Y = 12
		love.graphics.setColor(0, 1, 0, .25)
		love.graphics.rectangle("fill", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, CONST_DEBUG_H)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("DEBUG MENU", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, "center")
		--Displays FPS benchmark
		love.graphics.printf("FPS: " .. CONST_FPS, CONST_DEBUG_X, CONST_DEBUG_Y * 3, CONST_DEBUG_W, "left")
		love.graphics.printf("Player State: " .. player[1].state, CONST_DEBUG_X, CONST_DEBUG_Y * 6, CONST_DEBUG_W, "left")
		love.graphics.printf("Player Frame: " .. math.floor(player[1].current_frame), CONST_DEBUG_X, CONST_DEBUG_Y * 7.5, CONST_DEBUG_W, "left")
		love.graphics.printf("#Blocks: " .. #block, CONST_DEBUG_X, CONST_DEBUG_Y * 9, CONST_DEBUG_W, "left")
		love.graphics.printf("#Enemies: " .. #enemy, CONST_DEBUG_X, CONST_DEBUG_Y * 10.5, CONST_DEBUG_W, "left")
		love.graphics.printf("Game State: " .. LET_CUR_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 12, CONST_DEBUG_W, "left")
		love.graphics.printf("Previous Game State: " .. LET_PREV_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 13.5, CONST_DEBUG_W, "left")
		love.graphics.printf("Current Editor Tool: " .. LET_EDITOR_DEFAULT_TOOL, CONST_DEBUG_X, CONST_DEBUG_Y * 15, CONST_DEBUG_W, "left")
		love.graphics.printf("Selected Block: " .. LET_EDITOR_BLOCKTYPE_SELECTED, CONST_DEBUG_X, CONST_DEBUG_Y * 16.5, CONST_DEBUG_W, "left")
	end
end

function debugDraw()
	if CONST_DEBUG_M then
		for i,v in ipairs(player) do
			--Player Hitbox
			love.graphics.setColor(1, 0, 1)
			love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
		end

		for i,v in ipairs(enemy) do
			--Enemy Hitbox
			love.graphics.setColor(1, 0, 1)
			love.graphics.rectangle("line", v.x, v.y, v.width, v.height)

			if (v.dir == -1) then
				love.graphics.setColor(1, 0, 0)
				love.graphics.line(v.x, v.y + 25, v.x - v.loseRange, v.y + 25)
				--love.graphics.printf("Lose Target Range", v.x - v.loseRange, v.y + 25, v.loseRange, "center")
				love.graphics.setColor(0, 1, 0)
				love.graphics.line(v.x, v.y + 50, v.x - v.searchRange, v.y + 50)
				--love.graphics.printf("Found Target Range", v.x - v.searchRange, v.y + 50, v.searchRange, "center")
			elseif (v.dir == 1) then
				love.graphics.setColor(1, 0, 0)
				love.graphics.line(v.x, v.y + 25, v.x + v.loseRange, v.y + 25)
				--love.graphics.printf("Lose Target Range", v.x, v.y + 25, v.loseRange, "center")
				love.graphics.setColor(0, 1, 0)
				love.graphics.line(v.x, v.y + 50, v.x + v.searchRange, v.y + 50)
				--love.graphics.printf("Found Target Range", v.x, v.y + 50, v.searchRange, "center")
			end
		end
	end
end

item = {}
function item.spawn(x, y)
	table.insert(item, {type = "item", x = x, y = y, width = 24, height = 24})
	world:add(item[#item], item[#item].x, item[#item].y, item[#item].width, item[#item].height)
end

function item.update(dt)
	for i,v in ipairs(item) do
	end
end

function item.draw()
	for i,v in ipairs(item) do
		love.graphics.setColor(1, 1, 0)
		love.graphics.rectangle("line", v.x, v.y, v.width, v.height)
	end
end

--[[
**WHATS NEXT**
-Custom grid-based map
	--Includes---
	--32x32 grid
	--Placeable tiles/ents similar to Mario Maker level editor
	--Allow saving/loading of grids
	--CTRL+C and CTRL+V support
]]
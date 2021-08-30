local gamera = require "resources/libraries/gamera"
bump = require "resources/libraries/bump"
require "resources/libraries/TSerial"
require "utilities"
require "resources"
require "status_text"
require "button"
require "panel"
require "block"
require "player"
require "enemy"

local utf8 = require("utf8")

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setTextInput(false)
	love.keyboard.setKeyRepeat(false)
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
	CONST_DEBUG_M = false
	CONST_WORLD_LIMIT = 1800
	CONST_GRAVITY = 1800
	LET_FPS = 0
	LET_TIME_DILATION = 1
	LET_CUR_GAME_STATE = "create_state"
	LET_PREV_GAME_STATE = ""
	LET_GAME_PAUSED = false
	LET_BROWSE_PATH = ""
	LET_PANEL_FOCUS = false
	LET_PANEL_OPEN = ""
	LET_BUTTON_SELECTED = nil

	--Editor Vars
	LET_EDITOR_TOOL = "editor_tool_select"
	editor_change_mode("editor_tool_select", selection_cursor)
	LET_EDITOR_BLOCKTYPE_SELECTED = "ground_block"
	LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = 1

	--begins game logic
	createGridWorld()
	--ents]]
	--Panel
	panel.spawn("saving_panel_QD", "savePanel", gwidth / 2, (gheight / 2) + 25 * 2, 298, 98)
	panel.spawn("loading_panel_QD", "loadPanel", gwidth / 2, (gheight / 2) + 25 * 2, 298, 98)
	--Main Menu buttons
	button.spawn("resume_button_QD", "resume_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * .5)
	--Pause Menu buttons
	button.spawn("resume_button_QD", "resume_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * .5)
	button.spawn("save_level_button_QD", "save_level_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 2.5)
	button.spawn("load_level_button_QD", "load_level_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 4.5)
	button.spawn("options_button_QD", "options_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 6.5)
	button.spawn("quit_sesh_button_QD", "exit_session_action", "pauseButton", gwidth / 2, (gheight / 2) + 25 * 8.5)
	--Editor Mode buttons
	button.spawn("select_button_QD", "tool_selection_action", "create_state", gwidth - 50, gheight / 2 -  105, 50, 50)
	button.spawn("draw_button_QD", "tool_draw_action", "create_state", gwidth - 50, gheight / 2 - 50, 50, 50)
	button.spawn("dropper_button_QD", "tool_dropper_action", "create_state", gwidth - 50, gheight / 2 + 5, 50, 50)
	--Save Load buttons
	button.spawn("back_button_QD", "back_action", "loadPanel", (gwidth / 2) + 100, (gheight / 2) + 25 * 3, 74.5, 24.5)
	button.spawn("back_button_QD", "back_action", "savePanel", (gwidth / 2) + 100, (gheight / 2) + 25 * 3, 74.5, 24.5)
	button.spawn("browse_button_QD", "browse_action", "loadPanel", (gwidth / 2), (gheight / 2) + 25 * 3, 74.5, 24.5)
	button.spawn("browse_button_QD", "browse_action", "savePanel", (gwidth / 2), (gheight / 2) + 25 * 3, 74.5, 24.5)
	button.spawn("load_button_QD", "load_action", "loadPanel", (gwidth / 2) - 100, (gheight / 2) + 25 * 3, 74.5, 24.5)
	button.spawn("save_button_QD", "save_action", "savePanel", (gwidth / 2) - 100, (gheight / 2) + 25 * 3, 74.5, 24.5)
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
		if LET_CUR_GAME_STATE ~= "menu_state" and not love.keyboard.hasTextInput() then
			pauseGame()
		end
		--Backspacing functionality for level path input
	elseif key == "backspace" then
		if love.keyboard.hasTextInput() then
			local byteoffset = utf8.offset(LET_BROWSE_PATH, -1)

			if byteoffset then
				LET_BROWSE_PATH = string.sub(LET_BROWSE_PATH, 1, byteoffset - 1)
			end
		end
		--Enables 'enter' key functionality for level path input
	elseif key == "return" then
		if love.keyboard.hasTextInput() then
			if LET_PANEL_OPEN == "savePanel" then
				saveLevel(tostring(LET_BROWSE_PATH), block, enemy)
			elseif LET_PANEL_OPEN == "loadPanel" then
				loadLevel(tostring(LET_BROWSE_PATH))
			end
		end
	end
end

function love.mousepressed(x, y, mButton)
	if not LET_GAME_PAUSED then
		block.clickAction(mButton)
	end
end

function love.mousereleased(x, y, mButton)
	button.clickAction(mButton)
end

function love.wheelmoved(x, y)
	if not LET_GAME_PAUSED then
		block.cycleSelectedBlock(y)
	end
end

function love.textinput(t)
	if LET_GAME_PAUSED then
		LET_BROWSE_PATH = LET_BROWSE_PATH .. t
	end
end

function love.filedropped(file)
	if love.keyboard.hasTextInput() then
		local dropped_file = file:getFilename()
		dropped_file, LET_BROWSE_PATH = getFileName(dropped_file)

		status_text.create("Dropped file: " .. LET_BROWSE_PATH)
	end
end

function love.update(dt)
	--dt = .002 --slows down time
	--Grabs game FPS
	LET_FPS = love.timer.getFPS()
	mouseX, mouseY = love.mouse.getPosition()
	worldMouseX, worldMouseY = cam:toWorld(mouseX, mouseY)

	status_text.update(dt)
	button.update(dt)
	panel.update(dt)

	if LET_CUR_GAME_STATE ~= "menu_state" and not LET_GAME_PAUSED then
		player.update(dt)
		enemy.update(dt)
		block.update(dt)
		item.update(dt)
	end
end

function love.draw()
	if LET_CUR_GAME_STATE ~= "menu_state" then
		cam:draw(function()
		--Draws to worldspace
		block.draw()
		player.draw()
		enemy.draw()
		item.draw()
		debugDraw()
		end)
		--Draws to screen
		editorHUDDraw()
	end

--resets colors
	love.graphics.setColor(1, 1, 1)
	panel.draw()
	button.draw()
	debugMenuDraw()

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

		loadLevel("pitv1")

		player.spawn(block[1].x + 4, block[1].y - 4)
	end
end

function pauseGame()
	if LET_GAME_PAUSED then
		--close out of any previously opened panels
		LET_PANEL_FOCUS = false
		LET_PANEL_OPEN = ""
		LET_GAME_PAUSED = false
	else
		LET_GAME_PAUSED = true
	end
end

function saveLevel(name, t1, t2)
	local lower_name = string.lower(name)
	local mainTable = {}
	local blockTable = {}
	local enemyTable = {}
	for i = 1, #t1 do
		table.insert(blockTable, {subtype = t1[i].subtype, quad = t1[i].quad})
	end
	for i = 1, #t2 do
		table.insert(enemyTable, {subtype = t2[i].subtype, x = t2[i].x, y = t2[i].y, dir = t2[i].dir})
	end

	table.insert(mainTable, blockTable)
	table.insert(mainTable, enemyTable)

	local success, message = love.filesystem.write(lower_name  .. ".txt", TSerial.pack(mainTable, true))
	if success then
		status_text.create("Level Saved! ('" .. lower_name .. "')")
	else
		status_text.create("LEVEL SAVE FAILED (Unable to write to directory)")
	end
end

function loadLevel(name)
	local lower_name = string.lower(name)
	local file = love.filesystem.getInfo(lower_name .. ".txt")

	if file then
		--Read save file text
		local data_string = love.filesystem.read(lower_name .. ".txt")
		--Unserialize string into table
		data_string = TSerial.unpack(data_string, true)

		--Delete any enemies in current level
		sterilizeLevel()

		--Load in block data from new save table
		for i = 1, #block do
			block[i].subtype = data_string[1][i].subtype
			block[i].quad = data_string[1][i].quad

			if not world:hasItem(block[i]) then
				world:add(block[i], block[i].x, block[i].y, block[i].width, block[i].height)
			end
		end
		for i = 1, #data_string[2] do
			if data_string[2] ~= nil then
				enemy.spawn(data_string[2][i].subtype, data_string[2][i].x, data_string[2][i].y, data_string[2][i].dir)
			end
		end

		status_text.create("Level Loaded! ('" .. lower_name .. "')")
	else
		status_text.create("LEVEL LOAD FAILED (Level file does not exist)")
	end
end

--Function used to scrub memory of all level objects before loading a new stage
function sterilizeLevel()
	for i = 1, #enemy do
		table.remove(enemy, i)
	end
end

function switchGameState(newState) --Used for button.lua actions
	if LET_CUR_GAME_STATE ~= newState then
		LET_PREV_GAME_STATE = LET_CUR_GAME_STATE
		LET_CUR_GAME_STATE = newState
		--force unpausing
		LET_GAME_PAUSED = false
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
		local CONST_DEBUG_H = 230
		local CONST_DEBUG_X = gwidth - CONST_DEBUG_W
		local CONST_DEBUG_Y = 12
		love.graphics.setColor(0, 1, 0, .25)
		love.graphics.rectangle("fill", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, CONST_DEBUG_H)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("DEBUG MENU", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, "center")
		--Displays FPS benchmark
		love.graphics.printf("FPS: " .. LET_FPS, CONST_DEBUG_X, CONST_DEBUG_Y * 3, CONST_DEBUG_W, "left")
		love.graphics.printf("Player State: " .. player[1].state, CONST_DEBUG_X, CONST_DEBUG_Y * 6, CONST_DEBUG_W, "left")
		love.graphics.printf("Player Frame: " .. math.floor(player[1].current_frame), CONST_DEBUG_X, CONST_DEBUG_Y * 7.5, CONST_DEBUG_W, "left")
		love.graphics.printf("#Blocks: " .. #block, CONST_DEBUG_X, CONST_DEBUG_Y * 9, CONST_DEBUG_W, "left")
		love.graphics.printf("#Enemies: " .. #enemy, CONST_DEBUG_X, CONST_DEBUG_Y * 10.5, CONST_DEBUG_W, "left")
		love.graphics.printf("Game State: " .. LET_CUR_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 12, CONST_DEBUG_W, "left")
		love.graphics.printf("Previous Game State: " .. LET_PREV_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 13.5, CONST_DEBUG_W, "left")
		love.graphics.printf("Current Editor Tool: " .. LET_EDITOR_TOOL, CONST_DEBUG_X, CONST_DEBUG_Y * 15, CONST_DEBUG_W, "left")
		love.graphics.printf("Selected Block: " .. LET_EDITOR_BLOCKTYPE_SELECTED, CONST_DEBUG_X, CONST_DEBUG_Y * 16.5, CONST_DEBUG_W, "left")
		love.graphics.printf("xVel, yVel:" .. player[1].xVel .. ", " .. player[1].yVel, CONST_DEBUG_X, CONST_DEBUG_Y * 18, CONST_DEBUG_W, "left")
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
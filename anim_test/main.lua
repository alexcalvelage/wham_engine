local gamera = require "resources/libraries/gamera"
local bump = require "resources/libraries/bump"
require "utilities"
require "resources"
require "button"
require "block"
require "player"
require "enemy"

function love.load()
	--Load our textures, sounds, etc
	resourceLoad()
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setDefaultFilter("nearest", "nearest")
	gwidth, gheight = 1280, 720
	love.window.setMode(gwidth, gheight, {vsync = 0})
--sets coordinates for camera
	cam = gamera.new(0, 0, 8000, 720)
	cam:setWorld(0, 0, 8000, 720)
	cam:setWindow(0, 0, 1280, 720)
	--sets the collisions cell space to 32
	--smaller values make collision more accurate
	world = bump.newWorld(32)
	gridWorldCreated = false
	gridRowsX = 158
	gridColsY = 22

--BEGIN GAME
	--initialize some 'constants' first
	CONST_FPS = 0
	CONST_DEBUG_M = false
	CONST_WORLD_LIMIT = 1200
	CONST_GRAVITY = 1800
	LET_CUR_GAME_STATE = "create_state"
	LET_PREV_GAME_STATE = ""
	LET_GAME_PAUSED = false

	--Editor Vars
	LET_EDITOR_DEFAULT_TOOL = "editor_tool_select"
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
	player.spawn(50, gheight - (32 * gridColsY))
	--Menu buttons
	button.spawn("resume_button_QD", "resume", "pauseButton", gwidth / 2, gheight / 2)
	button.spawn("options_button_QD", "options", "pauseButton", gwidth / 2, (gheight / 2) + 49 * 2)
	button.spawn("quit_sesh_button_QD", "exit_session", "pauseButton", gwidth / 2, (gheight / 2) + 49 * 4)
	--Editor Mode buttons
	button.spawn("select_button_QD", "tool_selection", "create_state", 50, gheight / 2 -  105, 50, 50)
	button.spawn("draw_button_QD", "tool_draw", "create_state", 50, gheight / 2 - 50, 50, 50)
	button.spawn("eraser_button_QD", "tool_eraser", "create_state", 50, gheight / 2 + 5, 50, 50)
	button.spawn("dropper_button_QD", "tool_dropper", "create_state", 50, gheight / 2 + 60, 50, 50)
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
	elseif key == "return" then
		block.editor_paint()
	end
end

function love.mousepressed(x, y, mButton)
	for i = 1, #player do
		block.clickAction(player[i], mButton)
	end
	if mButton == 1 then
		button.clickAction()
	end
end

function love.mousereleased(x, y, mButton)
	for i = 1, #player do
		if mButton == 1 then
			button.clickAction()
			--block.clickReleaseAction(player[i])
		end
	end
end

--[[function love.wheelmoved(x, y)
	if y > 0 then
	elseif y < 0 then
	end
end--]]


function love.update(dt)
	--dt = .002 --slows down time
	--Grabs game FPS
	CONST_FPS = love.timer.getFPS()
	mouseX, mouseY = love.mouse.getPosition()
	worldMouseX, worldMouseY = cam:toWorld(mouseX, mouseY)
	button.update(dt)

	if not LET_GAME_PAUSED then
		player.update(dt)
		enemy.update(dt)
		block.update(dt)
		item.update(dt)
	end
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
	--Displays FPS benchmark
	love.graphics.print(CONST_FPS, 0, 0)
	debugMenuDraw()

	if LET_GAME_PAUSED then
		love.graphics.setFont(defaultFontHuge)
		love.graphics.printf("PAUSED", 0, (gheight / 2) * .5, gwidth, "center")
		love.graphics.setFont(defaultFont)
	end
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

		--Blocks that spawn underneath the player at spawn
		block.typeChange(block[8], "ground_block")
		block.typeChange(block[31], "ground_block")
		block.typeChange(block[54], "ground_block")
		block.typeChange(block[77], "ground_block")
	end
end

function switchGameState(newState) --Used for button.lua actions
	if LET_CUR_GAME_STATE ~= newState then
		LET_PREV_GAME_STATE = LET_CUR_GAME_STATE
		LET_CUR_GAME_STATE = newState
	end
end

function debugMenuDraw()
	if CONST_DEBUG_M then
		local CONST_DEBUG_W = 400
		local CONST_DEBUG_H = 200
		local CONST_DEBUG_X = gwidth - CONST_DEBUG_W
		local CONST_DEBUG_Y = 12
		love.graphics.setColor(0, 1, 0, .25)
		love.graphics.rectangle("fill", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, CONST_DEBUG_H)
		love.graphics.setColor(1, 1, 1)
		love.graphics.printf("DEBUG MENU", CONST_DEBUG_X, CONST_DEBUG_Y, CONST_DEBUG_W, "center")
		love.graphics.printf("# Players: " .. #player, CONST_DEBUG_X, CONST_DEBUG_Y * 3, CONST_DEBUG_W, "left")
		love.graphics.printf("Player State: " .. player[1].state, CONST_DEBUG_X, CONST_DEBUG_Y * 4.5, CONST_DEBUG_W, "left")
		love.graphics.printf("Player Frame: " .. math.floor(player[1].current_frame), CONST_DEBUG_X, CONST_DEBUG_Y * 6, CONST_DEBUG_W, "left")
		love.graphics.printf("#Blocks: " .. #block, CONST_DEBUG_X, CONST_DEBUG_Y * 7.5, CONST_DEBUG_W, "left")
		love.graphics.printf("#Enemies: " .. #enemy, CONST_DEBUG_X, CONST_DEBUG_Y * 9, CONST_DEBUG_W, "left")
		love.graphics.printf("Game State: " .. LET_CUR_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 11.5, CONST_DEBUG_W, "left")
		love.graphics.printf("Previous Game State: " .. LET_PREV_GAME_STATE, CONST_DEBUG_X, CONST_DEBUG_Y * 13, CONST_DEBUG_W, "left")
		love.graphics.printf("Current Editor Tool: " .. LET_EDITOR_DEFAULT_TOOL, CONST_DEBUG_X, CONST_DEBUG_Y * 15.5, CONST_DEBUG_W, "left")
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

			if (v.dir == "left") then
				love.graphics.setColor(1, 0, 0)
				love.graphics.line(v.x, v.y + 25, v.x - v.loseRange, v.y + 25)
				--love.graphics.printf("Lose Target Range", v.x - v.loseRange, v.y + 25, v.loseRange, "center")
				love.graphics.setColor(0, 1, 0)
				love.graphics.line(v.x, v.y + 50, v.x - v.searchRange, v.y + 50)
				--love.graphics.printf("Found Target Range", v.x - v.searchRange, v.y + 50, v.searchRange, "center")
			elseif (v.dir == "right") then
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
item_collision = {}
function item.spawn(x, y)
	table.insert(item, {type = "item", x = x, y = y, width = 24, height = 24})
	item_collision[#item] = world:add(item[#item], item[#item].x, item[#item].y, item[#item].width, item[#item].height)
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
local utf8 = require("utf8")

function math.dist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and
	x2 < x1 + w1 and
	y1 < y2 + h2 and
	y2 < y1 + h1
end

function playSound(name)
	name:play()
end

function stopSound(name)
	name:stop()
end

function increaseVolume()

end

function decreaseVolume()
end

function resetGraphicsColor()
	love.graphics.setColor(1,1,1)
end

function getFileName(path)
	return path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
end

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function Unset(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = false end
    return set
end

function Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

--Function used to scrub memory of all level objects before loading a new stage
function sterilizeLevel()
	while #block ~= 0 do rawset(block, #block, nil) end
	while #enemy ~= 0 do rawset(enemy, #enemy, nil) end
	while #player ~= 0 do rawset(player, #player, nil) end
	while #object ~= 0 do rawset(object, #object, nil) end
	--Re-initialize our world to force-update collisions/regenerate blocks for level
	LET_GRIDWORLD_CREATED = false
	world = bump.newWorld(32)
end

function createLevelGridData()
	local success = createGridWorld()
	if success then
		status.print("SUCCESS: BLOCK GRID GENERATION... " .. tostring(world_params.width) .. " / " .. tostring(world_params.height))
	else
		status.print("FAILED: BLOCK GRID GENERATION")
	end
end

function initializeLevel()
	for i,v in ipairs(block) do
		--Checks to make sure collision on this doesn't already exist
		if not world:hasItem(v) then
			world:add(v, v.x, v.y, v.width, v.height)
		end
		--Spawns player on a spawn block
		if v.subtype == "player_spawn" then
			if #player < 1 then
				player.spawn(v.x + 4, v.y - 4)
			end
		end

		cam:setWorld(0, 0, world_params.width * 32, world_params.height * 32)
	end
end

--world_params = {width = gridColsX, height = gridRowsY}
function modifyWorldWidth(amount)
	gridColsX = gridColsX + amount
	world_params.width = gridColsX
end

function modifyWorldHeight(amount)
	gridRowsY = gridRowsY + amount
	world_params.height = gridRowsY
end

--Prevents user from crashing the game with invalid string data or invalid level sizes
function createNewLevelForEditor(name, width, height)
	local isNameValid = false
	local isLevelValid = false

	if (name ~= "" and not string.match(name, "%W")) then
		LET_CURRENT_LEVEL = name
		isNameValid = true
	else
		status.print("ERROR: Level name can only contain alphanumeric characters!")
	end

	if (width > 1 and height > 1) then
		isLevelValid = true
	else
		status.print("ERROR: Level size (width and height) must be greater than 1!")
	end

	if (isNameValid == true and isLevelValid == true) then
		createLevelGridData()
		--Floor numbers to prevent odd level sizes from causing crashes when spawning
		block.typeChange(block[math.floor(gridRowsY/2)], "player_spawn")
		block.typeChange(block[math.floor(gridRowsY/2+1)], "dev_block")
		initializeLevel()
		return true
	else
		return false
	end
end

function switchGameState(newState) --Used for button.lua actions
	if LET_CUR_GAME_STATE ~= newState then
		LET_PREV_GAME_STATE = LET_CUR_GAME_STATE
		LET_CUR_GAME_STATE = newState
		--force unpausing
		LET_GAME_PAUSED = false

		LET_DEBUG_M = false
	end
end

function deleteCharacterByte()
	--Backspacing functionality for level path input
	if love.keyboard.hasTextInput() then
		local byteoffset = utf8.offset(LET_BROWSE_PATH, -1)

		if byteoffset then
			LET_BROWSE_PATH = string.sub(LET_BROWSE_PATH, 1, byteoffset - 1)
		end
	end
end

function start_keybind_change(binding, buttonIndex)
	LET_KEYBIND_CHANGE = true
	love.mouse.setVisible(false)
	love.mouse.setPosition(buttonIndex.x + (buttonIndex.width / 2), buttonIndex.y + (buttonIndex.height / 2))
	LET_LOCKED_CURSOR_POSITION_X, LET_LOCKED_CURSOR_POSITION_Y = buttonIndex.x + (buttonIndex.width / 2), buttonIndex.y + (buttonIndex.height / 2)
	LET_KEYBIND_BINDING = binding
end

	--Only runs if start_keybind_change() is called
function update_keybind_change()
	if LET_KEYBIND_CHANGE then
		LET_CURSOR_LOCKED = true
		love.mouse.setPosition(LET_LOCKED_CURSOR_POSITION_X, LET_LOCKED_CURSOR_POSITION_Y)
		for k,_ in pairs(keys_pressed) do
			--Check for reserved keys..open this up to other letters!
			if k ~= "escape" then
				--Now we change our button text to match change
				for i,v in ipairs(button) do
					if v.action == "options_keybinds_" .. LET_KEYBIND_BINDING then
						--Change our button text..
						v.text = k
						--..change our keybind
						_G[LET_KEYBIND_BINDING] = k
						status.print(LET_KEYBIND_BINDING .. " has been rebound to: " .. string.upper(_G[LET_KEYBIND_BINDING]))
					end
				end

				--Reset binding to nothing and exit out of change mode
				LET_KEYBIND_BINDING = nil
				LET_KEYBIND_CHANGE = false
				LET_CURSOR_LOCKED = false
				love.mouse.setVisible(true)
				LET_LOCKED_CURSOR_POSITION_X, LET_LOCKED_CURSOR_POSITION_Y = 0, 0
			elseif k == "escape" then
				--Reset binding to nothing and exit out of change mode
				LET_KEYBIND_BINDING = nil
				LET_KEYBIND_CHANGE = false
				LET_CURSOR_LOCKED = false
				love.mouse.setVisible(true)
				LET_LOCKED_CURSOR_POSITION_X, LET_LOCKED_CURSOR_POSITION_Y = 0, 0
			end
		end
	end
end

function dialogue_init()
	
end

function stateChange(ent, state, startFrame)
	--Hardcoding values for now
	local defaultHeight = 64
	local crouchHeight = 39
	--Changes player state only if a new action has occured.
	--Checks if the new incoming state is different from the current state
	if ent.state ~= state then
		--Checks if we need to change the starting animation frame..otherwise defaults to 1
		ent.current_frame = startFrame or 1

--Checks to prevent character controller from specific wonky behavior
		--Change character height when crouching
		if state == "crouch" or state == "crouch_walk" then
			ent.height = crouchHeight
			ent.isCrouching = true

		--Prevents character from falling into floor and being teleported backwards
		elseif (state == "run" and ent.prevState == "crouch") then
			ent.y = ent.y - 8
			ent.isCrouching = false

		--Fixes jumping directly after crouching causing character to phase through floor
		elseif (state == "jump" and ent.prevState == "crouch") or (state == "front_flip" and ent.prevState == "crouch") then
			--This method causes weird character collision when height is changing
			--ent.height = crouchHeight

			--This method seems to alleviate the issue at the cost of not shrinking hitbox to match sprite
			ent.y = ent.y - 16
			ent.isCrouching = false

		else --Last check to fully reset player's height and crouch toggle
			ent.height = defaultHeight
			ent.isCrouching = false
		end
		
		--Does a world update to ensure character controller's vars are changed
		world:update(ent, ent.x, ent.y, ent.width, ent.height)
		--local actualX, actualY, cols, len = world:move(ent, ent.x, ent.y)

		ent.prevState = ent.state
		ent.state = state
		
	end
end

--Takes state data from the Movement Controller and sets the animations accordingly
function animationStateController(dt, ent)
	--Resets animation timing
	animationTimeScale(ent, 12)
	--Change player's animation + timing based on his current state
	--Checks if we're dealing with an actual character or an object
	if ent.type == "player" or ent.type == "enemy" then
		character_animation_change(ent)
	else
		object_animation_change(ent)
	end

	--Changes our animation tick rate based on timescale
	ent.tick = ent.tick + dt * ent.animation_timescale

	--Checks if the current anim tick is greater than .9(seems to prevent footstep sound dupe)
	if ent.tick > 0.9 then
		ent.current_frame = ent.current_frame + 1

		if ent.current_frame >= #ent.animationTable then
			--Instead of just resetting our current animation frame we instead switch
			--player states to falling so that the jump and flip anims don't loop
			if ent.state == "jump" or ent.state == "front_flip" then
				--overrides any previous animation changes
				stateChange(ent, "fall")
			elseif ent.state == "interact" then
				ent.isInteracting = false
				status.print(tostring(ent.current_frame) .. " frame")
			end
			--Once we reach the end of the animation data table, start back at the beginning
			--Lua indices start at 1 instead of 0
			ent.current_frame = 1
		end
		--reset our timing ticks when reaching end of frames
		ent.tick = 0
	end
end

function soundStateController(dt, ent)
	--Add support for different surfaces[]
	if ent.state == "run" then
		if ent.current_frame == 1 or ent.current_frame == 5 then
			playSound(footstep_hard_floor_SND)
		end
	end
end

--Allows ease of animation changes
function character_animation_change(ent)
	--Checks for specific action states to determine action anim speed
	if ent.state == "jump" then
		animationTimeScale(ent, 3)
	elseif ent.state == "front_flip" then
		animationTimeScale(ent, 16)
	elseif ent.state == "interact" then
		animationTimeScale(ent, 16)
	end

	--
	local player_state = ("player_" .. ent.state)
	--converts concatenated string back to name of Global table
	--EG: "player_" .. "idle" == "player_idle" converted to player_idle
	ent.animationTable = _G[player_state]
	--Changes player height based on animation frame height
	--REMOVED.. causes issues elsewhere when crouching
	--ent.height = ent.animationTable[ent.current_frame]:getHeight() * player.playerScaling
end

--Allows ease of animation changes for OBJECTS
function object_animation_change(ent)
	if ent.subtype == "cog" then
		animationTimeScale(ent, 12)
	end

	local object_anim = (ent.subtype .. "_" .. ent.state)
	--converts concatenated string back to name of Global table
	--EG: "cog_" .. "spin" == "cog_spin" converted to cog_spin
	ent.animationTable = _G[object_anim]
end

--Changes timescale of animations(anim speed)
function animationTimeScale(ent, time)
	ent.animation_timescale = time
end

function object_auto_bump(ent)
	if not ent.cleanup then
		if not world:hasItem(ent) then
			world:add(ent, ent.x, ent.y, ent.width, ent.height)
		end
	end
end

function object_cleanup(ent)
	if ent.cleanup then
		table.remove(_G[ent.type], ent.id)
		if world:hasItem(ent) then
			world:remove(ent)
		end
	end
end

function object_damage(ent, dmg)
	if not ent.isDamaged then
		ent.isDamaged = true
		ent.health = ent.health - dmg
		--Held jump reset..disabling this on damage allows smoother transition state for player
		if ent.jumpHeld then
			ent.jumpHeld = false
		end
	end
end

function pauseGame()
	if LET_GAME_PAUSED then
		changeCursor()
		--close out of any previously opened panels for resume
		LET_PANEL_FOCUS = false
		LET_PANEL_OPEN = ""
		LET_GAME_PAUSED = false
	else
		--button.backButtonReset()
		LET_GAME_PAUSED = true
		--Set cursor back to default for menus
		love.mouse.setCursor(default_cursor)
	end
end

function console_toggle()
	if LET_PANEL_OPEN == "" or LET_PANEL_OPEN == "consolePanel" then
		if LET_CONSOLE_OPEN then
			panel.typeChange("")
			LET_CONSOLE_OPEN = false
			love.keyboard.setTextInput(false)
			love.keyboard.setKeyRepeat(false)
		else
			panel.typeChange("consolePanel")
			LET_CONSOLE_OPEN = true
			love.keyboard.setTextInput(true)
			love.keyboard.setKeyRepeat(true)
			if LET_CUR_GAME_STATE ~= "menu_state" and not LET_GAME_PAUSED then
				pauseGame()
			end
		end
	end
end

--Input is currently case-sensitive
function console_exec(input)
	local command = ""
	local arg1 = ""
	if string.sub(input, 1, 9) == "loadlevel" then
		command = "loadlevel"
		arg1 = string.sub(input, 11, LET_TEXTBOX_MAXCHAR)
		for i = 1, #game_level_data do
			if arg1 == game_level_data[i].title then
				button.levelSelect(arg1)
				table.insert(LET_CONSOLE_HISTORY, input)
				status.print("Exec command: " .. input)
			end
		end
	end
end

function textbox_ticker_alpha_update(dt)
	--Alpha modifier for textbox ticker |
	LET_TEXTBOX_TICKER_TIME = LET_TEXTBOX_TICKER_TIME + 1 * dt
	if LET_TEXTBOX_TICKER_TIME > LET_TEXTBOX_TICKER_TIME_MAX then
		LET_TEXTBOX_TICKER_TIME = 0
		if LET_TEXTBOX_TICKER_ALPHA == 1 then
			LET_TEXTBOX_TICKER_ALPHA = 0
		else
			LET_TEXTBOX_TICKER_ALPHA = 1
		end
	end
end
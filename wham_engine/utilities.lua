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

function deleteCharacterByte()
	--Backspacing functionality for level path input
	if love.keyboard.hasTextInput() then
		local byteoffset = utf8.offset(LET_BROWSE_PATH, -1)

		if byteoffset then
			LET_BROWSE_PATH = string.sub(LET_BROWSE_PATH, 1, byteoffset - 1)
		end
	end
end

function stateChange(ent, state, startFrame)
	local defaultHeight = 64
	--Changes player state only if a new action has occured.
	--Checks if the new incoming state is different from the current state
	if ent.state ~= state then
		--Checks if we need to change the starting animation frame..otherwise defaults to 1
		ent.current_frame = startFrame or 1

		if state == "crouch" or state == "crouch_walk" then
			ent.height = defaultHeight / 1.7
			ent.isCrouching = true
		else
			ent.height = defaultHeight
			ent.isCrouching = false
		end
		
		world:update(ent, ent.x, ent.y, ent.width, ent.height)

		ent.prevState = ent.state
		ent.state = state
	end
end

--Takes state data from the Movement Controller and sets the animations accordingly
function animationStateController(dt, ent)
	--Resets animation timing
	animationTimeScale(ent, 12)
	--Change player's animation + timing based on his current state
	animationChange(ent)
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
			end
			--Once we reach the end of the animation data table, start back at the beginning
			--Lua indices start at 1 instead of 0
			ent.current_frame = 1
		end
		--reset our timing ticks when reaching end of frames
		ent.tick = 0
	end
end

--Used only for object related animations
function animationStateController_Objects(dt, ent)
	--Resets animation timing
	animationTimeScale(ent, 12)
	--Change player's animation + timing based on his current state
	animationChange_Objects(ent)
	--Changes our animation tick rate based on timescale
	ent.tick = ent.tick + dt * ent.animation_timescale

	--Checks if the current anim tick is greater than .9(seems to prevent footstep sound dupe)
	if ent.tick > 0.9 then
		ent.current_frame = ent.current_frame + 1

		if ent.current_frame >= #ent.animationTable then
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
function animationChange(ent)
	--Checks for specific action states to determine action anim speed
	if ent.state == "jump" then
		animationTimeScale(ent, 3)
	elseif ent.state == "front_flip" then
		animationTimeScale(ent, 16)
	end

	--
	local player_state = ("player_" .. ent.state)
	--converts concatenated string back to name of Global table
	--EG: "player_" .. "idle" == "player_idle" converted to player_idle
	ent.animationTable = _G[player_state]
end

--Allows ease of animation changes for OBJECTS
function animationChange_Objects(ent)
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
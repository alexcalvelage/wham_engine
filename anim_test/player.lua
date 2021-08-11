--initialize player data table
player = {}
player_collision = {}
function player.spawn(x, y)
	--insert (1) player into the player table with included values
	table.insert(player, {type = player, name = "alex", x = x, y = y, width = 28, height = 80, speed = 200, xVel = 0, yVel = 0, jumpHeight = -800, isOnGround = false, dir = "right", state = "fall", prevState = "", animationTable = animationTable, current_frame = 1, animation_timescale = 12, editor = {select_x = 0, select_y = 0, select_width = 0, select_height = 0}})
	--adds collisions to each player created
	player_collision[#player] = world:add(player[#player], player[#player].x, player[#player].y, player[#player].width, player[#player].height)
end

function player.update(dt)
	for i,v in ipairs(player) do
		--Cue gravity
		v.yVel = v.yVel + (CONST_GRAVITY * dt)

		--where we WANT to go provided no collisions
		local goalX, goalY = v.x, v.y

		--Handles keyboard movements (NO BINDINGS SUPPORT)
		player.movementController(dt, player[i])

		--Constantly is updating our player's x,y position
		goalX = goalX + (v.xVel * dt)
		goalY = goalY + (v.yVel * dt)

		--Fall detection
		if v.yVel ~= 0 then
			v.isOnGround = false
		end

		--Handles animation state switching
		player.animationStateController(dt, player[i])

		--checks to see the player will collide with something using the goalX,Y
		v.x, v.y, collisions, len = world:move(player[i], goalX, goalY, player.filter)
		cam:setPosition(v.x, v.y)
		
		for a,coll in ipairs(collisions) do
			--we are goin' up and thru!
			if coll.touch.y >= goalY then
				v.isOnGround = false
			elseif coll.normal.y < 0 then --coming down onto block
				v.isOnGround = true
				v.yVel = 0
			end
		end

		if mouseMoved then
			block.clickReleaseAction(player[i])
		end
	end

	print(player[1].x, player[1].y, player[1].width, player[1].height)
end

function player.draw()
	local playerScaling = 2
	for i,v in ipairs(player) do
		love.graphics.setColor(1, 1, 1)
		--width is used here to calculate offset when mirroring texture
		local plrWidth = v.animationTable[math.floor(v.current_frame)]:getWidth() * playerScaling
		local plrHeight = v.animationTable[math.floor(v.current_frame)]:getHeight() * playerScaling
		v.width, v.height = plrWidth, plrHeight

		--flips player's texture when switching directions
		if v.dir == "right" then
			love.graphics.draw(v.animationTable[math.floor(v.current_frame)], v.x, v.y, 0, playerScaling, playerScaling, 0, 0)
		elseif v.dir == "left" then
			love.graphics.draw(v.animationTable[math.floor(v.current_frame)], v.x, v.y, 0, -playerScaling, playerScaling, v.width / playerScaling, 0)
		end

		love.graphics.setColor(0, 0, 1, .5)
		love.graphics.rectangle("fill", v.editor.select_x, v.editor.select_y, v.editor.select_width, v.editor.select_height)
	end
end

--Movement Controller sets the state and direction of the player after performing certain actions
--This tells the animation controller what to render
function player.movementController(dt, plr)
	--Checks if any movement keys are being held down
	local keyDown = love.keyboard.isDown("d", "a", "space")

	--Idle
	if not keyDown and plr.isOnGround then
		plr.xVel = 0
		player.stateChange(plr, "idle")
	end

	--Right, Left + Falling
	if love.keyboard.isDown("d") and plr.isOnGround then
		plr.xVel = plr.speed
		plr.dir = "right"
		player.stateChange(plr, "run")
	elseif love.keyboard.isDown("a") and plr.isOnGround then
		plr.xVel = -plr.speed
		plr.dir = "left"
		player.stateChange(plr, "run")
	end

	--Jumping
	if love.keyboard.isDown("space") and plr.isOnGround then
		plr.yVel = plr.jumpHeight
		--Checks xVel to see if we're doing a vertical jump or a frontflip
		if plr.xVel == 0 then
			--Forces the current animation frame to reset to 1...check for state change to fix
			plr.current_frame = 1
			player.stateChange(plr, "jump")
		else
			--starts on 4th frame to make jumping more immediate
			player.stateChange(plr, "front_flip", 4)
		end

		plr.isOnGround = false
	end

	--Falling
	--Checks to make sure the player isn't doing certain anims as to not override the animation table
	--Also make sure the player is not on the ground
	if plr.state ~= "front_flip" and plr.state ~= "jump" and not plr.isOnGround then
		player.stateChange(plr, "fall")
	end
end

function player.stateChange(plr, state, startFrame)
	--Changes player state only if a new action has occured.
	--Checks if the new incoming state is different from the current state
	if plr.state ~= state then
		--Checks if we need to change the starting animation frame..otherwise defaults to 1
		startFrame = startFrame or 1
		plr.prevState = plr.state
		plr.state = state
		plr.current_frame = startFrame
	end
end

--Takes player state data from the Movement Controller and sets the animations accordingly
function player.animationStateController(dt, plr)
	--Resets animation timing if it has been changed
	player.animationTimeScale(plr, 12)

	--Change player's animation based on his current state
	player.animationChange(plr, plr.state, startFrame)

	--Every game frame, move ahead an animation frame based on animation timing
	plr.current_frame = plr.current_frame + plr.animation_timescale * dt
	if plr.current_frame >= #plr.animationTable then
		--Instead of just resetting our current animation frame we instead switch
		--player states to falling so that the jump and flip anims don't loop
		if plr.state == "jump" or plr.state == "front_flip" then
			--overrides any previous animation changes
			player.stateChange(plr, "fall")
		end
		--Once we reach the end of the animation data table, start back at the beginning
		--Lua indices start at 1 instead of 0 :l
		plr.current_frame = 1
	end
end

--Allows ease of animation changes
function player.animationChange(plr, state)
	--Checks for specific action states to determine action anim speed
	if plr.state == "jump" then
		player.animationTimeScale(plr, 4)
	elseif plr.state == "front_flip" then
		player.animationTimeScale(plr, 16)
	end

	--
	local player_state = ("player_" .. state)
	--converts concatenated string back to name of Global table
	--EG: "player_" .. "idle" == "player_idle" converted to player_idle
	plr.animationTable = _G[player_state]
end

--Changes timescale of animations(anim speed)
function player.animationTimeScale(plr, time)
	plr.animation_timescale = time
end

player.filter = function(item, other)
	local x, y, w, h = world:getRect(other)
	local px, py, pw, ph = world:getRect(item)
	local playerBottom = py + ph
	local playerRight = px + pw
	local otherBottom = y + h

--Checks which hitbox to check against
	if other.subtype == "platform_block" then
		if playerBottom <= y then
			return 'slide'
		end
	elseif other.subtype == "item_block" or other.subtype == "ground_block" then
		if py >= y or playerBottom <= y then
			return 'slide'
		end
		if px <= x or playerRight >= x then
			return 'slide'
		end
	end
end
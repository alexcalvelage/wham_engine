--initialize player data table
player = {}
--player_collision = {}
function player.spawn(x, y)
	--insert (1) player into the player table with included values
	table.insert(player, {type = player, name = "Phil", health = 1, x = x, y = y, width = 25, height = 64, speed = 200, xVel = 0, yVel = 0, jumpHeight = -800, isOnGround = false, dir = 1, state = "fall", prevState = "", animationTable = animationTable, current_frame = 1, animation_timescale = 12, editor = {select_x = 0, select_y = 0, select_width = 0, select_height = 0}})
	--adds collisions to each player created
	world:add(player[#player], player[#player].x, player[#player].y, player[#player].width, player[#player].height)
end

function player.update(dt)
	dt = dt * LET_TIME_DILATION
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

		--Left side of screen collision
		if goalX <= 0 then
			goalX = 0
		end

		--Fall detection
		if v.yVel ~= 0 then
			v.isOnGround = false
		end

		--Death detection
		if goalY >= CONST_WORLD_LIMIT then
			v.health = 0
		end
		if v.health <= 0 then
			v.xVel, v.yVel = 0, 0
			for a = 1, #block do
				if block[a].subtype == "player_spawn" then
					goalX, goalY = block[a].x + 4, block[a].y - 4
					world:update(player[i], goalX, goalY, v.width, v.height)
				end
			end

			v.health = 1
		end

		--Handles animation state switching
		player.animationStateController(dt, player[i])

		--checks to see the player will collide with something using the goalX,Y
		v.x, v.y, collisions, len = world:move(player[i], goalX, goalY, player.filter)
		cam:setPosition(v.x + v.width * 10, v.y)
		
		for a,coll in ipairs(collisions) do
			--we are goin' up and thru!
			if coll.touch.y >= goalY then
				v.isOnGround = false
			elseif coll.normal.y < 0 then --coming down onto block
				v.isOnGround = true
				v.yVel = 0
			end
		end

		--testing for fixing drag selection bug
		--print(player[i].editor.select_x, player[i].editor.select_y, player[i].editor.select_width, player[i].editor.select_height)

		block.clickActionUpdate(player[i])
	end
end

function player.draw()
	local playerScaling = 1.66
	for i,v in ipairs(player) do
		local scaleX = v.dir
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(v.animationTable[math.floor(v.current_frame)], v.x + (v.width / 2), v.y, 0, scaleX * playerScaling, playerScaling, v.animationTable[math.floor(v.current_frame)]:getWidth() / 2, 0)
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

	--Right, Left
	if love.keyboard.isDown("d") and plr.isOnGround then
		plr.xVel = plr.speed
		plr.dir = 1
		player.stateChange(plr, "run")
	elseif love.keyboard.isDown("a") and plr.isOnGround then
		plr.xVel = -plr.speed
		plr.dir = -1
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
	local playerX, playerY, playerW, playerH = world:getRect(item)
	local otherX, otherY, otherW, otherH = world:getRect(other)

	local playerBottom, playerRight = playerY + playerH, playerX + playerW

--Checks which hitbox to check against
	if other.subtype == "wooden_plat" then
		if playerBottom <= otherY then
			return 'slide'
		end
	elseif other.subtype == "item_block" or other.subtype == "ground_block" or other.subtype == "grass_block" or other.subtype == "grass_block_l" or other.subtype == "grass_block_r" then
		if playerY >= otherY or playerBottom <= otherY then
			return 'slide'
		end
		if playerX >= otherX or playerRight <= otherX then
			return 'slide'
		end
	end
end
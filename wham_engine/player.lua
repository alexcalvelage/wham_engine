local defaultWidth, defaultHeight = 25, 64

--initialize player data table
player = {playerScaling = 1.66}
--player_collision = {}
function player.spawn(x, y)
	--insert (1) player into the player table with included values
	table.insert(player, {type = player, name = "Phil", health = 2, x = x, y = y, width = 25, height = 64, speed = 200, xVel = 0, yVel = 0, jumpHeight = -800, isOnGround = false, isCrouching = false, isKnockback = false, dir = 1, state = "fall", prevState = "", animationTable = player_idle, current_frame = 1, animation_timescale = 12, tick = 0})
	--adds collisions to each player created
	world:add(player[#player], player[#player].x, player[#player].y, player[#player].width, player[#player].height)
end

function player.update(dt)
	dt = dt * LET_TIME_DILATION
	for i,v in ipairs(player) do
		--Check if player is crouching..this lets player crouch instantly without 'falling'
		local gravityX = 1
		if v.isCrouching then
			gravityX = defaultHeight
		else
			gravityX = 1
		end
		--Cue gravity
		v.yVel = v.yVel + (CONST_GRAVITY * dt) * gravityX

		--where we WANT to go provided no collisions
		local goalX, goalY = v.x, v.y

		--Handles keyboard movements (NO BINDINGS SUPPORT)
		player.movementController(dt, v)

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
				end
			end

			world:update(v, goalX, goalY, v.width, v.height)
			v.health = 2
		end

		--Handles animation state switching
		animationStateController(dt, player[i])

		--Called after animation controller..handles sounds
		soundStateController(dt, player[i])

		--checks to see the player will collide with something using the goalX,Y
		v.x, v.y, collisions, len = world:move(v, goalX, goalY, player.filter)
		--update our cameras position
		cam:setPosition(v.x + v.width * 10, v.y)
		
		--Hit detection
		for a,coll in ipairs(collisions) do
			--Checks if the player's feet are on a solid collision
			if coll.normal.y < 0 and not coll.knockback and not coll.bounce then
				v.isOnGround = true
				v.yVel = 0
			end
			--Response for knockback damage
			if coll.knockback then
				v.isKnockback = true
				v.health = v.health - 1
				v.yVel = v.jumpHeight / 2
				if v.dir == 1 then
					v.xVel = v.jumpHeight / 2
				elseif v.dir == -1 then
					v.xVel = -v.jumpHeight / 2
				end
			else
				v.isKnockback = false
			end
		end
	end
end

function player.draw()
	for i,v in ipairs(player) do
		local scaleX = v.dir
		love.graphics.setColor(.15, 1, 1)
		love.graphics.draw(v.animationTable[v.current_frame], v.x + (v.width / 2), v.y, 0, scaleX * player.playerScaling, player.playerScaling, v.animationTable[v.current_frame]:getWidth() / 2, 0)
	end
end

--Movement Controller sets the state and direction of the player after performing certain actions
--This tells the animation controller what to render
function player.movementController(dt, plr)
	--Checks if any movement keys are being held down
	local keyDown = love.keyboard.isDown("d", "a", "space", "lctrl")
	local moveRight, moveLeft, moveJump, moveCrouch = "d", "a", "space", "lctrl"

	--Idle
	if not keyDown and plr.isOnGround then
		plr.xVel = 0
		stateChange(plr, "idle")
	elseif love.keyboard.isDown(moveCrouch) and plr.isOnGround then
		plr.xVel = 0
		stateChange(plr, "crouch")
	elseif not love.keyboard.isDown(moveCrouch) and plr.isCrouching then
		stateChange(plr, "idle")
	end

	--Running
	if not plr.isKnockback then
		if love.keyboard.isDown(moveRight) and not plr.isCrouching then
			plr.xVel = plr.speed
			plr.dir = 1
			if plr.isOnGround then
				stateChange(plr, "run")
			end
		elseif love.keyboard.isDown(moveLeft) and not plr.isCrouching then
			plr.xVel = -plr.speed
			plr.dir = -1
			if plr.isOnGround then
				stateChange(plr, "run")
			end
		end
	end

	--Crouch Walking
	--[[if love.keyboard.isDown("lctrl") and love.keyboard.isDown("d") and plr.isOnGround and plr.isCrouching then
		plr.xVel = plr.speed / 2
		plr.dir = 1
		player.stateChange(plr, "crouch_walk")
	elseif love.keyboard.isDown("lctrl") and love.keyboard.isDown("a") and plr.isOnGround and plr.isCrouching then
		plr.xVel = -plr.speed / 2
		plr.dir = -1
		player.stateChange(plr, "crouch_walk")
	end--]]

	--Ceiling check
	--[[local bumpItems, bumpLen = world:queryRect(plr.x, plr.y-32, plr.width, plr.height/2)
	for j = 1, #bumpItems do
		if bumpItems[j].subtype == "ground_block" then
			if not plr.isCrouching then
				player.stateChange(plr, "crouch") --player is JITTERY
			end
		end
	end--]]

	--Jumping
	if love.keyboard.isDown(moveJump) and plr.isOnGround and not plr.isCrouching then
		plr.yVel = plr.jumpHeight
		--Checks xVel to see if we're doing a vertical jump or a frontflip
		if plr.xVel == 0 then
			--Forces the current animation frame to reset to 1...check for state change to fix
			stateChange(plr, "jump", 1)
		elseif plr.xVel ~= 0 then
			--starts on 4th frame to make jumping more immediate
			stateChange(plr, "front_flip", 4)
		end

		playSound(jump_exert_SND)

		plr.isOnGround = false
	end
--[[
	--Crouch Walking Reset
	if plr.state == "crouch_walk" then
		if not love.keyboard.isDown("lctrl") then
			player.stateChange(plr, "run")
		elseif not love.keyboard.isDown("a", "d") then
			player.stateChange(plr, "crouch")
			plr.xVel = 0
		end
	end--]]

	--Falling
	--Checks to make sure the player isn't doing certain anims as to not override the animation table
	--Also make sure the player is not on the ground
	if (plr.state ~= "front_flip" and plr.state ~= "jump" and plr.state ~= "crouch") and not plr.isOnGround then
		stateChange(plr, "fall")
	end
end

player.filter = function(item, other)
	local playerX, playerY, playerW, playerH = world:getRect(item)
	local otherX, otherY, otherW, otherH = world:getRect(other)

	local playerBottom, playerRight = playerY + playerH, playerX + playerW

--Checks which block/ent to check against
	if other.subtype == "wooden_plat" then
		if playerBottom <= otherY then
			return 'slide'
		end
	elseif other.subtype == "dev_block" or other.subtype == "grass_block" or other.subtype == "grass_block_r" or other.subtype == "grass_block_l" or other.subtype == "dirt_block" or other.subtype == "item_block" then
		if playerY <= otherY or playerBottom >= otherY then
			return 'slide'
		end
		if playerX <= otherX or playerRight >= otherX then
			return 'slide'
		end
	elseif other.subtype == "spike_block_u" or other.subtype == "spike_block_d" then
		if playerBottom <= otherY then
			return 'knockback'
		end
	end
end
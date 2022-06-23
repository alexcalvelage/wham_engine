local defaultWidth, defaultHeight = 25, 64
local cameraY, cameraYTransitionSpeed = 0, 488

--initialize player data table
player = {playerScaling = 1.66}
--player_collision = {}
function player.spawn(x, y)
	--insert (1) player into the player table with included values
	table.insert(player, {type = "player", name = "Phil", health = 3, score = 0, x = x, y = y, width = 25, height = 64, speed = 200, xVel = 0, yVel = 0, jumpHeight = -600, 
	jumpHeld = false, isOnGround = false, isCrouching = false, isKnockback = false, isUnderwater = false, isDamaged = false, isDamagedTimer = 0, isDamagedTimerMax = 1.5, dir = 1, damageDir = 0, 
	state = "fall", prevState = "", animationTable = player_idle, current_frame = 1, animation_timescale = 12, tick = 0})
	
	--adds collisions to each player created
	world:add(player[#player], player[#player].x, player[#player].y, player[#player].width, player[#player].height)
	--sets our cameraY position to the newly spawned player
	cameraY = player[#player].y
end

function player.update(dt)
	dt = dt * LET_TIME_DILATION
	for i,v in ipairs(player) do
		--Cue gravity
		v.yVel = v.yVel + (CONST_GRAVITY * dt) * (gravityIntensity or 1)

		--'Mario Jump' detection
		if v.jumpHeld then
			v.yVel = v.yVel + (v.jumpHeight * 1.5) * dt
		end

		--where we WANT to go provided no collisions
		local goalX, goalY = v.x, v.y

		--Handles keyboard movements (NO BINDINGS SUPPORT)
		player.movementController(dt, v)

		--Constantly is updating our player's x,y position
		goalX = goalX + (v.xVel * dt)

		--Makes player instantly crouch instead of slowly falling
		if v.isCrouching and not v.isOnGround then
			goalY = goalY + 16
		else
			goalY = goalY + (v.yVel * dt)
		end

		--Left side of screen collision
		if goalX <= 0 then
			goalX = 0
		end

		--Fall detection
		if v.yVel <= 10 then
			v.isOnGround = false
		end

		--Death detection
		if goalY >= CONST_WORLD_LIMIT or goalY <= -CONST_WORLD_LIMIT then
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
			v.health = 3
		end

		--Handles animation state switching
		animationStateController(dt, player[i])

		--Called after animation controller..handles sounds
		soundStateController(dt, player[i])

		--checks to see the player will collide with something using the goalX,Y
		v.x, v.y, collisions, len = world:move(v, goalX, goalY, player.filter)

		--Hit detection
		for a,coll in ipairs(collisions) do
			--Checks if the player's feet are on a solid collision
			if coll.normal.y < 0 and not coll.knockback and not coll.bounce then
			--[[coll.normal.y <= 0 -lets player jump off side off blocks]]--
				v.isOnGround = true
				v.yVel = 0
			end
			--Response for knockback damage
			if coll.knockback then
				v.isKnockback = true
				object_damage(player[i], 0)
				--4 = playerTop, 3 = playerBottom, 2 = playerRight, 1 = playerLeft
				if v.damageDir == 1 then
					v.xVel = -v.jumpHeight / 2
					v.yVel = v.yVel + v.jumpHeight / 3
				elseif v.damageDir == 2 then
					v.xVel = v.jumpHeight / 2
					v.yVel = v.yVel + v.jumpHeight / 3
				elseif v.damageDir == 3 then
					v.xVel = -v.jumpHeight / 3
					v.yVel = v.yVel - v.jumpHeight
				elseif v.damageDir == 4 then
					v.xVel = v.jumpHeight / 3
					v.yVel = v.yVel - v.jumpHeight
				end
			else
				v.isKnockback = false
				v.damageDir = 0
			end
			--Response for going in water blocks
			if coll.submerge then
				v.isUnderwater = true
				status_text.create(tostring(v.isUnderwater))
			else
				v.isUnderwater = false
				--status_text.create(tostring(v.isUnderwater))
			end
		end

		--i-frame buffer update
		player.resetDmgBuffer(dt, player[i])
		--print("Jump Held: " .. tostring(v.jumpHeld) .. ", isOnGround: " .. tostring(v.isOnGround))

		--Sets camera height to player's y + height offset
		--Subraction here to raise camera pos higher
		local playerHeight = math.abs(v.y - v.height)

		--Check if camera's y pos is lower than the player
		if cameraY <= playerHeight then
			cameraY = cameraY + cameraYTransitionSpeed * dt	
			if cameraY >= playerHeight then
				--When camera position equals player's STOP
				cameraY = playerHeight
			end
		--Check if camera's y pos is higher than player
		elseif cameraY >= playerHeight then
			cameraY = cameraY - cameraYTransitionSpeed * dt
			if cameraY <= playerHeight then
				--When camera position equals player's STOP
				cameraY = playerHeight
			end
		end

		--update our cameras position
		cam:setPosition(goalX + v.width * 10, cameraY)
	end
end

function player.draw()
	for i,v in ipairs(player) do
		local scaleX = v.dir
		--Change player color based on if damaged
		if not v.isDamaged then
			love.graphics.setColor(.15, 1, 1)
		elseif v.isDamaged then
			love.graphics.setColor(.05, .75, 1, .6)
		end

		love.graphics.draw(v.animationTable[v.current_frame], v.x + (v.width / 2), v.y, 0, scaleX * player.playerScaling, player.playerScaling, v.animationTable[v.current_frame]:getWidth() / 2, 0)
	end
end

--Movement Controller sets the state and direction of the player after performing certain actions
--This tells the animation controller what to render
function player.movementController(dt, plr)
	--Checks if any movement keys are being held down
	local keyDown = love.keyboard.isDown(moveRight, moveLeft, moveJump, moveCrouch)

	--Idle
	if not keyDown and plr.isOnGround then
		plr.xVel = 0
		stateChange(plr, "idle")
	elseif love.keyboard.isDown(moveCrouch) and plr.isOnGround then
		plr.xVel = 0
		stateChange(plr, "crouch")
	elseif not love.keyboard.isDown(moveCrouch) and plr.isCrouching then
		stateChange(plr, "idle")
	elseif not love.keyboard.isDown(moveJump) and plr.jumpHeld then
		--Flips our jumpHeld var back to false, cancelling high jump if player lets go of control mid-air
		plr.jumpHeld = false
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
	--[[if not plr.isKnockback then
	if love.keyboard.isDown("lctrl") and love.keyboard.isDown("d") and plr.isOnGround and plr.isCrouching then
		plr.xVel = plr.speed / 2
		plr.dir = 1
		stateChange(plr, "crouch_walk")
	elseif love.keyboard.isDown("lctrl") and love.keyboard.isDown("a") and plr.isOnGround and plr.isCrouching then
		plr.xVel = -plr.speed / 2
		plr.dir = -1
		stateChange(plr, "crouch_walk")
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

	--Jumping update(item, x2,y2,w2,h2)
	if love.keyboard.isDown(moveJump) and plr.isOnGround and not plr.isCrouching then
		plr.yVel = plr.jumpHeight
		plr.jumpHeld = true
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

function player.resetDmgBuffer(dt, plr)
	if plr.isDamaged then
		plr.isDamagedTimer = plr.isDamagedTimer + 1 * dt
		if plr.isDamagedTimer > plr.isDamagedTimerMax then
			plr.isDamagedTimer = 0
			plr.isDamaged = false
		end
	end
end

player.filter = function(item, other)
	local playerX, playerY, playerW, playerH = world:getRect(item)
	local otherX, otherY, otherW, otherH = world:getRect(other)

	local playerBottom, playerRight = playerY + playerH, playerX + playerW
	local otherBottom, otherRight = otherY + otherH, otherX + otherW

--Checks which block/ent to check against
	if other.subtype == "wooden_plat" then
		--Allows player to go through bottom
		if playerBottom <= otherY then
			return 'slide'
		end
		
	elseif other.subtype == "dev_block" or other.subtype == "dev_block2" or other.subtype == "grass_block" or other.subtype == "grass_block_r" or other.subtype == "grass_block_l" or other.subtype == "grass_block_d" or other.subtype == "dirt_block" or other.subtype == "item_block" then
		--All of these blocks are completely solid on each side

		--Check if player has hit head on a block to push them towards ground
		--Last 2 checks are checking if player is inside a wall to the right and left
		if (playerY >= otherY + otherH) and (playerRight ~= otherX) and (playerX ~= otherRight) then
			stateChange(item, "fall")
			item.jumpHeld = false
			item.yVel = 0
			return 'touch'
		end
		
		return 'slide'

	elseif other.subtype == "spike_block_u" then
		--Check which direction spikes are facing for knockback
		--4 = playerTop, 3 = playerBottom, 2 = playerRight, 1 = playerLeft
		if playerRight >= otherX then
			if item.dir == 1 then
				item.damageDir = 2
			elseif item.dir == -1 then
				item.damageDir = 1
			end
		elseif playerX <= otherX + otherW then
			if item.dir == 1 then
				item.damageDir = 2
			elseif item.dir == -1 then
				item.damageDir = 1
			end
		end

		return 'knockback'

	elseif other.subtype == "spike_block_d" then
		if playerRight >= otherX then
			if item.dir == 1 then
				item.damageDir = 4
			elseif item.dir == -1 then
				item.damageDir = 3
			end
		elseif playerX <= otherX + otherW then
			if item.dir == 1 then
				item.damageDir = 4
			elseif item.dir == -1 then
				item.damageDir = 3
			end
		end

		return 'knockback'

	elseif other.subtype == "water_block" then
			item.isUnderwater = true
			return "submerge"

	elseif other.subtype == "goon" then
		--Orient player towards enemy that hit them
		--Knock back player in relation(opposite of) to enemy's direction
		if playerRight >= otherX or playerX <= otherX + otherW then
			if item.dir == 1 then
				item.damageDir = 2
			elseif item.dir == -1 then
				item.damageDir = 1
			end

			return 'knockback'
		end
	end
end
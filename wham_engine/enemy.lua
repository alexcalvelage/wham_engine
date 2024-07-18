--initialize enemy data table
enemy = {enemyScaling = 1.66}
function enemy.spawn(subtype, x, y, dir)
	--insert (1) enemy into the enemy table with included values
	table.insert(enemy, {id = #enemy + 1, type = "enemy", subtype = subtype, health = 1, x = x, y = y, spawn_x = x, spawn_y = y, width = 25, height = 64, speed = 75, xVel = 0, yVel = 0, jumpHeight = -800, isOnGround = false, isKnockback = false, dir = dir, damageDir = 0, target = nil, cleanup = false, searchRange = 250, loseRange = 500, state = "idle", prevState = "", animationTable = player_idle, current_frame = 1, animation_timescale = 12, tick = 0})
	--Centers our enemy inside a block
	enemy[#enemy].x, enemy[#enemy].y = enemy[#enemy].x + 4, enemy[#enemy].y - (enemy[#enemy].height / 2)
	--adds collisions to each enemy created
	world:add(enemy[#enemy], enemy[#enemy].x, enemy[#enemy].y, enemy[#enemy].width, enemy[#enemy].height)
end

function enemy.update(dt)
	for i,v in ipairs(enemy) do
		--matches ids to indices
		v.id = i

		if v.cleanup then
			table.remove(enemy, v.id)
			world:remove(v)
		end

		--Change AI behaviors based on current game state
		if LET_CUR_GAME_STATE == "create_state" then
			v.xVel, v.yVel = 0, 0
			v.isOnGround = true
		elseif LET_CUR_GAME_STATE == "play_state" then
			--Cue gravity
			v.yVel = v.yVel + (CONST_GRAVITY * dt)

			--where we WANT to go provided no collisions
			local goalX, goalY = v.x, v.y

			--Handles keyboard movements (NO BINDINGS SUPPORT)
			enemy.movementController(dt, v)

			--Constantly is updating our enemy's x,y position
			goalX = goalX + (v.xVel * dt)
			goalY = goalY + (v.yVel * dt)

			--Left side of screen collision
			if goalX <= 0 then
				goalX = 0
			end

			--Fall detection
			if v.yVel <= 10 then
				v.isOnGround = false
			end

			--Death detection
			if goalY >= CONST_WORLD_LIMIT then
				v.health = 0
			end
			if v.health <= 0 then
				v.xVel, v.yVel = 0, 0
				v.cleanup = true
			end

			--Handles animation state switching
			animationStateController(dt, enemy[i])

			-->>>>SOUND STATE CONTROLLER GOES HERE<<<<--
			--[][]--

			--checks to see the enemy will collide with something using the goalX,Y
			v.x, v.y, collisions, len = world:move(enemy[i], goalX, goalY, enemy.filter)
			
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
					--v.health = v.health - 1
					--4 = playerTop, 3 = playerBottom, 2 = playerRight, 1 = playerLeft
					if v.damageDir == 1 then
						v.xVel = -v.jumpHeight / 3
						v.yVel = v.jumpHeight / 4
					elseif v.damageDir == 2 then
						v.xVel = v.jumpHeight / 3
						v.yVel = v.jumpHeight / 4
					elseif v.damageDir == 3 then
						v.xVel = -v.jumpHeight / 3
						v.yVel = -1 * (v.jumpHeight / 8)
					elseif v.damageDir == 4 then
						v.xVel = v.jumpHeight / 3
						v.yVel = -1 * (v.jumpHeight / 8)
					end
				else
					v.isKnockback = false
					v.damageDir = 0
				end
			end
		end
	end
end

function enemy.draw()
	for i,v in ipairs(enemy) do
		if not v.cleanup then
			local scaleX = v.dir
			love.graphics.setColor(1, .15, .15)
			love.graphics.draw(v.animationTable[v.current_frame], v.x + (v.width / 2), v.y, 0, scaleX * enemy.enemyScaling, enemy.enemyScaling, v.animationTable[v.current_frame]:getWidth() / 2, 0)
		end
	end
end

--Movement Controller sets the state and direction of the enemy after performing certain actions
--This tells the animation controller what to render
function enemy.movementController(dt, me)
	local moveInProgress = false

	if me.target then
		if me.x <= me.target.x then
			me.dir = 1
		elseif me.x >= me.target.x then
			me.dir = -1
		end

		moveInProgress = true

		for a,b in ipairs(player) do
			--Target has been lost
			if math.dist(me.x, 0, b.x, 0) > me.loseRange then
				me.target = nil
			end
		end
	elseif me.target == nil then
		for a,b in ipairs(player) do
			if math.dist(me.x, 0, b.x, 0) < me.searchRange then
				me.target = player[a]
			end
		end
	end

	--Idle
	if not moveInProgress and me.isOnGround then
		me.xVel = 0
		stateChange(me, "idle")
	end

	if moveInProgress then
		if me.dir == 1 and me.isOnGround then
			me.xVel = me.speed
		elseif me.dir == -1 and me.isOnGround then
			me.xVel = -me.speed
		end

		stateChange(me, "run")
	end

	--Falling
	if (me.state ~= "front_flip" and me.state ~= "jump" and me.state ~= "crouch") and not me.isOnGround then
		stateChange(me, "fall")
	end
end

enemy.filter = function(item, other)
	local enemyX, enemyY, enemyW, enemyH = world:getRect(item)
	local otherX, otherY, otherW, otherH = world:getRect(other)

	local enemyBottom, enemyRight = enemyY + enemyH, enemyX + enemyW

	--Checks which block/ent to check against
	if other.subtype == "wooden_plat" then
		if enemyBottom <= otherY then
			return 'slide'
		end
		
	elseif other.subtype == "dev_block" or other.subtype == "dev_block2" or other.subtype == "grass_block" or other.subtype == "grass_block_r" or other.subtype == "grass_block_l" or other.subtype == "dirt_block" or other.subtype == "item_block" then
		return 'slide'

	elseif other.subtype == "spike_block_u" then
		--Check which direction spikes are facing for knockback
		--4 = playerTop, 3 = playerBottom, 2 = playerRight, 1 = playerLeft
		if enemyRight >= otherX then
			if item.dir == 1 then
				item.damageDir = 2
			elseif item.dir == -1 then
				item.damageDir = 1
			end
		elseif enemyX <= otherX + otherW then
			if item.dir == 1 then
				item.damageDir = 2
			elseif item.dir == -1 then
				item.damageDir = 1
			end
		end

		return 'knockback'

	elseif other.subtype == "spike_block_d" then
		if enemyRight >= otherX then
			if item.dir == 1 then
				item.damageDir = 4
			elseif item.dir == -1 then
				item.damageDir = 3
			end
		elseif enemyX <= otherX + otherW then
			if item.dir == 1 then
				item.damageDir = 3
			elseif item.dir == -1 then
				item.damageDir = 4
			end
		end

		return 'knockback'
	end
end
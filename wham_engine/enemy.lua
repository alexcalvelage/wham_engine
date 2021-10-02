--initialize enemy data table
enemy = {enemyScaling = 1.66}
function enemy.spawn(subtype, x, y, dir)
	--insert (1) enemy into the enemy table with included values
	table.insert(enemy, {subtype = subtype, health = 1, x = x, y = y, width = 25, height = 64, speed = 50, xVel = 0, yVel = 0, jumpHeight = -800, isOnGround = false, dir = dir, target = nil, cleanup = false, searchRange = 250, loseRange = 500, state = "fall", prevState = "", animationTable = player_fall, current_frame = 1, animation_timescale = 12, tick = 0})
	--adds collisions to each enemy created
	world:add(enemy[#enemy], enemy[#enemy].x, enemy[#enemy].y, enemy[#enemy].width, enemy[#enemy].height)
end

function enemy.update(dt)
	for i,v in ipairs(enemy) do
		if not v.cleanup then
			--Cue gravity
			v.yVel = v.yVel + (CONST_GRAVITY * dt)

			--where we WANT to go provided no collisions
			local goalX, goalY = v.x, v.y

			--Handles keyboard movements (NO BINDINGS SUPPORT)
			enemy.movementController(dt, enemy[i])

			--Constantly is updating our enemy's x,y position
			goalX = goalX + (v.xVel * dt)
			goalY = goalY + (v.yVel * dt)

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
				v.cleanup = true
			end

			--Handles animation state switching
			animationStateController(dt, enemy[i])

			--checks to see the enemy will collide with something using the goalX,Y
			v.x, v.y, collisions, len = world:move(enemy[i], goalX, goalY, enemy.filter)
			
			for a,coll in ipairs(collisions) do
				--we are goin' up and thru!
				if coll.touch.y >= goalY then
					v.isOnGround = false
				elseif coll.normal.y < 0 then --coming down onto block
					v.isOnGround = true
					v.yVel = 0
				end
			end
		end
	end
end

function enemy.draw()
	for i,v in ipairs(enemy) do
		local scaleX = v.dir
		love.graphics.setColor(1, .15, .15)
		love.graphics.draw(v.animationTable[v.current_frame], v.x + (v.width / 2), v.y, 0, scaleX * enemy.enemyScaling, enemy.enemyScaling, v.animationTable[v.current_frame]:getWidth() / 2, 0)
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
	if me.state ~= "front_flip" and me.state ~= "jump" and not me.isOnGround then
		stateChange(me, "fall")
	end
end

enemy.filter = function(item, other)
	local x, y, w, h = world:getRect(other)
	local px, py, pw, ph = world:getRect(item)
	local enemyBottom = py + ph
	local enemyLeft, enemyRight = px, px + pw
	local otherBottom = y + h

	--Resolves colliding with the top of blocks
	--Checks which hitbox to check against
	if other.subtype == "wooden_plat" then
		if enemyBottom <= y then
			return 'slide'
		end
	elseif other.subtype == "item_block" or other.subtype == "dev_block" or other.subtype == "grass_block" or other.subtype == "grass_block_l" or other.subtype == "grass_block_r" then
		if py >= y or enemyBottom <= y then
			return 'slide'
		end
		if px <= x or enemyRight >= x then
			return 'slide'
		end
	--Resolves enemy collision with other enemies
	elseif other.type == "enemy" then
		if enemyLeft >= x or enemyRight <= x + w then
			return 'slide'
		end
	end
end
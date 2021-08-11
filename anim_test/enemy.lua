--initialize enemy data table
enemy = {}
enemy_collision = {}
function enemy.spawn(subtype, x, y, dir)
	--insert (1) enemy into the enemy table with included values
	table.insert(enemy, {type = "enemy", subtype = subtype, x = x, y = y, width = 28, height = 80, speed = 50, xVel = 0, yVel = 0, jumpHeight = -800, isOnGround = false, dir = dir, target = nil, searchRange = 250, loseRange = 500, state = "fall", prevState = "", animationTable = animationTable, current_frame = 1, animation_timescale = 12})
	--adds collisions to each enemy created
	enemy_collision[#enemy] = world:add(enemy[#enemy], enemy[#enemy].x, enemy[#enemy].y, enemy[#enemy].width, enemy[#enemy].height)
end

function enemy.update(dt)
	for i,v in ipairs(enemy) do
		--Cue gravity
		v.yVel = v.yVel + (CONST_GRAVITY * dt)

		--where we WANT to go provided no collisions
		local goalX, goalY = v.x, v.y

		--Handles keyboard movements (NO BINDINGS SUPPORT)
		enemy.movementController(dt, enemy[i])

		--Constantly is updating our enemy's x,y position
		goalX = goalX + (v.xVel * dt)
		goalY = goalY + (v.yVel * dt)

		--Handles animation state switching
		enemy.animationStateController(dt, enemy[i])

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

function enemy.draw()
	local enemyScaling = 2
	for i,v in ipairs(enemy) do
		love.graphics.setColor(1, 0, 0)
		--width is used here to calculate offset when mirroring texture
		local meWidth = v.animationTable[math.floor(v.current_frame)]:getWidth() * enemyScaling
		local meHeight = v.animationTable[math.floor(v.current_frame)]:getHeight() * enemyScaling
		v.width, v.height = meWidth, meHeight

		--flips enemy's texture when switching directions
		if v.dir == "right" then
			love.graphics.draw(v.animationTable[math.floor(v.current_frame)], v.x, v.y, 0, enemyScaling, enemyScaling, 0, 0)
		elseif v.dir == "left" then
			love.graphics.draw(v.animationTable[math.floor(v.current_frame)], v.x, v.y, 0, -enemyScaling, enemyScaling, v.width / enemyScaling, 0)
		end
	end
end

--Movement Controller sets the state and direction of the enemy after performing certain actions
--This tells the animation controller what to render
function enemy.movementController(dt, me)
	local moveInProgress = false

	if me.target then
		if me.x <= me.target.x then
			me.dir = "right"
		elseif me.x >= me.target.x then
			me.dir = "left"
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

	if not moveInProgress and me.isOnGround then
		me.xVel = 0
		enemy.stateChange(me, "idle", love.math.random(1, #player_idle))
	end

	if moveInProgress then
		if me.dir == "right" and me.isOnGround then
			me.xVel = me.speed
		elseif me.dir == "left" and me.isOnGround then
			me.xVel = -me.speed
		end

		enemy.stateChange(me, "run")
	end
end

function enemy.stateChange(me, state, startFrame)
	--Changes enemy state only if a new action has occured.
	--Checks if the new incoming state is different from the current state
	if me.state ~= state then
		--Checks if we need to change the starting animation frame..otherwise defaults to 1
		startFrame = startFrame or 1
		me.prevState = me.state
		me.state = state
		me.current_frame = startFrame
	end
end

--Takes enemy state data from the Movement Controller and sets the animations accordingly
function enemy.animationStateController(dt, me)
	--Resets animation timing if it has been changed
	enemy.animationTimeScale(me, 12)

	--Change enemy's animation based on his current state
	enemy.animationChange(me, me.state, startFrame)

	--Every game frame, move ahead an animation frame based on animation timing
	me.current_frame = me.current_frame + me.animation_timescale * dt
	if me.current_frame >= #me.animationTable then
		--Instead of just resetting our current animation frame we instead switch
		--enemy states to falling so that the jump and flip anims don't loop
		if me.state == "jump" or me.state == "front_flip" then
			--overrides any previous animation changes
			enemy.stateChange(me, "fall")
		end
		--Once we reach the end of the animation data table, start back at the beginning
		--Lua indices start at 1 instead of 0 :l
		me.current_frame = 1
	end
end

--Allows ease of animation changes
function enemy.animationChange(me, state)
	--Checks for specific action states to determine action anim speed
	if me.state == "jump" then
		enemy.animationTimeScale(me, 4)
	elseif me.state == "front_flip" then
		enemy.animationTimeScale(me, 16)
	end

	--current enemies use the player animation data
	local enemy_state = ("player_" .. state)
	--converts concatenated string back to name of Global table
	--EG: "enemy_" .. "idle" == "enemy_idle" converted to enemy_idle
	me.animationTable = _G[enemy_state]
end

--Changes timescale of animations(anim speed)
function enemy.animationTimeScale(me, time)
	me.animation_timescale = time
end

enemy.filter = function(item, other)
	local x, y, w, h = world:getRect(other)
	local px, py, pw, ph = world:getRect(item)
	local enemyBottom = py + ph
	local enemyLeft, enemyRight = px, px + pw
	local otherBottom = y + h

	--Resolves colliding with the top of blocks
	if other.subtype == "platform_block" then
		if enemyBottom <= y then
			return 'slide'
		end
	elseif other.subtype == "item_block" or other.subtype == "ground_block" then
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
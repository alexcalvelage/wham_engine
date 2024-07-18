local select_x, select_y, select_width, select_height = 0, 0, 0, 0

block = {}
--block_collision = {}
function block.spawn(subtype, x, y, w, h)
	table.insert(block, {id = #block + 1, type = "block", subtype = subtype, quad = subtype, quad_overlay = nil, itemInside = nil, x = x, y = y, width = w or 32, height = h or 32, highlight = false})
	--Concatenate quad extension
	block[#block].quad = tostring(block[#block].quad) .. "_QD"
end

function block.update(dt)
	for i,v in ipairs(block) do
		--Check to disable default block highlighitng behavior
		--This allows the editor to display what blocks are selected
		--The selection tool uses a different method of highlighting as well
		if LET_EDITOR_TOOL ~= "editor_tool_select" then
			block.highlight(v)
			for a = 1, #button do
				if v.highlight and button[a].highlight then
					block.unhighlight(v)
				end
			end
			if LET_EDITOR_TOOL == "editor_tool_draw" then
				if love.mouse.isDown(1) then
					block.editor_paint(v)
				elseif love.mouse.isDown(2) then
					block.editor_paint(v, true)
				end
			elseif LET_EDITOR_TOOL == "editor_tool_dropper" then
				if love.mouse.isDown(1) then
					block.editor_dropper_paint(v)
				elseif love.mouse.isDown(2) then
					block.editor_dropper_paint(v, true)
				end
			elseif LET_EDITOR_TOOL == "editor_tool_linker" then
				--linker will let user select 2 objects to link them
				if love.mouse.isDown(1) then --lmb (for first object)
				elseif love.mouse.isDown(2) then --rmb (for second object)
				elseif love.mouse.isDown(3) then --mmb (clear link?)
				end
			end
		elseif LET_EDITOR_TOOL == "editor_tool_select" then
			block.clickActionUpdate(v)
		end
	end
end

function block.draw()
	--Clears our spritebatch draw call
	block_SB:clear()
	local camPosX, camPosY, camPosW, camPosH = cam:getVisible()
	local camSpacing = 32

	for i = 1, #block do
		--This isIntersecting func seems to cause major slow down..although headed in the right direction
		if bump.rect.isIntersecting(camPosX, camPosY, camPosW, camPosH, block[i].x, block[i].y, block[i].width, block[i].height) then
			--slower than isIntersecting()
			--if block[i].x < camPosX + camPosW and block[i].x > camPosX - camSpacing and block[i].y < camPosY + camPosH and block[i].y > camPosY - camSpacing then
			block_SB:add(_G[block[i].quad], block[i].x, block[i].y)
		end
	end

	--Draws our spritebatch
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(block_SB)

	for i = 1, #block do
		--[[if block[i].itemInside then
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", block[i].x, block[i].y, block[i].width, block[i].height)
			love.graphics.setColor(0, 0, 0)
			love.graphics.print(tostring(block[i].itemInside.id), block[i].x, block[i].y)
		end--]]
		if block[i].quad_overlay ~= nil then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(block_all_IMG, block[i].quad_overlay, block[i].x, block[i].y)
		end
	end

	--Our selection rectangle for the selection tool
	love.graphics.setColor(0, 0, 1, .2)
	love.graphics.rectangle("fill", select_x or 0, select_y or 0, select_width or 0, select_height or 0)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(tostring(select_x) .. " / " .. tostring(select_y) .. " / " .. tostring(select_width)  .. " / " .. tostring(select_height), worldMouseX + 32, worldMouseY - 16)
end

function block.highlight(me)
	--Checks mouse cursor position to determine if it's inside a block or not
	--Subtract 2 to reduce likelyhood of selecting multiple at once
	if worldMouseX >= me.x and
	worldMouseX <= me.x + me.width -2 and
	worldMouseY >= me.y and
	worldMouseY <= me.y + me.height -2 then
		me.highlight = true
		--sets block highlight texture
		me.quad_overlay = highlight_block_QD
	else
		block.unhighlight(me)
	end
end

function block.clickAction(mButton)
	if LET_EDITOR_TOOL == "editor_tool_select" then
		if mButton == 1 then
			--Set x,y when mouse is initially clicked
			select_x = worldMouseX
			select_y = worldMouseY
		end
	end
end

function block.clickActionUpdate(me)
	if LET_EDITOR_TOOL == "editor_tool_select" then
		if love.mouse.isDown(1) then
			--Local vars for bounding box if width/height are negative values
			local newX = nil
			local newY = nil
			local newW = nil
			local newH = nil
			--Select_* vars are local to this file..init at top
			--Continously sets w,h while mouse1 is being held down to set bounding box size
			select_width = worldMouseX - select_x
			select_height = worldMouseY - select_y

			--If w,h go negative, change newX->startingX - how far cursor is from origin
			--newX becomes the bounding box Width
			--newW becomes the bounding box X position
			if select_width ~= math.abs(select_width) then
				newX = select_x - math.abs(select_width)
				newW = math.abs(select_width)
				
			end
			if select_height ~= math.abs(select_height) then
				newY = select_y - math.abs(select_height)
				newH = math.abs(select_height)
			end

			--Start check to see if the supplied coordinates contain the center(x,y) point of any block
			if bump.rect.containsPoint(newX or select_x, newY or select_y, newW or select_width, newH or select_height, me.x + me.width / 2, me.y + me.height / 2) then
				--Center (x,y) point of block is inside the bounding box 
				me.highlight = true
				--Sets block highlight texture
				me.quad_overlay = highlight_block_QD
			else
				--If any block is outside the bounding box, set to unhighlighted
				block.unhighlight(me)
			end

		elseif love.mouse.isDown(2) then
			block.editor_paint(me)
		elseif love.mouse.isDown(3) then
			block.editor_paint(me, true)
		end
	end
end

function block.typeChange(me, subtype)
	if me.subtype ~= subtype then
		--Changes block quad to corresponding block subtype
		me.subtype = subtype
		me.quad = tostring(me.subtype) .. "_QD"
		--Checks to make sure collision on this doesn't already exist
		if not world:hasItem(me) then
			world:add(me, me.x, me.y, me.width, me.height)
		end

		if subtype == "air_block" then
			playSound(remove_block_SND)
		else
			playSound(place_block_SND)
		end
	end
end

function block.editor_paint(me, erase)
	if me.highlight then
		if erase then
			block.typeChange(me, "air_block")
		elseif not erase then
			block.typeChange(me, LET_EDITOR_BLOCKTYPE_SELECTED)
		end
	end
end

function block.editor_dropper_paint(me, erase)
	if me.highlight then
		if erase then
			if me.itemInside then
				me.itemInside.cleanup = true
				me.itemInside = nil
				
				playSound(remove_block_SND)
			end
		elseif not erase then
			if not me.itemInside then
				--Branch off for actual objects vs enemies
				if LET_EDITOR_OBJECTTYPE_SELECTED ~= "enemy" then
					object.spawn(LET_EDITOR_OBJECTTYPE_SELECTED, me.x, me.y)
					--Plugin the lastly spawned object as the item inside(TABLE DATA)
					me.itemInside = object[#object]
				elseif LET_EDITOR_OBJECTTYPE_SELECTED == "enemy" then
					enemy.spawn("goon", me.x, me.y, 1)
					me.itemInside = enemy[#enemy]
				end

				playSound(place_block_SND)
			end
		end
	end
end

--air, grass, grass_r, grass_l, dirt, wooden_plat, spike, devblock, itemblock
function block.cycleSelectedBlock(y)
	local maxIndex = 13
	--[[
	Implement way to initialize blocks inside a table
	then it's possible to automate the maxIndex
	--]]
	if y < 0 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = LET_EDITOR_BLOCKTYPE_SELECTED_INDEX + 1
	elseif y > 0 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = LET_EDITOR_BLOCKTYPE_SELECTED_INDEX - 1
	end

	if LET_EDITOR_BLOCKTYPE_SELECTED_INDEX > maxIndex then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = 1
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX < 1 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = maxIndex
	end

	if LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 1 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "dev_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 2 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "dev_block2"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 3 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 4 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block_d"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 5 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block_r"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 6 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block_l"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 7 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "dirt_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 8 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "wooden_plat"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 9 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "spike_block_u"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 10 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "spike_block_d"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 11 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "item_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 12 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "player_spawn"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 13 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "water_block"
	end
end

--
function block.cycleSelectedObject(y)
	local maxIndex = 4
	if y < 0 then
		LET_EDITOR_OBJECTTYPE_SELECTED_INDEX = LET_EDITOR_OBJECTTYPE_SELECTED_INDEX + 1
	elseif y > 0 then
		LET_EDITOR_OBJECTTYPE_SELECTED_INDEX = LET_EDITOR_OBJECTTYPE_SELECTED_INDEX - 1
	end

	if LET_EDITOR_OBJECTTYPE_SELECTED_INDEX > maxIndex then
		LET_EDITOR_OBJECTTYPE_SELECTED_INDEX = 1
	elseif LET_EDITOR_OBJECTTYPE_SELECTED_INDEX < 1 then
		LET_EDITOR_OBJECTTYPE_SELECTED_INDEX = maxIndex
	end

	if LET_EDITOR_OBJECTTYPE_SELECTED_INDEX == 1 then
		LET_EDITOR_OBJECTTYPE_SELECTED = "cog"
	elseif LET_EDITOR_OBJECTTYPE_SELECTED_INDEX == 2 then
		LET_EDITOR_OBJECTTYPE_SELECTED = "enemy"
	elseif LET_EDITOR_OBJECTTYPE_SELECTED_INDEX == 3 then
		LET_EDITOR_OBJECTTYPE_SELECTED = "button"
	elseif LET_EDITOR_OBJECTTYPE_SELECTED_INDEX == 4 then
		LET_EDITOR_OBJECTTYPE_SELECTED = "door"
	end
end

function block.interact(me)
end

function block.unhighlight(me)
	me.highlight = false
	--sets block highlight texture
	me.quad_overlay = nil
end
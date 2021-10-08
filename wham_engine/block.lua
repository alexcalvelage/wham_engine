local select_x, select_y, select_width, select_height

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
			end
		end

		block.clickActionUpdate(v)
	end
end

function block.draw()
	--Clears our spritebatch draw call
	block_SB:clear()

	for i = 1, #block do
		--Turn string back into Global
		block_SB:add(_G[block[i].quad], block[i].x, block[i].y)
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
			select_x = worldMouseX
			select_y = worldMouseY
		end
	end
end

function block.clickActionUpdate(me)
	if LET_EDITOR_TOOL == "editor_tool_select" then
		if love.mouse.isDown(1) then
			select_width = worldMouseX - select_x
			select_height = worldMouseY - select_y

			if bump.rect.containsPoint(newX or select_x, newY or select_y, newW or select_width, newH or select_height, me.x + me.width / 2, me.y + me.height / 2) then
				me.highlight = true
				--sets block highlight texture
				me.quad_overlay = highlight_block_QD
			else
				block.unhighlight(me)
			end
		elseif love.mouse.isDown(2) then
			block.editor_paint(me)
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

--Finish adding in removal of objects from scene!!
function block.editor_dropper_paint(me, erase)
	if me.highlight then
		if erase then
			if me.itemInside then
				if world:hasItem(object[me.itemInside]) then
					object[me.itemInside].cleanup = true
					me.itemInside = nil

					--table.remove(_G[me.itemInside.type], me.itemInside.id)
					--world:remove(_G[me.itemInside.type][me.itemInside.id])
					playSound(remove_block_SND)
				end
			end
		elseif not erase then
			if not me.itemInside then
				--Branch off for actual objects vs enemies
				if LET_EDITOR_OBJECTTYPE_SELECTED == "cog" then
					object.spawn(LET_EDITOR_OBJECTTYPE_SELECTED, me.x, me.y)
					--Plugin the lastly spawned object as the item inside
					me.itemInside = object[#object].id
					print(me.itemInside)
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
	local maxIndex = 10
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
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 3 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block_r"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 4 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "grass_block_l"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 5 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "dirt_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 6 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "wooden_plat"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 7 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "spike_block_u"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 8 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "spike_block_d"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 9 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "item_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 10 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "player_spawn"
	end
end

--
function block.cycleSelectedObject(y)
	local maxIndex = 2
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
	end
end

function block.interact(me)
end

function block.unhighlight(me)
	me.highlight = false
	--sets block highlight texture
	me.quad_overlay = nil
end
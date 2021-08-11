block = {}
block_collision = {}
function block.spawn(subtype, x, y, w, h)
	table.insert(block, {id = #block + 1, type = "block", subtype = subtype, quad = subtype, quad_overlay = nil, x = x, y = y, width = w or 32, height = h or 32, highlight = false})
	--Concatenate quad extension
	block[#block].quad = tostring(block[#block].quad) .. "_QD"
end

function block.update(dt)
	for i = 1, #block do
		--Check to disable default block highlighitng behavior
		--This allows the editor to display what blocks are selected
		if LET_EDITOR_DEFAULT_TOOL ~= "editor_tool_select" then
			block.highlight(block[i])
		end
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
		if block[i].quad_overlay ~= nil then
			love.graphics.draw(block_all_IMG, block[i].quad_overlay, block[i].x, block[i].y)
		end
	end
end

function block.typeChange(me, subtype)
	--Changes block quad to corresponding block subtype
	me.subtype = subtype
	me.quad = tostring(me.subtype) .. "_QD"
	--Checks to make sure collision on this doesn't already exist
	if not block_collision[me.id] then
		block_collision[me.id] = world:add(me, me.x, me.y, me.width, me.height)
	end
end

function block.highlight(me)
	--Checks mouse cursor position to determine if it's inside a block or not
	if worldMouseX >= me.x and
	worldMouseX <= me.x + me.width and
	worldMouseY >= me.y and
	worldMouseY <= me.y + me.height then
		me.highlight = true
		--sets block highlight texture
		me.quad_overlay = highlight_block_QD
	else
		me.highlight = false
		me.quad_overlay = nil
	end
end

function block.clickAction(user, mButton)
	if LET_EDITOR_DEFAULT_TOOL == "editor_tool_select" then
		if mButton == 1 then
				for i = 1, #block do
				if block[i].highlight then
					user.editor.select_x = 0
					user.editor.select_y = 0
					user.editor.select_width = 0
					user.editor.select_height = 0
				elseif not block[i].highlight then
					user.editor.select_x = worldMouseX
					user.editor.select_y = worldMouseY
				end
			end
		end
	end
	if LET_EDITOR_DEFAULT_TOOL == "editor_tool_draw" then
		if mButton == 1 then
			for i = 1, #block do
				if block[i].highlight then
					if block[i].subtype ~= "ground_block" then
						block.typeChange(block[i], "ground_block")
					end
				end
			end
		elseif mButton == 2 then
			for i = 1, #block do
				if block[i].highlight then
					if block[i].subtype ~= "item_block" then
						block.typeChange(block[i], "item_block")
					end
				end
			end
		elseif mButton == 3 then
			for i = 1, #block do
				if block[i].highlight then
					if block[i].subtype ~= "air_block" then
						block.typeChange(block[i], "air_block")
					end
				end
			end
		end
	end
end

function block.clickReleaseAction(user)
	if LET_EDITOR_DEFAULT_TOOL == "editor_tool_select" then
		if love.mouse.isDown(1) then
			user.editor.select_width = worldMouseX - user.editor.select_x
			user.editor.select_height = worldMouseY - user.editor.select_y

			if math.ceil(user.editor.select_width) < 100 then
				--user.editor.select_width = math.abs(user.editor.select_width)
				user.editor.select_width = math.abs(user.editor.select_width)
			end
			if math.ceil(user.editor.select_height) < 100 then
				user.editor.select_height = math.abs(user.editor.select_height)
			end
			for i = 1, #block do
				if CheckCollision(user.editor.select_x, user.editor.select_y, user.editor.select_width, user.editor.select_height, block[i].x, block[i].y, block[i].width, block[i].height) then
					block[i].highlight = true
					--sets block highlight texture
					block[i].quad_overlay = highlight_block_QD
				else
					block[i].highlight = false
					--sets block highlight texture
					block[i].quad_overlay = nil
				end
			end
		elseif love.mouse.isDown(2) then
			block.editor_paint()
		end
	end
end

function block.editor_paint()
	if LET_EDITOR_DEFAULT_TOOL == "editor_tool_select" then
		for i = 1, #block do
			if block[i].highlight then
				block.typeChange(block[i], LET_EDITOR_BLOCKTYPE_SELECTED)
			end
		end
	end
end

function block.cycleSelectedBlock(y)
	if y > 0 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = LET_EDITOR_BLOCKTYPE_SELECTED_INDEX + 1
	elseif y < 0 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = LET_EDITOR_BLOCKTYPE_SELECTED_INDEX - 1
	end

	if LET_EDITOR_BLOCKTYPE_SELECTED_INDEX > 3 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = 1
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX < 1 then
		LET_EDITOR_BLOCKTYPE_SELECTED_INDEX = 3
	end

	if LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 1 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "ground_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 2 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "item_block"
	elseif LET_EDITOR_BLOCKTYPE_SELECTED_INDEX == 3 then
		LET_EDITOR_BLOCKTYPE_SELECTED = "air_block"
	end
end
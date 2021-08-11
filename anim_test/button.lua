--add support for activeState

button = {}
function button.spawn(quad, action, activeState, x, y, w, h)
	table.insert(button, {id = #button + 1, type = "button", action = action, activeState = activeState, enabled = enabled, quad = quad, quad_overlay = nil, x = x, y = y, width = w or 190, height = h or 49, highlight = false})
	--Center our button according to our width, height
	button[#button].x, button[#button].y = button[#button].x - (button[#button].width / 2), button[#button].y - (button[#button].height / 2)
	--Concatenate quad extension
	button[#button].quad = tostring(button[#button].quad)
end

			--if (gameState ~= "play" and not gameIsPaused) or 
			--(gameState == "play" and gameIsPaused) or (gameState == "options") then

function button.update(dt)
	for i = 1, #button do
		button.detectVisibility(button[i])
		button.highlight(button[i])
	end
end

function button.draw()
		--Clears our spritebatch draw call
		button_SB:clear()
		for i = 1, #button do
			if button[i].enabled then
				--Turn string back into Global
				button_SB:add(_G[button[i].quad], button[i].x, button[i].y)
			end
		end

		--Draws our spritebatch
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(button_SB)

		--Loop over table twice to render highlight visual effect
		for i = 1, #button do
		if button[i].enabled then
			if button[i].quad_overlay ~= nil then
				love.graphics.draw(ui_hover_all_IMG, button[i].quad_overlay, button[i].x, button[i].y)
			end
		end
	end
end

function button.detectVisibility(me)
	for i = 1, #button do
		if (me.activeState == "pauseButton" and LET_CUR_GAME_STATE == "play_state" and LET_GAME_PAUSED) or (me.activeState == "play_state") then
			me.enabled = true
		elseif (me.activeState ~= LET_CUR_GAME_STATE) then
			me.enabled = false
		end
	end
end

function button.highlight(me)
	if worldMouseX >= me.x and
	worldMouseX <= me.x + me.width and
	worldMouseY >= me.y and
	worldMouseY <= me.y + me.height then
		me.highlight = true
		local quad_string = tostring(me.quad) .. "_2"
		me.quad_overlay = _G[quad_string]
	else
		me.highlight = false
		me.quad_overlay = nil
	end
end

function button.clickAction()
	for i = 1, #button do
		if button[i].enabled then
			if button[i].highlight then
				--MAIN MENU ACTIONS
				if button[i].action == "play" then
				elseif button[i].action == "load" then
				elseif button[i].action == "create" then
				elseif button[i].action == "options" then
				elseif button[i].action == "quit" then
					love.event.quit()
				--PAUSE MENU ACTIONS
				elseif button[i].action == "resume" then
				--elseif button[i].action == "options" --use other action and just check state?
				elseif button[i].action == "exit_session" then
					switchGameState("menu_0_state")
				--EDITOR ACTIONS
				elseif button[i].action == "tool_selection" then
				elseif button[i].action == "tool_draw" then
				elseif button[i].action == "tool_fill" then
				elseif button[i].action == "tool_item_dropper" then
				elseif button[i].action == "save" then
				elseif button[i].action == "load" then
				end
			end
		end
	end
end
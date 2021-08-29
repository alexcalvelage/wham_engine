local selectedButtons = {}

button = {}
function button.spawn(quad, action, activeState, x, y, w, h)
	table.insert(button, {id = #button + 1, type = "button", action = action, activeState = activeState, enabled = enabled, quad = quad, quad_overlay = nil, x = x, y = y, width = w or 194, height = h or 49, highlight = false})
	--Center our button according to our width, height
	button[#button].x, button[#button].y = button[#button].x - (button[#button].width / 2), button[#button].y - (button[#button].height / 2)
	--Concatenate quad extension
	button[#button].quad = tostring(button[#button].quad)
end

function button.update(dt)
	for i = 1, #button do
		button.detectVisibility(button[i])

		if button[i].enabled then
			button.highlight(button[i])
		end
	end
end

function button.draw()
		--Clears our spritebatch draw call
		button_SB:clear()
		for i = 1, #button do
			if button[i].enabled then
				--Turn string back into Global		
				button_SB:add(_G[button[i].quad], button[i].x, button[i].y)
				love.graphics.setColor(1, 1, 1)
			end
		end

		--Draws our spritebatch
		love.graphics.draw(button_SB)

		--Loop over table twice to render highlight visual effect
		for i = 1, #button do
		if button[i].enabled then
			if button[i].quad_overlay ~= nil then
				love.graphics.draw(ui_buttons_all_IMG, button[i].quad_overlay, button[i].x, button[i].y)
			end
		end
	end
end

function button.detectVisibility(me)
	--Checks to make sure buttons are only usable/rendered when they need to be.
	if (me.activeState == "pauseButton" and LET_GAME_PAUSED and LET_PANEL_FOCUS == false) or (me.activeState == LET_PANEL_OPEN and LET_GAME_PAUSED) or (me.activeState == LET_CUR_GAME_STATE and not LET_GAME_PAUSED) then
		me.enabled = true
	else
		me.enabled = false
		--if a button is selected and then it becomes disabled, this 
		--ensures that it is unselected
		me.highlight = false
	end
end

function button.highlight(me)
	if mouseX >= me.x and
	mouseX <= me.x + me.width and
	mouseY >= me.y and
	mouseY <= me.y + me.height then
		me.highlight = true
		local quad_string = tostring(me.quad) .. "_2"
		me.quad_overlay = _G[quad_string]
		LET_BUTTON_SELECTED = me.highlight
	else
		me.highlight = false
		me.quad_overlay = nil
	end
end

function button.clickAction(mButton)
	if mButton == 1 then
		for i = 1, #button do
			if button[i].highlight then
				--MAIN MENU ACTIONS
				if button[i].action == "play_game_action" then
				elseif button[i].action == "load_game_action" then
				elseif button[i].action == "create_level_action" then
				elseif button[i].action == "options_action" then
				elseif button[i].action == "quit_action" then
					love.event.quit()
				--PAUSE MENU ACTIONS
				elseif button[i].action == "resume_action" then
					LET_PANEL_FOCUS = false
					LET_PANEL_OPEN = ""
					LET_GAME_PAUSED = false
				elseif button[i].action == "save_level_action" then
					panel.typeChange("savePanel")
					love.keyboard.setTextInput(true)
					love.keyboard.setKeyRepeat(true)
				elseif button[i].action == "load_level_action" then
					panel.typeChange("loadPanel")
					love.keyboard.setTextInput(true)
					love.keyboard.setKeyRepeat(true)
				elseif button[i].action == "exit_session_action" then
					switchGameState("menu_state")
					love.mouse.setCursor(default_cursor)
				elseif button[i].action == "back_action" then
					panel.typeChange("")
					love.keyboard.setTextInput(false)
					love.keyboard.setKeyRepeat(false)
					LET_BROWSE_PATH = ""
				elseif button[i].action == "browse_action" then
					love.system.openURL("file://"..love.filesystem.getSaveDirectory())
				elseif button[i].action == "save_action" then
					saveLevel(tostring(LET_BROWSE_PATH), block, enemy)
				elseif button[i].action == "load_action" then
					loadLevel(tostring(LET_BROWSE_PATH))
				--EDITOR ACTIONS
				elseif button[i].action == "tool_selection_action" then
					editor_change_mode("editor_tool_select", selection_cursor)
				elseif button[i].action == "tool_draw_action" then
					editor_change_mode("editor_tool_draw", draw_cursor)
				elseif button[i].action == "tool_eraser_action" then
					editor_change_mode("editor_tool_eraser", eraser_cursor)
				elseif button[i].action == "tool_fill_action" then
				elseif button[i].action == "tool_dropper_action" then
					editor_change_mode("editor_tool_dropper", dropper_cursor)
				end
			end
		end
	end
end

function editor_change_mode(mode, cursor)
	love.mouse.setCursor(cursor)
	LET_EDITOR_TOOL = mode
end

--Check if create buttons are hovered over
--If these specific buttons are hovered then dont allow block highlight

button = {}
function button.spawn(quad, action, activeState, x, y, w, h, text)
	table.insert(button, {id = #button + 1, type = "button", action = action, activeState = activeState, text = text or nil, enabled = enabled, quad = quad, quad_overlay = nil, x = x, y = y, width = w or 194, height = h or 49, highlight = false})
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
	--Fixes spritebatch force clearing itself when sharing screen on Discord
	if LET_GAME_FOCUSED then
		--Clears our spritebatch draw call
		button_SB:clear()
	end
	
	for i = 1, #button do
		if button[i].enabled then
			--Turn string back into Global and add our button to the spritebatch
			button_SB:add(_G[button[i].quad], button[i].x, button[i].y)
		end
	end

	--Draws our spritebatch
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(button_SB)

	--Loop over table twice to render highlight visual effect*
	for i = 1, #button do
		if button[i].enabled then
			if button[i].quad_overlay ~= nil then
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(ui_buttons_all_IMG, button[i].quad_overlay, button[i].x, button[i].y)
			end

			if button[i].text ~= nil then
				if button[i].highlight then
					love.graphics.setColor(1,1,1)
				else
					love.graphics.setColor(0,0,0)
				end
				love.graphics.setFont(defaultKeyBindFont)
				--draws button text if available
				love.graphics.printf(button[i].text, button[i].x, button[i].y + 2, 37, "center")
			end
		end
	end
end

function button.detectVisibility(me)
	--Checks to make sure buttons are only usable/rendered when they need to be.
	--CHECKS: PAUSE MENU -> PANEL BUTTONS -> EDITOR BUTTONS + MENU BUTTONS
	if (me.activeState == "pauseButton" and LET_GAME_PAUSED and LET_PANEL_FOCUS == false) or (me.activeState == LET_PANEL_OPEN) or (me.activeState == LET_CUR_GAME_STATE and not LET_GAME_PAUSED and not LET_OPTIONS_MENU and not LET_LVLSELECTION_MENU) then
		me.enabled = true
	else
		me.enabled = false
		--if a button is selected and then it becomes disabled, this ensures that it is unselected
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
				local action = button[i].action
--MAIN MENU ACTIONS
				if action == "play_game_action" then
					--Remove for menu implementation
					panel.typeChange("lvlselectionPanel")
					LET_LVLSELECTION_MENU = true
					--loadOfficialLevel(LET_CURRENT_LEVEL)
					--switchGameState("play_state")
				elseif action == "load_game_action" then
				elseif action == "create_level_action" then
					--Remove for menu implementation
					if LET_CURRENT_LEVEL ~= "" then
						loadEditorLevel(LET_CURRENT_LEVEL)
					else
						status_text.create("global: LET_CURRENT_LEVEL NOT SET")
						button.levelSelect("default")
					end

					switchGameState("create_state")
				elseif action == "options_action" then
					panel.typeChange("optionsPanel")
					LET_OPTIONS_MENU = true
				elseif action == "quit_action" then
					love.event.quit()
--PAUSE MENU ACTIONS
				elseif action == "resume_action" then
					pauseGame()
				elseif action == "save_level_action" then
					panel.typeChange("savePanel")
					love.keyboard.setTextInput(true)
					love.keyboard.setKeyRepeat(true)
				elseif action == "load_level_action" then
					panel.typeChange("loadPanel")
					love.keyboard.setTextInput(true)
					love.keyboard.setKeyRepeat(true)
				elseif action == "exit_session_action" then
					switchGameState("menu_state")
					deloadLevel()
					editor_change_mode("", default_cursor)
				elseif action == "back_action" then
					button.backButtonReset()
				elseif action == "browse_action" then
					love.system.openURL("file://"..love.filesystem.getSaveDirectory())
				elseif action == "save_action" then
					saveLevel(tostring(LET_BROWSE_PATH), block, enemy, object)
				elseif action == "load_action" then
					loadEditorLevel(tostring(LET_BROWSE_PATH))
--OPTIONS ACTIONS
				elseif action == "options_keybinds_moveLeft" then
					start_keybind_change("moveLeft", button[i])
				elseif action == "options_keybinds_moveRight" then
					start_keybind_change("moveRight", button[i])
				elseif action == "options_keybinds_moveJump" then
					start_keybind_change("moveJump", button[i])
				elseif action == "options_keybinds_moveCrouch" then
					start_keybind_change("moveCrouch", button[i])
--LEVEL SELECTION ACTIONS
				elseif action == "lvl01_action" then
					button.levelSelect("default")
				elseif action == "lvl02_action" then
					button.levelSelect("testes")
--EDITOR ACTIONS
				elseif action == "tool_selection_action" then
					editor_change_mode("editor_tool_select", selection_cursor)
				elseif action == "tool_draw_action" then
					editor_change_mode("editor_tool_draw", draw_cursor)
				elseif action == "tool_eraser_action" then
					editor_change_mode("editor_tool_eraser", eraser_cursor)
				elseif action == "tool_fill_action" then
				elseif action == "tool_dropper_action" then
					editor_change_mode("editor_tool_dropper", dropper_cursor)
				elseif action == "tool_nuke_action" then
					editor_change_mode("editor_tool_nuke", eraser_cursor)
					panel.typeChange("lvlwarnPanel")
				elseif action == "confirmwipe_action" then
					button.confirmWipe()
				elseif action == "cancelwipe_action" then
					button.cancelWipe()
				end
			end
		end
	end
end

function button.backButtonReset()
	panel.typeChange("")
	love.keyboard.setTextInput(false)
	love.keyboard.setKeyRepeat(false)
	LET_BROWSE_PATH = ""
	editor_change_mode("")
	LET_OPTIONS_MENU = false
	LET_LVLSELECTION_MENU = false
end

function button.levelSelect(level_name)
	button.backButtonReset()
	loadOfficialLevel(level_name)
	switchGameState("play_state")
end

function button.cancelWipe()
	button.backButtonReset()
end

function button.confirmWipe()
	button.backButtonReset()
	for i = 1, #block do
		block.typeChange(block[i], "air_block")
	end

	block.typeChange(block[gridRowsY/2], "player_spawn")
	block.typeChange(block[gridRowsY/2+1], "dev_block")
	status_text.create("LEVEL WIPED")
end

function editor_change_mode(mode, cursor)
	--If current tool is the same as the supplied tool
	--then just toggle off tool to default
	if LET_EDITOR_TOOL == mode then
		LET_EDITOR_TOOL = ""
		cursor = default_cursor
	else
		LET_EDITOR_TOOL = mode
	end

	love.mouse.setCursor(cursor or default_cursor)
end
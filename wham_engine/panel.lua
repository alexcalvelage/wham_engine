local newPanelTextboxY = 0

panel = {}
function panel.spawn(quad, activeState, x, y, w, h)
	table.insert(panel, {id = #panel + 1, type = "panel", action = action, activeState = activeState, enabled = false, quad = quad, quad_overlay = nil, x = x, y = y, width = w or 194, height = h or 49, highlight = false})
	--Center our panel according to our width, height
	panel[#panel].x, panel[#panel].y = panel[#panel].x - (panel[#panel].width / 2), panel[#panel].y - (panel[#panel].height / 2)
	--Concatenate quad extension
	panel[#panel].quad = tostring(panel[#panel].quad)
end

function panel.update(dt)
	for i = 1, #panel do
		panel.detectVisibility(panel[i])

		if LET_PANEL_OPEN == "consolePanel" then
			newPanelTextboxY = panel[i].y + (panel[i].height / 2) - 128
		else
			newPanelTextboxY = nil
		end
	end
end

function panel.draw()
	local hint_path = nil
	--Clears our spritebatch draw call
	panel_SB:clear()
	for i = 1, #panel do
		if panel[i].enabled then
			--Turn string back into Global		
			panel_SB:add(_G[panel[i].quad], panel[i].x, panel[i].y)
		end
	end

	--Draws our spritebatch
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(panel_SB)

	--Loop over table twice to render highlight visual effect
	for i = 1, #panel do
		if panel[i].enabled then
			if LET_BROWSE_PATH == "" then
				love.graphics.setColor(0, 0, 0, .5)
				if panel[i].activeState == "loadPanel" then
					--hint_path = "From '%APPDATA%' you can drag+drop a level file here."
					hint_path = "Browse to drag+drop a level file here"
				elseif panel[i].activeState == "savePanel" then
					hint_path = "Ex: 'something_funny_v1'"
				elseif panel[i].activeState == "consolePanel" then
					hint_path = "Enter a command:"
				end
			else
				love.graphics.setColor(0, 0, 0)
				hint_path = nil
			end

			--Draw console history
			--[[if panel[i].activeState == "consolePanel" then
				for i = 1, #LET_CONSOLE_HISTORY do
					love.graphics.printf(LET_CONSOLE_HISTORY[i], panel[i].x - (panel[i].width / 2), panel[i].y - (panel[i].height / 2) + 14 * i, 480, "left")
				end
			end--]]

			--Draw textbox
			if love.keyboard.hasTextInput() then
				love.graphics.setColor(83/255, 53/255, 74/255)
				love.graphics.rectangle("fill", panel[i].x + 12, newPanelTextboxY or panel[i].y + (panel[i].height / 2) - 14, 480, 24)

				love.graphics.setFont(defaultFont)
				--Adds ticker to end of string
				if hint_path or #LET_BROWSE_PATH > 0 then
					love.graphics.setColor(1, 1, 1, LET_TEXTBOX_TICKER_ALPHA)
					love.graphics.printf("|", panel[i].x + 12 + defaultFont:getWidth(LET_BROWSE_PATH), newPanelTextboxY or panel[i].y + (panel[i].height / 2) - 14, 480, "left")
				end
			end

			--Draw text
			love.graphics.setColor(1, 1, 1)
			love.graphics.printf(hint_path or LET_BROWSE_PATH, panel[i].x + 12, newPanelTextboxY or panel[i].y + (panel[i].height / 2) - 14, 480, "left")

			if panel[i].quad_overlay ~= nil then
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(ui_panels_all_IMG, panel[i].quad_overlay, panel[i].x, panel[i].y)
			end
		end

		
	end
end

function panel.detectVisibility(me)
		--Checks to make sure panels are only usable/rendered when they need to be.
	if LET_PANEL_OPEN == me.activeState then
		me.enabled = true
	else
		me.enabled = false
	end
end

function panel.typeChange(panelToOpen)
	LET_PANEL_PREV = LET_PANEL_OPEN
	LET_PANEL_OPEN = panelToOpen
	if LET_PANEL_FOCUS then
		LET_PANEL_FOCUS = false
	else
		LET_PANEL_FOCUS = true
	end
end

function panel.clickAction(mpanel)
end

function panel.content_draw()
	if LET_PANEL_OPEN == "optionsPanel" then
		love.graphics.setColor(1,1,1)
		love.graphics.setFont(font_panel_title)
		love.graphics.printf("Options", 310, 120, 1280, "left")
		love.graphics.setFont(font_panel_subtitle)
		love.graphics.printf("Controls", 315, 220, 1280, "left")
		love.graphics.printf("Audio", -320, 220, 1280, "right")
		love.graphics.setFont(font_panel_subtitle2)
		love.graphics.printf("Move Right", 420, 280, 1280, "left")
		love.graphics.printf("Move Left", 420, 325, 1280, "left")
		love.graphics.printf("Jump", 420, 370, 1280, "left")
		love.graphics.printf("Crouch", 420, 417, 1280, "left")
	elseif LET_PANEL_OPEN == "savePanel" then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(font_panel_subtitle)
		love.graphics.printf("Save Level", 0, 270, 1280, "center")
	elseif LET_PANEL_OPEN == "loadPanel" then
		love.graphics.setColor(1, 1, 1)
		love.graphics.setFont(font_panel_subtitle)
		love.graphics.printf("Load Level", 0, 270, 1280, "center")
	end
end
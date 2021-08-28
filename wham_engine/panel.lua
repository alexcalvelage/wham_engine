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
					hint_path = "From '%APPDATA%' you can drag+drop a level file here."
				elseif panel[i].activeState == "savePanel" then
					hint_path = "Ex: 'something_funny_v1'"
				end
			else
				love.graphics.setColor(0, 0, 0)
				hint_path = nil
			end
			love.graphics.setFont(defaultFontSmol)
			love.graphics.printf(hint_path or LET_BROWSE_PATH, panel[i].x + 12, panel[i].y + (panel[i].height / 2) - 14, 278, "left")
			love.graphics.setFont(defaultFont)
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
	LET_PANEL_OPEN = panelToOpen
	if LET_PANEL_FOCUS then
		LET_PANEL_FOCUS = false
	else
		LET_PANEL_FOCUS = true
	end
end

function panel.clickAction(mpanel)
end
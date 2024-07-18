local status_text = {
	_VERSION		= "1.0.0",
	_DESCRIPTION	= "Library for printing system messages",
	_URL			= "N/A",
	_LICENSE		= "N/A"
}

local textFont = love.graphics.newFont(14)
local gameWindowWidth = love.window.getMode()

status_text.print = function(text)
	table.insert(status_text, {x = 6, y = 12, text = text, alpha = 1, speed = 9})
end

status_text.update = function(dt)
	for i,v in ipairs(status_text) do
		if v.y <= -textFont:getHeight() then --Removes objects from table when no longer visible
			table.remove(status_text, i)
		end
		if math.dist(v.x, v.y, 0, 0) <= textFont:getHeight() then --Allows each object to fade away at a specific distance from the top of screen
			v.alpha = v.alpha - .45 * dt
		end	

		for j = i + 1, #status_text do
			if math.dist(status_text[j].x, status_text[j].y, v.x, v.y) <= textFont:getHeight() / 2 then
				status_text[j].y = status_text[j].y + textFont:getHeight() / 2
			end
		end

		v.y = v.y - v.speed * dt
	end
end

status_text.draw = function()
	for i,v in ipairs(status_text) do
		love.graphics.setFont(textFont)
		--[][][]Add support for different colored messages
		love.graphics.setColor(1, 1, 1, v.alpha)
		love.graphics.printf(v.text, v.x, v.y, gameWindowWidth / 1.5, "left")
	end
end

return status_text
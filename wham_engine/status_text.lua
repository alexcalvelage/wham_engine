status_text = {}
function status_text.create(text)
	table.insert(status_text, {x = 0, y = 25, text = text, alpha = 1})
end

function status_text.update(dt)
	for i,v in ipairs(status_text) do
		v.y = v.y - 3 * dt
		v.alpha = v.alpha - .01 * dt
		if v.y <= -12 then
			table.remove(status_text, i)
		end
	end
end

function status_text.draw()
	for i,v in ipairs(status_text) do
		love.graphics.setFont(defaultFontBold)
		love.graphics.setColor(1, 1, 1, v.alpha)
		love.graphics.printf(v.text, v.x, v.y * i, gwidth / 2, "left")
	end
end
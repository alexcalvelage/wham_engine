status_text = {}
function status_text.create(text)
	table.insert(status_text, {x = 0, y = 15, text = text, alpha = 1})
end

function status_text.update(dt)
	--Has to be looped with ipairs otherwise table.remove fails
	for i,v in ipairs(status_text) do
		v.y = v.y - 10 * dt
		v.alpha = v.alpha - .30 * dt
		if v.y <= 0 then
			table.remove(status_text, i)
		end
	end
end

function status_text.draw()
	for i = 1, #status_text do
		love.graphics.setFont(defaultFontBold)
		love.graphics.setColor(1, 1, 1, status_text[i].alpha)
		love.graphics.printf(status_text[i].text, status_text[i].x, status_text[i].y, gwidth / 2, "left")
	end
end
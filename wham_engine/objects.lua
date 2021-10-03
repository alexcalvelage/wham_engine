--initialize object data table
object = {objectScaling = 1}
function object.spawn(subtype, x, y)
	table.insert(object, {type = "object", subtype = subtype, x = x, y = y, width = 32, height = 32, cleanup = false, state = "", animationTable = nil, current_frame = 1, animation_timescale = 1, tick = 0})
	world:add(object[#object], object[#object].x, object[#object].y, object[#object].width, object[#object].height)
end

function object.update(dt)
	for i,v in ipairs(object) do
		if not v.cleanup then
			object.checkValidAnimationTable(object[i])
			--Handles animation state switching
			animationStateController_Objects(dt, object[i])
		end
	end
end

--Refactor draw code with spritebatches in mind
function object.draw()
	for i,v in ipairs(object) do
		if v.animationTable then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(v.animationTable[v.current_frame], v.x + (v.width / 2), v.y, 0, object.objectScaling, object.objectScaling, v.animationTable[v.current_frame]:getWidth() / 2, 0)
		end
	end
end

--Checks to make sure that a given object has a proper animation table setup
function object.checkValidAnimationTable(obj)
	if not obj.animationTable then
		if obj.subtype == "cog" then
			obj.state = "spin"
		else
			obj.state = "idle"
		end

		animationChange_Objects(obj)
	end
end

object.filter = function(item, other)
	local x, y, w, h = world:getRect(other)
	local px, py, pw, ph = world:getRect(item)
	local objectBottom = py + ph
	local objectLeft, objectRight = px, px + pw
	local otherBottom = y + h
end
function math.dist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function CheckCollision(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2 + w2 and
	x2 < x1 + w1 and
	y1 < y2 + h2 and
	y2 < y1 + h1
end

function getFileName(path)
	return path:match("^(.-)([^\\/]-)%.([^\\/%.]-)%.?$")
end

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function Unset(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = false end
    return set
end

function Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end
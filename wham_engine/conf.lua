
--Allows realtime console printing
io.stdout:setvbuf("no")
function love.conf(t)
	--t.console = true
	t.window.title = "WHAM Engine [5/22/2022] | Alex Calvelage | Love2D [11.3] "
	t.identity = "WHAM"
end

--Allows realtime console printing
io.stdout:setvbuf("no")
function love.conf(t)
	--t.console = true
	t.window.title = "WHAM Engine | Alex Calvelage"
	t.identity = "WHAM"
end
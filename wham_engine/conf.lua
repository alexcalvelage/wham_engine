
--Allows realtime console printing
io.stdout:setvbuf("no")
function love.conf(t)
	t.console = false
	t.window.title = "wham engine | alex calvelage [12/22/2021] | love2d [11.3] "
	t.identity = "WHAM"
end
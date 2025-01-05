local Level = require("level")

local level

function love.load()
	love.graphics.setBackgroundColor(255, 255, 255)
	level = Level:new()
end

function love.update(dt)
	level:update(dt)
end

function love.keypressed(key)
	level:keypressed(key)
end

function love.draw()
	level:draw()
end

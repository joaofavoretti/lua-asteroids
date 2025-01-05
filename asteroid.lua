local Asteroid = {}
Asteroid.__index = Asteroid

function Asteroid:new(x, y, radius, angle)
	local self = setmetatable({}, Asteroid)
	self.x = x
	self.y = y
	self.radius = radius
	self.angle = angle
	self.speed = 100
	self.vx = math.cos(self.angle) * self.speed
	self.vy = math.sin(self.angle) * self.speed
	return self
end

function Asteroid:update(dt)
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	-- Wrap around the screen
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()
	if self.x < -self.radius then
		self.x = screenWidth
	elseif self.x > screenWidth + self.radius then
		self.x = -self.radius
	end
	if self.y < -self.radius then
		self.y = screenHeight
	elseif self.y > screenHeight + self.radius then
		self.y = -self.radius
	end
end

function Asteroid:draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.circle("line", self.x, self.y, self.radius)
end

return Asteroid

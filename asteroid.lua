local Asteroid = {}
Asteroid.__index = Asteroid

local AsteroidVerticesNumber = 10

function Asteroid:new(x, y, radius, angle)
	local self = setmetatable({}, Asteroid)
	self.x = x
	self.y = y
	self.radius = radius
	self.angle = angle
	self.speed = 100
	self.vx = math.cos(self.angle) * self.speed
	self.vy = math.sin(self.angle) * self.speed
	self.offsets = self:getVerticesOffsets()
	return self
end

function Asteroid:getVerticesOffsets()
	local offsets = {}
	local numPoints = AsteroidVerticesNumber
	for i = 1, numPoints do
		local offset = math.random(self.radius / 8, self.radius / 2)
		table.insert(offsets, offset)
	end
	return offsets
end

function Asteroid:getVertices()
	local vertices = {}
	local numPoints = AsteroidVerticesNumber
	for i = 1, numPoints do
		local angle = (i - 1) * 2 * math.pi / numPoints
		local x = self.x + math.cos(angle) * (self.radius + self.offsets[i])
		local y = self.y + math.sin(angle) * (self.radius + self.offsets[i])
		table.insert(vertices, x)
		table.insert(vertices, y)
	end
	return vertices
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
	local vertices = self:getVertices()
	love.graphics.polygon("line", vertices)
end

return Asteroid

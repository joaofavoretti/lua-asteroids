local Projectile = {}
Projectile.__index = Projectile

function Projectile:new(x, y, angle)
	local self = setmetatable({}, Projectile)
	self.x = x
	self.y = y
	self.angle = angle
	self.speed = 500
	self.radius = 3
	self.vx = math.cos(self.angle) * self.speed
	self.vy = math.sin(self.angle) * self.speed
	self.ttl = 1.2
	self.alive = true

	local shootSound = love.audio.newSource("assets/shoot.wav", "static")
	shootSound:play()

	return self
end

function Projectile:update(dt)
	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	self.ttl = self.ttl - dt
	if self.ttl <= 0 then
		self.alive = false
	end

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

function Projectile:draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.circle("fill", self.x, self.y, self.radius)
end

function Projectile:isAlive()
	return self.alive
end

function Projectile:isColliding(asteroids)
	for i, asteroid in ipairs(asteroids) do
		local dx = self.x - asteroid.x
		local dy = self.y - asteroid.y
		local distance = math.sqrt(dx * dx + dy * dy)
		if distance < self.radius + asteroid.radius then
			return i
		end
	end
	return -1
end

return Projectile

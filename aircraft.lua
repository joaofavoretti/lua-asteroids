local Projectile = require("projectile")

local AirCraft = {}
AirCraft.__index = AirCraft

function AirCraft:new(x, y, size)
	local self = setmetatable({}, AirCraft)
	self.x = x
	self.y = y
	self.width = size
	self.height = size
	self.angle = 3 * math.pi / 2
	self.vx = 0
	self.vy = 0
	self.maxSpeed = 200
	self.rotationSpeed = 2
	self.acceleration = 100
	self.deceleration = 50
	self.accelerating = false

	self.projectiles = {}
	return self
end

function AirCraft:_updateMove(dt)
	if love.keyboard.isDown("d") then
		self.angle = self.angle + math.pi * self.rotationSpeed * dt
	elseif love.keyboard.isDown("a") then
		self.angle = self.angle - math.pi * self.rotationSpeed * dt
	end

	if love.keyboard.isDown("w") then
		self.accelerating = true
		local ax = math.cos(self.angle) * self.acceleration
		local ay = math.sin(self.angle) * self.acceleration
		self.vx = self.vx + ax * dt
		self.vy = self.vy + ay * dt
	elseif love.keyboard.isDown("s") then
		self.accelerating = true
		local ax = math.cos(self.angle) * self.deceleration
		local ay = math.sin(self.angle) * self.deceleration
		self.vx = self.vx - ax * dt
		self.vy = self.vy - ay * dt
	else
		self.accelerating = false
		-- Apply friction to gradually reduce speed when no key is pressed
		local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
		if speed > 0 then
			local friction = self.deceleration * dt
			self.vx = self.vx - (self.vx / speed) * friction
			self.vy = self.vy - (self.vy / speed) * friction
		end
	end

	-- Clamp speed to maxSpeed
	local speed = math.sqrt(self.vx * self.vx + self.vy * self.vy)
	if speed > self.maxSpeed then
		local scale = self.maxSpeed / speed
		self.vx = self.vx * scale
		self.vy = self.vy * scale
	end

	self.x = self.x + self.vx * dt
	self.y = self.y + self.vy * dt

	-- Wrap around the screen
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()
	if self.x < -self.width then
		self.x = screenWidth
	elseif self.x > screenWidth + self.height then
		self.x = -self.width
	end
	if self.y < -self.height then
		self.y = screenHeight
	elseif self.y > screenHeight + self.height then
		self.y = -self.height
	end
end

function AirCraft:_updateShoot(dt, asteroids)
	for i, projectile in ipairs(self.projectiles) do
		projectile:update(dt)
		if not projectile:isAlive() then
			table.remove(self.projectiles, i)
		end

		local index = projectile:isColliding(asteroids)
		if index > 0 then
			table.remove(asteroids, index)
			table.remove(self.projectiles, i)
		end
	end
end

function AirCraft:checkCraftCollision(asteroids)
	local function checkRectangleCircleCollision(rx, ry, rw, rh, angle, cx, cy, cr)
		-- Rotate the circle's center point back
		local cosA = math.cos(-angle)
		local sinA = math.sin(-angle)
		local dx = cx - rx
		local dy = cy - ry
		local rotatedX = dx * cosA - dy * sinA + rx
		local rotatedY = dx * sinA + dy * cosA + ry

		-- Find the closest point to the circle within the rectangle
		local closestX = math.max(rx - rw / 2, math.min(rotatedX, rx + rw / 2))
		local closestY = math.max(ry - rh / 2, math.min(rotatedY, ry + rh / 2))

		-- Calculate the distance between the circle's center and this closest point
		local distanceX = rotatedX - closestX
		local distanceY = rotatedY - closestY

		-- If the distance is less than the circle's radius, an intersection occurs
		local distanceSquared = distanceX * distanceX + distanceY * distanceY
		return distanceSquared < cr * cr
	end

	for _, asteroid in ipairs(asteroids) do
		if
			checkRectangleCircleCollision(
				self.x,
				self.y,
				self.width / 2,
				self.height / 1.5,
				self.angle,
				asteroid.x,
				asteroid.y,
				asteroid.radius
			)
		then
			return true
		end
	end
	return false
end

function AirCraft:keypressed(key)
	if key == "space" then
		local angle = self.angle
		local x = self.x + self.width / 2 + math.cos(angle) * self.width
		local y = self.y + self.height / 2 + math.sin(angle) * self.height
		local projectile = Projectile:new(x, y, angle)
		table.insert(self.projectiles, projectile)
	end
end

function AirCraft:update(dt, asteroids)
	self:_updateMove(dt)
	self:_updateShoot(dt, asteroids)
end

function AirCraft:_drawProjectiles()
	for _, projectile in ipairs(self.projectiles) do
		projectile:draw()
	end
end

function AirCraft:_drawAirCraft()
	love.graphics.push()
	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.translate(self.x + self.width / 2, self.y + self.height / 2)
	love.graphics.rotate(self.angle)

	-- Two wings
	love.graphics.setLineWidth(2)

	love.graphics.polygon(
		"line",
		self.width / 2,
		0,
		-self.width / 2,
		self.height / 3,
		-self.width / 4,
		0,
		-self.width / 2,
		-self.height / 3
	)
	-- love.graphics.polygon("fill", self.width / 2, 0, -self.width / 2, -self.height / 3, -self.width / 4, 0)

	if self.accelerating then
		-- Draw the thruster
		local function interpolate(x1, y1, x2, y2, t)
			local x = x1 + (x2 - x1) * t
			local y = y1 + (y2 - y1) * t
			return x, y
		end

		local midX, midY = interpolate(-self.width / 4, 0, -self.width / 2, -self.height / 3, 0.5)
		love.graphics.polygon("line", -self.width / 4, 0, midX, midY, 1.5 * midX, 0, midX, -midY)
	end

	love.graphics.pop()
end

function AirCraft:draw()
	self:_drawAirCraft()
	self:_drawProjectiles()
end

return AirCraft

local AirCraft = require("aircraft")
local Asteroid = require("asteroid")
local Explosion = require("explosion")

local AirCraftInitialX = love.graphics.getWidth() / 2
local AirCraftInitialY = love.graphics.getHeight() / 2
local AirCraftSize = 35
local Lifes = 3

local Level = {
	aircraft = AirCraft:new(AirCraftInitialX, AirCraftInitialY, AirCraftSize),
	asteroids = {},
	explosions = {},
	maxAsteroids = 10,
	asteroidSpawnTimer = 0,
	asteroidSpawnInterval = 2, -- Spawn a new asteroid every 5 seconds
	lifes = Lifes,
	score = 0,
}
Level.__index = Level

function Level:new()
	local self = setmetatable({}, Level)
	love.graphics.setBackgroundColor(255, 255, 255)
	math.randomseed(os.time())
	return self
end

function Level:resetAirCraft()
	self.aircraft.x = AirCraftInitialX
	self.aircraft.y = AirCraftInitialY
	self.aircraft.vx = 0
	self.aircraft.vy = 0
	self.aircraft.angle = 0
end

function Level:_updateEndGame()
	if love.keyboard.isDown("space") then
		self.lifes = Lifes
		self.asteroids = {}
		self.score = 0
		self:resetAirCraft()
	end
end

function Level:update(dt)
	if self:gameEnded() then
		self:_updateEndGame()
		return
	end

	-- Update the aircraft and bullet positions
	self.aircraft:update(dt, self.asteroids)

	-- Check for collisions between bullets and asteroids
	local projectileIndex, asterdoidIndex = self.aircraft:checkBulletCollision(self.asteroids)
	if projectileIndex ~= -1 and asterdoidIndex ~= -1 then
		table.remove(self.aircraft.projectiles, projectileIndex)
		table.remove(self.asteroids, asterdoidIndex)
		self.score = self.score + 50
	end

	-- Check for collisions between the aircraft and asteroids
	local craftCollision = self.aircraft:checkCraftCollision(self.asteroids)
	if craftCollision then
		self.lifes = self.lifes - 1
		local explosion = Explosion:new(self.aircraft.x, self.aircraft.y)
		table.insert(self.explosions, explosion)
		self:resetAirCraft()
	end

	-- Asteroid insertion
	self.asteroidSpawnTimer = self.asteroidSpawnTimer + dt
	if self.asteroidSpawnTimer >= self.asteroidSpawnInterval and #self.asteroids < self.maxAsteroids then
		self.asteroidSpawnTimer = 0
		local x = math.random(0, love.graphics.getWidth())
		local y = math.random(0, love.graphics.getHeight())
		local radius = math.random(10, 30)
		local angle = math.random() * 2 * math.pi
		local asteroid = Asteroid:new(x, y, radius, angle)
		table.insert(self.asteroids, asteroid)
	end

	-- Asteroid update
	for _, asteroid in ipairs(self.asteroids) do
		asteroid:update(dt)
	end

	-- Explosion update
	for i, explosion in ipairs(self.explosions) do
		explosion:update(dt)
		if explosion:isFinished() then
			table.remove(self.explosions, i)
		end
	end
end

function Level:gameEnded()
	return self.lifes <= 0
end

function Level:keypressed(key)
	if self:gameEnded() then
		return
	end

	self.aircraft:keypressed(key)
end

function Level:_drawLifes()
	love.graphics.setColor(0, 0, 0)
	for i = 1, self.lifes do
		AirCraft:new(20 + i * 20, 20, 20):draw()
	end
end

function Level:_drawScore()
	local screenWidth = love.graphics.getWidth()
	local scoreText = tostring(self.score)
	local fontSize = 24
	local font = love.graphics.newFont(fontSize)
	love.graphics.setFont(font)
	local textWidth = font:getWidth(scoreText)
	local x = (screenWidth - textWidth) / 2
	love.graphics.setColor(0, 0, 0)
	love.graphics.print(scoreText, x, 50)
end

function Level:_drawEndGame()
	local screenWidth = love.graphics.getWidth()
	local screenHeight = love.graphics.getHeight()
	local gameOverText = "Game Over"
	local restartText = "Press 'space' to restart"
	local font = love.graphics.getFont()
	local gameOverWidth = font:getWidth(gameOverText)
	local gameOverHeight = font:getHeight()
	local restartWidth = font:getWidth(restartText)
	local restartHeight = font:getHeight()

	love.graphics.setColor(0, 0, 0)
	love.graphics.print(gameOverText, (screenWidth - gameOverWidth) / 2, (screenHeight - gameOverHeight) / 2)
	love.graphics.print(
		restartText,
		(screenWidth - restartWidth) / 2,
		(screenHeight - restartHeight) / 2 + gameOverHeight + 10
	)
end

function Level:draw()
	if self:gameEnded() then
		self:_drawEndGame()
		return
	end

	self:_drawLifes()
	self:_drawScore()
	self.aircraft:draw()

	for _, asteroid in ipairs(self.asteroids) do
		asteroid:draw()
	end

	for _, explosion in ipairs(self.explosions) do
		explosion:draw()
	end
end

return Level

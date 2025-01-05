Explosion = {}
Explosion.__index = Explosion

function Explosion:new(x, y)
	local self = setmetatable({}, Explosion)
	self.x = x
	self.y = y
	self.finished = false
	self.lines = self:generateLines(7, 0.5)
	return self
end

function Explosion:generateLines(numLines, lifespan)
	local lines = {}
	for _ = 1, numLines do
		local angle = math.random() * 2 * math.pi
		local rotation = math.random() * 2 * math.pi
		local speed = math.random() * 100 + 50
		local line = {
			x = self.x,
			y = self.y,
			vx = math.cos(angle) * speed,
			vy = math.sin(angle) * speed,
			rotation = rotation,
			lifespan = lifespan,
			age = 0,
		}
		table.insert(lines, line)
	end
	return lines
end

function Explosion:update(dt)
	for i, line in ipairs(self.lines) do
		line.x = line.x + line.vx * dt
		line.y = line.y + line.vy * dt
		line.age = line.age + dt
		if line.age >= line.lifespan then
			table.remove(self.lines, i)
		end
	end
	if #self.lines == 0 then
		self.finished = true
	end
end

function Explosion:isFinished()
	return self.finished
end

function Explosion:draw()
	for _, line in ipairs(self.lines) do
		love.graphics.push()
		love.graphics.translate(line.x, line.y)
		love.graphics.rotate(line.rotation)
		love.graphics.line(0, 0, 20, 0)
		love.graphics.pop()
	end
end

return Explosion

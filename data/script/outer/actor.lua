-- BSD Zero Clause License
--
-- Copyright (c) 2025 sockentrocken
--
-- Permission to use, copy, modify, and/or distribute this software for any
-- purpose with or without fee is hereby granted.
--
-- THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
-- REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
-- AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
-- INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
-- LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
-- OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
-- PERFORMANCE OF THIS SOFTWARE.

local ACTOR_FRICTION     = 8.00
local ACTOR_VELOCITY     = 8.00
local ACTOR_GRAVITY      = 32.00
local ACTOR_FLOOR_HELPER = vector_3:new(0.0, -0.5, 0.0)
ACTOR_SPEED_MAX          = 8.00
ACTOR_SPEED_MIN          = 0.01

--[[----------------------------------------------------------------]]

---@class actor : entity
actor = entity:new()

---Create a new actor.
---@param status status # The game status.
---@return actor value # The actor.
function actor:new(status, previous)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "actor"
	i.health = 100.0

	--[[]]

	-- lift the entity up slightly so that they don't bleed into the ground, making them unable to move into another room.
	i.point.y = i.point.y + 0.01

	-- if status is not nil...
	if status then
		-- attach collider.
		i:attach_collider(status, vector_3:old(0.5, 1.0, 0.5))
		i.character = status.outer.rapier:character_controller()
	end

	return i
end

function actor:tick(status, step)
	--self:movement(status, step, vector_3:zero(), 0.0)
end

--[[----------------------------------------------------------------]]

---Actor movement logic, responsible for calculating friction.
---@param step 		 number   # Time step.
---@param wish_where vector_3 # The direction in which we want to move in.
---@param wish_speed number   # The magnitude in which we want to move in.
function actor:movement(status, step, wish_where, wish_speed)
	if self.floor then
		-- run movement logic.
		local velocity = vector_3:old(self.speed.x, 0.0, self.speed.z)
		local friction = velocity:magnitude()

		if friction > 0.0 then
			if friction < ACTOR_SPEED_MIN then
				friction = 1.0 - step * (ACTOR_SPEED_MIN / friction) * ACTOR_FRICTION
			else
				friction = 1.0 - step * ACTOR_FRICTION
			end

			if friction < 0.0 then
				self.speed:copy(vector_3:zero())
			else
				self.speed.x = self.speed.x * friction
				self.speed.z = self.speed.z * friction
			end
		end

		friction = wish_speed - self.speed:magnitude()

		if friction > 0.0 then
			self.speed:copy(self.speed + wish_where * math.min(friction, ACTOR_VELOCITY * step * wish_speed))
		end
	end

	--[[]]

	self.speed.y = self.floor and 0.0 or self.speed.y - ACTOR_GRAVITY * step

	-- if actor was on floor on the previous frame, add epsilon to verify we are still on floor. otherwise, use regular vertical speed.
	local check = self.floor and self.speed + ACTOR_FLOOR_HELPER or self.speed

	-- TO-DO: add function to move the collider on our own.
	-- move the character.
	local x, y, z, floor = status.outer.rapier:character_controller_move(step, self.character, self.collider, check)
	-- update the actor.
	self.point:set(x, y, z)
	self.floor = floor
end

---Hurt the current actor, decrementing its health, and running its kill method, if the health should go below 0.
---@param status status # The game status.
---@param source entity # The hurt source.
---@param damage number # The hurt damage.
function actor:hurt(status, source, damage)
	-- spawn blood particle.
	particle:new(status, nil, self.point, source.point - self.point, 1.0, vector_3:old(1.0, 0.0, 0.0), "blood")

	-- decrement health.
	self.health = self.health - damage

	-- if health is below zero...
	if self.health < 0.0 then
		-- run kill method.
		self:kill(status, source, damage)
	end
end

---Kill the current actor.
---@param status status # The game status.
---@param source entity # The kill source.
---@param damage number # The kill damage.
function actor:kill(status, source, damage)
	-- detach us from the entity list.
	self:detach(status)
end

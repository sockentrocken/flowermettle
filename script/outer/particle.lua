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

---@class particle : entity
particle = entity:new()

---Create a new particle.
---@param status status # The game status.
---@return particle value # The particle.
function particle:new(status, previous, point, direction, count, random, image)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i:set_point(status, point)

	i.__type = "particle"
	i.time = 0.0
	i.data = {}

	local y = vector_3:y()
	local z = direction:cross(vector_3:y())

	-- create a particle list.
	for x = 1, count do
		print("spawn")

		-- create random point.
		local random =
			(math.random() * random.x) * direction +
			math.random_sign(random.y) * y +
			math.random_sign(random.z) * z

		-- insert particle.
		table.insert(i.data, {
			point = vector_3:new(
				random.x,
				random.y,
				random.z
			),
			angle = math.random(0.0, 360.0),
			scale = math.random(2.0, 4.000),
			image = "video/" .. image .. "_" .. math.random(1, 3) .. ".png"
		})
	end

	status.system:set_texture("video/blood_1.png")
	status.system:set_texture("video/blood_2.png")
	status.system:set_texture("video/blood_3.png")
	status.system:set_texture("video/concrete_1.png")
	status.system:set_texture("video/concrete_2.png")
	status.system:set_texture("video/concrete_3.png")

	return i
end

-- to rotate around the center:
-- if scale = 3.0
-- then origin is half of the scale. (1.5, 1.5)
-- if scale = 1.0
-- then origin is half of the scale. (0.5, 0.5)

function particle:tick(status, step)
	-- decremet time.
	self.time = self.time + step * 4.0

	-- if time is over 1.0, detach us.
	if self.time >= 1.0 then
		self:detach(status)
	end
end

function particle:draw_3d(status)
	local color = color:white()
	local shape = box_2:old(math.snap(32.0, self.time * 128.0), 0.0, 32.0, 32.0)

	--color.a = math.floor(255.0 * math.out_quad(1.0 - self.time))

	-- for each particle in the particle list...
	for _, particle in ipairs(self.data) do
		-- smooth out point, angle.
		local point = vector_3:old(
			math.out_quad(self.time) * particle.point.x,
			math.out_quad(self.time) * particle.point.y,
			math.out_quad(self.time) * particle.point.z
		)
		local angle = math.out_quad(self.time) * particle.angle
		local scale = math.out_quad(self.time) * particle.scale
		local image = status.system:get_texture(particle.image)

		-- draw particle.
		image:draw_billboard_pro(status.outer.camera_3d, shape, self.point + point,
			vector_3:y(), vector_2:one() * scale, vector_2:one() * scale * 0.5, angle, color)
	end
end

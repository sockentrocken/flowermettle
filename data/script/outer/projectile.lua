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

---@class projectile : entity
---@field parent entity
projectile = entity:new()

---Create a new projectile.
---@param status status # The game status.
---@return projectile value # The projectile.
function projectile:new(status, previous)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "projectile"

	return i
end

function projectile:tick(status, step)
	self.point:copy(self.point + (self.speed * step))

	local collider = status.outer.rapier:test_intersect_cuboid(self.point, vector_3:zero(), vector_3:one() * 0.5)

	-- if collider is not nil...
	if collider then
		-- get user-data from collider.
		local user = status.outer.rapier:get_collider_user_data(collider)

		-- if collider is not the same as the ignore collider...
		if not (user == self.parent.index) then
			-- find an entity with the same index as the user-data.
			local entity = status.outer:entity_find_index(status, user)

			-- if entity is not nil...
			if entity then
				-- if entity has a hurt method...
				if entity.hurt then
					-- hurt entity.
					entity:hurt(status, self, 25.0)
				end
			else
				-- cast ray.
				local collider, x, y, z = status.outer.rapier:cast_ray_normal(ray:old(self.point, self.speed), 2048.0,
					true)

				-- if collider is not nil...
				if collider then
					-- spawn smoke particle.
					particle:new(status, nil, self.point, vector_3:old(x, y, z), 1.0, vector_3:old(4.0, 0.0, 1.0),
						"concrete")
				end
			end

			-- detach us from the entity list.
			self:detach(status)
		end
	end
end

function projectile:draw_3d(status)
	quiver.draw_3d.draw_cube(self.point, vector_3:one() * 0.5, color:blue())
end

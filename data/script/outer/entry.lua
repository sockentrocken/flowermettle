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

---@class entry : entity
entry = entity:new()

---Create a new entry.
---@param status status # The game status.
---@return entry value # The entry.
function entry:new(status, previous, shape, depth)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "entry"

	-- if the entry is open...
	if not i.close then
		-- close the entry.
		i.close = true

		local x = 0.0

		-- attempt to close the entry by picking a random level.
		while x < 3.0 do
			-- pick a level.
			local level = status.level.regular[math.random(1, table.hash_length(status.level.regular))]

			-- if we were able to successfully generate a level...
			if status.outer:create_level(status, level, i, shape, depth and depth + 1.0 or 1.0) then
				-- break loop.
				break
			end

			x = x + 1.0
		end

		if x == 3.0 then
			i.seal = true
			i:attach_collider(status, vector_3:old(0.5, 2.0, 2.0))
			status.outer.rapier:set_collider_translation(i.collider, i.point + vector_3:old(0.0, 2.0, 0.0))
			status.outer.rapier:set_collider_rotation(i.collider, vector_3:old(
				math.degree_to_radian(0.0),
				math.degree_to_radian(i.angle.x + 90.0),
				math.degree_to_radian(0.0)
			))
		end
	end

	status.system:set_model("video/entry.glb")
	status.system:set_model("video/entry_seal.glb")

	return i
end

function entry:draw_3d(status)
	quiver.draw_3d.draw_cube(self.point, vector_3:one(), color:blue())
	local model = status.system:get_model("video/entry.glb")
	model:draw_transform(self.point, vector_3:old(0.0, self.angle.x + 90.0, 0.0),
		vector_3:one(), color:red())

	if self.seal then
		local model = status.system:get_model("video/entry_seal.glb")
		model:draw_transform(self.point, vector_3:old(0.0, self.angle.x + 90.0, 0.0),
			vector_3:one(), color:red())
	end
end

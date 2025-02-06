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

---@class elevator : entity
elevator = entity:new()

---Create a new elevator.
---@param status status # The game status.
---@return elevator value # The elevator.
function elevator:new(status, previous)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "elevator"

	-- if status is not nil...
	if status then
		-- attach collider.
		i:attach_collider(status, vector_3:old(3.5, 0.5, 2.5))
	end

	status.system:set_model("video/level/elevator.glb")

	return i
end

function elevator:tick(status, step)
	if status.outer.time <= 8.75 then
		self:set_point(status, self.point + vector_3:old(0.0, step, 0.0))
	end
end

function elevator:draw_3d(status)
	local model = status.system:get_model("video/level/elevator.glb")
	model:draw(self.point, 1.0, color:white())
end

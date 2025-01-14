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

---@class entity
---@field index number
---@field point vector_3
---@field angle vector_3
---@field speed vector_3
entity = {
	__meta = {}
}

---Create a new entity.
---@param status status # The game status.
---@return entity value # The entity.
function entity:new(status, point, angle, speed)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type    = "entity"
	i.point     = point and vector_3:new(point.x, point.y, point.z) or vector_3:new(0.0, 0.0, 0.0)
	i.angle     = angle and vector_3:new(angle.x, angle.y, angle.z) or vector_3:new(0.0, 0.0, 0.0)
	i.speed     = speed and vector_3:new(speed.x, speed.y, speed.z) or vector_3:new(0.0, 0.0, 0.0)
	i.old_point = point and vector_3:new(point.x, point.y, point.z) or vector_3:new(0.0, 0.0, 0.0)
	i.old_angle = angle and vector_3:new(angle.x, angle.y, angle.z) or vector_3:new(0.0, 0.0, 0.0)

	status:entity_attach(i)

	return i
end

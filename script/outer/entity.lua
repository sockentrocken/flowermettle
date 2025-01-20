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
---@field which number
---@field index number
---@field point vector_3
---@field angle vector_3
---@field speed vector_3
---@field old_point vector_3
---@field old_angle vector_3
entity = {}

---Create a new entity.
---@param status status # The game status.
---@return entity value # The entity.
function entity:new(status, previous)
	local i = {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type    = "entity"
	i.point     = previous and previous.point or vector_3:new(0.0, 0.0, 0.0)
	i.angle     = previous and previous.angle or vector_3:new(0.0, 0.0, 0.0)
	i.speed     = previous and previous.speed or vector_3:new(0.0, 0.0, 0.0)
	i.shape     = previous and previous.shape or vector_3:new(0.0, 0.0, 0.0)
	i.old_point = previous and previous.old_point or vector_3:new(0.0, 0.0, 0.0)
	i.old_angle = previous and previous.old_angle or vector_3:new(0.0, 0.0, 0.0)

	-- attach entity to outer state.
	if status then
		status.outer:entity_attach(status, i)
	end

	return i
end

function entity:set_point(status, point)
	self.point:copy(point)
	self.old_point:copy(point)

	if self.collider then
		status.outer.rapier:set_collider_translation(self.collider, self.point)
	end
end

function entity:attach_collider(status, shape)
	self.collider = status.outer.rapier:collider_builder_cuboid(shape)
	status.outer.rapier:set_collider_translation(self.collider, self.point)
	status.outer.rapier:set_collider_user_data(self.collider, self.index)
end

function entity:detach_collider(status)
	if self.collider then
		status.outer.rapier:collider_remove(self.collider, true)
	end
end

---@class entity_pointer
---@field number
---@field number
entity_pointer = {}

---Create a new entity pointer.
---@param entity entity # The entity.
---@return entity_pointer value # The entity pointer.
function entity_pointer:new(entity)
	return {
		which = entity.which,
		index = entity.index
	}
end

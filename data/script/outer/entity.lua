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
	local i = previous or {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type    = "entity"
	i.point     = previous and previous.point or vector_3:new(0.0, 0.0, 0.0)
	i.angle     = previous and previous.angle or vector_3:new(0.0, 0.0, 0.0)
	i.speed     = previous and previous.speed or vector_3:new(0.0, 0.0, 0.0)
	i.shape     = previous and previous.shape or vector_3:new(0.0, 0.0, 0.0)

	-- interpolation data.
	i.point_old = previous and previous.point_old or vector_3:new(0.0, 0.0, 0.0)
	i.angle_old = previous and previous.angle_old or vector_3:new(0.0, 0.0, 0.0)

	-- if status is not nil...
	if status then
		-- attach us to the entity list.
		i:attach(status)
	end

	return i
end

---Set the point of the current entity, also setting the point of the collider, if there is any.
---@param status status   # The game status.
---@param point  vector_3 # The point of the entity.
function entity:set_point(status, point)
	-- copy the given point to both the "new"/"current" point, and also the "old"/"interpolation" point.
	self.point:copy(point); self.point_old:copy(point)

	-- if collider is not nil...
	if self.collider then
		-- copy the given point to the collider.
		status.outer.rapier:set_collider_translation(self.collider, self.point)
	end
end

---Attach a collider to the current entity.
---@param status status   # The game status.
---@param shape  vector_3 # The half-shape of the collider.
function entity:attach_collider(status, shape)
	-- create a new cuboid collider, set its translation and user-data.
	self.collider = status.outer.rapier:collider_builder_cuboid(shape)
	status.outer.rapier:set_collider_translation(self.collider, self.point)
	status.outer.rapier:set_collider_user_data(self.collider, self.index)
end

---Detach a collider from the current entity.
---@param status status # The game status.
function entity:detach_collider(status)
	-- if collider is not nil...
	if self.collider then
		-- detach collider.
		status.outer.rapier:collider_remove(self.collider, true)
	end
end

---Attach the current entity.
---@param status status # The game status.
function entity:attach(status)
	-- add index to entity.
	self.which = #status.outer.entity + 1.0
	self.index = status.outer.entity_index

	-- add entity to table.
	table.insert(status.outer.entity, self)

	-- increase index.
	status.outer.entity_index = status.outer.entity_index + 1.0
end

---Detach the current entity.
---@param status status # The game status.
function entity:detach(status)
	self:detach_collider(status)

	-- TO-DO: use table.remove instead.
	table.remove_object(status.outer.entity, self)
end

--[[----------------------------------------------------------------]]

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

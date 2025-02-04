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

---@class level : entity
level = entity:new()

---Create a new level.
---@param status status # The game status.
---@return level value # The level.
function level:new(status, previous, c_level, shape, depth)
	-- load model, bind to light shader.
	local model = status.system:set_model(c_level.file)

	-- check if level might be colliding with any other level.
	local min_x, min_y, min_z, max_x, max_y, max_z = model:get_box_3()
	local min = vector_3:old(min_x, min_y, min_z)
	local max = vector_3:old(max_x, max_y, max_z)
	local b_shape = (((min * -1.0) + max) * 0.5) * 0.99

	for _, value in ipairs(shape) do
		if status.outer.rapier:test_intersect_cuboid_cuboid(previous.point, previous.angle, b_shape, value.point, value.angle, value.shape) then
			return false
		end
	end

	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "level"
	i.model = c_level.file
	i.min = vector_3:new(0.0, 0.0, 0.0)
	i.max = vector_3:new(0.0, 0.0, 0.0)
	i.min:copy(min:rotate_vector_4(vector_4:from_euler(i.angle.x, i.angle.y, i.angle.z)) + i.point)
	i.max:copy(max:rotate_vector_4(vector_4:from_euler(i.angle.x, i.angle.y, i.angle.z)) + i.point)

	table.insert(shape, {
		point = vector_3:new(i.point.x, i.point.y, i.point.z),
		angle = vector_3:new(i.angle.x, i.angle.y, i.angle.z),
		shape = vector_3:new(b_shape.x, b_shape.y, b_shape.z),
	})

	for x = 1, model.material_count - 1.0 do
		model:bind_shader(x, status.outer.scene.light.shader)
	end

	-- for each mesh in the model...
	for x = 0, model.mesh_count - 1.0 do
		local vertex = model:mesh_vertex(x)
		local index = model:mesh_index(x)

		for k, v in ipairs(vertex) do
			vertex[k] = vector_3:old(v.x, v.y, v.z)
			vertex[k] = vertex[k]:rotate_vector_4(vector_4:from_euler(
				i.angle.x,
				i.angle.y,
				i.angle.z
			))
			vertex[k].x = vertex[k].x + i.point.x
			vertex[k].y = vertex[k].y + i.point.y
			vertex[k].z = vertex[k].z + i.point.z
		end

		-- load the tri-mesh, and parent it to the level rigid body.
		status.outer.rapier:collider_builder_tri_mesh(vertex, index, status.outer.level_rigid)
	end

	local level_entity = {}

	-- for each entity in the level...
	for _, entity in ipairs(c_level.data) do
		-- find the table class.
		local table_class = _G[entity.__type]

		-- if table class is not nil...
		if table_class then
			table.restore_meta(entity)

			-- if table class has a constructor...
			if table_class.new then
				-- apply point and angle to entity.
				entity.point:copy(entity.point:rotate_vector_4(vector_4:from_euler(
					i.angle.x,
					i.angle.y,
					i.angle.z
				)))
				entity.point.x = entity.point.x + i.point.x
				entity.point.y = entity.point.y + i.point.y
				entity.point.z = entity.point.z + i.point.z
				entity.angle.x = entity.angle.x + math.radian_to_degree(i.angle.y)
				entity.angle.y = entity.angle.y + math.radian_to_degree(i.angle.x)
				entity.angle.z = entity.angle.z + math.radian_to_degree(i.angle.z)

				table_class.new(table_class, status, entity, shape, depth)

				table.insert(level_entity, entity)
			else
				-- error.
				error("outer::new(): Entity \"" .. entity.__type .. "\" has no \"new\" constructor.")
			end
		else
			-- error.
			error("outer::new(): Entity \"" .. entity.__type .. "\" has no table-class.")
		end
	end

	for _, entity in ipairs(level_entity) do
		if entity.level then
			entity:level(status, level_entity)
		end
	end

	return true
end

function level:draw_3d(status)
	if status.outer.scene:box_3_in_frustum(box_3:old(self.min, self.max)) then
		local model = status.system:get_model(self.model)
		model:draw_transform(self.point,
			vector_3:old(
				math.radian_to_degree(self.angle.x),
				-math.radian_to_degree(self.angle.y),
				math.radian_to_degree(self.angle.z)
			),
			vector_3:one(), color:white())
	end
end

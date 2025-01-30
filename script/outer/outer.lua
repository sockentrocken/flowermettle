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

require "script/outer/entity"
require "script/outer/door"
require "script/outer/actor"
require "script/outer/enemy"
require "script/outer/player"
require "script/outer/zombie"
require "script/outer/particle"
require "script/outer/projectile"

local TIME_STEP = 1.0 / 60.0
local ACTION_TOGGLE = action:new(
	{
		action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.ESCAPE),
		action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.MIDDLE_RIGHT)
	}
)

---@class outer
outer = {}

---Create a new outer state (in-game state).
---@param level string # The path to the game level.
---@return outer value # The outer state.
function outer:new(status, level)
	local i = {}
	setmetatable(i, {
		__index = self
	})

	--[[]]

	status.outer   = i

	i.__type       = "outer"
	i.camera_3d    = camera_3d:new(vector_3:new(16.0, 16.0, 16.0), vector_3:new(0.0, 0.0, 0.0),
		vector_3:new(0.0, 1.0, 0.0),
		90.0, CAMERA_3D_KIND.PERSPECTIVE)
	i.camera_2d    = camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 1.0)
	i.time         = 0.0
	i.step         = 0.0
	i.entity       = {}
	i.entity_index = 1.0
	i.rapier       = quiver.rapier:new()

	--[[]]

	-- make sure to enable mouse if the current device isn't a pad.
	if not (status.lobby.window.device == INPUT_DEVICE.PAD) then
		status.lobby.window:set_device(INPUT_DEVICE.MOUSE)
		quiver.input.mouse.set_hidden(true)
	end

	quiver.input.mouse.set_scale(vector_2:old(1.0, 1.0))

	-- reset layout. TO-DO: should probably be a method.
	status.lobby.layout = 0.0
	status.lobby.active = false

	level = status.level.initial[math.random(1, table.hash_length(status.level.initial))]

	i.box_list = {}
	i.lev_list = {}

	-- create rigid body for level geometry.
	i.level_rigid = i.rapier:rigid_body(0.0)

	i:create_level(status, level)

	-- run post-load logic for each entity.
	for _, entity in pairs(i.entity) do
		if entity.frame then
			entity:frame(status)
		end
	end

	-- collect garbage.
	collectgarbage("collect")

	return i
end

function collision_box_box_3(box_a, box_b)
	local collision = true;

	if ((box_a.max.x >= box_b.min.x) and (box_a.min.x <= box_b.max.x)) then
		if ((box_a.max.y <= box_b.min.y) or (box_a.min.y >= box_b.max.y)) then collision = false end;
		if ((box_a.max.z <= box_b.min.z) or (box_a.min.z >= box_b.max.z)) then collision = false end;
	else
		collision = false
	end;

	return collision;
end

function outer:check_collision(box)
	for _, value in ipairs(self.box_list) do
		if collision_box_box_3(box, value) then
			return true
		end
	end

	return false
end

function outer:create_level(status, level, past, point, angle, loop)
	level = table.copy(level)

	if loop and loop > 2.0 then
		return
	end

	local point = vector_3:old(0.0, 0.0, 0.0)
	local angle = vector_3:old(0.0, math.degree_to_radian(0.0), 0.0)

	if past then
		local past_direction = math.direction_from_euler(past.angle)
		past_direction = past_direction * -1.0

		local where = 0.0
		local index = nil

		-- for each entity in the level...
		for i, entity in ipairs(level.data) do
			-- find the table class.
			local table_class = _G[entity.__type]

			-- if table class is not nil...
			if table_class then
				table.restore_meta(entity)

				if entity.__type == "door" then
					local door_angle = math.direction_from_euler(entity.angle)
					local real_angle = door_angle:angle(past_direction)

					local real_point = entity.point:rotate_vector_4(vector_4:from_euler(
						0.0,
						real_angle,
						0.0
					))

					local difference = (past.point - real_point):magnitude()

					if difference >= where and not entity.close then
						point = past.point - real_point
						angle = vector_3:old(0.0, real_angle, 0.0)
						where = difference
						index = i
					end
				end
			end
		end

		level.data[index].close = true
	end

	-- load model, bind to light shader.
	local model = status.system:set_model(level.file)

	-- check if level might be colliding with any other level.
	local min_x, min_y, min_z, max_x, max_y, max_z = model:get_box_3()
	local min = vector_3:old(min_x, min_y, min_z)
	local max = vector_3:old(max_x, max_y, max_z)

	--[[]]

	min = min:rotate_vector_4(vector_4:from_euler(
		angle.x,
		angle.y,
		angle.z
	))
	min.x = min.x + point.x
	min.y = min.y + point.y
	min.z = min.z + point.z

	--[[]]

	max = max:rotate_vector_4(vector_4:from_euler(
		angle.x,
		angle.y,
		angle.z
	))
	max.x = max.x + point.x
	max.y = max.y + point.y
	max.z = max.z + point.z

	local box = box_3:new(min, max)

	if self:check_collision(box) then
		return
	end

	table.insert(self.box_list, box)
	table.insert(self.lev_list, {
		model = level.file,
		point = vector_3:new(point.x, point.y, point.z),
		angle = vector_3:new(angle.x, angle.y, angle.z),
	})

	model:bind_shader(1.0, status.light.shader)

	-- for each mesh in the model...
	for x = 0, model.mesh_count - 1.0 do
		local vertex = model:mesh_vertex(x)

		for i, v in ipairs(vertex) do
			vertex[i] = vector_3:old(v.x, v.y, v.z)
			vertex[i] = vertex[i]:rotate_vector_4(vector_4:from_euler(
				angle.x,
				angle.y,
				angle.z
			))
			vertex[i].x = vertex[i].x + point.x
			vertex[i].y = vertex[i].y + point.y
			vertex[i].z = vertex[i].z + point.z
		end

		-- load the convex hull, and parent it to the level rigid body.
		self.rapier:collider_builder_convex_hull(vertex, self.level_rigid)
	end

	-- for each entity in the level...
	for _, entity in ipairs(level.data) do
		-- find the table class.
		local table_class = _G[entity.__type]

		-- if table class is not nil...
		if table_class then
			table.restore_meta(entity)

			-- if table class has a constructor...
			if table_class.new then
				entity.point:copy(entity.point:rotate_vector_4(vector_4:from_euler(
					angle.x,
					angle.y,
					angle.z
				)))
				entity.point.x = entity.point.x + point.x
				entity.point.y = entity.point.y + point.y
				entity.point.z = entity.point.z + point.z
				entity.angle.x = entity.angle.x + math.radian_to_degree(angle.y)
				entity.angle.y = entity.angle.y + math.radian_to_degree(angle.x)
				entity.angle.z = entity.angle.z + math.radian_to_degree(angle.z)

				if entity.__type == "door" and not entity.close then
					entity.close = true
					local level = status.level.regular[math.random(1, table.hash_length(status.level.regular))]
					self:create_level(status, level, entity, nil, nil, loop and loop + 1.0 or 1.0)
				end

				table_class.new(table_class, status, entity)
			else
				-- error.
				error("outer::new(): Entity \"" .. entity.__type .. "\" has no \"new\" constructor.")
			end
		else
			-- error.
			error("outer::new(): Entity \"" .. entity.__type .. "\" has no table-class.")
		end
	end
end

local ONE_TENTH = vector_3:new(0.1, 0.1, 0.1)
local COLOR_X = color:new(255.0, 0.0, 0.0, 255.0)
local COLOR_Y = color:new(0.0, 255.0, 0.0, 255.0)
local COLOR_Z = color:new(0.0, 0.0, 255.0, 255.0)

function outer:draw(status)
	local shape = vector_2:old(quiver.window.get_shape())
	self.camera_2d.zoom = math.clamp(0.25, 4.0, math.snap(0.25, shape.y / 320.0))

	-- check if the lobby toggle button has been set off.
	local _, which = ACTION_TOGGLE:press()

	-- if it has, and if our former lobby state is off...
	if which then
		-- get the actual button.
		local which = ACTION_TOGGLE.list[which]

		-- if the toggle actuator came from the board...
		if which.button == INPUT_BOARD.ESCAPE then
			-- set the new device to be the mouse.
			status.lobby.window:set_device(INPUT_DEVICE.MOUSE)
		end

		-- toggle lobby state on.
		status.lobby.active = true
	end

	--[[]]

	-- clear table pool.
	table_pool:clear()

	local delta = math.min(quiver.general.get_frame_time(), 0.25)

	-- increment tick accumulator.
	self.step = self.step + delta

	-- while tick accumulator is greater than the tick step...
	while self.step >= TIME_STEP do
		-- run tick logic for each entity.
		for _, entity in pairs(self.entity) do
			-- save entity point, angle.
			entity.point_old:copy(entity.point)
			entity.angle_old:copy(entity.angle)

			if entity.tick then
				entity:tick(status, TIME_STEP)
			end
		end

		-- run rapier step.
		self.rapier:step()

		-- increment time, decrement tick accumulator.
		self.time = self.time + TIME_STEP
		self.step = self.step - TIME_STEP
	end

	--[[]]

	-- clear table pool.
	table_pool:clear()

	local alpha = self.step / TIME_STEP
	local new_point = vector_3:zero()
	local new_angle = vector_3:zero()

	-- begin render-texture.
	status.render:begin(function()
		-- clear screen.
		quiver.draw.clear(color:black())

		-- begin 3D view.
		quiver.draw_3d.begin(function()
			-- begin light frame.
			status.light:begin(nil, self.camera_3d)

			-- run 3D logic for each entity.
			for _, entity in pairs(self.entity) do
				if entity.draw_3d then
					-- save entity point, angle.
					--new_point:copy(entity.point)
					--new_angle:copy(entity.angle)

					--- interpolate old/new point, angle.
					--entity.point:copy(entity.point * alpha + entity.point_old * (1.0 - alpha))
					--entity.angle:copy(entity.angle * alpha + entity.angle_old * (1.0 - alpha))

					entity:draw_3d(status)


					-- draw angle help.
					local x, y, z = math.direction_from_euler(entity.angle)
					x = entity.point + x * 2.0
					y = entity.point + y * 2.0
					z = entity.point + z * 2.0

					quiver.draw_3d.draw_cube(x, ONE_TENTH, COLOR_X)
					quiver.draw_3d.draw_cube(y, ONE_TENTH, COLOR_Y)
					quiver.draw_3d.draw_cube(z, ONE_TENTH, COLOR_Z)

					quiver.draw_3d.draw_line(entity.point, x, COLOR_X)
					quiver.draw_3d.draw_line(entity.point, y, COLOR_Y)
					quiver.draw_3d.draw_line(entity.point, z, COLOR_Z)

					-- load entity point, angle.
					--entity.point:copy(new_point)
					--entity.angle:copy(new_angle)
				end
			end

			-- draw level.
			for _, level in ipairs(self.lev_list) do
				local model = status.system:get_model(level.model)
				model:draw_transform(level.point,
					vector_3:old(
						math.radian_to_degree(level.angle.x),
						math.radian_to_degree(level.angle.y),
						math.radian_to_degree(level.angle.z)
					),
					vector_3:one(), color:white())
			end

			--self.rapier:debug_render()
		end, self.camera_3d)
	end)

	-- begin screen-space shader.
	status.shader:begin(function()
		local shape = vector_2:old(quiver.window.get_shape())
		local render = box_2:old(0.0, 0.0, status.render.shape_x, -status.render.shape_y)
		local window = box_2:old(0.0, 0.0, shape.x, shape.y)

		-- draw 3D view, as render-texture.
		status.render:draw_pro(render, window, vector_2:zero(), 0.0, color:white())
	end)

	--[[]]

	-- clear table pool.
	table_pool:clear()

	-- begin 2D view.
	quiver.draw_2d.begin(function()
		-- run 2D logic for each entity.
		for _, entity in pairs(self.entity) do
			if entity.draw_2d then
				entity:draw_2d(status)
			end
		end
	end, self.camera_2d)
end

--[[----------------------------------------------------------------]]

---Find an entity by an entity pointer.
---@param pointer entity_pointer # The entity pointer.
---@return entity | nil value # The entity.
function outer:entity_find(status, pointer)
	-- if there is an entity at the given slot...
	if self.entity[pointer.which] then
		local entity = self.entity[pointer.which]

		-- if the entity in the slot's index is the same as the pointer's...
		if entity.index == pointer.index then
			-- return entity.
			return entity
		end
	end

	-- no entity found, return nil.
	return nil
end

---Find an entity by entity index.
---@param index number # The entity index.
---@return entity | nil value # The entity.
function outer:entity_find_index(status, index)
	for _, entity in ipairs(self.entity) do
		if entity.index == index then
			return entity
		end
	end

	-- no entity found, return nil.
	return nil
end

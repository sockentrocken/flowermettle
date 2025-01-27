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
	i.camera_3d    = camera_3d:new(vector_3:new(4.0, 4.0, 4.0), vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 1.0, 0.0),
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

	-- locate the actual path to the level, load it into memory, then deserialize it to a table.
	level = quiver.general.deserialize(quiver.file.get(status.system:find(level)))

	-- store the pointer to the level model.
	i.level = level.file

	-- create rigid body for level geometry.
	i.level_rigid = i.rapier:rigid_body(0.0)

	-- load model, bind to light shader.
	local model = status.system:set_model(i.level)
	model:bind_shader(1.0, status.light.shader)

	-- for each mesh in the model...
	for x = 0, model.mesh_count - 1.0 do
		-- load the convex hull, and parent it to the level rigid body.
		i.rapier:collider_builder_convex_hull(model:mesh_vertex(x), i.level_rigid)
	end

	-- for each entity in the level...
	for _, entity in ipairs(level.data) do
		-- find the table class.
		local table_class = _G[entity.__type]

		-- if table class is not nil...
		if table_class then
			-- if table class has a constructor...
			if table_class.new then
				-- TO-DO: this doesn't load custom data unless it's .point, .angle, or .scale. fix.
				table.restore_meta(entity)
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
		quiver.draw.clear(color:white())

		-- begin 3D view.
		quiver.draw_3d.begin(function()
			-- begin light frame.
			status.light:begin(nil, self.camera_3d)

			-- run 3D logic for each entity.
			for _, entity in pairs(self.entity) do
				if entity.draw_3d then
					-- save entity point, angle.
					new_point:copy(entity.point)
					new_angle:copy(entity.angle)

					--- interpolate old/new point, angle.
					entity.point:copy(entity.point * alpha + entity.point_old * (1.0 - alpha))
					entity.angle:copy(entity.angle * alpha + entity.angle_old * (1.0 - alpha))

					entity:draw_3d(status)

					-- load entity point, angle.
					entity.point:copy(new_point)
					entity.angle:copy(new_angle)
				end
			end

			-- draw level.
			local level = status.system:get_model(self.level)
			level:draw(vector_3:zero(), 1.0, color:old(127.0, 127.0, 127.0, 255.0))

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

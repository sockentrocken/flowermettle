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

local TIME_STEP = 1.0 / 60.0

---@class outer
outer = {
	__meta = {}
}

---Create a new outer state (in-game state).
---@param level string # The path to the game level.
---@return outer value # The outer state.
function outer:new(status, level)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	status.outer   = i

	i.__type       = "outer"
	i.system       = file_system:new({
		"asset"
	})
	i.camera_3d    = camera_3d:new(vector_3:new(4.0, 4.0, 4.0), vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 1.0, 0.0),
		90.0, CAMERA_3D_KIND.PERSPECTIVE)
	i.camera_2d    = camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 1.0)
	i.time         = 0.0
	i.step         = 0.0
	i.entity       = {}
	i.entity_index = 0.0
	i.rapier       = quiver.rapier:new()


	--[[]]

	--if not (status.lobby.window.device == INPUT_DEVICE.PAD) then
	--	status.lobby.window:set_device(INPUT_DEVICE.MOUSE)
	--	quiver.input.mouse.set_hidden(true)
	--end

	status.lobby.layout = 0.0
	status.lobby.active = false

	level = quiver.file.get(i.system:find(level))
	level = quiver.general.deserialize(level)

	i.level = i.system:set_model(level.base)

	i.level_rigid = i.rapier:rigid_body(0.0)

	for x = 0, i.level.mesh_count - 1.0 do
		i.rapier:collider_builder_convex_hull(i.level:mesh_vertex(x), i.level_rigid)
	end

	for _, entity in ipairs(level.data) do
		local table_class = _G[entity.__type]
		local table_spawn = table_class.new
		if table_class and table_spawn then
			table.restore_meta(entity)
			table_spawn(table_class, status, entity)
		end
	end

	enemy:new(status, {
		point = vector_3:new(16.0, 0.0, -4.0)
	})
	enemy:new(status, {
		point = vector_3:new(16.0, 0.0, 0.0)
	})
	enemy:new(status, {
		point = vector_3:new(16.0, 0.0, 4.0)
	})
	enemy:new(status, {
		point = vector_3:new(32.0, 1.0, 0.0)
	})

	collectgarbage("collect")

	return i
end

---Attach an entity.
---@param attach entity # The entity to attach.
function outer:entity_attach(status, attach)
	-- add index to entity.
	attach.index = self.entity_index

	-- add entity to table.
	self.entity[tostring(attach.index)] = attach

	-- increase index.
	self.entity_index = self.entity_index + 1.0
end

---Detach an entity.
---@param detach entity # The entity to detach.
function outer:entity_detach(status, detach)
	self.entity[tostring(detach.index)]:detach_collider(status)

	-- remove entity from table.
	self.entity[tostring(detach.index)] = nil
end

local ACTION_TOGGLE = action:new(
	{
		action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.ESCAPE),
		action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.MIDDLE_RIGHT)
	}
)

function outer:draw(status)
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

	local delta = math.min(quiver.general.get_frame_time(), 0.25)

	self.step = self.step + delta

	while self.step >= TIME_STEP do
		for _, entity in pairs(self.entity) do
			-- save entity point, angle.
			entity.old_point:copy(entity.point)
			entity.old_angle:copy(entity.angle)

			if entity.tick then
				entity:tick(status, TIME_STEP)
			end
		end

		self.rapier:step()
		self.time = self.time + TIME_STEP
		self.step = self.step - TIME_STEP
	end

	--[[]]

	-- clear table pool.
	table_pool:clear()

	local alpha = self.step / TIME_STEP

	local new_point = vector_3:zero()
	local new_angle = vector_3:zero()

	quiver.draw_3d.begin(function()
		for _, entity in pairs(self.entity) do
			if entity.draw_3d then
				-- save entity point, angle.
				new_point:copy(entity.point)
				new_angle:copy(entity.angle)

				-- interpolate old/new point, angle.
				entity.point:copy(entity.point * alpha + entity.old_point * (1.0 - alpha))
				entity.angle:copy(entity.angle * alpha + entity.old_angle * (1.0 - alpha))

				entity:draw_3d(status)

				-- load entity point, angle.
				entity.point:copy(new_point)
				entity.angle:copy(new_angle)
			end
		end

		self.level:draw(vector_3:zero(), 1.0, color:white())

		self.rapier:debug_render()
	end, self.camera_3d)

	-- clear table pool.
	table_pool:clear()

	quiver.draw_2d.begin(function()
		for _, entity in pairs(self.entity) do
			if entity.draw_2d then
				entity:draw_2d(status)
			end
		end
	end, self.camera_2d)
end

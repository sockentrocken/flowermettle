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

local ENTITY_LIST = {
	{ name = "player" },
	{ name = "zombie" }
}

---@class editor
editor = {
	__meta = {}
}

---Create a new editor.
---@return editor value # The editor.
function editor:new()
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "editor"
	i.entity = {}
	i.active = nil
	i.picker = nil

	return i
end

function editor:draw_3d(status)
	for _, entity in pairs(self.entity) do
		quiver.draw_3d.draw_cube(entity.point, vector_3:one(), self.picker == entity and color:green() or color:blue())
	end

	if quiver.input.mouse.get_down(INPUT_MOUSE.MIDDLE) then
		local x, y = quiver.input.mouse.get_delta()
		status.camera_3d.point.x = status.camera_3d.point.x - x * 0.05
		status.camera_3d.point.z = status.camera_3d.point.z - y * 0.05

		status.camera_3d.focus.x = status.camera_3d.focus.x - x * 0.05
		status.camera_3d.focus.z = status.camera_3d.focus.z - y * 0.05
	end

	local x, y = quiver.input.mouse.get_wheel()

	status.camera_3d.zoom = status.camera_3d.zoom - y * 5.0

	local model = status.system:get_model("video/test.glb")
	model:draw(vector_3:zero(), 1.0, color:white())

	if self.active then
		local x, y = quiver.input.mouse.get_point()
		x = math.snap(8.0, x)
		y = math.snap(8.0, y)
		local ray = quiver.draw_3d.get_screen_to_world(status.camera_3d, vector_2:old(x, y),
			vector_2:old(quiver.window.get_render_shape()))
		quiver.draw_3d.draw_cube(vector_3:old(ray.position.x, 0.0, ray.position.z), vector_3:one(),
			color:red())

		if quiver.input.mouse.get_press(INPUT_MOUSE.LEFT) then
			for i, entity in pairs(self.entity) do
				if entity.point.x == ray.position.x and entity.point.z == ray.position.z then
					self.picker = entity
					self.active = nil
					return
				end
			end

			local i = table.copy(ENTITY_LIST[self.active])
			i.point = vector_3:new(ray.position.x, 0.0, ray.position.z)
			i.angle = vector_3:new(0.0, 0.0, 0.0)
			table.insert(self.entity, i)
			self.picker = i
			self.active = nil
		end
	else
		if quiver.input.mouse.get_press(INPUT_MOUSE.LEFT) then
			local x, y = quiver.input.mouse.get_point()
			x = math.snap(8.0, x)
			y = math.snap(8.0, y)
			local ray = quiver.draw_3d.get_screen_to_world(status.camera_3d, vector_2:old(x, y),
				vector_2:old(quiver.window.get_render_shape()))

			for i, entity in pairs(self.entity) do
				if entity.point.x == ray.position.x and entity.point.z == ray.position.z then
					self.picker = entity
					self.active = nil
					print("picker")
					return
				end
			end
		end
	end

	if quiver.input.mouse.get_press(INPUT_MOUSE.RIGHT) then
		local x, y = quiver.input.mouse.get_point()
		x = math.snap(8.0, x)
		y = math.snap(8.0, y)
		local ray = quiver.draw_3d.get_screen_to_world(status.camera_3d, vector_2:old(x, y),
			vector_2:old(quiver.window.get_render_shape()))

		for i, entity in pairs(self.entity) do
			if entity.point.x == ray.position.x and entity.point.z == ray.position.z then
				if self.picker == i then
					self.picker = nil
				end

				table.remove(self.entity, i)
			end
		end
	end
end

function editor:draw_2d(status)
	local x, y = quiver.window.get_render_shape()
	--local main_bar = vector_2:old(8.00, 8.00)
	local side_bar = vector_2:old(8.00, 8.0)

	--quiver.draw_2d.draw_box_2_border(box_2:old(main_bar.x, main_bar.y, x - 16.00, 48.0))
	quiver.draw_2d.draw_box_2_border(box_2:old(side_bar.x, side_bar.y, 192.0, y - 16.0))

	for i, value in ipairs(ENTITY_LIST) do
		if status.dialog.window:button(box_2:old(side_bar.x + 8.0, side_bar.y + 8.0 + 36.0 * (i - 1.0), 192.0 - 16.0, 32.0), value.name) then
			self.active = i
		end
	end

	if self.picker then
		LOGGER_FONT:draw(self.picker.name, vector_2:old(8.0, 8.0), 24.0, 1.0, color:red())
	end
end

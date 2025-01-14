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

	return i
end

function editor:draw_3d(status)
	if quiver.input.mouse.get_down(INPUT_MOUSE.LEFT) then
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
end

function editor:draw_2d(status)
	local x, y = quiver.window.get_render_shape()
	local main_bar = vector_2:old(8.00, 8.00)
	local side_bar = vector_2:old(8.00, 64.0)

	quiver.draw_2d.draw_box_2_border(box_2:old(main_bar.x, main_bar.y, x - 16.00, 48.0))
	quiver.draw_2d.draw_box_2_border(box_2:old(side_bar.x, side_bar.y, 192.0, y - 72.0))

	for i, value in ipairs(ENTITY_LIST) do
		if status.dialog.window:button(box_2:old(side_bar.x, side_bar.y + 36.0 * (i - 1.0), 192.0, 32.0), value.name) then
			self.active = i
		end
	end
end

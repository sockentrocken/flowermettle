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

---@class hunter
hunter = {
	__meta = {}
}

---Create a new hunter.
---@param status status # The game status.
---@return hunter value # The hunter.
function hunter:new(status)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "hunter"
	i.name   = "Hunter #1"
	i.health = 100.0

	return i
end

---Draw the hunter.
---@param status status # The game status.
function hunter:draw_3d(status)
	--quiver.draw_3d.draw_cube(status.player.point, vector_3:one(), color:red())

	local model = status.system:get_model("video/character.glb")
	model:draw(status.player.point - vector_3:old(0.0, 1.0, 0.0), 0.5, color:blue())
end

---Draw the hunter.
---@param status status # The game status.
function hunter:draw_2d(status)
	local x, y  = quiver.window.get_render_shape()
	local point = vector_2:old(x * 0.5 - 160.0 * 0.5, y - 40.0 * 2.0)

	quiver.draw_2d.draw_box_2_border(box_2:old(point.x, point.y, 160.0, 32.0))
	LOGGER_FONT:draw("Health: " .. self.health, point + vector_2:old(8.0, 4.0), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
		color:white())
end

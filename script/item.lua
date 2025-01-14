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

---@class item
item = {
	__meta = {}
}

---Create a new item.
---@param status status # The game status.
---@return item value # The item.
function item:new(status, name)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "item"
	i.name   = name

	return i
end

function item:draw_2d(status, side, both)
	local x, y  = quiver.window.get_render_shape()
	local shape = both and 80.0 or 160.0
	local shift = both and (shape * -0.5) + shape * side or 0.0
	local point = vector_2:old(x * 0.5 - shape * 0.5 + shift, y - 40.0 * 1.0)

	quiver.draw_2d.draw_box_2_border(box_2:old(point.x, point.y, shape, 32.0))
	LOGGER_FONT:draw("I: 25", point + vector_2:old(8.0, 4.0), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
		color:white())
end

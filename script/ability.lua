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

---@class ability
ability = {
	__meta = {}
}

---Create a new ability.
---@param status status # The game status.
---@return ability value # The ability.
function ability:new(status)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "ability"
	i.name   = "Ability #1"

	return i
end

function ability:draw(status, side)
	local x, y  = quiver.window.get_render_shape()
	local point = vector_2:old(8.0 + (x - 160.0 - 16.0) * side, y - 40.0 * 1.0)

	quiver.draw_2d.draw_box_2_border(box_2:old(point.x, point.y, 160.0, 32.0))
	LOGGER_FONT:draw("Ability: 25", point + vector_2:old(8.0, 4.0), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
		color:white())
end

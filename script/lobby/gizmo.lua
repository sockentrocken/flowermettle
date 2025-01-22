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

---@class gizmo
---@field hover 	  number
---@field sound_hover boolean
---@field sound_focus boolean
gizmo = {}

---Create a new gizmo.
---@return gizmo value # The gizmo.
function gizmo:new()
	local i = {}
	setmetatable(i, {
		__index = self
	})

	--[[]]

	i.__type      = "gizmo"
	i.hover       = 0.0
	i.sound_hover = false
	i.sound_focus = false

	return i
end

---Calculate a shape with animation.
---@param lobby lobby # The lobby.
---@param shape box_2 # The shape.
function gizmo:move(lobby, shape)
	-- move shape horizontally.
	shape.x = shape.x + (math.out_quad(self.hover) * 8.0) - 16.0 +
		math.out_quad(math.min(1.0, lobby.time * 4.0)) * 16.0

	return shape
end

function gizmo:fade(lobby, color)
	-- fade in/out from hover.
	color = color * (math.out_quad(self.hover) * 0.25 + 0.75)

	-- fade in/out from time.
	color.a = math.floor(math.out_quad(math.min(1.0, lobby.time * 4.0)) * 255.0)

	return color
end

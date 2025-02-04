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

---@class zombie : enemy
zombie = enemy:new()

---Create a new zombie.
---@param status status # The game status.
---@return zombie value # The zombie.
function zombie:new(status, previous)
	local i = enemy:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "zombie"

	-- load model.
	status.system:set_model("video/character.glb"):bind_shader(0.0, status.outer.scene.light.shader)

	return i
end

function zombie:draw_3d(status)
	local model = status.system:get_model("video/character.glb")
	model:draw(self.point - vector_3:old(0.0, 1.0, 0.0), 0.5, color:red())
end

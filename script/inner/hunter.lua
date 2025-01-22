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

local HUNTER_NAME = {
	"Rick",
	"John",
	"Barney",
	"Gordon",
	"Margaret",
	"Alice",
	"Claire",
	"Bella"
}

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

	i.__type         = "hunter"
	i.name           = i:randomize_name()
	i.health         = 100.0
	i.health_maximum = 100.0
	i.walk_rate      = 1.0
	i.drop_rate      = 1.0
	i.fire_rate      = 1.0

	return i
end

function hunter:randomize_name(value)
	if not value then value = HUNTER_NAME end

	local pick = math.random(1, table.hash_length(value))

	local i = 1.0

	for key, value in pairs(value) do
		if i == pick then
			if type(value) == "string" then
				return value
			else
				return key .. self:randomize_name(value)
			end
		end

		i = i + 1.0
	end
end

---Draw the hunter.
---@param status status # The game status.
function hunter:draw_3d(status)
	local aim = status.outer.player:aim(status)
	local aim = (math.atan2(aim.z, aim.x) * 180.0) / 3.14

	local model = status.outer.system:get_model("video/character.glb")
	model:draw_transform(status.outer.player.point - vector_3:old(0.0, 1.0, 0.0), vector_3:old(0.0, aim + 90.0, 0.0),
		vector_3:one() * 0.5, color:blue())
end

---Draw the hunter.
---@param status status # The game status.
function hunter:draw_2d(status)
	local x, y  = quiver.window.get_render_shape()

	local shape = vector_2:old(256.0, 64.0)
	local point = vector_2:old(x * 0.5 - shape.x * 0.5, y - shape.y - 8.0)

	local box_a = box_2:old(point.x, point.y, shape.x, shape.y)
	local box_b = box_2:old(box_a.x + 4.0, box_a.y + box_a.height * 0.5, box_a.width - 8.0, (box_a.height - 8.0) * 0.5)
	local box_c = box_2:old(box_b.x + 4.0, box_b.y + 4.0, box_b.width - 8.0, (box_b.height - 8.0))

	quiver.draw_2d.draw_box_2_round(box_a, 0.25, 4.0, color:grey() * 0.5)
	quiver.draw_2d.draw_box_2_round(box_b, 0.25, 4.0, color:grey() * 1.0)
	quiver.draw_2d.draw_box_2_round(box_c, 0.25, 4.0, color:white())

	local font = status.system:get_font("video/font_side.ttf")
	font:draw(self.name, point + vector_2:old(8.0, 4.0), LOGGER_FONT_SCALE,
		LOGGER_FONT_SPACE,
		color:white())
	font:draw(self.health, vector_2:old(box_b.x + 8.0, box_b.y + 4.0), LOGGER_FONT_SCALE,
		LOGGER_FONT_SPACE,
		color:black())
end

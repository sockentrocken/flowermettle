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

function hunter:draw_3d(status)
end

function hunter:draw_2d(status)
	-- get the shape of the window.
	local shape = vector_2:old(quiver.window.get_shape()):scale_zoom(status.outer.scene.camera_2d)

	-- draw weapon plaque.
	status.outer.player:draw_plaque(status, vector_2:old(0.0, 0.0), self.name, self.health, self
		.health_maximum)
end

--[[----------------------------------------------------------------]]

---Randomize hunter name.
---@param value? table # OPTIONAL: Hunter name table.
---@return string name # The hunter name.
function hunter:randomize_name(value)
	-- automatically use default hunter name table if table is not given.
	if not value then value = HUNTER_NAME end

	-- pick a random number between 1 and every available option in the table.
	local pick = math.random(1, table.hash_length(value))

	local i = 1.0

	-- for every element in the table...
	for key, value in pairs(value) do
		-- if the current index is the same as the random index...
		if i == pick then
			-- if value is string, end recursion. return hunter name.
			if type(value) == "string" then
				return value
			else
				return key .. self:randomize_name(value)
			end
		end

		i = i + 1.0
	end
end

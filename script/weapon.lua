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

local WEAPON_NAME = {
	"The Executioner",
	"The Bastard",
	"The Killer",
	"The Eviscerator",
	"The Naughty",
	"The Evil",
	"The Gone",
	"The Irredeemable"
}

---@class weapon
weapon = {
	__meta = {}
}

---Create a new weapon.
---@param status status # The game status.
---@return weapon value # The weapon.
function weapon:new(status)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type       = "weapon"
	i.name         = WEAPON_NAME[math.random(1, #WEAPON_NAME)]
	i.ammo         = 25.0
	i.ammo_maximum = 25.0
	i.miss_rate    = 1.00
	i.fire_rate    = 10.00
	i.rate         = 0.00
	i.miss         = 0.00

	return i
end

function weapon:randomize_name(status)
	local name = WEAPON_NAME[math.random(1, #WEAPON_NAME)]

	while self.name == name do
		name = WEAPON_NAME[math.random(1, #WEAPON_NAME)]
	end

	self.name = name
end

---Draw the weapon.
---@param status status # The game status.
function weapon:tick(status, step, side)
	self.rate = math.max(0.0, self.rate - step * 1.0)
	self.miss = math.max(0.0, self.miss - step * 8.0)
end

---Draw the weapon.
---@param status status # The game status.
function weapon:draw_3d(status, side)
	do end
end

---Draw the weapon.
---@param status status # The game status.
function weapon:draw_2d(status, side)
	local point = vector_2:old(8.0, 8.0 + 44.0 * side)
	local font  = status.lobby.system:get_font("video/font_side.ttf")
	local text  = side == 0.0 and "Weapon A: " or "Weapon B: "

	quiver.draw_2d.draw_box_2_border(box_2:old(point.x, point.y, 512.0, 36.0))
	font:draw(text .. self.name .. " : " .. self.ammo, point + vector_2:old(8.0, 4.0), LOGGER_FONT_SCALE,
		LOGGER_FONT_SPACE,
		color:white())
end

function weapon:use(status, side)
	if self.ammo > 0.0 and self.rate == 0.0 then
		local x, y = quiver.input.mouse.get_point()
		local ray = quiver.draw_3d.get_screen_to_world(status.outer.camera_3d, vector_2:old(x, y),
			vector_2:old(quiver.window.get_shape()))

		local collider, time = status.outer.rapier:cast_ray(ray, 4096.0, true, status.outer.level_rigid)

		local aim = status.outer.player:aim(status)

		if collider then
			local c_point = vector_3:old(status.outer.rapier:get_collider_translation(collider))
			aim = (c_point - status.outer.player.point):normalize()
		end

		local i = projectile:new(status)
		i:set_point(status, status.outer.player.point)
		i.speed:copy(aim * 32.0)
		i.parent = status.outer.rapier:get_collider_user_data(status.outer.player.collider)
		status.outer.player.camera_shake = 0.05
		--self.ammo = self.ammo - 1.00
		self.rate = self.rate + (0.50 / self.fire_rate)
		self.miss = math.min(4.0, self.miss + 1.0)
	end
end

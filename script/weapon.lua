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

	i.__type = "weapon"
	i.name   = "Weapon #1"
	i.ammo   = 25.0
	i.rate   = 0.00

	return i
end

---Draw the weapon.
---@param status status # The game status.
function weapon:tick(status, step, side)
	self.rate = math.max(0.0, self.rate - step)
end

---Draw the weapon.
---@param status status # The game status.
function weapon:draw_3d(status, side)
	do end
end

---Draw the weapon.
---@param status status # The game status.
function weapon:draw_2d(status, side)
	local x, y  = quiver.window.get_render_shape()
	local point = vector_2:old(8.0 + (x - 160.0 - 16.0) * side, y - 40.0 * 2.0)

	quiver.draw_2d.draw_box_2_border(box_2:old(point.x, point.y, 160.0, 32.0))
	LOGGER_FONT:draw("Weapon: " .. self.ammo, point + vector_2:old(8.0, 4.0), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
		color:white())
end

function weapon:use(status, side)
	if self.ammo > 0.0 and self.rate == 0.0 then
		local x, y = quiver.input.mouse.get_point()
		local ray = quiver.draw_3d.get_screen_to_world(status.camera_3d, vector_2:old(x, y),
			vector_2:old(quiver.window.get_shape()))

		local collider, time = status.rapier:cast_ray(ray, 4096.0, true, status.level_rigid)

		local aim = status.player:aim(status)

		if collider then
			local c_point = vector_3:old(status.rapier:get_collider_translation(collider))
			aim = (c_point - status.player.point):normalize()
		end

		local i = projectile:new(status, status.player.point, nil, aim * 32.0)
		status.player.camera_shake = 0.15
		self.ammo = self.ammo - 1.00
		self.rate = self.rate + 0.20
		--quiver.input.pad.set_rumble(0.0, 1024.0, 1024.0, 0.25)
	end
end

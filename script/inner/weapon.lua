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
	The = {
		" Executioner",
		" Bastard",
		" Killer",
		" Eviscerator",
		" Naughty",
		" Evil",
		" Gone",
		" Irredeemable",
		" Rat Bastard"
	},
	A = {
		[" Violet"] = {
			" Pain",
			" Fluid"
		}
	},
	An = {
		[" Incredible"] = {
			" Pain",
			" Hurt"
		}
	},
	Psycho = {
		" Freak",
		" Bastard"
	},
	Hole = {
		" Maker",
		" Puncher"
	},
	Dust = {
		" Sucker",
		" Licker",
		" Puncher"
	}
}

---@class weapon
---@field name string
---@field ammo string
---@field ammo_maximum string
---@field miss_rate string
---@field fire_rate string
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
	i.name         = i:randomize_name()
	i.ammo         = 25.0
	i.ammo_maximum = 25.0
	i.miss_rate    = 1.00
	i.fire_rate    = 4.00
	i.rate         = 0.00
	i.miss         = 0.00

	status.system:set_model("video/weapon_bullet.glb")
	status.system:set_model("video/weapon_shell.glb")

	return i
end

function weapon:randomize_name(value)
	if not value then value = WEAPON_NAME end

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

---Draw the weapon.
---@param status status # The game status.
function weapon:tick(status, step, side)
	self.rate = math.max(0.0, self.rate - step * 1.0)
	self.miss = math.max(0.0, self.miss - step * 8.0)
end

---Draw the weapon.
---@param status status # The game status.
function weapon:draw_3d(status, side)
	local aim = status.outer.player:aim(status)

	local cross = vector_3:old(0.0, 1.0, 0.0):cross(aim) * 0.75

	if side > 0.0 then cross = cross * -1.0 end

	cross = cross - aim * self.rate * 4.0

	local aim = (math.atan2(aim.z, aim.x) * 180.0) / 3.14

	local model = status.system:get_model("video/weapon_bullet.glb")
	model:draw_transform(status.outer.player.point + cross, vector_3:old(0.0, aim + 90.0, 0.0),
		vector_3:one(), color:red())
end

---Draw the weapon.
---@param status status # The game status.
function weapon:draw_2d(status, side)
	local x, y  = quiver.window.get_render_shape()

	local shape = vector_2:old(256.0, 64.0)
	local point = vector_2:old(8.0 + (x - shape.x - 16.0) * side, y - shape.y - 8.0)

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
	font:draw(self.ammo, vector_2:old(box_b.x + 8.0, box_b.y + 4.0), LOGGER_FONT_SCALE,
		LOGGER_FONT_SPACE,
		color:black())
end

function weapon:draw_lobby(status, side)
	local model = status.system:get_model(side == 0.0 and "video/weapon_bullet.glb" or "video/weapon_shell.glb")

	local point = side == 0.0 and vector_3:old(-0.50, 1.25, 0.00) or vector_3:old(0.50, 1.25, 0.00)
	local angle = side == 0.0 and vector_3:old(-45.0, 0.00, 90.0) or vector_3:old(135.0, 180.00, 90.0)

	model:draw_transform(point, angle, vector_3:one(), color:white())
end

function weapon:use(status, side)
	if self.ammo > 0.0 and self.rate == 0.0 then
		local aim = nil

		if quiver.input.board.get_down(INPUT_BOARD.TAB) then
			aim = math.direction_from_euler(status.outer.player.angle)
		else
			local x, y = quiver.input.mouse.get_point()
			local ray = ray:old(vector_3:zero(), vector_3:zero())

			ray:pack(quiver.draw_3d.get_screen_to_world(status.outer.camera_3d, vector_2:old(x, y),
				vector_2:old(quiver.window.get_shape())))

			local collider, time = status.outer.rapier:cast_ray(ray, 4096.0, true, status.outer.level_rigid)

			aim = status.outer.player:aim(status)

			if collider then
				local c_point = vector_3:old(status.outer.rapier:get_collider_translation(collider))
				aim = (c_point - status.outer.player.point):normalize()
			end
		end

		local i = projectile:new(status)
		i:set_point(status, status.outer.player.point)
		i.speed:copy(aim * 32.0)
		i.parent = entity_pointer:new(status.outer.player)
		--status.outer.rapier:get_collider_user_data(status.outer.player.collider)
		status.outer.player.camera_shake = 0.05
		--self.ammo = self.ammo - 1.00
		self.rate = self.rate + (0.50 / self.fire_rate)
		self.miss = math.min(4.0, self.miss + 1.0)
	end
end

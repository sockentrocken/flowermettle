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
---@enum weapon_kind
local WEAPON_KIND = {
	BULLET = 0,
	SHELL = 1,
	GRENADE = 2,
	MISSILE = 3,
	MELEE = 4,
}
local WEAPON_DATA = {
	[WEAPON_KIND.BULLET] = {
		ammo_base_min = 128.0,
		ammo_base_max = 256.0,
		fire_rate = 0.10,
		miss_rate = 0.75,
		miss_base = 0.05,
		projectile_count_min = 1.0,
		projectile_count_max = 4.0,
		projectile_speed = 64.0,
		camera_shake = 0.15,
		model = "video/weapon/bullet.glb",
		sound = {
			"audio/weapon/bullet_1.ogg",
			"audio/weapon/bullet_2.ogg",
			"audio/weapon/bullet_3.ogg",
		},
	},
	[WEAPON_KIND.SHELL] = {
		ammo_base_min = 16.0,
		ammo_base_max = 32.0,
		fire_rate = 0.25,
		miss_rate = 0.35,
		projectile_count_min = 4.0,
		projectile_count_max = 8.0,
		projectile_speed = 16.0,
		camera_shake = 0.25,
		model = "video/weapon/shell.glb",
		sound = {
			"audio/weapon/shell_1.ogg",
			"audio/weapon/shell_2.ogg",
			"audio/weapon/shell_3.ogg",
		},
	},
}
local WEAPON_DATA_LOBBY = {
	[0] = {
		point = vector_3:new(-0.50, 1.25, 0.00),
		angle = vector_3:new(-45.0, 0.00, 90.0),
	},
	[1] = {
		point = vector_3:new(0.500, 1.250, 0.00),
		angle = vector_3:new(135.0, 180.0, 90.0),
	}
}
---@enum ammo_kind
local AMMO_KIND = {
	STANDARD = 0,
	FLESH = 1,
	ARMOR = 2,
}
---@enum fire_kind
local FIRE_KIND = {
	SINGLE = 0,
	TRIPLE = 1,
	FULL = 2,
}

---@class weapon
---@field name 		   string
---@field kind  weapon_kind
---@field ammo 		   number
---@field ammo_kind    ammo_kind
---@field ammo_maximum number
---@field miss_rate    number
---@field miss_time    number
---@field fire_rate    number
---@field fire_kind    fire_kind
---@field fire_time    number
weapon = {}

---Create a new weapon.
---@param status status # The game status.
---@return weapon value # The weapon.
function weapon:new(status)
	local i = {}
	setmetatable(i, {
		__index = self
	})

	--[[]]

	i.__type       = "weapon"

	-- weapon name, weapon kind.
	i.name         = i:randomize_name()
	i.kind         = WEAPON_KIND.BULLET

	-- current ammo, ammo type, and maximum ammo capacity.
	i.ammo         = WEAPON_DATA[i.kind].ammo_base_min
	i.ammo_kind    = AMMO_KIND.STANDARD
	i.ammo_maximum = WEAPON_DATA[i.kind].ammo_base_max

	-- base miss rate, and current miss factor.
	i.miss_rate    = 1.00
	i.miss_time    = 0.00

	-- base fire rate, fire type, and current fire factor.
	i.fire_rate    = 1.00
	i.fire_kind    = FIRE_KIND.FULL
	i.fire_time    = 0.00
	i.sway         = vector_2:new(0.0, 0.0)

	-- load model.
	status.system:set_model("video/weapon/bullet.glb")
	status.system:set_model("video/weapon/shell.glb")

	-- load sound.
	status.system:set_sound("audio/weapon/bullet_1.ogg")
	status.system:set_sound("audio/weapon/bullet_2.ogg")
	status.system:set_sound("audio/weapon/bullet_3.ogg")
	status.system:set_sound("audio/weapon/shell_1.ogg")
	status.system:set_sound("audio/weapon/shell_2.ogg")
	status.system:set_sound("audio/weapon/shell_3.ogg")
	status.system:set_sound("audio/weapon/grenade_1.ogg")
	status.system:set_sound("audio/weapon/grenade_2.ogg")
	status.system:set_sound("audio/weapon/grenade_3.ogg")
	status.system:set_sound("audio/weapon/missile_1.ogg")
	status.system:set_sound("audio/weapon/missile_2.ogg")
	status.system:set_sound("audio/weapon/missile_3.ogg")
	status.system:set_sound("audio/weapon/explosion.ogg")
	status.system:set_sound("audio/weapon/no_ammo.ogg")

	-- load font.
	status.system:set_font("video/font_plaque.ttf", false, 28.0)

	return i
end

function weapon:tick(status, step, side)
	-- decrement fire delay, accuracy penalty.
	self.fire_time = math.max(0.0, self.fire_time - step)
	self.miss_time = math.max(0.0, self.miss_time - step * self.miss_time)

	-- select which input to poll.
	local input = side == 0.0 and status.lobby.user.input_weapon_a or status.lobby.user.input_weapon_b

	if status.outer.player.enemy_count > 0.0 then
		self:use(status, side, input)
	end
end

local COLOR_MUZZLE_FLASH = color:new(255.0, 90.0, 32.0, 255.0)

function weapon:draw_3d(status, side)
	-- get the player's aim in 3D space.
	local aim = math.direction_from_euler(status.outer.player.angle)

	-- get the cross-product between the player's aim and the up vector. invert the cross if our weapon is on the other side.
	local cross = side == 0.0 and
		vector_3:old(0.0, 1.0, 0.0):cross(aim) * 0.75 or
		vector_3:old(0.0, 1.0, 0.0):cross(aim) * 0.75 * -1.0

	-- push the cross back by the amount of fire time left.
	cross = cross - aim * self.fire_time * 4.0

	-- if there is ammo and fire time left...
	if self.ammo > 0.0 and self.fire_time > 0.0 then
		local color = COLOR_MUZZLE_FLASH * (self.fire_time / WEAPON_DATA[self.kind].fire_rate) * 2.0

		-- draw a point light.
		status.outer.scene.light:light_point(status.outer.player.point + cross, color)
	end
end

function weapon:draw_2d(status, side)
	-- get the shape of the window.
	local shape = vector_2:old(quiver.window.get_shape()):scale_zoom(status.outer.scene.camera_2d)

	-- draw weapon plaque.
	status.outer.player:draw_plaque(status, vector_2:old((shape.x - 108.0) * side, shape.y - 40.0), self.name,
		self.ammo, self.ammo_maximum)
end

function weapon:render(status, side)
	local player = status.outer.player

	local shake = vector_3:old(
		math.random_sign(player.camera_shake * status.lobby.user.video_shake),
		math.random_sign(player.camera_shake * status.lobby.user.video_shake),
		math.random_sign(player.camera_shake * status.lobby.user.video_shake)
	) * self.miss_time * 0.5

	local mouse = vector_2:old(quiver.input.mouse.get_delta())
	local delta = quiver.general.get_frame_time()
	self.sway.x = self.sway.x - self.sway.x * delta * 8.0
	self.sway.y = self.sway.y - self.sway.y * delta * 8.0

	self.sway.x = self.sway.x + mouse.y
	self.sway.y = self.sway.y - mouse.x

	-- begin 3D view.
	quiver.draw_3d.begin(function()
		local angle_x, angle_y, angle_z = math.direction_from_euler(player.angle)

		local shpee = vector_3:old(player.speed.x, 0.0, player.speed.z)

		local fall = (math.sin((player.fall * math.pi * 2.0) + math.pi * 0.5) - 1.0) * 0.5 * 0.5
		local jump = (math.sin((player.jump * math.pi * 2.0) + math.pi * 0.5) - 1.0) * 0.5 * 0.5 * -1.0

		fall = fall * 0.5
		jump = jump * 0.5

		local camera_walk = vector_3:old(
			0.0,
			math.cos(quiver.general.get_time() * 8.0) * (shpee:magnitude() / 8.0) * 0.1,
			math.sin(quiver.general.get_time() * 4.0) * (shpee:magnitude() / 8.0) * 0.1
		)

		local angle = math.percentage_from_value(-90.0, 90.0, player.angle.y)
		local angle = math.value_from_percentage(0.1, -0.1, angle)

		local camera_move = vector_3:old(
			-0.50 + angle - (self.fire_time / self.fire_rate) * 2.0 + (angle_x:dot(shpee) / 8.0) * 0.25 * -1.0,
			-0.50 + angle * 2.0 + fall + jump + self.sway.x * 0.0005 +
			math.sin(quiver.general.get_time()) * 0.025,
			-0.00 + self.sway.y * 0.0005 + (angle_z:dot(shpee) / 8.0) * 0.25 + (side == 0.0 and -0.5 or 0.5)
		) + shake * 0.25

		-- draw weapon.
		local model = status.system:get_model(WEAPON_DATA[self.kind].model)
		model:draw_transform(camera_walk + camera_move, vector_3:old(0.0, 90.0, 0.0),
			vector_3:one(),
			color:red())
	end, camera_3d:old(vector_3:old(-1.0, 0.0, 0.0), vector_3:zero(), vector_3:y(), 90.0, CAMERA_3D_KIND.PERSPECTIVE))
end

--[[----------------------------------------------------------------]]

---Draw the weapon, in the lobby.
---@param status status # The game status.
---@param side   number # The side on which the weapon is on. 0.0 for l. side, 1.0 for r. side.
function weapon:draw_lobby(status, side)
	local model = status.system:get_model(WEAPON_DATA[self.kind].model)
	model:draw_transform(
		WEAPON_DATA_LOBBY[side].point,
		WEAPON_DATA_LOBBY[side].angle,
		vector_3:one(), color:white())
end

---Draw the weapon, in the lobby.
---@param status status # The game status.
---@param side   number # The side on which the weapon is on. 0.0 for l. side, 1.0 for r. side.
function weapon:use(status, side, input)
	if self.ammo > 0.0 and self.fire_time == 0.0 and input:down() then
		-- get the other currently held weapon.
		local side = side == 0.0 and
			status.inner.weapon[status.outer.player.weapon[2]] or
			status.inner.weapon[status.outer.player.weapon[1]]

		-- the accuracy of the other weapon will have a penalty on the current weapon. dual-firing is not advisable.
		local average = (side.miss_time + 1.0) * 0.1

		-- get the aim of the player.
		local aim = math.direction_from_euler(status.outer.player.angle)

		-- alternate inaccuracy pattern.
		local even = math.fmod(self.ammo, 2.0) == 0.0 and 1.0 or -1.0

		-- get the vertical and horizontal inaccuracy.
		local miss_y = self.miss_time * even * average * WEAPON_DATA[self.kind].miss_base *
			vector_3:old(0.0, 1.0, 0.0)
		local miss_z = self.miss_time * even * average * WEAPON_DATA[self.kind].miss_base *
			vector_3:old(0.0, 1.0, 0.0):cross(aim)

		-- add inaccuracy to aim.
		aim = aim + miss_y + miss_z

		-- spawn a new projectile.
		local i = projectile:new(status)

		-- set the point, speed, and parent of the projectile.
		i:set_point(status, status.outer.player.point + vector_3:old(0.0, 1.0, 0.0))
		i.speed:copy(aim * WEAPON_DATA[self.kind].projectile_speed)
		i.parent = entity_pointer:new(status.outer.player)

		-- apply camera shake to player.
		status.outer.player.camera_shake = WEAPON_DATA[self.kind].camera_shake

		-- decrement ammo, apply fire delay and inaccuracy.
		self.ammo = self.ammo - 1.00
		self.fire_time = self.fire_time + (WEAPON_DATA[self.kind].fire_rate / self.fire_rate)
		self.miss_time = self.miss_time + (WEAPON_DATA[self.kind].miss_rate / self.miss_rate)

		local sound = WEAPON_DATA[self.kind].sound[math.random(1, 3)]
		sound = status.system:get_sound(sound)
		sound:play()
	end
end

---Randomize weapon name.
---@param value? table # OPTIONAL: Weapon name table.
---@return string name # The weapon name.
function weapon:randomize_name(value)
	-- automatically use default weapon name table if table is not given.
	if not value then value = WEAPON_NAME end

	-- pick a random number between 1 and every available option in the table.
	local pick = math.random(1, table.hash_length(value))

	local i = 1.0

	-- for every element in the table...
	for key, value in pairs(value) do
		-- if the current index is the same as the random index...
		if i == pick then
			-- if value is string, end recursion. return weapon name.
			if type(value) == "string" then
				return value
			else
				return key .. self:randomize_name(value)
			end
		end

		i = i + 1.0
	end
end

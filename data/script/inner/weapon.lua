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

	return i
end

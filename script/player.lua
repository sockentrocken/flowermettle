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

---@class projectile : entity
projectile = {
	__meta = {}
}

---Create a new projectile.
---@param status status # The game status.
---@return projectile value # The projectile.
function projectile:new(status, point, angle, speed, parent)
	local i = entity:new(status, point, angle, speed)
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "projectile"
	i.parent = parent

	return i
end

function projectile:tick(status, step)
	self.point:copy(self.point + (self.speed * step))

	local test = status.rapier:test_intersect_cuboid(self.point, vector_3:one())
	if test then
		print(test)
	end
end

function projectile:draw_3d(status)
	quiver.draw_3d.draw_cube(self.point, vector_3:one(), color:blue())
end

--[[----------------------------------------------------------------]]

local PLAYER_FRICTION     = 8.00
local PLAYER_GRAVITY      = 32.00
local PLAYER_INCREASE     = 8.00
local PLAYER_SPEED_MAX    = 8.00
local PLAYER_SPEED_MIN    = 0.01
local CAMERA_FOLLOW_POINT = vector_3:new(0.0, 12.0, 4.0)
local CAMERA_FOLLOW_SPEED = 8.0

--[[----------------------------------------------------------------]]

---@class player : entity
player = {
	__meta = {}
}

---Create a new player.
---@param status    status # The game status.
---@param hunter    number # The index of the hunter to equip (A).
---@param weapon_a  number # The index of the weapon to equip (A).
---@param weapon_b  number # The index of the weapon to equip (B).
---@param ability_a number # The index of the ability to equip (A).
---@param ability_b number # The index of the ability to equip (A).
---@return player value # The player.
function player:new(status)
	local i = entity:new(status)
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	i.point.y               = 4.0

	i.__type                = "player"
	i.camera_point          = vector_3:new(0.0, 0.0, 0.0)
	i.camera_shake          = 0.0
	i.hunter                = status.dialog.hunter
	i.weapon                = status.dialog.weapon
	i.ability               = status.dialog.ability
	i.item                  = status.dialog.item
	local collider          = status.rapier:collider_builder_cuboid(vector_3:old(0.5, 1.0, 0.5))
	collider                = status.rapier:collider_builder_translation(collider, i.point)
	i.collider              = status.rapier:collider_insert(collider)
	i.character             = status.rapier:character_controller()
	i.floor                 = false

	status.system:set_texture("video/cross.png")

	return i
end

local function player_movement(self, step, wish_where, wish_speed)
	local velocity = vector_3:old(self.speed.x, 0.0, self.speed.z)
	local friction = velocity:magnitude()

	if friction > 0.0 then
		if friction < PLAYER_SPEED_MIN then
			friction = 1.0 - step * (PLAYER_SPEED_MIN / friction) * PLAYER_FRICTION
		else
			friction = 1.0 - step * PLAYER_FRICTION
		end

		if friction < 0.0 then
			self.speed:copy(vector_3:zero())
		else
			self.speed.x = self.speed.x * friction
			self.speed.z = self.speed.z * friction
		end
	end

	friction = wish_speed - self.speed:dot(wish_where)
	if friction > 0.0 then
		self.speed:copy(self.speed + wish_where * math.min(friction, PLAYER_INCREASE * step * wish_speed))
	end
end

function player:aim(status)
	local where = nil
	local shape = vector_2:old(quiver.window.get_render_shape()) * 0.5

	if status.dialog.window.device == INPUT_DEVICE.PAD then
		local axis_x = quiver.input.pad.get_axis_state(0.0, 2.0)
		local axis_y = quiver.input.pad.get_axis_state(0.0, 3.0)
		where = vector_2:old(axis_x, axis_y) * 256.0
	else
		local mouse = vector_2:old(quiver.input.mouse.get_point())
		local shape = vector_2:old(quiver.window.get_render_shape()) * 0.5
		where = (mouse - shape)
	end

	return vector_3:old(where.x, 0.0, where.y):normalize(), where:magnitude()
end

function player:tick(status, step)
	status.weapon[self.weapon[1]]:tick(status, step, 0.0)
	status.weapon[self.weapon[2]]:tick(status, step, 1.0)

	if status.user.input_weapon_a:down() then status.weapon[self.weapon[1]]:use(status, 0.0) end
	if status.user.input_weapon_b:down() then status.weapon[self.weapon[2]]:use(status, 1.0) end

	local movement = vector_3:old(0.0, 0.0, 0.0)

	if status.dialog.window.device == INPUT_DEVICE.PAD then
		movement.x = quiver.input.pad.get_axis_state(0.0, 0.0)
		movement.z = quiver.input.pad.get_axis_state(0.0, 1.0)
	else
		movement.x = status.user.input_move_y_a:down() and -1.0 or movement.x
		movement.x = status.user.input_move_y_b:down() and 1.00 or movement.x
		movement.z = status.user.input_move_x_a:down() and -1.0 or movement.z
		movement.z = status.user.input_move_x_b:down() and 1.00 or movement.z
	end

	movement = movement * PLAYER_SPEED_MAX
	local wish_where = movement:normalize()
	local wish_speed = movement:magnitude()

	player_movement(self, step, wish_where, wish_speed)

	local check = self.floor and self.speed + vector_3:old(0.0, -0.5, 0.0) or self.speed

	if self.floor then
		self.speed.y = 0.0
	else
		self.speed.y = self.speed.y - step * PLAYER_GRAVITY
	end

	local x, y, z, floor = status.rapier:character_controller_move(step, self.character, self.collider, check)

	self.point:set(x, y, z)
	self.floor = floor
end

function player:draw_3d(status)
	local aim, magnitude = self:aim(status)

	local delta = quiver.general.get_frame_time()
	local shake = vector_3:old(
		math.random_sign(self.camera_shake * status.user.video_shake),
		math.random_sign(self.camera_shake * status.user.video_shake),
		math.random_sign(self.camera_shake * status.user.video_shake)
	)

	-- update the camera.
	local camera_point = self.point + CAMERA_FOLLOW_POINT + (aim * magnitude * 0.01)
	self.camera_point:copy(self.camera_point + (camera_point - status.camera_3d.point) * delta * CAMERA_FOLLOW_SPEED)
	self.camera_shake = math.max(0.0, self.camera_shake - delta)
	status.camera_3d.point:copy(self.camera_point + shake + CAMERA_FOLLOW_POINT)
	status.camera_3d.focus:copy(self.camera_point + shake)
	status.camera_3d.zoom = 90.0

	quiver.draw_3d.draw_line(self.point, self.point + self:aim(status) * 4.0, color:red())

	-- draw hunter, weapon.
	status.hunter[self.hunter]:draw_3d(status)
	status.weapon[self.weapon[1]]:draw_3d(status, 0.0)
	status.weapon[self.weapon[2]]:draw_3d(status, 1.0)
end

function player:draw_2d(status)
	if status.dialog.window.device == INPUT_DEVICE.PAD then
		for x = 0, quiver.input.pad.get_axis_count(0.0) do
			LOGGER_FONT:draw("axis " .. x .. " : " .. quiver.input.pad.get_axis_state(0.0, x),
				vector_2:old(8.0, 8.0 + LOGGER_FONT_SCALE * x),
				LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
				color:red())
		end
	end

	local where = nil

	if status.dialog.window.device == INPUT_DEVICE.PAD then
		local axis_x = quiver.input.pad.get_axis_state(0.0, 2.0)
		local axis_y = quiver.input.pad.get_axis_state(0.0, 3.0)
		local shape = vector_2:old(quiver.window.get_render_shape()) * 0.5

		where = vector_2:old(axis_x, axis_y) * 256.0 + shape
	else
		where = vector_2:old(quiver.input.mouse.get_point())
	end

	local cross = status.system:get_texture("video/cross.png")

	cross:draw(where - vector_2:old(cross.shape_x, cross.shape_y) * 0.5, 0.0, 1.0, color:red())

	-- draw hunter, weapon, ability, item.
	status.hunter[self.hunter]:draw_2d(status)
	status.weapon[self.weapon[1]]:draw_2d(status, 0.0)
	status.weapon[self.weapon[2]]:draw_2d(status, 1.0)
	status.ability[self.ability[1]]:draw(status, 0.0)
	status.ability[self.ability[2]]:draw(status, 1.0)

	if self.item[1] then status.item[self.item[1]]:draw_2d(status, 0.0, self.item[1] and self.item[2]) end
	if self.item[2] then status.item[self.item[2]]:draw_2d(status, 1.0, self.item[1] and self.item[2]) end
end

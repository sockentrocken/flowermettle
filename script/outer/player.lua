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

local PLAYER_FRICTION     = 8.00
local PLAYER_GRAVITY      = 32.00
local PLAYER_INCREASE     = 8.00
local PLAYER_SPEED_MAX    = 8.00
local PLAYER_SPEED_MIN    = 0.01
local CAMERA_FOLLOW_POINT = vector_3:new(0.0, 8.0, 4.0)
local CAMERA_FOLLOW_SPEED = 8.0

---@class player : entity
player                    = entity:new()

---Create a new player.
---@param status    status # The game status.
---@return player value # The player.
function player:new(status, previous)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	i.__type                = "player"
	i.camera_point          = vector_3:new(0.0, 0.0, 0.0)
	i.camera_shake          = 0.0
	i.hunter                = status.lobby.hunter_select
	i.weapon                = status.lobby.weapon_select
	i:attach_collider(status, vector_3:old(0.5, 1.0, 0.5))

	i.character = status.outer.rapier:character_controller()
	i.floor     = false

	status.outer.system:set_texture("video/cross.png")
	status.outer.player = i

	status.outer.system:set_model("video/character.glb")

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
	local shape = vector_2:old(quiver.window.get_shape()) * 0.5

	if status.lobby.window.device == INPUT_DEVICE.PAD then
		local axis_x = quiver.input.pad.get_axis_state(0.0, 2.0)
		local axis_y = quiver.input.pad.get_axis_state(0.0, 3.0)
		where = vector_2:old(axis_x, axis_y) * 256.0
	else
		local mouse = vector_2:old(quiver.input.mouse.get_point())
		local shape = vector_2:old(quiver.window.get_shape()) * 0.5
		where = (mouse - shape)
	end

	return vector_3:old(where.x, 0.0, where.y):normalize(), where:magnitude()
end

function player:tick(status, step)
	status.inner.weapon[self.weapon[1]]:tick(status, step, 0.0)
	status.inner.weapon[self.weapon[2]]:tick(status, step, 1.0)

	if status.lobby.user.input_weapon_a:down() then status.inner.weapon[self.weapon[1]]:use(status, 0.0) end
	if status.lobby.user.input_weapon_b:down() then status.inner.weapon[self.weapon[2]]:use(status, 1.0) end

	local movement = vector_3:old(0.0, 0.0, 0.0)

	if status.lobby.window.device == INPUT_DEVICE.PAD then
		movement.x = quiver.input.pad.get_axis_state(0.0, 0.0)
		movement.z = quiver.input.pad.get_axis_state(0.0, 1.0)
	else
		movement.x = status.lobby.user.input_move_y_a:down() and -8.0 or movement.x
		movement.x = status.lobby.user.input_move_y_b:down() and 8.00 or movement.x
		movement.z = status.lobby.user.input_move_x_a:down() and -8.0 or movement.z
		movement.z = status.lobby.user.input_move_x_b:down() and 8.00 or movement.z
	end

	local d_x, _, d_z = math.direction_from_euler(vector_3:old(self.angle.x, 0.0, 0.0))

	if quiver.input.board.get_down(INPUT_BOARD.TAB) then
		movement = (d_x * -movement.z) + (d_z * -movement.x)
	end

	local wish_where = movement:normalize()
	local wish_speed = movement:magnitude()

	player_movement(self, step, wish_where, wish_speed)

	local check = self.floor and self.speed + vector_3:old(0.0, -0.5, 0.0) or self.speed

	if self.floor then
		self.speed.y = 0.0
	else
		self.speed.y = self.speed.y - step * PLAYER_GRAVITY
	end

	local x, y, z, floor = status.outer.rapier:character_controller_move(step, self.character, self.collider, check)

	self.point:set(x, y, z)
	self.floor = floor
end

function player:draw_3d(status)
	local hunter         = status.inner.hunter[self.hunter]
	local weapon_a       = status.inner.weapon[self.weapon[1]]
	local weapon_b       = status.inner.weapon[self.weapon[2]]

	local average        = (weapon_a.miss + weapon_b.miss) * 0.5 * 0.25

	local aim, magnitude = self:aim(status)

	local delta          = quiver.general.get_frame_time()
	local shake          = vector_3:old(
		math.random_sign(self.camera_shake + average * 0.1) * status.lobby.user.video_shake,
		math.random_sign(self.camera_shake + average * 0.1) * status.lobby.user.video_shake,
		math.random_sign(self.camera_shake + average * 0.1) * status.lobby.user.video_shake
	)

	if quiver.input.board.get_press(INPUT_BOARD.TAB) then
		status.outer.camera_3d.point:copy(self.point)
		status.outer.camera_3d.focus:copy(self.point + vector_3:old(1.0, 0.0, 0.0))
		quiver.input.mouse.set_active(false)
	end

	if quiver.input.board.get_release(INPUT_BOARD.TAB) then
		quiver.input.mouse.set_active(true)
		quiver.input.mouse.set_hidden(true)
	end

	if quiver.input.board.get_down(INPUT_BOARD.TAB) then
		local x, y = quiver.input.mouse.get_delta()

		self.angle.x = self.angle.x - x * 0.1
		self.angle.y = self.angle.y + y * 0.1

		local d_x = math.direction_from_euler(self.angle)

		status.outer.camera_3d.point:copy(self.point + shake)
		status.outer.camera_3d.focus:copy(self.point + shake + d_x)
	else
		-- update the camera.
		local camera_point = self.point + CAMERA_FOLLOW_POINT + (aim * magnitude * 0.01)
		self.camera_point:copy(self.camera_point +
			(camera_point - status.outer.camera_3d.point) * delta * CAMERA_FOLLOW_SPEED)
		status.outer.camera_3d.point:copy(self.camera_point + shake + CAMERA_FOLLOW_POINT)
		status.outer.camera_3d.focus:copy(self.camera_point + shake)
	end

	self.camera_shake = math.max(0.0, self.camera_shake - delta * self.camera_shake * 8.0)

	status.outer.camera_2d.shift:copy(shake * 16.0)

	local x, y = quiver.input.mouse.get_point()
	local ray = quiver.draw_3d.get_screen_to_world(status.outer.camera_3d, vector_2:old(x, y),
		vector_2:old(quiver.window.get_render_shape()))

	local collider, time = status.outer.rapier:cast_ray(ray, 4096.0, true, status.outer.level_rigid)

	local c = color:red()

	if collider then
		local c_point = vector_3:old(status.outer.rapier:get_collider_translation(collider))
		aim = (c_point - self.point):normalize()
		c = c:blue()

		quiver.draw_3d.draw_cube(
			vector_3:old(ray.position.x, ray.position.y, ray.position.z) +
			vector_3:old(ray.direction.x, ray.direction.y, ray.direction.z) * time,
			vector_3:one() * 0.5, color:green())
	end

	quiver.draw_3d.draw_line(self.point, self.point + aim * 4.0, c)

	-- draw hunter, weapon.
	hunter:draw_3d(status)
	weapon_a:draw_3d(status, 0.0)
	weapon_b:draw_3d(status, 1.0)
end

function player:draw_2d(status)
	local hunter   = status.inner.hunter[self.hunter]
	local weapon_a = status.inner.weapon[self.weapon[1]]
	local weapon_b = status.inner.weapon[self.weapon[2]]

	local average  = (weapon_a.miss + weapon_b.miss) * 0.5 * 0.25

	if status.lobby.window.device == INPUT_DEVICE.PAD then
		for x = 0, quiver.input.pad.get_axis_count(0.0) do
			LOGGER_FONT:draw("axis " .. x .. " : " .. quiver.input.pad.get_axis_state(0.0, x),
				vector_2:old(8.0, 8.0 + LOGGER_FONT_SCALE * x),
				LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
				color:red())
		end
	end

	local where = nil

	if status.lobby.window.device == INPUT_DEVICE.PAD then
		local axis_x = quiver.input.pad.get_axis_state(0.0, 2.0)
		local axis_y = quiver.input.pad.get_axis_state(0.0, 3.0)
		local shape = vector_2:old(quiver.window.get_render_shape()) * 0.5

		where = vector_2:old(axis_x, axis_y) * 256.0 + shape
	else
		where = vector_2:old(quiver.input.mouse.get_point())
	end

	local x, y = quiver.window.get_render_shape()

	local cross = status.outer.system:get_texture("video/cross.png")

	if quiver.input.board.get_down(INPUT_BOARD.TAB) then
		where = vector_2:old(x, y) * 0.5
	end

	cross:draw(where - (vector_2:old(cross.shape_x, cross.shape_y) * 0.75 * (average + 1.0) * 0.5), 0.0, 0.75 + average,
		color:red())

	-- draw hunter, weapon.
	hunter:draw_2d(status)
	weapon_a:draw_2d(status, 0.0)
	weapon_b:draw_2d(status, 1.0)
end

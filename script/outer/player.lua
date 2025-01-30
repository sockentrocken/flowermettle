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

local PLAYER_AIM_LENGTH = 4096.0
local PLAYER_AIM_HELPER = vector_3:new(0.0, 0.1, 0.0)
local CAMERA_POINT      = vector_3:new(0.0, 8.0, 4.0)
local CAMERA_SPEED      = 8.0

---@class player : actor
player                  = actor:new()

---Create a new player.
---@param status status # The game status.
---@return player value # The player.
function player:new(status, previous)
	local i = actor:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	i.__type                = "player"

	-- camera smooth point + camera shake.
	i.camera_point          = vector_3:new(0.0, 0.0, 0.0)
	i.camera_shake          = 0.0

	-- current hunter + weapon selection.
	i.hunter                = status.lobby.select_hunter
	i.weapon                = status.lobby.select_weapon

	-- current enemy count.
	i.enemy_count           = 0.0

	-- currently standing on floor.
	i.step                  = 0.0

	-- TO-DO
	i.done                  = 0.0

	-- associate us as the main player.
	status.outer.player     = i

	-- load model.
	status.system:set_model("video/character.glb"):bind_shader(0.0, status.light.shader)

	-- load sound.
	status.system:set_sound("audio/player/step_1.ogg")
	status.system:set_sound("audio/player/step_2.ogg")
	status.system:set_sound("audio/player/step_3.ogg")
	status.system:set_sound("audio/player/step_4.ogg")
	status.system:set_sound("audio/player/step_5.ogg")
	status.system:set_sound("audio/player/step_6.ogg")
	status.system:set_sound("audio/player/step_7.ogg")
	status.system:set_sound("audio/player/step_8.ogg")
	status.system:set_sound("audio/player/step_9.ogg")
	status.system:set_sound("audio/player/step_10.ogg")
	status.system:set_sound("audio/player/land_1.ogg")
	status.system:set_sound("audio/player/land_2.ogg")

	-- load texture.
	status.system:set_texture("video/cross.png")
	status.system:set_texture("video/plaque.png")

	print(i.value_4)

	return i
end

function player:tick(status, step)
	local weapon_a = status.inner.weapon[self.weapon[1]]
	local weapon_b = status.inner.weapon[self.weapon[2]]
	local movement = vector_3:old(0.0, 0.0, 0.0)

	if self.enemy_count > 0.0 then
		-- if the current device is pad...
		if status.lobby.window.device == INPUT_DEVICE.PAD then
			-- get l. stick input.
			movement.x = quiver.input.pad.get_axis_state(0.0, 0.0)
			movement.z = quiver.input.pad.get_axis_state(0.0, 1.0)
		else
			-- get digital input.
			movement.x = status.lobby.user.input_move_y_a:down() and ACTOR_SPEED_MAX * -1.0 or movement.x
			movement.x = status.lobby.user.input_move_y_b:down() and ACTOR_SPEED_MAX or movement.x
			movement.z = status.lobby.user.input_move_x_a:down() and ACTOR_SPEED_MAX * -1.0 or movement.z
			movement.z = status.lobby.user.input_move_x_b:down() and ACTOR_SPEED_MAX or movement.z
		end
	end

	local floor = self.floor

	print(self.enemy_count)

	self:movement(status, step, movement:normalize(), movement:magnitude())

	if self.floor and not floor then
		if self.speed.y < -16.0 then
			local sound = status.system:get_sound("audio/player/land_" .. math.random(1, 2) .. ".ogg")
			sound:play()
		end
	end

	self.step = math.max(0.0, self.step - step)

	if self.floor and vector_3:old(self.speed.x, 0.0, self.speed.z):magnitude() > 2.5 and self.step == 0.0 then
		local sound = status.system:get_sound("audio/player/step_" .. math.random(1, 10) .. ".ogg")
		sound:play()
		self.step = self.step + 0.30
	end

	-- process weapon tick.
	weapon_a:tick(status, step, 0.0)
	weapon_b:tick(status, step, 1.0)

	if self.enemy_count == 0.0 then
		self.done = self.done + step
	end

	if self.done >= 1.0 then
		status.lobby.active = true
		status.outer.entity = {}
		status.outer = nil
	end
end

function player:draw_3d(status)
	local hunter         = status.inner.hunter[self.hunter]
	local weapon_a       = status.inner.weapon[self.weapon[1]]
	local weapon_b       = status.inner.weapon[self.weapon[2]]
	local aim, magnitude = self:aim_3d(status)
	local delta          = quiver.general.get_frame_time()
	local shake          = vector_3:old(
		math.random_sign(self.camera_shake * status.lobby.user.video_shake),
		math.random_sign(self.camera_shake * status.lobby.user.video_shake),
		math.random_sign(self.camera_shake * status.lobby.user.video_shake)
	)

	-- decrement camera shake.
	self.camera_shake    = math.max(0.0, self.camera_shake - delta * self.camera_shake * 8.0)

	local camera_point   = nil

	-- update the player camera.
	if status.outer.player.enemy_count > 0.0 then
		camera_point = self.point + CAMERA_POINT + (aim * magnitude * 0.01)
	else
		camera_point = self.point + CAMERA_POINT * 0.5
	end

	self.camera_point:copy(self.camera_point + (camera_point - status.outer.camera_3d.point) * delta * CAMERA_SPEED)

	-- update the 3D camera.
	status.outer.camera_3d.point:copy(self.camera_point + shake + CAMERA_POINT)
	status.outer.camera_3d.focus:copy(self.camera_point + shake)

	-- update the 2D camera.
	--status.outer.camera_2d.shift:copy(shake * 16.0)

	-- draw hunter, weapon.
	hunter:draw_3d(status)
	weapon_a:draw_3d(status, 0.0)
	weapon_b:draw_3d(status, 1.0)
end

function player:draw_2d(status)
	if self.enemy_count == 0.0 then
		return
	end

	local hunter   = status.inner.hunter[self.hunter]
	local weapon_a = status.inner.weapon[self.weapon[1]]
	local weapon_b = status.inner.weapon[self.weapon[2]]
	local average  = (weapon_a.miss_time + weapon_b.miss_time) * 0.5

	-- draw crosshair.
	local cross    = status.system:get_texture("video/cross.png")
	cross:draw(player:aim_2d(status) - (vector_2:old(cross.shape_x, cross.shape_y) * (1.0 + average) * 0.5), 0.0,
		1.0 + average,
		color:white())

	-- draw hunter, weapon.
	hunter:draw_2d(status)
	weapon_a:draw_2d(status, 0.0)
	weapon_b:draw_2d(status, 1.0)

	if quiver.input.board.get_down(INPUT_BOARD.SPACE) then
		self.speed.y = 32.0
	end
end

--[[----------------------------------------------------------------]]

---Get where the player's aim should be, in 2D space.
---@param status status # The game status.
---@return vector_2 value # The player's aim, in 2D space.
function player:aim_2d(status)
	-- if current device is pad...
	if status.lobby.window.device == INPUT_DEVICE.PAD then
		-- get l. stick input.
		local axis_x = quiver.input.pad.get_axis_state(0.0, 2.0)
		local axis_y = quiver.input.pad.get_axis_state(0.0, 3.0)
		local shape = vector_2:old(quiver.window.get_render_shape()) * 0.5

		return vector_2:old(axis_x, axis_y) * 256.0 + shape
	else
		-- return mouse point.
		return vector_2:old(quiver.input.mouse.get_point()):scale_zoom(status.outer.camera_2d)
	end
end

---Get where the player's aim should be, in 3D space.
---@param status status # The game status.
---@return vector_3 value # The player's aim, in 3D space.
function player:aim_3d(status)
	local where = nil

	-- TO-DO: normalize this so that the camera doesn't go farther on a higher resolution.

	-- if current device is pad...
	if status.lobby.window.device == INPUT_DEVICE.PAD then
		-- get l. stick input.
		local axis_x = quiver.input.pad.get_axis_state(0.0, 2.0)
		local axis_y = quiver.input.pad.get_axis_state(0.0, 3.0)
		where = vector_2:old(axis_x, axis_y) * 256.0
	else
		-- get mouse, render shape.
		local mouse = vector_2:old(quiver.input.mouse.get_point())
		local shape = vector_2:old(quiver.window.get_render_shape()) * 0.5
		where = (mouse - shape)
	end

	return vector_3:old(where.x, 0.0, where.y):normalize(), where:magnitude()
end

---Cast a ray into the world for an enemy.
---@param status status # The game status.
---@return vector_3 value # The player's aim, in 3D space.
function player:aim(status)
	-- get mouse point, construct ray.
	local mouse = vector_2:old(quiver.input.mouse.get_point())
	local shape = vector_2:old(quiver.window.get_render_shape())
	local aim_ray = ray:zero()

	-- get the view ray, from the point of the mouse.
	aim_ray:pack(
		quiver.draw_3d.get_screen_to_world(
			status.outer.camera_3d,
			mouse,
			shape
		)
	)

	-- cast ray, ignoring the level geometry.
	local collider, time = status.outer.rapier:cast_ray(aim_ray, PLAYER_AIM_LENGTH, true, status.outer.level_rigid,
		self.collider)

	-- if collider is not nil...
	if collider then
		-- get the point of the collider.
		local point = vector_3:old(status.outer.rapier:get_collider_translation(collider))

		-- if collider is above/below player by a certain threshold...
		if math.abs(point.y - self.point.y) >= 0.5 then
			-- aim at center mass.
			local point_min = (point - self.point):normalize()

			-- cast ray from player to target.
			local collider, time = status.outer.rapier:cast_ray(ray:new(self.point, point_min), PLAYER_AIM_LENGTH,
				true, nil,
				self.collider)

			local data = status.outer.rapier:get_collider_user_data(collider)

			-- if collider is not nil and collider is not the world (0.0 is world)...
			if collider and not (data == 0.0) then
				print("mid. hit")
				-- return direction between player and collider, with a small epsilon to help with aiming.
				return point_min + PLAYER_AIM_HELPER
			end

			--[[----------------------------------------------------------------]]
			-- TO-DO: remove 0.5 hard-code, which is assuming EVERY projectile will have a size of 0.5.
			--[[----------------------------------------------------------------]]

			-- aim at center mass + add upper half.
			local point_min = ((point + vector_3:old(0.0, 0.5, 0.0)) - self.point):normalize()

			-- cast ray from player to target.
			local collider, time = status.outer.rapier:cast_ray(ray:new(self.point, point_min), PLAYER_AIM_LENGTH,
				true, nil,
				self.collider)

			local data = status.outer.rapier:get_collider_user_data(collider)

			-- if collider is not nil and collider is not the world (0.0 is world)...
			if collider and not (data == 0.0) then
				print("upp. hit")
				-- return direction between player and collider, with a small epsilon to help with aiming.
				return point_min + PLAYER_AIM_HELPER
			end
		end
	end

	-- no collider was hit, or collider was not above/below us.
	return self:aim_3d(status)
end

-- TO-DO clean up, parm desc.
function player:draw_plaque(status, point, label, value_min, value_max)
	-- get texture, font.
	local texture = status.system:get_texture("video/plaque.png")
	local font = status.system:get_font("video/font_plaque.ttf")

	-- texture data.
	local panel_a = box_2:old(301.0, 0.0, 11.0, -16.0)
	local panel_b = box_2:old(313.0, 0.0, 16.0, -16.0)
	local panel_c = box_2:old(330.0, 0.0, 11.0, -16.0)
	local main = box_2:old(0.0, 0.0, 108.0, 25.0)
	local bar_a = box_2:old(109.0, 0.0, 50.0, 18.0)
	local bar_b = box_2:old(160.0, 0.0, 50.0, 18.0)

	local function draw_number_font(point, value)
		local to_string = tostring(value)

		local i = 0.0

		if value < 10 then to_string = "0" .. to_string end
		if value < 100 then to_string = "0" .. to_string end

		for c in to_string:gmatch(".") do
			local to_number = tonumber(c)

			texture:draw_pro(box_2:old(211.0 + 9.0 * to_number, 0.0, 8.0, 10.0),
				box_2:old(point.x + (7.0 * i), point.y, 8.0, 10.0), vector_2:zero(), 0.0, color:white())

			i = i + 1.0
		end
	end

	bar_b.width = bar_b.width * (value_min / value_max)

	texture:draw_pro(main, box_2:old(point.x, point.y, main.width, main.height),
		vector_2:zero(), 0.0, color:white())

	texture:draw_pro(bar_a,
		box_2:old(point.x + 43.0, point.y + (3.0), bar_a.width, bar_a.height),
		vector_2:zero(), 0.0, color:white())

	texture:draw_pro(bar_b,
		box_2:old(point.x + 43.0, point.y + (3.0), bar_b.width, bar_b.height),
		vector_2:zero(), 0.0,
		color:white())

	local size = font:measure_text(label, 14.0, 1.0)

	texture:draw_pro(panel_a, box_2:old(point.x, point.y + main.height, panel_a.width, panel_a.height), vector_2:zero(),
		0.0,
		color:white())

	local x = 0.0

	while x < math.floor((size + 4.0) / panel_b.width) do
		texture:draw_pro(panel_b,
			box_2:old(point.x + panel_a.width + panel_b.width * x, point.y + main.height, panel_b.width, panel_b.height),
			vector_2:zero(), 0.0,
			color:white())

		x = x + 1.0
	end

	texture:draw_pro(panel_c,
		box_2:old(point.x + panel_a.width + panel_b.width * x, point.y + main.height, panel_c.width, panel_c.height),
		vector_2:zero(),
		0.0,
		color:white())

	font:draw(label, point + vector_2:old(8.0, main.height + 1.0), 14.0, 1.0, color:old(170.0, 255.0, 140.0, 255.0))

	draw_number_font(vector_2:old(point.x + 17.0, point.y + (7.0)), value_min)
end

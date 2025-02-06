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

local PLAYER_LEAN_SPEED             = 8.0
local PLAYER_LEAN_DECREMENT         = 0.25
local PLAYER_LEAN_INCREMENT         = 0.20
local PLAYER_SPRINT_SPEED_INCREMENT = 4.0
local PLAYER_SPRINT_SPEED_DECREMENT = 4.0
local PLAYER_SPRINT_DECREMENT       = 0.15
local PLAYER_SPRINT_INCREMENT       = 0.20
local PLAYER_CROUCH_SPEED           = 8.0
local PLAYER_WALK_SPEED             = 8.0
local PLAYER_WALK_FORCE             = 0.1
local PLAYER_TILT_FORCE             = -5.0
local PLAYER_LEAN_FORCE             = 25.0
local PLAYER_SPRINT_ZOOM            = 30.0
local PLAYER_CROUCH_ZOOM            = 15.0
local PLAYER_ANGLE_MIN              = -90.0
local PLAYER_ANGLE_MAX              = 90.00
local PLAYER_CHEVRON_POINT_MIN      = 12.0
local PLAYER_CHEVRON_POINT_MAX      = 12.0
local PLAYER_STEP_RANGE             = 2.50
local PLAYER_STEP_DELAY             = 0.35

--[[----------------------------------------------------------------]]

---@class player : actor
player = actor:new()

---Create a new player.
---@param status status # The game status.
---@return player value # The player.
function player:new(status, previous)
	local i = actor:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	i.__type                = "player"

	-- associate us as the main player.
	status.outer.player     = i

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

	status.system:set_texture("video/chevron.png")

	i.lean_where = 0.0
	i.lean_delay = 1.0
	i.sprint_where = 0.0
	i.sprint_delay = 1.0
	i.crouch_where = 0.0
	i.step_delay = 0.0
	i.fall_scale = 0.0
	i.sway = vector_2:new(0.0, 0.0)

	return i
end

function player:tick(status, step)
	--if status.outer.time <= 8.75 then
	--	self:set_point(status, self.point + vector_3:old(0.0, step, 0.0))
	--	return
	--end

	local movement = vector_3:old(0.0, 0.0, 0.0)

	local speed = self:get_speed()

	if status.lobby.user.input.sprint:down() then
		movement.x = speed
	else
		-- if the current device is pad...
		if status.lobby.window.device == INPUT_DEVICE.PAD then
			-- get l. stick input.
			movement.x = quiver.input.pad.get_axis_state(0.0, 0.0)
			movement.z = quiver.input.pad.get_axis_state(0.0, 1.0)
		else
			-- get digital input.
			movement.z = status.lobby.user.input.move_y_a:down() and speed or movement.z
			movement.z = status.lobby.user.input.move_y_b:down() and speed * -1.0 or movement.z
			movement.x = status.lobby.user.input.move_x_a:down() and speed or movement.x
			movement.x = status.lobby.user.input.move_x_b:down() and speed * -1.0 or movement.x
		end
	end

	local angle_x, _, angle_z = math.direction_from_euler(vector_3:old(self.angle.x, 0.0, 0.0))

	movement = movement.x * angle_x + movement.z * angle_z

	local speed = self.speed.y
	local floor = self.floor

	self:movement(status, step, movement:normalize(), movement:magnitude())

	if self.floor and not floor then
		if speed <= -10.0 then
			self.fall_scale = 1.0
		end
	end

	self:step(status, step)
	self:fall(status, step)
	self:lean(status, step)
	self:sprint(status, step)
	self:crouch(status, step)
end

function player:draw_3d(status)
	if quiver.input.board.get_press(INPUT_BOARD.F2) then
		status.system:load()

		status.outer.rapier:rigid_body_remove(status.outer.level_rigid, true)

		status.outer.level_rigid = status.outer.rapier:rigid_body(0.0)

		for _, entity in pairs(status.outer.entity) do
			if entity.__type == "level" then
				local model = status.system:get_model(entity.model)

				for x = 1, model.material_count - 1.0 do
					model:bind_shader(x, status.outer.scene.light.shader)
				end

				-- for each mesh in the model...
				for x = 0, model.mesh_count - 1.0 do
					local vertex = model:mesh_vertex(x)
					local index = model:mesh_index(x)

					for k, v in ipairs(vertex) do
						vertex[k] = vector_3:old(v.x, v.y, v.z)
						vertex[k] = vertex[k]:rotate_vector_4(vector_4:from_euler(
							entity.angle.x,
							entity.angle.y,
							entity.angle.z
						))
						vertex[k].x = vertex[k].x + entity.point.x
						vertex[k].y = vertex[k].y + entity.point.y
						vertex[k].z = vertex[k].z + entity.point.z
					end

					-- load the tri-mesh, and parent it to the level rigid body.
					status.outer.rapier:collider_builder_tri_mesh(vertex, index, status.outer.level_rigid)
				end
			end
		end

		self:set_point(status, self.point + vector_3:old(0.0, 1.0, 0.0))
	end

	local user = status.lobby.user
	local delta = quiver.general.get_frame_time()
	local speed = vector_3:old(self.speed.x, 0.0, self.speed.z)
	local speed_magnitude = (speed:magnitude() / self:get_speed())

	-- decrease scale.
	self.fall_scale = math.max(0.0, self.fall_scale - self.fall_scale * delta * 4.0)

	-- fall animation.
	local fall = (math.sin(self.fall_scale * math.pi * 2.0 + math.pi * 0.5) - 1.0) * 0.5 * 0.5

	-- walk animation.
	local walk = math.sin(quiver.general.get_time() * PLAYER_WALK_SPEED) * speed_magnitude *
		PLAYER_WALK_FORCE * user.video.camera_walk

	-- duck animation.
	local crouch_sin = math.sin(quiver.general.get_time() * 8.0) * speed_magnitude *
		(1.5 + self.sprint_where * 2.0 + self.crouch_where)
	local crouch_cos = math.cos(quiver.general.get_time() * 4.0) * speed_magnitude *
		(1.0 + self.sprint_where * 2.0 + self.crouch_where)
	local crouch = 1.0 - self.crouch_where

	local angle_x, angle_y, angle_z = math.direction_from_euler(self.angle +
		vector_3:old(0.0, fall * 15.0 * -1.0 + crouch_sin, 0.0))

	-- tilt + lean animation.
	local tilt = (angle_z:dot(speed) / self:get_speed()) * PLAYER_TILT_FORCE * user.video.camera_tilt
	local lean = self.lean_where * PLAYER_LEAN_FORCE
	angle_y = angle_y:rotate_axis_angle(angle_x, math.degree_to_radian(tilt + lean + crouch_cos))
	local lean = angle_z * self.lean_where * -1.0

	-- get the final point of the camera.
	local point = self.point + vector_3:old(0.0, fall + walk + crouch, 0.0) + lean

	-- update the 3D camera.
	status.outer.scene.camera_3d.point:copy(point)
	status.outer.scene.camera_3d.focus:copy(angle_x + point)
	status.outer.scene.camera_3d.angle:copy(angle_y)
	status.outer.scene.camera_3d.zoom = user.video.field +
		(self.sprint_where * PLAYER_SPRINT_ZOOM) -
		(self.crouch_where * PLAYER_CROUCH_ZOOM)

	-- update player angle.
	local mouse = vector_2:old(quiver.input.mouse.get_delta())
	self.angle.x = self.angle.x - mouse.x * status.lobby.user.input.mouse_sensitivity_x
	self.angle.y = self.angle.y + mouse.y * status.lobby.user.input.mouse_sensitivity_y
	self.angle.y = math.clamp(PLAYER_ANGLE_MIN, PLAYER_ANGLE_MAX, self.angle.y)
end

function player:draw_2d(status)
	local shape         = vector_2:old(status.render.shape_x, status.render.shape_y)
	local speed         = self.speed:magnitude() / self:get_speed()
	local chevron       = status.system:get_texture("video/chevron.png")
	local chevron_shape = vector_2:old(chevron.shape_x, chevron.shape_y)
	local chevron_point = box_2:old(0.0, 0.0, chevron_shape.x, chevron_shape.y)
	local chevron_range = PLAYER_CHEVRON_POINT_MIN + PLAYER_CHEVRON_POINT_MAX * speed
	local color_a       = color:old(255.0, 255.0, 255.0, math.floor(255.0 * self.sprint_delay))
	local color_b       = color:old(255.0, 255.0, 255.0, math.floor(255.0 * self.lean_delay))
	local point         = vector_2:old(shape.x * 0.5, shape.y * 0.5)

	if status.lobby.user.video.info_draw then
		chevron_shape = chevron_shape * (1.0 - self.crouch_where * 0.50)
		chevron_range = chevron_range * (1.0 - self.crouch_where * 0.50)

		chevron:draw_pro(chevron_point,
			box_2:old(point.x, point.y + chevron_range, chevron_shape.x, chevron_shape.y),
			chevron_shape * 0.5, 0.0000, color_a)

		chevron:draw_pro(chevron_point,
			box_2:old(point.x, point.y - chevron_range, chevron_shape.x, chevron_shape.y),
			chevron_shape * 0.5, -180.0, color_a)

		chevron:draw_pro(chevron_point,
			box_2:old(point.x - chevron_range, point.y, chevron_shape.x, chevron_shape.y),
			chevron_shape * 0.5, 90.000, color_b)

		chevron:draw_pro(chevron_point,
			box_2:old(point.x + chevron_range, point.y, chevron_shape.x, chevron_shape.y),
			chevron_shape * 0.5, -90.00, color_b)

		quiver.draw_2d.draw_circle(point, 2.0, color:white())

		local box_a = box_2:old(8.0, shape.y - 36.0, 96.0, 28.0)
		local box_b = box_2:old(box_a.x + 2.0, box_a.y + 2.0, box_a.width - 4.0, box_a.height - 4.0)
		local box_c = box_2:old(box_b.x + 2.0, box_b.y + 2.0, box_b.width - 4.0, box_b.height - 4.0)

		box_c.width = box_c.width * 1.0

		local font = status.system:get_font("video/font_side.ttf")

		local box_color_a = color:old(127.0, 127.0, 127.0, 255.0)
		local box_color_b = box_color_a * 0.5
		local box_color_c = box_color_a * 1.5

		quiver.draw_2d.draw_box_2_round(box_a, 0.25, 4.0, box_color_a)
		quiver.draw_2d.draw_box_2_round(box_b, 0.25, 4.0, box_color_b)
		quiver.draw_2d.draw_box_2_round(box_c, 0.25, 4.0, box_color_c)

		font:draw("100", vector_2:old(box_c.x + 4.0, box_c.y + 2.0), 20.0, 1.0, color:black())

		if status.outer.time >= 10.0 and status.outer.time <= 16.0 then
			local value = math.ease_interval(10.0, 12.0, 14.0, 16.0, status.outer.time)

			-- measure text.
			local measure = vector_2:old(font:measure_text("Zone 1-1", 24.0, 1.0))

			font:draw("Zone 1-1", shape * 0.5 - vector_2:old(measure.x * 0.5, 64.0), 24.0, 1.0,
				color:old(255.0, 255.0, 255.0, math.floor(255.0 * value)))
		end
	end

	if status.outer.time <= 2.0 then
		quiver.draw_2d.draw_box_2(box_2:old(0.0, 0.0, shape.x, shape.y), vector_2:zero(), 0.0,
			color:old(0.0, 0.0, 0.0, math.floor(255.0 * (1.0 - status.outer.time * 0.5))))
	end

	if status.lobby.user.video.frame_draw then
		local font = status.system:get_font("video/font_side.ttf")

		font:draw(quiver.general.get_frame_rate(), vector_2:old(8.0, 8.0), 24.0, 1.0, color:white())
	end
end

--[[----------------------------------------------------------------]]

function player:step(status, step)
	-- get the speed of the player, without the Y component.
	local speed = vector_3:old(self.speed.x, 0.0, self.speed.z):magnitude()

	-- decrease delay.
	self.step_delay = math.max(0.0, self.step_delay - step)

	-- if delay is 0.0, we are on the floor, and our speed is above the threshold...
	if self.step_delay <= 0.0 and self.floor and speed >= PLAYER_STEP_RANGE then
		-- get a random sound, and play it.
		status.system:get_sound("audio/player/step_" .. math.random(1, 10) .. ".ogg"):play()
		self.step_delay = PLAYER_STEP_DELAY
	end
end

function player:fall(status, step)
end

function player:lean(status, step)
	if status.lobby.user.input.lean_a:down() then
		local time = self:check_lean(status, step, 1.00) * self.lean_delay * -1.0
		self.lean_where = self.lean_where + (time - self.lean_where) * step * PLAYER_LEAN_SPEED
		self.lean_delay = math.max(0.0, self.lean_delay - step * PLAYER_LEAN_DECREMENT)
	elseif status.lobby.user.input.lean_b:down() then
		local time = self:check_lean(status, step, -1.0) * self.lean_delay
		self.lean_where = self.lean_where + (time - self.lean_where) * step * PLAYER_LEAN_SPEED
		self.lean_delay = math.max(0.0, self.lean_delay - step * PLAYER_LEAN_DECREMENT)
	else
		self.lean_where = self.lean_where - (self.lean_where * step) * PLAYER_LEAN_SPEED
		self.lean_delay = math.min(1.0, self.lean_delay + step * PLAYER_LEAN_INCREMENT)
	end
end

function player:sprint(status, step)
	if status.lobby.user.input.sprint:down() then
		self.sprint_where = math.min(self.sprint_delay,
			self.sprint_where + (1.0 - self.sprint_where) * step * PLAYER_SPRINT_SPEED_INCREMENT)
		self.sprint_delay = math.max(0.0, self.sprint_delay - step * PLAYER_SPRINT_DECREMENT)
	else
		self.sprint_where = self.sprint_where - (self.sprint_where * step) * PLAYER_SPRINT_SPEED_DECREMENT
		self.sprint_delay = math.min(1.0, self.sprint_delay + step * PLAYER_SPRINT_INCREMENT)
	end
end

function player:crouch(status, step)
	if status.lobby.user.input.crouch:down() then
		if self.shape.y == 1.0 then
			self:set_shape(status, vector_3:old(0.5, 0.5, 0.5))
			self:set_point(status, self.point - vector_3:old(0.0, 0.5, 0.0))
		end

		self.crouch_where = math.min(1.0,
			self.crouch_where + (1.0 - self.crouch_where) * step * PLAYER_CROUCH_SPEED)
	else
		if self.shape.y == 0.5 then
			local check = status.outer.rapier:test_intersect_cuboid(self.point + vector_3:old(0.0, 0.5, 0.0),
				vector_3:zero(), vector_3:old(0.5, 1.0, 0.5), nil, self.collider)

			if not check then
				self:set_shape(status, vector_3:old(0.5, 1.0, 0.5))
				self:set_point(status, self.point + vector_3:old(0.0, 0.5, 0.0))
			end
		end

		if self.shape.y == 1.0 then
			self.crouch_where = self.crouch_where - (self.crouch_where * step) * PLAYER_CROUCH_SPEED
		end
	end

	local shader = status.system:get_shader("base")
	shader:set_shader_decimal(shader:get_location_name("vignette"), self.crouch_where)
end

function player:check_lean(status, step, direction)
	local point = self.point + vector_3:old(0.0, self.shape.y - self.crouch_where, 0.0)

	local _, _, angle_z = math.direction_from_euler(self.angle)

	local lean = angle_z * direction
	local from = 1.0

	local collider, time = status.outer.rapier:cast_ray(ray:old(point, lean), self.shape.x + 1.0, true, nil,
		self.collider)

	if collider then
		from = from * (time / (self.shape.x + 1.0))
	end

	return from
end

function player:get_speed()
	return ACTOR_SPEED_MAX * (1.0 - (self.crouch_where * 0.75)) * (1.0 + self.sprint_where * 0.75)
end

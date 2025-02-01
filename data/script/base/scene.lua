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

---@class scene
scene = {}

---Create a new scene.
---@param shader shader # The light shader.
---@return scene value # The scene.
function scene:new(shader)
	local i = {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "scene"
	i.camera_3d = camera_3d:new(vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 1.0, 0.0),
		90.0, CAMERA_3D_KIND.PERSPECTIVE)
	i.camera_2d = camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 1.0)
	i.light = light:new(shader)
	i.frustum = {
		vector_4:new(0.0, 0.0, 0.0, 0.0),
		vector_4:new(0.0, 0.0, 0.0, 0.0),
		vector_4:new(0.0, 0.0, 0.0, 0.0),
		vector_4:new(0.0, 0.0, 0.0, 0.0),
		vector_4:new(0.0, 0.0, 0.0, 0.0),
		vector_4:new(0.0, 0.0, 0.0, 0.0),
	}

	return i
end

function scene:get_frustum()
	local projection = matrix:old(
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0
	)
	local model_view = matrix:old(
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0
	)
	projection:set(quiver.draw_3d.get_matrix_projection())
	model_view:set(quiver.draw_3d.get_matrix_model_view())

	local plane = matrix:old(
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0,
		0.0, 0.0, 0.0, 0.0
	)

	plane.m0 = model_view.m0 * projection.m0 + model_view.m1 * projection.m4 + model_view.m2 * projection.m8 +
		model_view.m3 * projection.m12
	plane.m1 = model_view.m0 * projection.m1 + model_view.m1 * projection.m5 + model_view.m2 * projection.m9 +
		model_view.m3 * projection.m13
	plane.m2 = model_view.m0 * projection.m2 + model_view.m1 * projection.m6 + model_view.m2 * projection.m10 +
		model_view.m3 * projection.m14
	plane.m3 = model_view.m0 * projection.m3 + model_view.m1 * projection.m7 + model_view.m2 * projection.m11 +
		model_view.m3 * projection.m15
	plane.m4 = model_view.m4 * projection.m0 + model_view.m5 * projection.m4 + model_view.m6 * projection.m8 +
		model_view.m7 * projection.m12
	plane.m5 = model_view.m4 * projection.m1 + model_view.m5 * projection.m5 + model_view.m6 * projection.m9 +
		model_view.m7 * projection.m13
	plane.m6 = model_view.m4 * projection.m2 + model_view.m5 * projection.m6 + model_view.m6 * projection.m10 +
		model_view.m7 * projection.m14
	plane.m7 = model_view.m4 * projection.m3 + model_view.m5 * projection.m7 + model_view.m6 * projection.m11 +
		model_view.m7 * projection.m15
	plane.m8 = model_view.m8 * projection.m0 + model_view.m9 * projection.m4 + model_view.m10 * projection.m8 +
		model_view.m11 * projection.m12
	plane.m9 = model_view.m8 * projection.m1 + model_view.m9 * projection.m5 + model_view.m10 * projection.m9 +
		model_view.m11 * projection.m13
	plane.m10 = model_view.m8 * projection.m2 + model_view.m9 * projection.m6 + model_view.m10 * projection.m10 +
		model_view.m11 * projection.m14
	plane.m11 = model_view.m8 * projection.m3 + model_view.m9 * projection.m7 + model_view.m10 * projection.m11 +
		model_view.m11 * projection.m15
	plane.m12 = model_view.m12 * projection.m0 + model_view.m13 * projection.m4 + model_view.m14 * projection.m8 +
		model_view.m15 * projection.m12
	plane.m13 = model_view.m12 * projection.m1 + model_view.m13 * projection.m5 + model_view.m14 * projection.m9 +
		model_view.m15 * projection.m13
	plane.m14 = model_view.m12 * projection.m2 + model_view.m13 * projection.m6 + model_view.m14 * projection.m10 +
		model_view.m15 * projection.m14
	plane.m15 = model_view.m12 * projection.m3 + model_view.m13 * projection.m7 + model_view.m14 * projection.m11 +
		model_view.m15 * projection.m15

	-- r. plane.
	self.frustum[5]:set(plane.m3 - plane.m0, plane.m7 - plane.m4, plane.m11 - plane.m8, plane.m15 - plane.m12)
	self.frustum[5]:copy(self.frustum[5]:normalize())

	-- l. plane.
	self.frustum[6]:set(plane.m3 + plane.m0, plane.m7 + plane.m4, plane.m11 + plane.m8, plane.m15 + plane.m12)
	self.frustum[6]:copy(self.frustum[6]:normalize())

	-- t. plane.
	self.frustum[4]:set(plane.m3 - plane.m1, plane.m7 - plane.m5, plane.m11 - plane.m9, plane.m15 - plane.m13)
	self.frustum[4]:copy(self.frustum[4]:normalize())

	-- b. plane.
	self.frustum[3]:set(plane.m3 + plane.m1, plane.m7 + plane.m5, plane.m11 + plane.m9, plane.m15 + plane.m13)
	self.frustum[3]:copy(self.frustum[3]:normalize())

	-- back plane.
	self.frustum[1]:set(plane.m3 - plane.m2, plane.m7 - plane.m6, plane.m11 - plane.m10, plane.m15 - plane.m14)
	self.frustum[1]:copy(self.frustum[1]:normalize())

	-- front plane.
	self.frustum[2]:set(plane.m3 + plane.m2, plane.m7 + plane.m6, plane.m11 + plane.m10, plane.m15 + plane.m14)
	self.frustum[2]:copy(self.frustum[2]:normalize())
end

function scene:distance_to_plane(plane, point)
	return plane.x * point.x + plane.y * point.y + plane.z * point.z + plane.w
end

function scene:point_in_frustum(point)
	for _, plane in ipairs(self.frustum) do
		if self:distance_to_plane(plane, point) <= 0.0 then
			return false
		end
	end

	return true
end

function scene:box_3_in_frustum(shape)
	local point = vector_3:old(0.0, 0.0, 0.0)

	-- if any point is in and we are good
	if (self:point_in_frustum(point:set(shape.min.x, shape.min.y, shape.min.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.min.x, shape.max.y, shape.min.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.max.x, shape.max.y, shape.min.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.max.x, shape.min.y, shape.min.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.min.x, shape.min.y, shape.max.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.min.x, shape.max.y, shape.max.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.max.x, shape.max.y, shape.max.z))) then return true end;
	if (self:point_in_frustum(point:set(shape.max.x, shape.min.y, shape.max.z))) then return true end;

	-- check to see if all points are outside of any one plane, if so the entire box is outside
	for _, plane in ipairs(self.frustum) do
		local oneInside = false;

		if (self:distance_to_plane(plane, point:set(shape.min.x, shape.min.y, shape.min.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.max.x, shape.min.y, shape.min.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.max.x, shape.max.y, shape.min.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.min.x, shape.max.y, shape.min.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.min.x, shape.min.y, shape.max.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.max.x, shape.min.y, shape.max.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.max.x, shape.max.y, shape.max.z)) >= 0) then oneInside = true; end
		if (self:distance_to_plane(plane, point:set(shape.min.x, shape.max.y, shape.max.z)) >= 0) then oneInside = true; end

		if (not oneInside) then
			return false;
		end
	end

	-- the box extends outside the frustum but crosses it
	return true;
end

function scene:begin(call, camera_3d)
	self:get_frustum()
	self.light:begin(call, camera_3d)
end

local LIGHT_MAXIMUM = 4.0

---@class light
light = {}

---Create a new light.
---@param shader shader # The light shader.
---@return light value # The light.
function light:new(shader)
	local i = {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "light"
	i.shader = shader
	i.point_list = {
		light_instance:new(i, 0.0, true),
		light_instance:new(i, 1.0, true),
		light_instance:new(i, 2.0, true),
		light_instance:new(i, 3.0, true)
	}
	i.focus_list = {
		light_instance:new(i, 0.0, false),
		light_instance:new(i, 1.0, false),
		light_instance:new(i, 2.0, false),
		light_instance:new(i, 3.0, false)
	}
	i.point_amount = 0.0
	i.focus_amount = 0.0

	local location = i.shader:get_location_name("base_color")
	i.shader:set_shader_vector_4(location, vector_4:old(1.0, 1.0, 1.0, 1.0))

	local location = i.shader:get_location_name("view_point")
	i.shader:set_location(11, location)

	i.point_amount_location = i.shader:get_location_name("light_point_count")
	i.focus_amount_location = i.shader:get_location_name("light_focus_count")

	return i
end

function light:set_base_color(color)
	local location = self.shader:get_location_name("base_color")
	self.shader:set_shader_vector_4(location, vector_4:old(
		color.r / 255.0,
		color.g / 255.0,
		color.b / 255.0,
		color.a / 255.0
	))
end

function light:begin(call, camera_3d)
	local location = self.shader:get_location(11)
	self.shader:set_shader_vector_3(location, camera_3d.point)
	self.shader:set_shader_integer(self.point_amount_location, self.point_amount)
	self.shader:set_shader_integer(self.focus_amount_location, self.focus_amount)

	if call then
		self.shader:begin(call, camera_3d)
	end

	self.point_amount = 0.0
	self.focus_amount = 0.0
end

function light:light_point(point, color)
	if self.point_amount < LIGHT_MAXIMUM then
		self.point_amount = self.point_amount + 1.0

		self.point_list[self.point_amount]:set_point(self, point)
		self.point_list[self.point_amount]:set_color(self, color)
	end
end

function light:light_focus(point, focus, color)
	if self.focus_amount < LIGHT_MAXIMUM then
		self.focus_amount = self.focus_amount + 1.0

		self.focus_list[self.focus_amount]:set_point(self, point)
		self.focus_list[self.focus_amount]:set_focus(self, focus)
		self.focus_list[self.focus_amount]:set_color(self, color)
	end
end

---@class light_instance
light_instance = {}

---Create a new light instance.
---@return light_instance value # The light_instance.
function light_instance:new(light, index, point)
	local i = {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "light_instance"

	local uniform = point and "light_point" or "light_focus"

	i.point_location = light.shader:get_location_name(uniform .. "[" .. index .. "].point")

	if not point then
		i.focus_location = light.shader:get_location_name(uniform .. "[" .. index .. "].focus")
	end

	i.color_location = light.shader:get_location_name(uniform .. "[" .. index .. "].color")

	return i
end

function light_instance:set_point(light, point)
	light.shader:set_shader_vector_3(self.point_location, point)
end

function light_instance:set_focus(light, focus)
	light.shader:set_shader_vector_3(self.focus_location, focus)
end

function light_instance:set_color(light, color)
	light.shader:set_shader_vector_4(self.color_location, vector_4:old(
		color.r / 255.0,
		color.g / 255.0,
		color.b / 255.0,
		color.a / 255.0
	))
end

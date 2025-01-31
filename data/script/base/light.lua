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

local LIGHT_MAXIMUM = 4.0

---@class light_manager
light_manager = {}

---Create a new light_manager.
---@param shader shader # The light shader.
---@return light_manager value # The light_manager.
function light_manager:new(shader)
	local i = {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "light_manager"
	i.shader = shader
	i.point_list = {
		light:new(i, 0.0, true),
		light:new(i, 1.0, true),
		light:new(i, 2.0, true),
		light:new(i, 3.0, true)
	}
	i.focus_list = {
		light:new(i, 0.0, false),
		light:new(i, 1.0, false),
		light:new(i, 2.0, false),
		light:new(i, 3.0, false)
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

function light_manager:begin(call, camera_3d)
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

function light_manager:light_point(point, color)
	if self.point_amount < LIGHT_MAXIMUM then
		self.point_amount = self.point_amount + 1.0

		self.point_list[self.point_amount]:set_point(self, point)
		self.point_list[self.point_amount]:set_color(self, color)
	end
end

function light_manager:light_focus(point, focus, color)
	if self.focus_amount < LIGHT_MAXIMUM then
		self.focus_amount = self.focus_amount + 1.0

		self.focus_list[self.focus_amount]:set_point(self, point)
		self.focus_list[self.focus_amount]:set_focus(self, focus)
		self.focus_list[self.focus_amount]:set_color(self, color)
	end
end

---@class light
light = {}

---Create a new light.
---@return light value # The light.
function light:new(light_manager, index, point)
	local i = {}
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "light"

	local uniform = point and "light_point" or "light_focus"

	i.point_location = light_manager.shader:get_location_name(uniform .. "[" .. index .. "].point")

	if not point then
		i.focus_location = light_manager.shader:get_location_name(uniform .. "[" .. index .. "].focus")
	end

	i.color_location = light_manager.shader:get_location_name(uniform .. "[" .. index .. "].color")

	return i
end

function light:set_point(light_manager, point)
	light_manager.shader:set_shader_vector_3(self.point_location, point)
end

function light:set_focus(light_manager, focus)
	light_manager.shader:set_shader_vector_3(self.focus_location, focus)
end

function light:set_color(light_manager, color)
	light_manager.shader:set_shader_vector_4(self.color_location, vector_4:old(
		math.floor(color.r / 255.0),
		math.floor(color.g / 255.0),
		math.floor(color.b / 255.0),
		math.floor(color.a / 255.0)
	))
end

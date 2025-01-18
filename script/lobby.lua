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

local ACTION_RETURN = action:new(
	{
		action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.ESCAPE),
		action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.MIDDLE),
		action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_FACE_RIGHT)
	}
)
local ACTION_TOGGLE = action:new(
	{
		action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.ESCAPE),
		action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.MIDDLE_RIGHT)
	}
)
local VIDEO_GLYPH = {
	[0] = "Auto",
	[1] = "PlayStation",
	[2] = "Xbox",
	[3] = "Nintendo",
	[4] = "Steam",
}
---@enum LOBBY_LAYOUT
local LOBBY_LAYOUT = {
	MAIN = 0,
	MISSION = 1,
	HUNTER = 2,
	WEAPON = 3,
	CONFIGURATION = 4,
	EXIT = 5,
}
local LAYOUT_CAMERA_DATA = {
	[LOBBY_LAYOUT.MAIN] = {
		point = vector_3:old(8.0, 2.5, 0.0),
		focus = vector_3:old(0.0, 2.0, 0.0)
	},
	[LOBBY_LAYOUT.MISSION] = {
		point = vector_3:old(8.0, 2.5, 0.0),
		focus = vector_3:old(0.0, 2.0, 0.0)
	},
	[LOBBY_LAYOUT.HUNTER] = {
		point = vector_3:old(8.0, 2.5, 0.0),
		focus = vector_3:old(0.0, 2.0, 0.0)
	},
	[LOBBY_LAYOUT.WEAPON] = {
		point = vector_3:old(8.0, 2.5, 0.0),
		focus = vector_3:old(0.0, 2.0, 0.0)
	},
	[LOBBY_LAYOUT.CONFIGURATION] = {
		point = vector_3:old(8.0, 2.5, 0.0),
		focus = vector_3:old(0.0, 2.0, 0.0)
	},
	[LOBBY_LAYOUT.EXIT] = {
		point = vector_3:old(8.0, 2.5, 0.0),
		focus = vector_3:old(0.0, 2.0, 0.0)
	},
}

--[[----------------------------------------------------------------]]

---@class gizmo
---@field hover number
gizmo = {
	__meta = {}
}

---Create a new gizmo.
---@return gizmo value # The gizmo.
function gizmo:new()
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "gizmo"
	i.hover  = 0.0

	return i
end

---Calculate a shape with animation.
---@param lobby lobby # The lobby.
---@param shape box_2 # The shape.
function gizmo:move(lobby, shape)
	-- move shape horizontally.
	shape.x = shape.x + (self.hover * 8.0)

	return shape
end

function gizmo:fade(lobby, color)
	-- fade in/out from hover.
	color = color * (self.hover * 0.25 + 0.75)

	-- fade in/out from elapse time.
	color.a = math.floor(math.min(1.0, lobby.elapse * 4.0) * 255.0)

	return color
end

--[[----------------------------------------------------------------]]

---@class lobby
---@field active boolean
---@field window window
---@field logger logger
---@field layout LOBBY_LAYOUT
lobby = {
	__meta = {}
}

---Create a new lobby.
---@return lobby value # The lobby.
function lobby:new()
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type    = "lobby"
	i.user      = user:new(i)
	i.system    = file_system:new({
		"asset"
	})
	i.active    = true
	i.camera_3d = camera_3d:new(vector_3:new(4.0, 4.0, 4.0), vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 1.0, 0.0),
		90.0, CAMERA_3D_KIND.PERSPECTIVE)
	i.camera_2d = camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 1.0)

	--[[]]

	i.system:set_font("video/font_side.ttf", 24.0)

	local tex_a = i.system:set_texture("video/map/black/texture_08.png")
	local tex_b = i.system:set_texture("video/map/white/texture_08.png")

	local menu = i.system:set_model("video/menu.glb")
	menu:bind(1.0, 0.0, tex_a)
	menu:bind(2.0, 0.0, tex_b)

	-- over-ride default print function with our own.
	--print           = function(...)
	--	i.logger:print(..., color:new(255.0, 255.0, 255.0, 255.0))
	--end

	i.window        = window:new()
	i.logger        = logger:new()
	i.layout        = LOBBY_LAYOUT.MAIN
	i.ease_point    = vector_3:new(6.00, 2.5, 4.0)
	i.ease_focus    = vector_3:new(-4.0, 1.0, 0.0)
	i.hunter_select = 1.0
	i.weapon_select = { 1.0, 2.0 }
	i.data          = {}
	i.elapse        = 0.0
	i.scroll        = 0.0
	i.scroll_last   = 0.0

	return i
end

local function gizmo_data(self, label, hover, index, focus)
	local delta = quiver.general.get_frame_time()

	if not self.data[label] then
		self.data[label] = gizmo:new()
	end

	local data = self.data[label]

	data.hover = math.clamp(0.0, 1.0,
		data.hover + ((hover or index or focus) and delta * 8.0 or delta * -8.0))

	return data
end

local function gizmo_fade(self, status, color)
end

local function button_call_back(status, window, shape, hover, index, focus, label)
	local gizmo = gizmo_data(status.lobby, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local font = status.lobby.system:get_font("video/font_side.ttf")
	font:draw(string.tokenize(label, "([^|]+)")[1], vector_2:old(shape.x + 4.0, shape.y + 4.0), 24.0, 1.0,
		color)

	if hover or index then
		do end
	end
end

local function lobby_button(status, shape, label, flag)
	return status.lobby.window:button(shape, label, GIZMO_FLAG.CLICK_ON_PRESS, button_call_back, status)
end

local function toggle_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = gizmo_data(status.lobby, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	if value then
		quiver.draw_2d.draw_box_2_round(box_2:old(shape.x + 4.0, shape.y + 4.0, shape.width - 8.0, shape.height - 8.0),
			0.25,
			4.0, color)
	end

	local font = status.lobby.system:get_font("video/font_side.ttf")
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), 24.0, 1.0, color)

	if hover or index then
		do end
	end
end

local function lobby_toggle(status, shape, label, value, flag)
	return status.lobby.window:toggle(shape, label, value, GIZMO_FLAG.CLICK_ON_PRESS, toggle_call_back, status)
end

local function slider_call_back(status, window, shape, hover, index, focus, label, value, percentage)
	local gizmo = gizmo_data(status.lobby, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)
	quiver.draw_2d.draw_box_2_round(
		box_2:old(shape.x + 4.0, shape.y + 4.0, (shape.width - 8.0) * percentage, shape.height - 8.0), 0.25, 4.0,
		color)

	local font = status.lobby.system:get_font("video/font_side.ttf")
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), 24.0, 1.0, color)

	-- measure text.
	local measure = font:measure_text(value, 24.0, 1.0)

	-- draw value.
	font:draw(value, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 4.0),
		24.0,
		1.0,
		color:black())

	if hover or index then
		do end
	end
end

local function lobby_slider(status, shape, label, value, min, max, step, flag)
	return status.lobby.window:slider(shape, label, value, min, max, step, flag, slider_call_back,
		status)
end

local function switch_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = gizmo_data(status.lobby, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local font = status.lobby.system:get_font("video/font_side.ttf")
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), 24.0, 1.0, color)

	-- measure text.
	local measure = font:measure_text(value, 24.0, 1.0)

	-- draw value.
	font:draw(value, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 4.0),
		24.0,
		1.0,
		color:black())

	if hover or index then
		do end
	end
end

local function lobby_switch(status, shape, label, value, pool, flag)
	return status.lobby.window:switch(shape, label, value, pool, GIZMO_FLAG.CLICK_ON_PRESS, switch_call_back,
		status)
end

local function action_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = gizmo_data(status.lobby, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local font = status.lobby.system:get_font("video/font_side.ttf")
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), 24.0, 1.0, color)

	local label = #value.list > 0.0 and "" or "N/A"

	-- for every button in the action's list...
	for i, button in ipairs(value.list) do
		-- concatenate the button's name.
		label = label .. (i > 1.0 and ": " or "")
			.. button:name()
	end

	-- measure text.
	local measure = font:measure_text(label, 24.0, 1.0)

	-- draw value.
	font:draw(label, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 4.0),
		24.0,
		1.0,
		color:black())

	if hover or index then
		do end
	end
end

local function lobby_action(status, shape, label, value, clamp, flag)
	return status.lobby.window:action(shape, label, value, clamp, GIZMO_FLAG.CLICK_ON_PRESS, action_call_back,
		status)
end

local function scroll_call_back(status, window, shape, value, last)
	local height = shape.height * math.min(1.0, shape.height / last)

	--if shape.height > height then
	local color = color:white() * 0.25

	-- fade in/out from elapse time.
	color.a = math.floor(math.min(1.0, status.lobby.elapse * 4.0) * 255.0)

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.05, 4.0, color)

	local view_size = math.min(0.0, shape.height - last) * value


	-- draw border.
	quiver.draw_2d.draw_box_2_round(box_2:old(shape.x + shape.width + 8.0, shape.y, 32.0, shape.height), 0.25, 4.0,
		color)
	quiver.draw_2d.draw_box_2_round(
		box_2:old(shape.x + shape.width + 8.0, shape.y + (shape.height - height) * value, 32.0, height),
		0.25,
		4.0,
		color * 1.5)
	--end
end

local function lobby_scroll(status, shape, value, last, call)
	return status.lobby.window:scroll(shape, value, last, call, scroll_call_back,
		status)
end

---Ease the camera to a given point, and focus.
---@param self   lobby   # The lobby.
---@param status status   # The status.
---@param point  vector_3 # The point to ease to.
---@param focus  vector_3 # The focus to ease to.
local function change_layout(self, layout)
	self.layout = layout
	self.elapse = 0.0
	self.scroll = 0.0
	self.scroll_last = 0.0
	self.window.index = 0.0
end

---Draw a return button header, as well as check for a lobby toggle.
---@param self   lobby   	   # The lobby.
---@param status status   	   # The status.
---@param former LOBBY_LAYOUT # The former lobby layout.
local function header_return(self, status, former)
	-- if button is set off or the return action has been set off...
	if lobby_button(status, box_2:old(8.0, 12.0, 142.0, 32.0), "Return") or ACTION_RETURN:press(self.window.device) then
		-- set the current layout to the former layout.
		change_layout(self, former)
	end
end

---Layout: main.
---@param self   lobby # The lobby.
---@param status status # The status.
local function layout_main(self, status)
	local y = 0.0

	local check, which = ACTION_RETURN:press()

	if which and status.outer then
		local which = ACTION_RETURN.list[which]

		if not (which.button == INPUT_PAD.RIGHT_FACE_RIGHT) then
			self.window:set_device(INPUT_DEVICE.MOUSE)
			quiver.input.mouse.set_hidden(true)
		end

		self.active = false
	end

	if status.inner then
		if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Mission") then
			change_layout(self, LOBBY_LAYOUT.MISSION)
		end; y = y + 1.0
		if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Hunter Cust.") then
			change_layout(self, LOBBY_LAYOUT.HUNTER)
		end; y = y + 1.0
		if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Weapon Cust.") then
			change_layout(self, LOBBY_LAYOUT.WEAPON)
		end; y = y + 1.0
	end

	if not status.inner then
		if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Clock In") then
			inner:new(status)
		end; y = y + 1.0
	end

	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Configuration") then
		change_layout(self, LOBBY_LAYOUT.CONFIGURATION)
	end; y = y + 1.0

	if status.inner then
		if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Clock Out") then
			status.inner = nil
			status.outer = nil
		end; y = y + 1.0
	end

	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 256.0, 32.0), "Exit") then
		change_layout(self, LOBBY_LAYOUT.EXIT)
	end; y = y + 1.0
end

local function equip_collision(equip, equip_list, click_a, click_b)
	while equip[1] == equip[2] do
		if click_b then
			equip[1] = math.roll_over(1.0, #equip_list, equip[1] + 1)
		end
		if click_a then
			equip[2] = math.roll_over(1.0, #equip_list, equip[2] + 1)
		end
	end
end

---Layout: mission.
---@param self   lobby # The lobby.
---@param status status # The status.
local function layout_mission(self, status)
	header_return(self, status, LOBBY_LAYOUT.MAIN)

	local y = 1.0

	local table_hunter = {}
	local table_weapon = {}

	for i, j in ipairs(status.inner.hunter) do table.insert(table_hunter, j.name) end
	for i, j in ipairs(status.inner.weapon) do table.insert(table_weapon, j.name) end

	self.hunter_select = lobby_switch(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Select Hunter",
		self.hunter_select, table_hunter); y = y + 1.0

	local click_a = false
	local click_b = false

	--[[ weapon selection. ]]

	self.weapon_select[1], click_a = lobby_switch(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
		"Select Weapon A",
		self.weapon_select[1], table_weapon); y = y + 1.0

	self.weapon_select[2], click_b = lobby_switch(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
		"Select Weapon B",
		self.weapon_select[2], table_weapon); y = y + 1.0

	-- solve an equipment collision, if any.
	equip_collision(self.weapon_select, status.inner.weapon, click_a, click_b)

	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 192.0, 32.0), "GO!") then
		outer:new(status, "level/test.glb.json")
	end; y = y + 1.0
end

---Layout: hunter.
---@param self   lobby # The lobby.
---@param status status # The status.
local function layout_hunter(self, status)
	header_return(self, status, LOBBY_LAYOUT.MAIN)

	local y = 1.0

	local table_hunter = {}

	for i, j in ipairs(status.inner.hunter) do table.insert(table_hunter, j.name) end

	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Purchase Hunter") then
		table.insert(status.inner.hunter, hunter:new())
	end; y = y + 1.0

	self.hunter_select = lobby_switch(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Select Hunter",
		self.hunter_select, table_hunter); y = y + 1.0

	local _, screen = quiver.window.get_render_shape()

	local font = self.system:get_font("video/font_side.ttf")

	local hunter = status.inner.hunter[self.hunter_select]

	self.scroll, self.scroll_last = lobby_scroll(status,
		box_2:old(8.0, 12.0 + 36.0 * y, 512.0 + 160.0, screen - (12.0 + 36.0 * y) - 64.0),
		self.scroll,
		self.scroll_last, function()
			if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Randomize Name") then
				hunter:randomize_name()
			end; y = y + 1.0

			self.window:text(vector_2:old(8.0, 12.0 + 36.0 * y),
				"Health: " .. hunter.health .. " (" .. hunter.health_maximum .. ")", font, 24.0, 1.0, color:white()); y =
				y + 1.0

			self.window:text(vector_2:old(8.0, 12.0 + 36.0 * y),
				"Walk Rate: " .. hunter.walk_rate, font, 24.0, 1.0, color:white()); y =
				y + 1.0

			self.window:text(vector_2:old(8.0, 12.0 + 36.0 * y),
				"Drop Rate: " .. hunter.drop_rate, font, 24.0, 1.0, color:white()); y =
				y + 1.0

			self.window:text(vector_2:old(8.0, 12.0 + 36.0 * y),
				"Fire Rate: " .. hunter.fire_rate, font, 24.0, 1.0, color:white()); y =
				y + 1.0
		end)
end

local function upgrade_weapon(status, point, field, price, label, font)
	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * point, 144.0, 32.0), "Upgrade|" .. label) then
		if status.inner.credit >= price then
			field = field + 1.0
			status.inner.credit = math.max(0.0, status.inner.credit - price)
		end
	end

	label = label .. ": " .. field

	status.lobby.window:text(vector_2:old(8.0 + 144.0 + 4.0, 16.0 + 36.0 * point), label, font, 24.0, 1.0, color:white())

	return field, point + 1.0
end

---Layout: weapon.
---@param self   lobby # The lobby.
---@param status status # The status.
local function layout_weapon(self, status)
	header_return(self, status, LOBBY_LAYOUT.MAIN)

	local y = 1.0

	local table_weapon = {}

	for i, j in ipairs(status.inner.weapon) do table.insert(table_weapon, j.name) end

	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Purchase Weapon") then
		table.insert(status.inner.weapon, weapon:new())
	end; y = y + 1.0

	self.weapon_select[1] = lobby_switch(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Select Weapon",
		self.weapon_select[1], table_weapon); y = y + 1.0

	-- solve an equipment collision, if any.
	equip_collision(self.weapon_select, status.inner.weapon, true, false)

	local _, screen = quiver.window.get_render_shape()

	local font = self.system:get_font("video/font_side.ttf")

	local weapon = status.inner.weapon[self.weapon_select[1]]

	status.lobby.window:text(vector_2:old(256.0, 8.0), "Credit: " .. status.inner.credit, font,
		24.0, 1.0,
		color:white())

	self.scroll, self.scroll_last = lobby_scroll(status,
		box_2:old(8.0, 12.0 + 36.0 * y, 512.0 + 160.0, screen - (12.0 + 36.0 * y) - 64.0),
		self.scroll,
		self.scroll_last, function()
			if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Randomize Name") then
				weapon:randomize_name()
			end; y = y + 1.0

			weapon.ammo_maximum, y = upgrade_weapon(status, y, weapon.ammo_maximum, 25.0, "Maximum Ammo",
				font)

			weapon.miss_rate, y = upgrade_weapon(status, y, weapon.miss_rate, 25.0, "Spread",
				font)

			weapon.fire_rate, y = upgrade_weapon(status, y, weapon.fire_rate, 25.0, "Rate of Fire",
				font)
		end)
end

---Layout: configuration.
---@param self   lobby # The lobby.
---@param status status # The status.
local function layout_configuration(self, status)
	header_return(self, status, LOBBY_LAYOUT.MAIN)

	local y = 0.0

	if lobby_button(status, box_2:old(8.0 + 146.0 * 1.0, 12.0 + 36.0 * y, 142.0, 32.0), "Default") then
		self.user = user:default(status)
	end; y = y + 1.0

	local _, screen = quiver.window.get_render_shape()

	local font = self.system:get_font("video/font_side.ttf")

	self.scroll, self.scroll_last = lobby_scroll(status,
		box_2:old(8.0, 12.0 + 36.0 * y, 512.0 + 160.0, screen - (12.0 + 36.0 * y) - 64.0),
		self.scroll,
		self.scroll_last, function()
			local click = false

			self.window:text(vector_2:old(16.0, 12.0 + 36.0 * y), "Video", font, 24.0, 1.0, color:white()); y = y + 0.75

			self.user.video_full, click = lobby_toggle(status, box_2:old(8.0, 12.0 + 36.0 * y, 32.0, 32.0), "Full-Screen",
				self.user.video_full); y = y + 1.0

			if click then
				self.user:apply(status)
			end

			self.user.video_frame, click = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
				"Frame Rate",
				self.user.video_frame, 30.0, 300.0, 1.0); y = y + 1.0

			if click then
				self.user:apply(status)
			end

			self.user.video_shake = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "View Shake",
				self.user.video_shake, 0.0, 4.0, 0.1); y = y + 1.0

			self.user.video_light = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Brightness",
				self.user.video_light, 0.0, 4.0, 0.1); y = y + 1.0

			self.user.video_gamma = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Gamma",
				self.user.video_gamma, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.video_glyph = lobby_switch(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Glyph Type",
				self.user.video_glyph, VIDEO_GLYPH); y = y + 1.0

			self.window:text(vector_2:old(16.0, 12.0 + 36.0 * y), "Audio", font, 24.0, 1.0, color:white()); y = y + 0.75

			self.user.audio_sound = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Sound Volume",
				self.user.audio_sound, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.audio_music = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Music Volume",
				self.user.audio_music, 0.0, 1.0, 0.05); y = y + 1.0

			self.window:text(vector_2:old(16.0, 12.0 + 36.0 * y), "Input", font, 24.0, 1.0, color:white()); y = y + 0.75

			self.user.input_pad_look = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
				"Pad Stick Behavior",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_look = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
				"Pad Stick Dead Zone (X)",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_look = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
				"Pad Stick Dead Zone (Y)",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_look = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0),
				"Pad Look Range",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_assist = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Pad Assist",
				self.user.input_pad_assist, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_rumble = lobby_slider(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Pad Rumble",
				self.user.input_pad_rumble, 1.0, 4.0, 0.1); y = y + 1.0

			lobby_action(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Move X+", self.user.input_move_x_a, 3.0)
			y = y + 1.0

			lobby_action(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Move X-", self.user.input_move_x_b, 3.0)
			y = y + 1.0

			lobby_action(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Move Y-", self.user.input_move_y_a, 3.0)
			y = y + 1.0

			lobby_action(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Move Y+", self.user.input_move_y_b, 3.0)
			y = y + 1.0

			lobby_action(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Weapon A", self.user.input_weapon_a, 3.0)
			y = y + 1.0

			lobby_action(status, box_2:old(8.0, 12.0 + 36.0 * y, 288.0, 32.0), "Weapon B", self.user.input_weapon_b, 3.0)
			y = y + 1.0
		end)
end

---Layout: exit.
---@param self   lobby # The lobby.
---@param status status # The status.
local function layout_exit(self, status)
	header_return(self, status, LOBBY_LAYOUT.MAIN)

	if lobby_button(status, box_2:old(8.0, 12.0 + 36.0 * 1.0, 142.0, 32.0), "Accept") then
		status.active = false
	end
end

---Draw the lobby.
---@param status status # The game status.
function lobby:draw(status)
	local delta = quiver.general.get_frame_time()

	-- update time in current layout.
	self.elapse = self.elapse + delta

	--[[]]

	-- draw 3D view.
	quiver.draw_3d.begin(function()
		local point = LAYOUT_CAMERA_DATA[self.layout].point
		local focus = LAYOUT_CAMERA_DATA[self.layout].focus

		--self.ease_point:copy(self.ease_point + (point - self.camera_3d.point) * delta * 1.0)
		--self.ease_focus:copy(self.ease_focus + (focus - self.camera_3d.focus) * delta * 1.0)

		-- update the camera.
		self.camera_3d.point:copy(self.ease_point)
		self.camera_3d.focus:copy(self.ease_focus)
		self.camera_3d.zoom = 45.0

		local model = self.system:get_model("video/menu.glb")
		model:draw(vector_3:zero(), 1.0, color:white())
	end, self.camera_3d)

	--[[]]

	-- draw 2D view.
	quiver.draw_2d.begin(function()
		self.window:begin()

		-- draw a gradient.
		local x, y = quiver.window.get_shape()
		quiver.draw_2d.draw_box_2_gradient(box_2:old(0.0, 0.0, x * 0.5, y),
			color:old(0.0, 0.0, 0.0, 160.0),
			color:old(0.0, 0.0, 0.0, 160.0),
			color:old(0.0, 0.0, 0.0, 0.0),
			color:old(0.0, 0.0, 0.0, 0.0)
		)

		-- select a layout to draw.
		if self.layout == LOBBY_LAYOUT.MAIN then
			layout_main(self, status)
		elseif self.layout == LOBBY_LAYOUT.MISSION then
			layout_mission(self, status)
		elseif self.layout == LOBBY_LAYOUT.HUNTER then
			layout_hunter(self, status)
		elseif self.layout == LOBBY_LAYOUT.WEAPON then
			layout_weapon(self, status)
		elseif self.layout == LOBBY_LAYOUT.CONFIGURATION then
			layout_configuration(self, status)
		elseif self.layout == LOBBY_LAYOUT.EXIT then
			layout_exit(self, status)
		end

		-- draw logger.
		self.logger:draw(self.window)

		self.window:close(not self.active)
	end, self.camera_2d)
end

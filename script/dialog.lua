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
local VIDEO_MENU = {
	[0] = "Auto",
	[1] = "0.25x",
	[2] = "0.50x",
	[3] = "0.75x",
	[4] = "1.00x",
	[5] = "1.25x",
	[6] = "1.50x",
	[7] = "1.75x",
	[8] = "2.00x",
}
local VIDEO_GLYPH = {
	[0] = "Auto",
	[1] = "PlayStation",
	[2] = "Xbox",
	[3] = "Nintendo",
	[4] = "Steam",
}
---@enum dialog_layout
local DIALOG_LAYOUT = {
	MAIN = 0,
	MISSION = 1,
	HUNTER = 2,
	WEAPON = 3,
	ABILITY = 4,
	ITEM = 5,
	CONFIGURATION = 6,
	EDITOR = 7,
	EXIT = 8,
}

--[[----------------------------------------------------------------]]

---@class dialog
---@field active boolean
---@field window window
---@field logger logger
---@field layout dialog_layout
dialog = {
	__meta = {}
}

---Create a new dialog.
---@return dialog value # The dialog.
function dialog:new()
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type     = "dialog"
	i.active     = true
	i.editor     = editor:new()
	i.window     = window:new()
	i.logger     = logger:new()
	i.layout     = DIALOG_LAYOUT.MAIN
	i.ease_point = vector_3:new(6.00, 2.5, 4.0)
	i.ease_focus = vector_3:new(-4.0, 1.0, 0.0)
	i.hunter     = 1.0
	i.weapon     = { 1.0, 2.0 }
	i.ability    = { 1.0, 2.0 }
	i.item       = { nil, nil }

	return i
end

---Draw a return button header, as well as check for a dialog toggle.
---@param self   dialog   	   # The dialog.
---@param status status   	   # The status.
---@param former dialog_layout # The former dialog layout.
local function header_return(self, status, former)
	-- if button is set off or the return action has been set off...
	if self.window:button(box_2:old(8.0, 8.0, 142.0, 32.0), "Return") or ACTION_RETURN:press(self.window.device) then
		-- set the current layout to the former layout.
		self.layout = former
	end
end

---Ease the camera to a given point, and focus.
---@param self   dialog   # The dialog.
---@param status status   # The status.
---@param point  vector_3 # The point to ease to.
---@param focus  vector_3 # The focus to ease to.
local function camera_ease(self, status, point, focus)
	local delta = quiver.general.get_frame_time()

	self.ease_point:copy(self.ease_point + (point - status.camera_3d.point) * delta * 8.0)
	self.ease_focus:copy(self.ease_focus + (focus - status.camera_3d.focus) * delta * 8.0)
end

local function call_back(self, window, shape, hover, index, focus, label)
	-- draw border.
	quiver.draw_2d.draw_box_2_border(shape, focus)
end

---Layout: main.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_main(self, status)
	local y = 0.0

	local check, which = ACTION_RETURN:press()

	if which and status.map then
		local which = ACTION_RETURN.list[which]

		if not (which.button == INPUT_PAD.RIGHT_FACE_RIGHT) then
			self.window:set_device(INPUT_DEVICE.MOUSE)
			quiver.input.mouse.set_hidden(true)
		end

		self.active = false
	end

	if not status.map then
		if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Mission", nil, call_back) then
			self.layout = DIALOG_LAYOUT.MISSION
			self.window.index = 0.0
		end; y = y + 1.0
		if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Hunter Cust.") then
			self.layout = DIALOG_LAYOUT.HUNTER
			self.window.index = 0.0
		end; y = y + 1.0
		if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Weapon Cust.") then
			self.layout = DIALOG_LAYOUT.WEAPON
			self.window.index = 0.0
		end; y = y + 1.0
		if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Ability Cust.") then
			self.layout = DIALOG_LAYOUT.ABILITY
			self.window.index = 0.0
		end; y = y + 1.0
		if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Item Store") then
			self.layout = DIALOG_LAYOUT.ITEM
			self.window.index = 0.0
		end; y = y + 1.0
	end

	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Configuration") then
		self.layout = DIALOG_LAYOUT.CONFIGURATION
		self.window.index = 0.0
	end; y = y + 1.0
	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Editor") then
		self.layout = DIALOG_LAYOUT.EDITOR
		self.window.index = 0.0

		-- update the camera.
		status.camera_3d.point = vector_3:new(0.0, 4.0, 0.0)
		status.camera_3d.angle = vector_3:new(0.0, 0.0, -1.0)
		status.camera_3d.focus = vector_3:new(0.0, 0.0, 0.00)
		status.camera_3d.zoom = 90.0
		status.camera_3d.kind = 1.0
	end; y = y + 1.0
	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "Exit") then
		self.layout = DIALOG_LAYOUT.EXIT
		self.window.index = 0.0
	end; y = y + 1.0

	camera_ease(self, status, vector_3:old(8.0, 2.5, 0.0), vector_3:old(0.0, 2.0, 0.0))
	--camera_ease(self, status, vector_3:one() * 16.0, vector_3:zero())
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
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_mission(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	local y = 1.0

	local table_hunter = {}
	local table_weapon = {}
	local table_ability = {}
	local table_item = {}

	for i, j in ipairs(status.hunter) do table.insert(table_hunter, "Hunter #" .. i) end
	for i, j in ipairs(status.weapon) do table.insert(table_weapon, "Weapon #" .. i) end
	for i, j in ipairs(status.ability) do table.insert(table_ability, "Ability #" .. i) end
	for i, j in ipairs(status.item) do table.insert(table_item, j.name) end

	self.hunter = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Select Hunter",
		self.hunter, table_hunter); y = y + 1.0

	local click_a = false
	local click_b = false

	--[[ weapon selection. ]]

	self.weapon[1], click_a = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Select Weapon A",
		self.weapon[1], table_weapon); y = y + 1.0

	self.weapon[2], click_b = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Select Weapon B",
		self.weapon[2], table_weapon); y = y + 1.0

	-- solve an equipment collision, if any.
	equip_collision(self.weapon, status.weapon, click_a, click_b)

	--[[ ability selection. ]]

	self.ability[1], click_a = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Select Ability A",
		self.ability[1], table_ability); y = y + 1.0

	self.ability[2], click_b = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Select Ability B",
		self.ability[2], table_ability); y = y + 1.0

	-- solve an equipment collision, if any.
	equip_collision(self.ability, status.ability, click_a, click_b)

	--[[ item selection. ]]

	if not self.item[1] and #status.item > 0.0 then
		self.item[1] = 1.0
	end

	if not self.item[2] and #status.item > 1.0 then
		self.item[2] = 2.0
	end

	if self.item[1] then
		self.item[1], click_a = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0),
			"Select Item A",
			self.item[1], table_item); y = y + 1.0
	end

	if self.item[2] then
		self.item[2], click_b = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0),
			"Select Item B",
			self.item[2], table_item); y = y + 1.0
	end

	if self.item[1] and self.item[2] then
		-- solve an equipment collision, if any.
		equip_collision(self.item, status.item, click_a, click_b)
	end

	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 192.0, 32.0), "GO!") then
		status:initialize_map("video/test.glb")
	end; y = y + 1.0

	camera_ease(self, status, vector_3:old(-2.0, 1.5, 0.0), vector_3:old(-8.0, 1.5, 0.0))
end

---Layout: hunter.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_hunter(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	camera_ease(self, status, vector_3:old(0.0, 2.0, 0.0), vector_3:old(0.0, 2.0, 2.0))
end

---Layout: weapon.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_weapon(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	camera_ease(self, status, vector_3:old(4.0, 3.0, 0.0), vector_3:old(0.0, 1.0, 0.0))
end

---Layout: ability.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_ability(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	camera_ease(self, status, vector_3:old(0.0, 2.0, 0.0), vector_3:old(0.0, 2.0, -2.0))
end

---Layout: item.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_item(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	local y = 1.0

	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 264.0, 32.0), "Buy Heal Item ($50)") then
		if status.credit >= 50.0 then
			table.insert(status.item, item:new(status, "Heal Item"))
			status.credit = status.credit - 50.0
		end
	end; y = y + 1.0

	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * y, 264.0, 32.0), "Buy Ammo Item ($25)") then
		if status.credit >= 25.0 then
			table.insert(status.item, item:new(status, "Ammo Item"))
			status.credit = status.credit - 25.0
		end
	end; y = y + 1.0

	LOGGER_FONT:draw("Credit: " .. status.credit, vector_2:old(8.0 + 256.0, 8.0), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
		color:white())

	camera_ease(self, status, vector_3:old(-3.0, 2.0, -2.85), vector_3:old(-5.0, 1.5, -2.85))
end

---Layout: configuration.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_configuration(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	local y = 0.0

	if self.window:button(box_2:old(8.0 + 146.0 * 1.0, 8.0 + 36.0 * y, 142.0, 32.0), "Default") then
		status.user = user:default(status)
	end; y = y + 1.0

	local click = false

	--[[ video section. ]]
	status.user.video_full, click = self.window:toggle(box_2:old(8.0, 8.0 + 36.0 * y, 32.0, 32.0), "Full-Screen",
		status.user.video_full); y = y + 1.0

	if click then
		status.user:apply(status)
	end

	status.user.video_frame, click = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Frame Rate",
		status.user.video_frame, 30.0, 300.0, 1.0); y = y + 1.0

	if click then
		status.user:apply(status)
	end

	status.user.video_shake = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "View Shake",
		status.user.video_shake, 0.0, 4.0, 0.1); y = y + 1.0

	status.user.video_view = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "View Scale",
		status.user.video_view, 0.1, 1.0, 0.05); y = y + 1.0

	status.user.video_menu, click = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Menu Scale",
		status.user.video_menu, VIDEO_MENU); y = y + 1.0

	if click then
		status.user:apply(status)
	end

	status.user.video_light = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Brightness",
		status.user.video_light, 0.0, 4.0, 0.1); y = y + 1.0

	status.user.video_gamma = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Gamma",
		status.user.video_gamma, 1.0, 4.0, 0.1); y = y + 1.0

	status.user.video_cross = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Crosshair",
		status.user.video_cross, 1.0, 4.0, 0.1); y = y + 1.0

	status.user.video_language = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Language",
		status.user.video_language, 1.0, 4.0, 0.1); y = y + 1.0

	status.user.video_glyph = self.window:switch(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Glyph Type",
		status.user.video_glyph, VIDEO_GLYPH); y = y + 1.0

	--[[ video section. ]]
	status.user.audio_sound = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Sound Volume",
		status.user.audio_sound, 0.0, 1.0, 0.05); y = y + 1.0

	status.user.audio_music = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Music Volume",
		status.user.audio_music, 0.0, 1.0, 0.05); y = y + 1.0

	--[[ input section. ]]
	status.user.input_pad_look = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Pad Look Range",
		status.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

	status.user.input_pad_assist = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Pad Assist",
		status.user.input_pad_assist, 1.0, 4.0, 0.1); y = y + 1.0

	status.user.input_pad_rumble = self.window:slider(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Pad Rumble",
		status.user.input_pad_rumble, 1.0, 4.0, 0.1); y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Move X+", status.user.input_move_x_a, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Move X-", status.user.input_move_x_b, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Move Y-", status.user.input_move_y_a, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Move Y+", status.user.input_move_y_b, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Weapon A", status.user.input_weapon_a, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Weapon B", status.user.input_weapon_b, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Ability A", status.user.input_ability_a, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Ability B", status.user.input_ability_b, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Item A", status.user.input_item_a, 3.0)
	y = y + 1.0

	self.window:action(box_2:old(8.0, 8.0 + 36.0 * y, 288.0, 32.0), "Item B", status.user.input_item_b, 3.0)
	y = y + 1.0

	camera_ease(self, status, vector_3:old(-3.0, 2.0, 3.5), vector_3:old(-5.0, 1.0, 2.75))
end

---Layout: exit.
---@param self   dialog # The dialog.
---@param status status # The status.
local function layout_exit(self, status)
	header_return(self, status, DIALOG_LAYOUT.MAIN)

	if self.window:button(box_2:old(8.0, 8.0 + 36.0 * 1.0, 142.0, 32.0), "Accept") then
		status.active = false
	end

	camera_ease(self, status, vector_3:old(8.0, 2.5, 0.0), vector_3:old(0.0, 2.0, 0.0))
end

---Draw the dialog.
---@param status status # The game status.
function dialog:draw_3d(status)
	if self.layout == DIALOG_LAYOUT.EDITOR then
		self.editor:draw_3d(status)
	else
		-- update the camera.
		status.camera_3d.point:copy(self.ease_point)
		status.camera_3d.focus:copy(self.ease_focus)
		status.camera_3d.zoom = 45.0

		local model = status.system:get_model("video/menu.gltf")
		model:draw(vector_3:zero(), 1.0, color:white())

		-- hunter
		local point = vector_3:old(0.0, 0.0, 4.0)
		quiver.draw_3d.draw_box_3(box_3:old(point - vector_3:old(2.25, 0.0, 0.5), point + vector_3:old(2.25, 1.5, 1.0)),
			color:red())

		-- weapon
		local point = vector_3:old(0.0, 0.0, 0.0)
		quiver.draw_3d.draw_box_3(box_3:old(point - vector_3:old(2.25, 0.0, 1.0), point + vector_3:old(2.25, 1.25, 1.0)),
			color:red())

		-- ability
		local point = vector_3:old(0.0, 0.0, -4.0)
		quiver.draw_3d.draw_box_3(box_3:old(point - vector_3:old(2.25, 0.0, 1.0), point + vector_3:old(2.25, 1.5, 0.5)),
			color:red())

		-- configuration
		local point = vector_3:old(-5.0, 0.0, 3.0)
		quiver.draw_3d.draw_box_3(box_3:old(point - vector_3:old(1.0, 0.0, 1.0), point + vector_3:old(1.0, 2.5, 1.0)),
			color:red())

		-- mission
		local point = vector_3:old(-6.0, 0.0, 0.0)
		quiver.draw_3d.draw_box_3(box_3:old(point - vector_3:old(0.0, 0.0, 2.0), point + vector_3:old(0.5, 2.5, 2.0)),
			color:red())


		-- configuration
		local point = vector_3:old(-5.0, 0.0, -3.0)
		quiver.draw_3d.draw_box_3(box_3:old(point - vector_3:old(1.0, 0.0, 1.0), point + vector_3:old(1.0, 2.5, 1.0)),
			color:red())
	end
end

---Draw the dialog.
---@param status status # The game status.
function dialog:draw_2d(status)
	-- store current state, before any input.
	local former = self.active

	self.window:begin()

	if self.active then
		-- draw a gradient.
		local x, y = quiver.window.get_shape()
		quiver.draw_2d.draw_box_2_gradient(box_2:old(0.0, 0.0, 320.0, y),
			color:old(0.0, 0.0, 0.0, 160.0),
			color:old(0.0, 0.0, 0.0, 160.0),
			color:old(0.0, 0.0, 0.0, 0.0),
			color:old(0.0, 0.0, 0.0, 0.0)
		)

		-- layout draw block.
		if self.layout == DIALOG_LAYOUT.MAIN then
			layout_main(self, status)
		elseif self.layout == DIALOG_LAYOUT.MISSION then
			layout_mission(self, status)
		elseif self.layout == DIALOG_LAYOUT.HUNTER then
			layout_hunter(self, status)
		elseif self.layout == DIALOG_LAYOUT.WEAPON then
			layout_weapon(self, status)
		elseif self.layout == DIALOG_LAYOUT.ABILITY then
			layout_ability(self, status)
		elseif self.layout == DIALOG_LAYOUT.ITEM then
			layout_item(self, status)
		elseif self.layout == DIALOG_LAYOUT.CONFIGURATION then
			layout_configuration(self, status)
		elseif self.layout == DIALOG_LAYOUT.EDITOR then
			self.editor:draw_2d(status)
		elseif self.layout == DIALOG_LAYOUT.EXIT then
			layout_exit(self, status)
		end
	end

	self.logger:draw(self.window)

	self.window:close(not self.active)

	-- check if the dialog toggle button has been set off.
	local _, which = ACTION_TOGGLE:press()

	-- if it has, and if our former dialog state is off...
	if which and not former then
		-- get the actual button.
		local which = ACTION_TOGGLE.list[which]

		-- if the toggle actuator came from the board...
		if which.button == INPUT_BOARD.ESCAPE then
			-- set the new device to be the mouse.
			self.window:set_device(INPUT_DEVICE.MOUSE)
		end

		-- toggle dialog state on.
		self.active = true
	end
end

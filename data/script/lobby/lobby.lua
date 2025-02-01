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


local WINDOW_POINT = vector_2:new(8.0, 64.0)
local ACTION_RETURN = action:new(
	{
		action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.ESCAPE),
		action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.MIDDLE),
		action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_FACE_RIGHT)
	}
)
---@enum VIDEO_GLYPH
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
	EDITOR = 5,
	EXIT = 6,
}
local LOBBY_LAYOUT_CAMERA = {
	[LOBBY_LAYOUT.MAIN] = {
		point = vector_3:new(8.0, 2.0, 0.0),
		focus = vector_3:new(0.0, 2.0, 0.0)
	},
	[LOBBY_LAYOUT.MISSION] = {
		point = vector_3:new(-2.0, 1.5, 0.0),
		focus = vector_3:new(-4.0, 1.5, 0.0)
	},
	[LOBBY_LAYOUT.HUNTER] = {
		point = vector_3:new(0.0, 2.5, 0.0),
		focus = vector_3:new(0.0, 2.0, 4.0)
	},
	[LOBBY_LAYOUT.WEAPON] = {
		point = vector_3:new(0.0, 3.0, 2.0),
		focus = vector_3:new(0.0, 1.0, 0.0)
	},
	[LOBBY_LAYOUT.CONFIGURATION] = {
		point = vector_3:new(-2.0, 1.50, 1.0),
		focus = vector_3:new(-4.0, 1.10, 2.0)
	},
	[LOBBY_LAYOUT.EXIT] = {
		point = vector_3:new(8.0, 2.5, 0.0),
		focus = vector_3:new(0.0, 2.0, 0.0)
	},
}

---@class lobby
---@field active    	boolean
---@field editor    	editor
---@field window    	window
---@field user      	user
---@field camera_3d 	camera_3d
---@field camera_2d 	camera_2d
---@field layout 		LOBBY_LAYOUT
---@field ease_point 	vector_3
---@field ease_focus 	vector_3
---@field select_hunter number
---@field select_weapon table
---@field data 			table
---@field time 			number
---@field scroll_value 	number
---@field scroll_frame 	number
lobby = {
	__meta = {}
}

---Create a new lobby.
---@return lobby value # The lobby.
function lobby:new(status)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type        = "lobby"
	i.scene         = scene:new(status.system:get_shader("light"))
	i.active        = true
	i.editor        = editor:new(status)
	i.window        = window:new()
	i.user          = user:new(status)
	i.layout        = LOBBY_LAYOUT.MAIN
	-- to-do fix snap.
	i.ease_point    = vector_3:new(6.00, 2.5, 4.0)
	i.ease_focus    = vector_3:new(-4.0, 1.0, 0.0)
	i.select_hunter = 1.0
	i.select_weapon = { 1.0, 2.0 }
	i.reel          = true
	i.data          = {}
	i.time          = 0.0
	i.scroll_value  = 0.0
	i.scroll_frame  = 0.0

	-- load model.
	status.system:set_model("video/menu.glb"):bind_shader(1.0, i.scene.light.shader)

	-- load sound.
	status.system:set_sound("audio/interface/hover.ogg")
	status.system:set_sound("audio/interface/click.ogg")

	-- load font.
	status.system:set_font("video/font_main.ttf", false, 48.0)
	status.system:set_font("video/font_side.ttf", false, 24.0)

	-- load texture.
	status.system:set_texture("video/logo_a.png")
	status.system:set_texture("video/logo_b.png")
	status.system:set_texture("video/logo_c.png")

	status.system:set_shader("grain", "video/shader/base.vs", "video/shader/grain.fs")

	i.scene.camera_3d.zoom = 45.0

	-- collect garbage.
	collectgarbage("collect")

	return i
end

local REEL_TIME = 22.5


---Draw the lobby.
---@param status status # The game status.
function lobby:draw(status)
	--local shape = vector_2:old(quiver.window.get_shape())
	--self.scene.camera_2d.zoom = math.clamp(0.25, 4.0, math.snap(0.25, shape.y / 640.0))

	--if quiver.window.get_resize() then
	--	quiver.input.mouse.set_scale(vector_2:old(1.0 / self.scene.camera_2d.zoom, 1.0 / self.scene.camera_2d.zoom))
	--end

	local delta = quiver.general.get_frame_time()

	-- update time in current layout.
	self.time = self.time + delta

	if self.time < REEL_TIME and self.reel and self.user.video_reel and not ACTION_RETURN:press() then
		-- draw 2D view.
		status.render:begin(function()
			quiver.draw.clear(color:black())
			quiver.draw_2d.begin(function() self:layout_reel(status) end, self.scene.camera_2d)
		end)

		local shader = status.system:get_shader("grain")
		shader:set_shader_decimal(shader:get_location_name("time"), quiver.general.get_time())

		-- begin screen-space shader.
		shader:begin(function()
			local x, y = quiver.window.get_shape()
			local render = box_2:old(0.0, 0.0, status.render.shape_x, -status.render.shape_y)
			local window = box_2:old(0.0, 0.0, x, y)

			-- draw 3D view, as render-texture.
			status.render:draw_pro(render, window, vector_2:zero(), 0.0, color:white())
		end)
		return
	else
		self.reel = false
	end

	-- if current layout is editor...
	if self.layout == LOBBY_LAYOUT.EDITOR then
		-- draw editor.
		self.editor:draw(status)
		return
	end

	-- begin render-texture.
	status.render:begin(function()
		quiver.draw.clear(color:white())

		-- draw 3D view.
		quiver.draw_3d.begin(function()
			self.scene.light:begin(nil, self.scene.camera_3d)

			--status.light:static_light(vector_3:old(0.0, 2.0, 4.0), vector_3:zero(), color:red())

			quiver.draw_3d.draw_cube(vector_3:zero(), vector_3:one(), color:red())

			-- get point and focus for the current layout.
			local point = LOBBY_LAYOUT_CAMERA[self.layout].point
			local focus = LOBBY_LAYOUT_CAMERA[self.layout].focus

			-- interpolate to ease point/focus.
			self.ease_point:copy(self.ease_point + (point - self.scene.camera_3d.point) * delta * 8.0)
			self.ease_focus:copy(self.ease_focus + (focus - self.scene.camera_3d.focus) * delta * 8.0)

			-- update camera.
			self.scene.camera_3d.point:copy(self.ease_point)
			self.scene.camera_3d.focus:copy(self.ease_focus)

			-- draw menu model.
			local model = status.system:get_model("video/menu.glb")
			model:draw(vector_3:zero(), 1.0, color:white())

			-- inner-state is available; draw current hunter, and weapon A/B.
			if status.inner then
				local hunter = status.inner.hunter[self.select_hunter]
				local weapon_a = status.inner.weapon[self.select_weapon[1]]
				local weapon_b = status.inner.weapon[self.select_weapon[2]]

				-- draw hunter, weapon.
				--hunter:draw_lobby(status)
				weapon_a:draw_lobby(status, 0.0)
				weapon_b:draw_lobby(status, 1.0)
			end
		end, self.scene.camera_3d)
	end)

	-- begin screen-space shader.
	local shader = status.system:get_shader("base")
	shader:begin(function()
		local x, y = quiver.window.get_shape()
		local render = box_2:old(0.0, 0.0, status.render.shape_x, -status.render.shape_y)
		local window = box_2:old(0.0, 0.0, x, y)

		-- draw 3D view, as render-texture.
		status.render:draw_pro(render, window, vector_2:zero(), 0.0, color:white())
	end)

	-- draw 2D view.
	quiver.draw_2d.begin(function()
		-- begin window.
		self.window:begin()

		-- select a layout to draw.
		if self.layout == LOBBY_LAYOUT.MAIN then
			self:layout_main(status)
		elseif self.layout == LOBBY_LAYOUT.MISSION then
			self:layout_mission(status)
		elseif self.layout == LOBBY_LAYOUT.HUNTER then
			self:layout_hunter(status)
		elseif self.layout == LOBBY_LAYOUT.WEAPON then
			self:layout_weapon(status)
		elseif self.layout == LOBBY_LAYOUT.CONFIGURATION then
			self:layout_configuration(status)
		elseif self.layout == LOBBY_LAYOUT.EXIT then
			self:layout_exit(status)
		end

		-- close window.
		self.window:close(not self.active)
	end, self.scene.camera_2d)
end

--[[----------------------------------------------------------------]]

---Layout: reel.
---@param status status # The status.
function lobby:layout_reel(status)
	local shape        = vector_2:old(quiver.window.get_shape()) * 0.5

	local logo_a_color = math.bell_curve_clamp(math.percentage_from_value((REEL_TIME / 3.0) * 0.0,
		(REEL_TIME / 3.0) * 1.0, self.time))
	local logo_b_color = math.bell_curve_clamp(math.percentage_from_value((REEL_TIME / 3.0) * 1.0,
		(REEL_TIME / 3.0) * 2.0, self.time))
	local logo_c_color = math.bell_curve_clamp(math.percentage_from_value((REEL_TIME / 3.0) * 2.0,
		(REEL_TIME / 3.0) * 3.0, self.time))
	logo_a_color       = color:old(255.0, 255.0, 255.0, math.floor(logo_a_color * 255.0))
	logo_b_color       = color:old(255.0, 255.0, 255.0, math.floor(logo_b_color * 255.0))
	logo_c_color       = color:old(255.0, 255.0, 255.0, math.floor(logo_c_color * 255.0))

	local logo_a       = status.system:get_texture("video/logo_a.png")
	local logo_b       = status.system:get_texture("video/logo_b.png")
	local logo_c       = status.system:get_texture("video/logo_c.png")
	local logo_a_point = vector_2:old(shape.x - logo_a.shape_x * 0.5, shape.y - logo_a.shape_y * 0.5) * 0.5
	local logo_b_point = vector_2:old(shape.x - logo_b.shape_x * 0.5, shape.y - logo_b.shape_y * 0.5) * 0.5
	local logo_c_point = vector_2:old(shape.x - logo_c.shape_x * 0.5, shape.y - logo_c.shape_y * 0.5) * 0.5

	logo_a:draw(logo_a_point, 0.0, 0.5, logo_a_color)
	logo_b:draw(logo_b_point, 0.0, 0.5, logo_b_color)
	logo_c:draw(logo_c_point, 0.0, 0.5, logo_c_color)
end

---Layout: main.
---@param status status # The status.
function lobby:layout_main(status)
	self:header_label(status, "Main Menu")

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
		if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Mission") then
			self:layout_change(LOBBY_LAYOUT.MISSION)
		end; y = y + 1.0
		if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Hunter Customization") then
			self:layout_change(LOBBY_LAYOUT.HUNTER)
		end; y = y + 1.0
		if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Weapon Customization") then
			self:layout_change(LOBBY_LAYOUT.WEAPON)
		end; y = y + 1.0
	end

	if not status.inner then
		if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Clock In") then
			inner:new(status)
			self:layout_change(LOBBY_LAYOUT.MAIN)
		end; y = y + 1.0
	end

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Configuration") then
		self:layout_change(LOBBY_LAYOUT.CONFIGURATION)
	end; y = y + 1.0

	if status.inner then
		if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Clock Out") then
			status.inner = nil
			status.outer = nil
			self:layout_change(LOBBY_LAYOUT.MAIN)
		end; y = y + 1.0
	end

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Editor") then
		self:layout_change(LOBBY_LAYOUT.EDITOR)
	end; y = y + 1.0

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 256.0, 32.0), "Exit") then
		self:layout_change(LOBBY_LAYOUT.EXIT)
	end; y = y + 1.0
end

---Layout: mission.
---@param status status # The status.
function lobby:layout_mission(status)
	self:header_label(status, "Mission")
	self:header_input(status, LOBBY_LAYOUT.MAIN)

	local y = 1.0

	local table_hunter = {}
	local table_weapon = {}

	for i, j in ipairs(status.inner.hunter) do table.insert(table_hunter, j.name) end
	for i, j in ipairs(status.inner.weapon) do table.insert(table_weapon, j.name) end

	self.select_hunter = lobby:switch(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
		"Select Hunter",
		self.select_hunter, table_hunter); y = y + 1.0

	local click_a = false
	local click_b = false

	--[[ weapon selection. ]]

	self.select_weapon[1], click_a = lobby:switch(status,
		box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
		"Select Weapon A",
		self.select_weapon[1], table_weapon); y = y + 1.0

	self.select_weapon[2], click_b = lobby:switch(status,
		box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
		"Select Weapon B",
		self.select_weapon[2], table_weapon); y = y + 1.0

	-- solve an equipment collision, if any.
	self:equip_collision(self.select_weapon, status.inner.weapon, click_a, click_b)

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 192.0, 32.0), "GO!") then
		outer:new(status)
	end; y = y + 1.0
end

---Layout: hunter.
---@param status status # The status.
function lobby:layout_hunter(status)
	self:header_label(status, "Hunter Customization")
	self:header_input(status, LOBBY_LAYOUT.MAIN)

	local y = 1.0

	local table_hunter = {}

	for i, j in ipairs(status.inner.hunter) do table.insert(table_hunter, j.name) end

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Purchase Hunter") then
		table.insert(status.inner.hunter, hunter:new())
	end; y = y + 1.0

	self.select_hunter = lobby:switch(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
		"Select Hunter",
		self.select_hunter, table_hunter); y = y + 1.0

	local _, screen = quiver.window.get_render_shape()

	local font = status.system:get_font("video/font_side.ttf")

	local hunter = status.inner.hunter[self.select_hunter]

	self.scroll_value, self.scroll_frame = self:scroll(status,
		box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 512.0 + 160.0, screen - (12.0 + 36.0 * y) - 64.0),
		self.scroll_value,
		self.scroll_frame, function()
			if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Randomize Name") then
				hunter:randomize_name()
			end; y = y + 1.0

			self.window:text(vector_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y),
				"Health: " .. hunter.health .. " (" .. hunter.health_maximum .. ")", font, 24.0, 1.0, color:white()); y =
				y + 1.0

			self.window:text(vector_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y),
				"Walk Rate: " .. hunter.walk_rate, font, 24.0, 1.0, color:white()); y =
				y + 1.0

			self.window:text(vector_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y),
				"Drop Rate: " .. hunter.drop_rate, font, 24.0, 1.0, color:white()); y =
				y + 1.0

			self.window:text(vector_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y),
				"Fire Rate: " .. hunter.fire_rate, font, 24.0, 1.0, color:white()); y =
				y + 1.0
		end)
end

---Layout: weapon.
---@param status status # The status.
function lobby:layout_weapon(status)
	self:header_label(status, "Weapon Customization")
	self:header_input(status, LOBBY_LAYOUT.MAIN)

	local y = 1.0

	local table_weapon = {}

	for i, j in ipairs(status.inner.weapon) do table.insert(table_weapon, j.name) end

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Purchase Weapon") then
		table.insert(status.inner.weapon, weapon:new())
	end; y = y + 1.0

	self.select_weapon[1] = lobby:switch(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
		"Select Weapon",
		self.select_weapon[1], table_weapon); y = y + 1.0

	-- solve an equipment collision, if any.
	self:equip_collision(self.select_weapon, status.inner.weapon, true, false)

	local _, screen = quiver.window.get_render_shape()

	local font = status.system:get_font("video/font_side.ttf")

	local weapon_a = status.inner.weapon[self.select_weapon[1]]
	local weapon_b = status.inner.weapon[self.select_weapon[2]]

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Randomize Name") then
		local name = weapon_a:randomize_name()

		while name == weapon_a.name or name == weapon_b.name do
			name = weapon_a:randomize_name()
		end

		weapon_a.name = name
	end; y = y + 1.0

	--[[
	self.scroll_value, self.scroll_frame = self:scroll(status,
		box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 512.0 + 160.0, screen - (12.0 + 36.0 * y) - 64.0),
		self.scroll_value,
		self.scroll_frame, function()
			do end
		end)
]]
end

---Layout: configuration.
---@param status status # The status.
function lobby:layout_configuration(status)
	self:header_label(status, "Configuration")
	self:header_input(status, LOBBY_LAYOUT.MAIN)

	local y = 0.0

	if self:button(status, box_2:old(WINDOW_POINT.x + 146.0 * 1.0, WINDOW_POINT.y + 36.0 * y, 142.0, 32.0), "Default") then
		self.user = user:default(status)
	end; y = y + 1.0

	local shape = vector_2:old(quiver.window.get_shape()):scale_zoom(self.scene.camera_2d)

	self.scroll_value, self.scroll_frame = self:scroll(status,
		box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 512.0 + 160.0, shape.y - (WINDOW_POINT.y + 36.0 * y) - 64.0),
		self.scroll_value,
		self.scroll_frame, function()
			local click = false

			self.user.video_full, click = self:toggle(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 32.0, 32.0), "Full-Screen",
				self.user.video_full); y = y + 1.0

			if click then
				self.user:apply(status)
			end

			self.user.video_reel = self:toggle(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 32.0, 32.0), "Show Intro",
				self.user.video_reel); y = y + 1.0

			self.user.video_frame, click = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
				"Frame Rate",
				self.user.video_frame, 30.0, 300.0, 1.0); y = y + 1.0

			if click then
				self.user:apply(status)
			end

			self.user.video_shake = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "View Shake",
				self.user.video_shake, 0.0, 4.0, 0.1); y = y + 1.0

			self.user.video_glyph = self:switch(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Glyph Type",
				self.user.video_glyph, VIDEO_GLYPH); y = y + 1.0

			self.user.audio_sound = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Sound Volume",
				self.user.audio_sound, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.audio_music = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Music Volume",
				self.user.audio_music, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.input_pad_look = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
				"Pad Stick Behavior",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_look = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
				"Pad Stick Dead Zone (X)",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_look = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
				"Pad Stick Dead Zone (Y)",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_look = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0),
				"Pad Look Range",
				self.user.input_pad_look, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_assist = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Pad Assist",
				self.user.input_pad_assist, 1.0, 4.0, 0.1); y = y + 1.0

			self.user.input_pad_rumble = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Pad Rumble",
				self.user.input_pad_rumble, 1.0, 4.0, 0.1); y = y + 1.0

			self:action(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Move X+",
				self.user.input_move_x_a, 3.0)
			y = y + 1.0

			self:action(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Move X-",
				self.user.input_move_x_b, 3.0)
			y = y + 1.0

			self:action(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Move Y-",
				self.user.input_move_y_a, 3.0)
			y = y + 1.0

			self:action(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Move Y+",
				self.user.input_move_y_b, 3.0)
			y = y + 1.0

			self:action(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Weapon A",
				self.user.input_weapon_a, 3.0)
			y = y + 1.0

			self:action(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * y, 288.0, 32.0), "Weapon B",
				self.user.input_weapon_b, 3.0)
			y = y + 1.0
		end)
end

---Layout: exit.
---@param status status # The status.
function lobby:layout_exit(status)
	self:header_label(status, "Exit")
	self:header_input(status, LOBBY_LAYOUT.MAIN)

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * 1.0, 142.0, 32.0), "Accept") then
		status.active = false
	end
end

-- TO-DO parm desc
-- TO-DO re-order label.
---Get the data of a gizmo.
---@param status
---@param label
---@param hover
---@param index
---@param focus
---@param click
function lobby:get_gizmo(status, label, hover, index, focus, click)
	local delta = quiver.general.get_frame_time()

	label = label .. status.lobby.window.count

	if not self.data[label] then
		self.data[label] = gizmo:new()
	end

	local data = self.data[label]

	data.hover = math.clamp(0.0, 1.0,
		data.hover + ((hover or index or focus) and delta * 8.0 or delta * -8.0))

	if hover or index then
		if not data.sound_hover then
			data.sound_hover = true
			if self.time > 0.1 then
				local sound = status.system:get_sound("audio/interface/hover.ogg")
				sound:play()
			end
		end
	else
		data.sound_hover = false
	end

	if click then
		local sound = status.system:get_sound("audio/interface/click.ogg")
		sound:play()
	end

	return data
end

-- TO-DO parameter description
---@param status status
---@param window window
---@param shape  vector_2
---@param hover  boolean
---@param index  boolean
---@param focus  boolean
---@param label  string
local function button_call_back(status, window, shape, hover, index, focus, click, label)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus, click)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local texture = status.system:get_texture(label)

	if texture then
		texture:draw_pro(box_2:old(0.0, 0.0, texture.shape_x, texture.shape_y), shape, vector_2:zero(), 0.0,
			color:white())
	else
		local font = status.system:get_font("video/font_side.ttf")
		font:draw(string.tokenize(label, "([^|]+)")[1], vector_2:old(shape.x + 4.0, shape.y + 4.0), 24.0, 1.0,
			color)
	end

	if hover or index then
		do end
	end
end

---Draw a button gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return boolean click # True on click, false otherwise.
function lobby:button(status, shape, label, flag)
	return status.lobby.window:button(shape, label, GIZMO_FLAG.CLICK_ON_PRESS, button_call_back, status)
end

-- TO-DO parameter description
---@param status status
---@param window window
---@param shape  vector_2
---@param hover  boolean
---@param index  boolean
---@param focus  boolean
---@param label  string
local function button_toggle_call_back(status, window, shape, hover, index, focus, click, label, value)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus, click)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	if not value then
		color = color * 0.5
	end

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local texture = status.system:get_texture(label)

	if texture then
		texture:draw_pro(box_2:old(0.0, 0.0, texture.shape_x, texture.shape_y), shape, vector_2:zero(), 0.0,
			color:white())
	else
		local font = status.system:get_font("video/font_side.ttf")
		font:draw(string.tokenize(label, "([^|]+)")[1], vector_2:old(shape.x + 4.0, shape.y + 4.0), 24.0, 1.0,
			color)
	end

	if hover or index then
		do end
	end
end

---Draw a button toggle gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param value boolean    # The value of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return boolean click # True on click, false otherwise.
function lobby:button_toggle(status, shape, label, value, flag)
	return status.lobby.window:button_toggle(shape, label, value, GIZMO_FLAG.CLICK_ON_PRESS, button_toggle_call_back,
		status)
end

-- TO-DO parameter description
---@param status status
---@param window window
---@param shape  vector_2
---@param hover  boolean
---@param index  boolean
---@param focus  boolean
---@param label  string
---@param value  boolean
local function toggle_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	if value then
		quiver.draw_2d.draw_box_2_round(box_2:old(shape.x + 4.0, shape.y + 4.0, shape.width - 8.0, shape.height - 8.0),
			0.25,
			4.0, color)
	end

	local font = status.system:get_font("video/font_side.ttf")
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), 24.0, 1.0, color)

	if hover or index then
		do end
	end
end

---Draw a toggle gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param value number     # The value of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return number  value # The value.
---@return boolean click # True on click, false otherwise.
function lobby:toggle(status, shape, label, value, flag)
	return status.lobby.window:toggle(shape, label, value, GIZMO_FLAG.CLICK_ON_PRESS, toggle_call_back, status)
end

-- TO-DO parameter description
---@param status     status
---@param window     window
---@param shape      vector_2
---@param hover      boolean
---@param index      boolean
---@param focus      boolean
---@param label      string
---@param value      number
---@param percentage number
local function slider_call_back(status, window, shape, hover, index, focus, label, value, percentage)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)
	quiver.draw_2d.draw_box_2_round(
		box_2:old(shape.x + 4.0, shape.y + 4.0, (shape.width - 8.0) * percentage, shape.height - 8.0), 0.25, 4.0,
		color)

	local font = status.system:get_font("video/font_side.ttf")
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

---Draw a slider gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param value number     # The value of the gizmo.
---@param min   number     # The minimum value of the gizmo.
---@param max   number     # The minimum value of the gizmo.
---@param step  number     # The step size of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return number  value # The value.
---@return boolean click # True on click, false otherwise.
function lobby:slider(status, shape, label, value, min, max, step, flag)
	return status.lobby.window:slider(shape, label, value, min, max, step, flag, slider_call_back,
		status)
end

-- TO-DO parameter description
---@param status status
---@param window window
---@param shape  vector_2
---@param hover  boolean
---@param index  boolean
---@param focus  boolean
---@param label  string
---@param value  number
local function spinner_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local font = status.system:get_font("video/font_side.ttf")
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

function lobby:spinner(status, shape, label, value, min, max, flag)
	return status.lobby.window:spinner(shape, label, value, min, max, GIZMO_FLAG.CLICK_ON_PRESS, spinner_call_back,
		status)
end

-- TO-DO parameter description
---@param status status
---@param window window
---@param shape  vector_2
---@param hover  boolean
---@param index  boolean
---@param focus  boolean
---@param label  string
---@param value  number
local function switch_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local font = status.system:get_font("video/font_side.ttf")
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

function lobby:switch(status, shape, label, value, pool, flag)
	return status.lobby.window:switch(shape, label, value, pool, GIZMO_FLAG.CLICK_ON_PRESS, switch_call_back,
		status)
end

-- TO-DO parameter description
---@param status status
---@param window window
---@param shape  vector_2
---@param hover  boolean
---@param index  boolean
---@param focus  boolean
---@param label  string
---@param value  action
local function action_call_back(status, window, shape, hover, index, focus, label, value)
	local gizmo = status.lobby:get_gizmo(status, label, hover, index, focus)
	local shape = gizmo:move(status.lobby, shape)
	local color = gizmo:fade(status.lobby, color:white())

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.25, 4.0, color * 0.5)

	local font = status.system:get_font("video/font_side.ttf")
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

---Draw an action gizmo.
---@param shape   box_2      # The shape of the gizmo.
---@param label   string     # The label of the gizmo.
---@param value   action     # The value of the gizmo.
---@param clamp?  number     # OPTIONAL: The maximum button count for the action. If nil, do not clamp.
---@param flag?   gizmo_flag # The flag of the gizmo.
---@return boolean click # True on click, false otherwise.
function lobby:action(status, shape, label, value, clamp, flag)
	return status.lobby.window:action(shape, label, value, clamp, GIZMO_FLAG.CLICK_ON_PRESS, action_call_back,
		status)
end

-- TO-DO parameter description
---Scroll call-back.
---@param status status
---@param window window
---@param shape  vector_2
---@param value  number
---@param frame  number
local function scroll_call_back(status, window, shape, value, frame)
	local height = shape.height * math.min(1.0, shape.height / frame)

	local color = color:white() * 0.25

	-- fade in/out from time time.
	color.a = math.floor(math.min(1.0, status.lobby.time * 4.0) * 255.0)

	-- draw border.
	quiver.draw_2d.draw_box_2_round(shape, 0.05, 4.0, color)

	if shape.height > height then
		local view_size = math.min(0.0, shape.height - frame) * value

		-- draw border.
		quiver.draw_2d.draw_box_2_round(box_2:old(shape.x + shape.width + 8.0, shape.y, 32.0, shape.height), 0.25, 4.0,
			color)
		quiver.draw_2d.draw_box_2_round(
			box_2:old(shape.x + shape.width + 8.0, shape.y + (shape.height - height) * value, 32.0, height),
			0.25,
			4.0,
			color * 1.5)
	end
end

---Draw a scroll gizmo.
---@param shape box_2    # The shape of the gizmo.
---@param value number   # The value of the gizmo.
---@param frame number   # The frame of the gizmo.
---@param call  function # The draw function.
---@return number value
---@return number frame
function lobby:scroll(status, shape, value, last, call)
	return status.lobby.window:scroll(shape, value, last, call, scroll_call_back, status)
end

-- TO-DO parameter description
---Handle a potential weapon equipment collision (the player is equipping the same weapon on each hand).
---@param equip 	 table
---@param equip_list table
---@param click_a 	 boolean
---@param click_b 	 boolean
function lobby:equip_collision(equip, equip_list, click_a, click_b)
	while equip[1] == equip[2] do
		if click_b then
			equip[1] = math.roll_over(1.0, #equip_list, equip[1] + 1)
		end
		if click_a then
			equip[2] = math.roll_over(1.0, #equip_list, equip[2] + 1)
		end
	end
end

---Change the layout of the lobby.
---@param layout LOBBY_LAYOUT # Lobby layout to change to.
function lobby:layout_change(layout)
	self.window.index = 0.0
	self.layout = layout
	self.data = {}
	self.time = 0.0
	self.scroll_value = 0.0
	self.scroll_frame = 0.0
end

-- TO-DO
function lobby:header_label(status, label)
	local font = status.system:get_font("video/font_main.ttf")
	font:draw(label, vector_2:old(8.0, 8.0), 48.0, 1.0, color:white())
end

-- TO-DO
function lobby:header_input(status, layout)
	-- if button is set off or the return action has been set off...
	local result = self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y, 160.0, 32.0), "Return") or
		ACTION_RETURN:press(self.window.device)

	if layout and result then
		-- set the current layout to the given layout.
		self:layout_change(layout)
	end

	return result
end

-- TO-DO parameter description
---Draw a purchase button.
---@param status status
---@param point  number
---@param field  number
---@param price  number
---@param label  string
---@param font   font
---@return number field
---@return number point
function lobby:button_purchase(status, point, field, price, label, font)
	-- if the purchase button has been set-off...
	if self.self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + 36.0 * point, 144.0, 32.0), "Upgrade|" .. label) then
		-- if the player can afford the purchase...
		if status.inner.credit >= price then
			-- increment the field.
			field = field + 1.0
			-- decrement the player's credit.
			status.inner.credit = math.max(0.0, status.inner.credit - price)
		end
	end

	-- concatenate label with field value.
	label = label .. ": " .. field

	-- TO-DO
	self.window:text(vector_2:old(8.0 + 144.0 + 4.0, 16.0 + 36.0 * point), label, font, 24.0, 1.0, color:white())

	return field, point + 1.0
end

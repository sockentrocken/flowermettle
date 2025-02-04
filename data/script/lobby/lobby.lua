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


local WINDOW_POINT = vector_2:new(8.0, 56.0)
local WINDOW_SHAPE = vector_2:new(144.0, 22.0)
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
---@enum INPUT_PAD_STICK
local INPUT_PAD_STICK = {
	[0] = "Move/Look",
	[1] = "Look/Move",
}
---@enum LOBBY_LAYOUT
local LOBBY_LAYOUT = {
	INTRO = 0,
	BEGIN = 1,
	SETUP = 2,
	ABOUT = 3,
	CLOSE = 4,
	EDITOR = 5,
	TRANSITION_STANDARD = 6,
	TRANSITION_TUTORIAL = 7,
}
local LOBBY_LAYOUT_CAMERA = {
	[LOBBY_LAYOUT.INTRO] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	},
	[LOBBY_LAYOUT.BEGIN] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	},
	[LOBBY_LAYOUT.SETUP] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	},
	[LOBBY_LAYOUT.ABOUT] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	},
	[LOBBY_LAYOUT.CLOSE] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	},
	[LOBBY_LAYOUT.TRANSITION_STANDARD] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	},
	[LOBBY_LAYOUT.TRANSITION_TUTORIAL] = {
		point = vector_3:new(-1.5, 1.5, 3.0),
		focus = vector_3:new(0.0, 0.5, 0.0)
	}
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

	i.__type       = "lobby"
	i.scene        = scene:new(status.system:get_shader("light"))
	i.active       = true
	i.editor       = editor:new(status)
	i.window       = window:new()
	i.user         = user:new(status)
	i.layout       = LOBBY_LAYOUT.INTRO
	i.ease_point   = vector_3:new(0.0, 0.0, 0.0)
	i.ease_focus   = vector_3:new(0.0, 0.0, 0.0)
	i.data         = {}
	i.time         = 0.0
	i.scroll_value = 0.0
	i.scroll_frame = 0.0

	i.ease_point:copy(LOBBY_LAYOUT_CAMERA[i.layout].point)
	i.ease_focus:copy(LOBBY_LAYOUT_CAMERA[i.layout].focus)
	i.scene.camera_3d.point:copy(LOBBY_LAYOUT_CAMERA[i.layout].point)
	i.scene.camera_3d.focus:copy(LOBBY_LAYOUT_CAMERA[i.layout].focus)

	local menu = status.system:set_model("video/menu.glb")

	-- load model.
	for x = 1, menu.material_count - 1.0 do
		menu:bind_shader(x, i.scene.light.shader)
	end

	i.scene.light:set_base_color(color:old(32.0, 32.0, 32.0, 255.0))

	-- load sound.
	status.system:set_sound("audio/interface/hover.ogg")
	status.system:set_sound("audio/interface/click.ogg")

	-- load font.
	status.system:set_font("video/font_main.ttf", false, 48.0)
	status.system:set_font("video/font_side.ttf", false, 64.0)

	-- load texture.
	status.system:set_texture("video/logo_a.png")
	status.system:set_texture("video/logo_b.png")
	status.system:set_texture("video/logo_c.png")

	i.scene.camera_3d.zoom = 45.0

	quiver.input.mouse.set_scale(vector_2:old(0.5, 0.5))

	-- collect garbage.
	collectgarbage("collect")

	return i
end

---Draw the lobby.
---@param status status # The game status.
function lobby:draw(status)
	local delta = quiver.general.get_frame_time()

	-- update time in current layout.
	self.time = self.time + delta

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

			local logo_a = math.ease_interval(3.00, 5.00, 7.00, 8.00, status.time)
			local logo_b = math.ease_interval(9.00, 10.0, 12.0, 13.0, status.time)
			local logo_c = math.ease_interval(14.0, 15.0, nil, nil, status.time)

			local scale = math.min(1.0, logo_a + logo_b + logo_c + math.random() * 0.10)

			local lobby_light = color:old(255.0, 128.0, 0.0, 255.0) * (math.random() * 0.25 + 0.75) * scale

			self.scene.light:light_point(vector_3:old(math.cos(status.time) * 0.5, 1.0, math.sin(status.time) * 0.5),
				lobby_light)

			-- get point and focus for the current layout.
			local point = LOBBY_LAYOUT_CAMERA[self.layout].point
			local focus = LOBBY_LAYOUT_CAMERA[self.layout].focus

			-- interpolate to ease point/focus.
			self.ease_point:copy(self.ease_point + (point - self.scene.camera_3d.point) * delta * 32.0)
			self.ease_focus:copy(self.ease_focus + (focus - self.scene.camera_3d.focus) * delta * 32.0)

			-- update camera.
			self.scene.camera_3d.point:copy(self.ease_point)
			self.scene.camera_3d.focus:copy(self.ease_focus)

			-- draw menu model.
			local model = status.system:get_model("video/menu.glb")
			model:draw(vector_3:zero(), 1.0, color:white())
		end, self.scene.camera_3d)

		-- draw 2D view.
		quiver.draw_2d.begin(function()
			-- begin window.
			self.window:begin()

			-- select a layout to draw.
			if self.layout == LOBBY_LAYOUT.INTRO then
				self:layout_intro(status)
			elseif self.layout == LOBBY_LAYOUT.BEGIN then
				self:layout_begin(status)
			elseif self.layout == LOBBY_LAYOUT.SETUP then
				self:layout_setup(status)
			elseif self.layout == LOBBY_LAYOUT.ABOUT then
				self:layout_about(status)
			elseif self.layout == LOBBY_LAYOUT.CLOSE then
				self:layout_close(status)
			elseif self.layout == LOBBY_LAYOUT.TRANSITION_STANDARD then
				self:layout_transition(status, false)
			elseif self.layout == LOBBY_LAYOUT.TRANSITION_TUTORIAL then
				self:layout_transition(status, true)
			end

			-- close window.
			self.window:close(not self.active)
		end, self.scene.camera_2d)
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
end

--[[----------------------------------------------------------------]]

---Layout: intro.
---@param status status # The status.
function lobby:layout_intro(status)
	local shape = vector_2:old(status.render.shape_x, status.render.shape_y)

	if self.time <= 2.0 then
		quiver.draw_2d.draw_box_2(box_2:old(0.0, 0.0, shape.x, shape.y), vector_2:zero(), 0.0,
			color:old(0.0, 0.0, 0.0, math.floor(255.0 * (1.0 - self.time * 0.5))))
	end

	shape = shape * 0.5

	local logo_a = status.system:get_texture("video/logo_a.png")
	local logo_b = status.system:get_texture("video/logo_b.png")
	local logo_c = status.system:get_texture("video/logo_c.png")

	local logo_a_point = vector_2:old(shape.x - logo_a.shape_x * 0.5, shape.y - logo_a.shape_y * 0.5)
	local logo_b_point = vector_2:old(shape.x - logo_b.shape_x * 0.5, shape.y - logo_b.shape_y * 0.5)
	local logo_c_point = vector_2:old(shape.x - logo_c.shape_x * 0.5, shape.y - logo_c.shape_y * 0.5)

	local logo_a_color = color:old(255.0, 255.0, 255.0,
		math.floor(255.0 * math.ease_interval(3.00, 5.00, 7.00, 8.00, self.time)))
	local logo_b_color = color:old(255.0, 255.0, 255.0,
		math.floor(255.0 * math.ease_interval(9.00, 10.0, 12.0, 13.0, self.time)))
	local logo_c_color = color:old(255.0, 255.0, 255.0,
		math.floor(255.0 * math.ease_interval(14.0, 15.0, nil, nil, self.time)))
	local logo_d_color = color:old(255.0, 255.0, 255.0,
		math.floor(255.0 * math.ease_interval(17.0, 18.0, nil, nil, self.time) * (math.sin(self.time) + 1.0) * 0.5))

	logo_a:draw(logo_a_point, 0.0, 1.0, logo_a_color)
	logo_b:draw(logo_b_point, 0.0, 1.0, logo_b_color)
	logo_c:draw(logo_c_point, 0.0, 1.0, logo_c_color)

	-- get every button press in the queue.
	local board_queue = quiver.input.board.get_key_code_queue()
	local mouse_queue = quiver.input.mouse.get_queue()

	if board_queue > 0.0 or mouse_queue then
		self:layout_change(LOBBY_LAYOUT.BEGIN)
	end
end

---Layout: main.
---@param status status # The status.
function lobby:layout_begin(status)
	self:header_label(status, "Main Menu")

	local y = 0.0

	local check, which = ACTION_RETURN:press()

	if which and status.outer then
		local which = ACTION_RETURN.list[which]

		if not (which.button == INPUT_PAD.RIGHT_FACE_RIGHT) then
			self.window:set_device(INPUT_DEVICE.MOUSE)
			quiver.input.mouse.set_active(false)
		end

		self.active = false
	end

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "New Game") then
		self:layout_change(LOBBY_LAYOUT.TRANSITION_STANDARD)
	end; y = y + 1.0

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Tutorial") then
		self:layout_change(LOBBY_LAYOUT.TRANSITION_TUTORIAL)
	end; y = y + 1.0

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Setup") then
		self:layout_change(LOBBY_LAYOUT.SETUP)
	end; y = y + 1.0

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "About") then
		self:layout_change(LOBBY_LAYOUT.ABOUT)
	end; y = y + 1.0

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Close") then
		self:layout_change(LOBBY_LAYOUT.CLOSE)
	end; y = y + 1.0

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Editor") then
		self:layout_change(LOBBY_LAYOUT.EDITOR)
	end; y = y + 1.0
end

---Layout: setup.
---@param status status # The status.
function lobby:layout_setup(status)
	self:header_label(status, "Setup")
	self:header_input(status, LOBBY_LAYOUT.BEGIN)

	local y = 0.0

	if self:button(status, box_2:old(WINDOW_POINT.x + 146.0 * 1.0, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Default") then
		self.user = user:default(status)
	end; y = y + 1.0

	local shape = vector_2:old(status.render.shape_x, status.render.shape_y)

	self.scroll_value, self.scroll_frame = self:scroll(status,
		box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, shape.x - WINDOW_POINT.x - 48.0,
			shape.y - (WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y) - 8.0),
		self.scroll_value,
		self.scroll_frame, function()
			local click = false

			WINDOW_POINT.x = WINDOW_POINT.x + 8.0
			WINDOW_POINT.y = WINDOW_POINT.y + 8.0

			self.user.video.full, click = self:toggle(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.y, WINDOW_SHAPE.y),
				"Full-Screen",
				self.user.video.full); y = y + 1.0

			if click then
				self.user:apply(status)
			end

			self.user.video.frame, click = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Frame Rate",
				self.user.video.frame, 30.0, 300.0, 1.0); y = y + 1.0

			if click then
				self.user:apply(status)
			end

			self.user.video.field = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Field Of View",
				self.user.video.field, 60.0, 120.0, 1.0); y = y + 1.0

			self.user.video.camera_shake = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Camera Shake",
				self.user.video.camera_shake, 0.0, 2.0, 0.1); y = y + 1.0

			self.user.video.camera_walk = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Camera Walk Force",
				self.user.video.camera_walk, 0.0, 2.0, 0.1); y = y + 1.0

			self.user.video.camera_tilt = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Camera Tilt Force",
				self.user.video.camera_tilt, 0.0, 2.0, 0.1); y = y + 1.0

			self.user.video.glyph = self:switch(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Glyph Type",
				self.user.video.glyph, VIDEO_GLYPH); y = y + 1.0

			--[[]]

			self.user.audio.sound = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Sound Volume",
				self.user.audio.sound, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.audio.music = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Music Volume",
				self.user.audio.music, 0.0, 1.0, 0.05); y = y + 1.0

			--[[]]

			self.user.input.pad_stick = self:switch(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Pad Stick Behavior",
				self.user.input.pad_stick, INPUT_PAD_STICK); y = y + 1.0

			self.user.input.pad_dead_zone_x = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Pad Stick Dead Zone (X)",
				self.user.input.pad_dead_zone_x, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.input.pad_dead_zone_y = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Pad Stick Dead Zone (Y)",
				self.user.input.pad_dead_zone_y, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.input.pad_rumble = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Pad Rumble",
				self.user.input.pad_rumble, 0.0, 1.0, 0.05); y = y + 1.0

			self.user.input.mouse_sensitivity_x = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Mouse Sensitivity (X)",
				self.user.input.mouse_sensitivity_x, -2.0, 2.0, 0.1); y = y + 1.0

			self.user.input.mouse_sensitivity_y = self:slider(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Mouse Sensitivity (Y)",
				self.user.input.mouse_sensitivity_y, -2.0, 2.0, 0.1); y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Move X+",
				self.user.input.move_x_a, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Move X-",
				self.user.input.move_x_b, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Move Y-",
				self.user.input.move_y_a, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Move Y+",
				self.user.input.move_y_b, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Lean L.",
				self.user.input.lean_a, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Lean R.",
				self.user.input.lean_b, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Sprint",
				self.user.input.sprint, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Crouch",
				self.user.input.crouch, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Weapon Fire",
				self.user.input.weapon_fire, 3.0)
			y = y + 1.0

			self:action(status,
				box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
				"Weapon Swap",
				self.user.input.weapon_swap, 3.0)
			y = y + 1.0

			WINDOW_POINT.x = WINDOW_POINT.x - 8.0
			WINDOW_POINT.y = WINDOW_POINT.y - 8.0
		end)
end

---Layout: about.
---@param status status # The status.
function lobby:layout_about(status)
	self:header_label(status, "About")
	self:header_input(status, LOBBY_LAYOUT.BEGIN)

	local label = [[
Marcus von Euler - music

mccad00 - 2D art
sockentrocken - 3D art, code, design

Thank you for playing!
]]

	local font = status.system:get_font("video/font_side.ttf")
	font:draw(label, vector_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 4.0) * 1.0), 24.0, 1.0,
		color:white())

	if self:button(status, box_2:old(WINDOW_POINT.x + 150.0 * 0.0, WINDOW_POINT.y + (WINDOW_SHAPE.y + 4.0) * 2.0, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Bandcamp") then
		quiver.general.open_link("https://marcusvoneuler.bandcamp.com")
	end

	if self:button(status, box_2:old(WINDOW_POINT.x + 150.0 * 1.0, WINDOW_POINT.y + (WINDOW_SHAPE.y + 4.0) * 2.0, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Instagram") then
		quiver.general.open_link("https://www.instagram.com/marcusveul")
	end
end

---Layout: close.
---@param status status # The status.
function lobby:layout_close(status)
	self:header_label(status, "Close")
	self:header_input(status, LOBBY_LAYOUT.BEGIN)

	if self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y + (WINDOW_SHAPE.y + 2.0) * 1.0, WINDOW_SHAPE.x, WINDOW_SHAPE.y), "Accept") then
		status.active = false
	end
end

---Layout: level transition.
---@param status status # The status.
function lobby:layout_transition(status, tutorial)
	if tutorial then
		inner:new(status)
		outer:new(status, tutorial)
	end

	local shape = vector_2:old(status.render.shape_x, status.render.shape_y)

	quiver.draw_2d.draw_box_2(box_2:old(0.0, 0.0, shape.x, shape.y), vector_2:zero(), 0.0,
		color:old(0.0, 0.0, 0.0, math.min(255.0, math.floor(255.0 * self.time * 0.5))))

	if self.time >= 2.0 then
		inner:new(status)
		outer:new(status, tutorial)
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

	local tokenize = string.tokenize(label, "([^|]+)")
	local label = tokenize[1]
	local image = tokenize[2]

	if image then
		local texture = status.system:get_texture(image)

		texture:draw_pro(box_2:old(0.0, 0.0, texture.shape_x, texture.shape_y),
			box_2:old(shape.x + 1.0, shape.y + 1.0, shape.width - 2.0, shape.height - 2.0), vector_2:zero(), 0.0,
			color:white())

		if hover or index or focus then
			local font = status.system:get_font("video/font_side.ttf")

			-- measure text.
			local measure = vector_2:old(font:measure_text(label, 24.0, 1.0))

			-- draw border.
			quiver.draw_2d.draw_box_2_round(box_2:old(shape.x, shape.y + shape.height, measure.x + 8.0, measure.y + 4.0),
				0.25, 4.0,
				color * 0.5)

			font:draw(label, vector_2:old(shape.x + 4.0, shape.y + shape.height + 2.0), shape.height - 2.0, 1.0,
				color)
		end
	else
		local font = status.system:get_font("video/font_side.ttf")
		font:draw(label, vector_2:old(shape.x + 4.0, shape.y + 2.0), shape.height - 2.0, 1.0,
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

	local tokenize = string.tokenize(label, "([^|]+)")
	local label = tokenize[1]
	local image = tokenize[2]

	if image then
		local texture = status.system:get_texture(image)

		texture:draw_pro(box_2:old(0.0, 0.0, texture.shape_x, texture.shape_y),
			box_2:old(shape.x + 1.0, shape.y + 1.0, shape.width - 2.0, shape.height - 2.0), vector_2:zero(), 0.0,
			color:white())

		if hover or index or focus then
			local font = status.system:get_font("video/font_side.ttf")

			-- measure text.
			local measure = vector_2:old(font:measure_text(label, 24.0, 1.0))

			-- draw border.
			quiver.draw_2d.draw_box_2_round(box_2:old(shape.x, shape.y + shape.height, measure.x + 8.0, measure.y + 4.0),
				0.25, 4.0,
				color * 0.5)

			font:draw(label, vector_2:old(shape.x + 4.0, shape.y + shape.height + 2.0), 24.0, 1.0,
				color)
		end
	else
		local font = status.system:get_font("video/font_side.ttf")
		font:draw(label, vector_2:old(shape.x + 4.0, shape.y + 2.0), shape.height - 2.0, 1.0,
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
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), shape.height - 2.0,
		1.0, color)

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
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), shape.height - 2.0,
		1.0, color)

	-- measure text.
	local measure = font:measure_text(value, shape.height - 2.0, 1.0)

	-- draw value.
	font:draw(value, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 2.0),
		shape.height - 2.0,
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
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), shape.height - 2.0,
		1.0, color)

	-- measure text.
	local measure = font:measure_text(value, shape.height - 2.0, 1.0)

	-- draw value.
	font:draw(value, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 2.0),
		shape.height - 2.0,
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
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), shape.height - 2.0,
		1.0, color)

	-- measure text.
	local measure = font:measure_text(value, shape.height - 2.0, 1.0)

	-- draw value.
	font:draw(value, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 2.0),
		shape.height - 2.0,
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
	font:draw(label, vector_2:old(shape.x + shape.width + 4.0, shape.y + shape.height * 0.5 - 12.0), shape.height - 2.0,
		1.0, color)

	local label = #value.list > 0.0 and "" or "N/A"

	-- for every button in the action's list...
	for i, button in ipairs(value.list) do
		-- concatenate the button's name.
		label = label .. (i > 1.0 and ": " or "")
			.. button:name()
	end

	-- measure text.
	local measure = font:measure_text(label, shape.height - 2.0, 1.0)

	-- draw value.
	font:draw(label, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 2.0),
		shape.height - 2.0,
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
	local shape = vector_2:old(status.render.shape_x, status.render.shape_y)

	local font = status.system:get_font("video/font_main.ttf")
	font:draw(label, vector_2:old(8.0, 8.0), 48.0, 1.0, color:white())

	font:draw("DD61", vector_2:old(shape.x - 68.0, 8.0), 24.0, 1.0,
		color:white())
end

-- TO-DO
function lobby:header_input(status, layout)
	-- if button is set off or the return action has been set off...
	local result = self:button(status, box_2:old(WINDOW_POINT.x, WINDOW_POINT.y, WINDOW_SHAPE.x, WINDOW_SHAPE.y),
			"Return") or
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

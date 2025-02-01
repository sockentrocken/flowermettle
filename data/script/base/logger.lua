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

local LOGGER_LINE_COLOR_HISTORY = color:new(127.0, 127.0, 127.0, 255.0)
local LOGGER_LINE_COLOR_MESSAGE = color:new(255.0, 255.0, 255.0, 255.0)
local LOGGER_LINE_COLOR_FAILURE = color:new(255.0, 0.0, 0.0, 255.0)
local LOGGER_LINE_COUNT         = 4.0
local LOGGER_LINE_DELAY         = 4.0
local LOGGER_LINE_LABEL_TIME    = true

---@class logger_line
logger_line                     = {
	__meta = {}
}

function logger_line:new(label, color)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "logger_line"
	i.label = label
	i.color = color
	i.time = quiver.general.get_time()

	return i
end

--[[----------------------------------------------------------------]]

local LOGGER_FONT_SCALE = 24.0
local LOGGER_FONT_SPACE = 2.0
local LOGGER_FONT       = quiver.font.new_default()
local LOGGER_LINE_CAP   = 64.0

---@class logger
---@field buffer  table
logger                  = {
	__meta = {}
}

---Draw a small portion of the most recently sent content in the logger buffer. Only drawn when logger is not set.
local function logger_draw_side(self)

end

---Create a new logger.
---@return logger value # The logger.
function logger:new()
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "logger"
	i.buffer = {}

	local lua_print = print

	-- over-ride default print function with our own.
	print = function(...)
		lua_print(...)
		i:print(..., color:new(255.0, 255.0, 255.0, 255.0))
	end

	return i
end

---Draw the logger.
---@param window window # The window for rendering every possible command suggestion.
function logger:draw(window)
	-- get the length of the buffer worker.
	local count = #self.buffer
	local text_point_a = vector_2:old(0.0, 0.0)
	local text_point_b = vector_2:old(0.0, 0.0)

	-- draw the latest logger buffer, iterating through the buffer in reverse.
	for i = 1, LOGGER_LINE_COUNT do
		local line = self.buffer[count + 1 - i]

		-- line isn't nil...
		if line then
			-- line is within the time threshold...
			if quiver.general.get_time() < line.time + LOGGER_LINE_DELAY then
				-- start from 0.
				i = i - 1

				text_point_a:set(13.0, 13.0 + (i * LOGGER_FONT_SCALE))
				text_point_b:set(12.0, 12.0 + (i * LOGGER_FONT_SCALE))
				local label = line.label

				-- line with time-stamp is set, add time-stamp to beginning.
				if LOGGER_LINE_LABEL_TIME then
					label = string.format("(%.2f) %s", line.time, line.label)
				end

				-- draw back-drop.
				LOGGER_FONT:draw(label, text_point_a, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, line.color * 0.5)
				-- draw line.
				LOGGER_FONT:draw(label, text_point_b, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, line.color)
			end
		end
	end
end

---Print a new line to the logger.
---@param line_label  string # Line label.
---@param line_color? color  # OPTIONAL: Line color.
function logger:print(line_label, line_color)
	-- if line color is nil, use default color.
	line_color = line_color and line_color or LOGGER_LINE_COLOR_MESSAGE

	-- insert a new logger line.
	table.insert(self.buffer, logger_line:new(tostring(line_label), line_color))

	-- if logger line count is over the cap...
	if #self.buffer > LOGGER_LINE_CAP then
		-- pop one logger line.
		table.remove(self.buffer, 1)
	end
end

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

---Check if a string does start with another string.
---@param text string # Main text.
---@param find string # Text to check against with main text.
function string.start_with(text, find)
	return string.sub(text, 1, string.len(find)) == find
end

---Tokenize a string.
---@param text string # Text to tokenize.
---@param find string # Pattern to tokenize with.
function string.tokenize(text, find)
	local i = {}

	for token in text:gmatch(find) do
		table.insert(i, token)
	end

	return i
end

--[[----------------------------------------------------------------]]

---Get the length of the hash-side of a table.
---@param value table # Table to calculate length from.
---@return number length # The length of the hash-side of the table.
function table.hash_length(value)
	local i = 0.0

	for _, _ in pairs(value) do i = i + 1.0 end

	return i
end

---Deep copy a table.
---@param value table # Table to copy.
---@return table value # The table.
function table.copy(value, work)
	if not work then
		work = {}
	end

	for k, v in pairs(value) do
		if type(v) == "table" then
			work[k] = table.copy(v)
		else
			work[k] = v
		end
	end

	return work
end

---Print every key/value pair in a table.
---@param value table # Table to print.
function table.print(value)
	for k, v in pairs(value) do
		print(tostring(k) .. ":" .. tostring(v))

		if type(v) == "table" then
			table.print(v)
		end
	end
end

---Check if an object is within a table.
---@param value  table # Table to check the value in.
---@param object any   # Value to check.
---@return boolean check # True if value is in table, false otherwise.
function table.in_set(value, object)
	for k, v in ipairs(value) do
		if v == object then
			return true
		end
	end

	return false
end

---Remove an object from an array table by value.
---@param value  table # Table to remove the value from.
---@param object any   # Value to remove.
function table.remove_object(value, object)
	for k, v in ipairs(value) do
		if v == object then
			table.remove(value, k)
			return
		end
	end
end

---Recursively restore every table within a table's meta table.
---@param value table # Table to restore.
function table.restore_meta(value)
	-- for each key/value pair in the table...
	for k, v in pairs(value) do
		-- if the current value is a table...
		if type(v) == "table" then
			-- if the current table has a .__type field...
			if v.__type then
				-- locate the "class" table.
				local meta = _G[v.__type]

				-- if the class table does exist...
				if meta then
					-- restore the current table's meta-table to be that of the class table.
					setmetatable(v, meta.__meta)
					getmetatable(v).__index = meta
				else
					error(string.format(
						"table.restore_meta(): Found \"__type\" for table, but could not find \"%s\" class table.",
						v.__type))
				end
			end

			-- recursively iterate table.
			table.restore_meta(v)
		end
	end

	-- check the given value as well.
	if type(value) == "table" then
		-- if the current table has a .__type field...
		if value.__type then
			-- locate the "class" table.
			local meta = _G[value.__type]

			-- if the class table does exist...
			if meta then
				-- restore the current table's meta-table to be that of the class table.
				if meta.__meta then
					setmetatable(value, meta.__meta)
					getmetatable(value).__index = meta
				end
			else
				error(string.format(
					"table.restore_meta(): Found \"__type\" for table, but could not find \"%s\" class table.",
					value.__type))
			end
		end
	end
end

--[[----------------------------------------------------------------]]

math.euler = 2.71828

---Check the sanity of a number, which will check for NaN and Infinite.
---@param value number # Number to check.
---@return boolean sanity # True if number is not sane, false otherwise.
function math.sanity(value)
	return not (value == value) or value == math.huge
end

---Check the sign of a number.
---@param value number # Number to check.
---@return number sign # 1.0 if number is positive OR equal to 0.0, -1.0 otherwise.
function math.sign(value)
	return value >= 0 and 1.0 or -1.0
end

---Get the percentage of a value in a range.
---@param min number # Minimum value.
---@param max number # Maximum value.
---@param value number # Input value.
---@return number percentage # Percentage.
function math.percentage_from_value(min, max, value)
	return (value - min) / (max - min)
end

---Get the value of a percentage in a range.
---@param min number # Minimum value.
---@param max number # Maximum value.
---@param value number # Input percentage.
---@return number value # Value.
function math.value_from_percentage(min, max, value)
	return value * (max - min) + min
end

---Snap a value to a given step.
---@param step  number # Step.
---@param value number # Input value.
---@return number value # Value.
function math.snap(step, value)
	return math.floor(value / step) * step
end

---Get a random variation of a given value, which can either be positive or negative.
---@param value number # Number to randomize.
---@return number value # A value between [-number, number].
function math.random_sign(value)
	local random = math.random()
	if random > 0.5 then
		return value * math.percentage_from_value(0.5, 1.0, random)
	else
		return value * math.percentage_from_value(0.0, 0.5, random) * -1.0
	end
end

---Linear interpolation.
---@param a    number # Point "A".
---@param b    number # Point "B".
---@param time number # Time into the interpolation.
---@return number interpolation # The interpolation.
function math.interpolate(a, b, time)
	return (1.0 - time) * a + time * b
end

---Clamp a value in a range.
---@param min   number # Minimum value.
---@param max   number # Maximum value.
---@param value number # Value to clamp.
---@return number value # The value, within the min/max range.
function math.clamp(min, max, value)
	if value < min then return min end
	if value > max then return max end
	return value
end

---Roll-over a value: if value is lower than the minimum, roll-over to the maximum, and viceversa.
---@param min   number # Minimum value.
---@param max   number # Maximum value.
---@param value number # Value to roll-over.
---@return number value # The value, within the min/max roll-over range.
function math.roll_over(min, max, value)
	if value < min then return max end
	if value > max then return min end
	return value
end

---Return the "X", "Y", "Z" vector from an Euler angle.
---@param angle vector_3
---@return vector_3 d_x # "X" direction.
---@return vector_3 d_y # "Y" direction.
---@return vector_3 d_z # "Z" direction.
function math.direction_from_euler(angle)
	local d_x = vector_3:zero()
	local d_y = vector_3:zero()
	local d_z = vector_3:zero()

	-- Convert to radian.
	local angle = vector_2:old(angle.x * (math.pi / 180.0), angle.y * (math.pi / 180.0))

	-- "X" vector.
	d_x.x = math.cos(angle.y) * math.sin(angle.x)
	d_x.y = math.sin(angle.y) * -1.0
	d_x.z = math.cos(angle.y) * math.cos(angle.x)

	-- "Y" vector.
	d_y.x = math.sin(angle.y) * math.sin(angle.x)
	d_y.y = math.cos(angle.y)
	d_y.z = math.sin(angle.y) * math.cos(angle.x)

	-- "Z" vector.
	d_z.x = math.cos(angle.x)
	d_z.y = 0.0
	d_z.z = math.sin(angle.x) * -1.0

	return d_x, d_y, d_z
end

function math.degree_to_radian(value)
	return value * (math.pi / 180.0)
end

function math.radian_to_degree(value)
	return value * (180.0 / math.pi)
end

function math.out_sine(value)
	return math.sin((value * math.pi) * 0.5)
end

function math.out_quad(value)
	return 1.0 - (1.0 - value) * (1.0 - value)
end

function math.bell_curve(value)
	return math.euler ^ -value ^ 2
end

function math.bell_curve_clamp(value)
	local percentage = math.value_from_percentage(-3.0, 3.0, value)

	if percentage < -3.0 or percentage > 3.0 then return 0.0 end

	return math.bell_curve(percentage)
end

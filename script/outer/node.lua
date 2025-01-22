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

---@class node : entity
node = entity:new()

---Create a new node.
---@param status status # The game status.
---@return node value # The node.
function node:new(status, previous)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "node"

	return i
end

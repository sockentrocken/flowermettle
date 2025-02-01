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

---@class path : entity
path = entity:new()

---Create a new path.
---@param status status # The game status.
---@return path value # The path.
function path:new(status, previous)
	local i = entity:new(status, previous)
	setmetatable(i, self)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "path"
	i.link = {}
	i.find = {}

	return i
end

function path:level(status, level_list)
	for _, entity in ipairs(level_list) do
		if entity.__type == "path" then
			if entity.source == self.target then
				print("add path.")
				table.insert(self.link, entity_pointer:new(entity))
			end
		elseif entity.__type == "entry" then
			if entity.entry_source == self.entry then
				print("add door.")
				table.insert(self.find, entity_pointer:new(entity))
			end
		end
	end
end

function path:frame(status)
	for _, entity in ipairs(status.outer.entity) do
		if entity.__type == "path" then
			for _, self_entry in ipairs(self.find) do
				for _, path_entry in ipairs(entity.find) do
					local self_link = status.outer:entity_find(status, self_entry)
					local path_link = status.outer:entity_find(status, path_entry)

					if self_link and path_link then
						local difference = (self_link.point - path_link.point):magnitude()

						if difference <= 0.1 then
							table.insert(self.link, entity_pointer:new(entity))
						end
					end
				end
			end
		end
	end
end

function path:draw_3d(status)
	quiver.draw_3d.draw_cube(self.point, vector_3:one(), color:red())

	for _, entity in ipairs(self.link) do
		local link = status.outer:entity_find(status, entity)

		quiver.draw_3d.draw_line(self.point, link.point, color:red())
	end

	for _, entity in ipairs(self.find) do
		local link = status.outer:entity_find(status, entity)
		quiver.draw_3d.draw_line(self.point, link.point, color:green())
	end
end

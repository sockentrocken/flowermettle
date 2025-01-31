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

---@class file_system
---@field search      table
---@field locate      table
---@field memory_list table
---@field memory_data table
file_system = {
	__meta = {}
}

---Create a new virtual file-system. For serialization, you may want to only serialize "search", "locate", and "memory_list", which only contain serializable data.
---```lua
---local i = file_system:new({
---    "game_folder_1", -- image.png, sound.wav, model.obj
---    "game_folder_2", -- image.png
---    "game_folder_3"  -- sound.wav
---})
---
----- Scan "g_f_1", "g_f_2", "g_f_3" to update the asset look-up table.
---i:scan()
---
---i:find("image.png") -- "game_folder_2/image.png"
---i:find("sound.wav") -- "game_folder_3/sound.wav"
---i:find("model.obj") -- "game_folder_1/model.obj"
---```
---@return file_system value # The virtual file-system.
function file_system:new(search)
	local i = {}
	setmetatable(i, self.__meta)
	getmetatable(i).__index = self

	--[[]]

	i.__type = "file_system"
	i.locate = {}
	i.memory_list = {
		texture = {},
		model = {},
		sound = {},
		music = {},
		shader = {},
		font = {}
	}
	i.memory_data = {
		texture = {},
		model = {},
		sound = {},
		music = {},
		shader = {},
		font = {}
	}

	i:scan(search)

	return i
end

---Scan every directory in the asset's search table, to update the asset look-up table.
function file_system:scan(search)
	-- get the info path (i.e. path: "main_folder").
	local _, path = quiver.general.get_info()

	-- for each search path in the search table...
	for _, search_path in ipairs(search) do
		-- scan the path recursively.
		local list = quiver.file.scan_path(search_path, nil, true)
		-- make the full path (main_folder/game_folder_1).
		local wipe = path .. "/" .. search_path

		for _, search_file in ipairs(list) do
			-- strip "main_folder/game_folder_1/video/image.png" to "video/image.png".
			local entry = string.sub(search_file, #wipe + 2, -1)
			local value = string.sub(search_file, #path + 2, -1)

			-- set entry. (i.e. "video/image.png" = "main_folder/game_folder_1/video/image.png").
			self.locate[entry] = value
		end
	end
end

function file_system:list(search)
	local result = {}

	for path, _ in pairs(self.locate) do
		if string.start_with(path, search) then
			table.insert(result, path)
		end
	end

	return result
end

---Find an asset by name, to get the full path of the asset.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return string full_path # The "full" path to the asset.
function file_system:find(faux_path)
	return self.locate[faux_path]
end

---Re-load every asset in memory.
function file_system:load()
	for path, _ in pairs(self.memory_data.texture) do
		self:set_texture(path, true)
	end
	for path, _ in pairs(self.memory_data.model) do
		self:set_model(path, true)
	end
end

local function file_system_set_asset(self, memory_data, memory_list, call_new, force, faux_path, ...)
	-- if asset was already in memory...
	if memory_data[faux_path] then
		if force then
			-- remove from the book-keeping memory table.
			table.remove_object(memory_list, faux_path)

			-- remove from the data-keeping memory table.
			memory_data[faux_path] = nil

			collectgarbage("collect")
		else
			return memory_data[faux_path]
		end
	end

	-- locate the asset.
	local asset = self.locate[faux_path]

	-- create the asset.
	asset = call_new(asset, ...)

	-- insert into the book-keeping memory table.
	table.insert(memory_list, faux_path)

	-- insert into the data-keeping memory table.
	memory_data[faux_path] = asset

	return asset
end

---Get a Lua source file from the file-system table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return string asset # The asset.
function file_system:get_source(faux_path)
	return string.sub(self.locate[faux_path], 0.0, -5.0)
end

---Get a texture asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return texture asset # The asset.
function file_system:get_texture(faux_path)
	return self.memory_data.texture[faux_path]
end

---Set a texture asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return texture asset # The asset.
function file_system:set_texture(faux_path, force)
	return file_system_set_asset(self, self.memory_data.texture, self.memory_list.texture, quiver.texture.new, force,
		faux_path)
end

---Get a model asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return model asset # The asset.
function file_system:get_model(faux_path)
	return self.memory_data.model[faux_path]
end

---Set a model asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return model asset # The asset.
function file_system:set_model(faux_path, force)
	return file_system_set_asset(self, self.memory_data.model, self.memory_list.model, quiver.model.new, force, faux_path)
end

---Get a sound asset from the file-system sound resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return sound asset # The asset.
function file_system:get_sound(faux_path)
	return self.memory_data.sound[faux_path]
end

---Set a sound asset into the file-system sound resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return sound asset # The asset.
function file_system:set_sound(faux_path, force)
	return file_system_set_asset(self, self.memory_data.sound, self.memory_list.sound, quiver.sound.new, force, faux_path)
end

---Get a model asset from the file-system model resource table.
---@param  faux_name string # The "faux" name to the asset.
---@return shader asset # The asset.
function file_system:get_shader(faux_name)
	return self.memory_data.shader[faux_name]
end

---Set a shader asset into the file-system model resource table.
---@param  faux_name    string # The "faux" name to the asset. It will be the key for storing the asset.
---@param  faux_path_vs string # The "faux" path to the ".vs" asset, not taking into consideration the search path in which it was found.
---@param  faux_path_fs string # The "faux" path to the ".fs" asset, not taking into consideration the search path in which it was found.
---@return shader asset # The asset.
function file_system:set_shader(faux_name, faux_path_vs, faux_path_fs, force)
	-- NOTE: storing a shader is slightly different from every other asset as it will
	-- normally take in more than one path (.vs and .fs). for that reason, a specific
	-- implementation just for the shader asset has to be made.

	-- if asset was already in memory...
	if self.memory_data.shader[faux_name] then
		if force then
			-- remove from the book-keeping memory table.
			table.remove_object(self.memory_list.shader, faux_name)

			-- remove from the data-keeping memory table.
			self.memory_data.shader[faux_name] = nil

			collectgarbage("collect")
		else
			return self.memory_data.shader[faux_name]
		end
	end

	-- locate the asset.
	local asset_vs = self.locate[faux_path_vs]
	local asset_fs = self.locate[faux_path_fs]

	-- create the asset.
	asset = quiver.shader.new(asset_vs, asset_fs)

	-- insert into the book-keeping memory table.
	table.insert(self.memory_list.shader, faux_name)

	-- insert into the data-keeping memory table.
	self.memory_data.shader[faux_name] = asset

	return asset
end

---Get a model asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return font asset # The asset.
function file_system:get_font(faux_path)
	return self.memory_data.font[faux_path]
end

---Set a font asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return font asset # The asset.
function file_system:set_font(faux_path, force, ...)
	return file_system_set_asset(self, self.memory_data.font, self.memory_list.font, quiver.font.new, force, faux_path,
		...)
end

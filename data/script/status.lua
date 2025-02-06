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

-- load standard library.
require "data/script/base/base"

-- request:
-- light flare
-- water particle
-- steam particle
-- streak texture

---@class status
---@field active boolean
---@field render render_texture
---@field system system
---@field lobby  lobby
---@field inner  inner | nil
---@field outer  outer | nil
status = {}

---Create a new status.
---@return status value # The status.
function status:new()
    local i = {}
    setmetatable(i, {
        __index = self
    })

    --[[]]

    i.__type = "status"
    i.active = true
    i.logger = logger:new()
    i.render = quiver.render_texture.new(vector_2:old(quiver.window.get_shape()) * 0.5)
    i.system = system:new({
        "data"
    })
    i.time = 0.0

    quiver.window.set_icon(quiver.image.new("data/video/icon.png"))
    quiver.window.set_name("FLOWERMETTLE")

    -- load inner-state source code.
    require(i.system:get_source("script/lobby/lobby.lua"))
    require(i.system:get_source("script/lobby/gizmo.lua"))
    require(i.system:get_source("script/lobby/user.lua"))

    -- load inner-state source code.
    require(i.system:get_source("script/inner/inner.lua"))
    require(i.system:get_source("script/inner/hunter.lua"))
    require(i.system:get_source("script/inner/weapon.lua"))

    -- load outer-state source code.
    require(i.system:get_source("script/outer/outer.lua"))
    require(i.system:get_source("script/outer/entity.lua"))
    require(i.system:get_source("script/outer/light.lua"))
    require(i.system:get_source("script/outer/level.lua"))
    require(i.system:get_source("script/outer/entry.lua"))
    require(i.system:get_source("script/outer/actor.lua"))
    require(i.system:get_source("script/outer/enemy.lua"))
    require(i.system:get_source("script/outer/elevator.lua"))
    require(i.system:get_source("script/outer/player.lua"))
    require(i.system:get_source("script/outer/zombie.lua"))
    require(i.system:get_source("script/outer/particle.lua"))
    require(i.system:get_source("script/outer/projectile.lua"))
    require(i.system:get_source("script/outer/path.lua"))
    require(i.system:get_source("script/outer/text.lua"))

    i.system:set_shader("base", "video/shader/base.vs", "video/shader/dither.fs")
    i.system:set_shader("light", "video/shader/light.vs", "video/shader/light.fs")

    local level_list = i.system:list("level/")

    i.level = {
        initial = {},
        regular = {},
    }

    for _, path in ipairs(level_list) do
        local file = quiver.general.deserialize(quiver.file.get(i.system:find(path)))
        local initial = false

        for _, entity in ipairs(file.data) do
            if entity.__type == "player" then
                initial = true
            end
        end

        -- TO-DO: hack. remove.
        if path == "level/_tutorial.json" then
            i.level.tutorial = file
        elseif initial then
            table.insert(i.level.initial, file)
        else
            table.insert(i.level.regular, file)
        end
    end

    lobby:new(i)

    return i
end

--[[----------------------------------------------------------------]]

function status:draw()
    local delta = quiver.general.get_frame_time()

    self.time = self.time + delta

    -- clear table pool.
    table_pool:clear()

    -- clear color.
    quiver.draw.clear(color:black())

    -- re-load render-texture with the window.
    if quiver.window.get_resize() then
        self.render = quiver.render_texture.new(vector_2:old(quiver.window.get_shape()) * 0.5)
    end

    -- if lobby is active, draw lobby. otherwise, draw in-game state.
    if self.lobby.active then
        self.lobby:draw(self)
    else
        self.outer:draw(self)
    end

    -- draw logger.
    self.logger:draw()
end

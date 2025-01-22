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

require "script/base/base"
require "script/lobby/lobby"
require "script/inner/inner"
require "script/outer/outer"

---@class status
---@field active boolean
---@field render render_texture
---@field system file_system
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
    i.render = quiver.render_texture.new(vector_2:old(quiver.window.get_shape()))
    -- TO-DO use VFS.
    i.shader = quiver.shader.new("asset/video/shader/base.vs", "asset/video/shader/vignette.fs")
    i.system = file_system:new({
        "asset"
    })
    i.lobby  = lobby:new(i)

    return i
end

--[[----------------------------------------------------------------]]

function status:draw()
    -- clear table pool.
    table_pool:clear()

    -- clear color.
    quiver.draw.clear(color:black())

    -- re-load render-texture with the window.
    if quiver.window.get_resize() then
        self.render = quiver.render_texture.new(vector_2:old(quiver.window.get_shape()))
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

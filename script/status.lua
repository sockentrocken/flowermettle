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

---@class status
---@field active boolean
---@field lobby lobby
---@field inner  inner | nil
---@field outer  outer | nil
status = {
    __meta = {}
}

---Create a new status.
---@return status value # The status.
function status:new()
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "status"
    i.active = true
    i.lobby = lobby:new()

    return i
end

--[[----------------------------------------------------------------]]


function status:draw()
    -- clear table pool.
    table_pool:clear()

    -- clear color.
    quiver.draw.clear(color:white())

    -- if lobby is active, draw lobby. otherwise, draw in-game state.
    if self.lobby.active then
        self.lobby:draw(self)
    else
        self.outer:draw(self)
    end
end

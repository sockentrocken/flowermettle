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

---A table pool, for initializing a memory arena of a certain kind for borrowing later.
---@class table_pool
---@field index number
---@field count number
---@field kind  table
table_pool = {
    __meta = {}
}

---Create a new table pool.
---@param kind table  # The kind of table this table pool will initialize a memory arena for. MUST have a "default" function.
---@param size number # The size of the table.
function table_pool:new(kind, size, name)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    -- initialize the table pool from 1 to {size} with the default instance of the {kind}.
    for x = 1, size + 1 do
        i[x] = kind:default()
    end

    i.__type = "table_pool"
    i.index = 1
    i.count = size
    i.kind = kind
    i.name = name

    return i
end

---Clear the table pool index.
function table_pool:begin()
    self.index = 1
end

---Borrow a table from the table pool. WILL allocate a new table if every table in the pool is already in use.
function table_pool:get()
    -- increase the index by 1.
    self.index = self.index + 1

    -- index overflow!
    if self.index > self.count then
        error("index overflow: " .. self.name)
        -- create a new table.
        self[self.index] = self.kind:default()
        -- update our known table pool size.
        self.count = self.index
    end

    -- borrow table.
    return self[self.index - 1]
end

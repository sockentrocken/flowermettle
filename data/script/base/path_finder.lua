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

---@class path_node
---@field position vector_2|vector_3
---@field parent path_node
---@field f_cost number
---@field g_cost number
---@field h_cost number
path_node = {
    __meta = {}
}

---Create a new path node.
---@param position vector_3|vector_2 # The position of the node.
---@return value path_node # The node.
function path_node:new(position)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    i.__type = "path_node"
    i.position = position
    i.parent = nil
    i.g_cost = 0.0
    i.h_cost = 0.0
    i.f_cost = 0.0

    return i
end

---Get a path from point A to point B, given a list of every point node.
---@param point_a    path_node # Point A.
---@param point_b    path_node # Point B.
---@param node_list  table     # A list of every point node.
---@param node_find  function  # A function call-back with every nearby node. Function must be of the type `call_back(node_a, node_b)` and return a boolean, true for valid nearby node, false otherwise.
---@return table|nil value # A path from point A to point B.
function path_node:find(point_a, point_b, node_list, node_find)
    -- initialize the open and lock list.
    local open_list = { point_a }
    local lock_list = {}

    -- initialize the g, h, and f-cost of point A.
    point_a.g_cost = 0.0
    point_a.h_cost = (point_a.position - point_b.position):magnitude()
    point_a.f_cost = point_a.g_cost + point_a.h_cost

    -- while the open list isn't empty...
    while #open_list > 0.0 do
        local active_find = 1
        local pick_node = open_list[1]
        local active_distance = math.huge

        -- for every node in the open list...
        for i, node in ipairs(open_list) do
            -- if the f-cost of the current node is lower than the current lowest...
            if active_distance > node.f_cost then
                -- set active node and distance.
                active_find = i
                pick_node = node
                active_distance = node.f_cost
            end
        end

        -- if we are at point B...
        if pick_node == point_b then
            local path = {}
            local find = pick_node

            -- while the traversal node is not nil...
            while find do
                -- unroll path.
                table.insert(path, find)

                -- go up the parent tree.
                find = find.parent
            end

            -- return path.
            return path
        end

        -- remove the active node from the open list and move it to the lock list.
        table.remove(open_list, active_find)
        table.insert(lock_list, pick_node)

        local near = {}

        -- for every node in the node list...
        for _, node in ipairs(node_list) do
            -- if the current node is not the active node and the current node is a valid node...
            if node ~= pick_node and node_find(pick_node, node) then
                -- add the node as a near node.
                table.insert(near, node)
            end
        end

        -- for every node in the near list...
        for _, near_node in ipairs(near) do
            if not table.in_set(lock_list, near_node) then
                -- calculate g, h-cost.
                local g_cost = (near_node.position - pick_node.position):magnitude() + pick_node.g_cost
                local h_cost = (near_node.position - point_b.position):magnitude()

                if not table.in_set(open_list, near_node) or g_cost < near_node.g_cost then
                    -- link near node, add g, h, f-cost.
                    near_node.parent = pick_node
                    near_node.g_cost = g_cost
                    near_node.h_cost = h_cost
                    near_node.f_cost = near_node.g_cost + near_node.h_cost

                    -- if near node isn't in the open list...
                    if not table.in_set(open_list, near_node) then
                        -- add to open list.
                        table.insert(open_list, near_node)
                    end
                end
            end
        end
    end

    -- no valid path found, return nil.
    return nil
end

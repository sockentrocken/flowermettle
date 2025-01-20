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

local ENTITY_LIST = {
    {
        name = "player",
        info = "Player",
        box = box_3:new(
            vector_3:new(0.5, 1.0, 0.5) * -1.0,
            vector_3:new(0.5, 1.0, 0.5)
        )
    }
}

---@class editor
editor = {
    __meta = {}
}

---Create a new editor.
---@return editor value # The editor.
function editor:new()
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "editor"
    i.entity = nil
    i.system = file_system:new({
        "asset"
    })
    i.list = table.copy(ENTITY_LIST)
    i.snap = 0.5
    i.name = ""
    i.wire = true

    local list = i.system:list("video/level/")

    for _, value in ipairs(list) do
        i.system:set_model(value)

        table.insert(i.list, {
            name = "level",
            info = string.sub(value, 13),
            view = value
        })
    end

    table.restore_meta(i.list)

    return i
end

local function GetRayCollisionBox(ray, box)
    local collision = {}

    -- Note: If ray.position is inside the box, the distance is negative (as if the ray was reversed)
    -- Reversing ray.direction will give use the correct result
    local insideBox = (ray.position.x > box.min.x) and (ray.position.x < box.max.x) and
        (ray.position.y > box.min.y) and (ray.position.y < box.max.y) and
        (ray.position.z > box.min.z) and (ray.position.z < box.max.z)

    --if (insideBox) then ray.direction = Vector3Negate(ray.direction) end
    if (insideBox) then ray.direction = ray.direction * -1.0 end

    local t            = {}

    t[8]               = 1.0 / ray.direction.x
    t[9]               = 1.0 / ray.direction.y
    t[10]              = 1.0 / ray.direction.z

    t[0]               = (box.min.x - ray.position.x) * t[8]
    t[1]               = (box.max.x - ray.position.x) * t[8]
    t[2]               = (box.min.y - ray.position.y) * t[9]
    t[3]               = (box.max.y - ray.position.y) * t[9]
    t[4]               = (box.min.z - ray.position.z) * t[10]
    t[5]               = (box.max.z - ray.position.z) * t[10]
    t[6]               = math.max(math.max(math.min(t[0], t[1]), math.min(t[2], t[3])), math.min(t[4], t[5]))
    t[7]               = math.min(math.min(math.max(t[0], t[1]), math.max(t[2], t[3])), math.max(t[4], t[5]))

    collision.hit      = not ((t[7] < 0) or (t[6] > t[7]))
    collision.distance = t[6]
    collision.point    = ray.position + (ray.direction * collision.distance)

    -- Get box center point
    collision.normal   = box.min:interpolate(box.max, 0.5)
    -- Get vector center point->hit point
    collision.normal   = collision.point - collision.normal
    -- Scale vector to unit cube
    -- NOTE: We use an additional .01 to fix numerical errors
    collision.normal   = collision.normal * 2.01
    collision.normal   = collision.normal / (box.max - box.min)
    -- The relevant elements of the vector are now slightly larger than 1.0 (or smaller than -1.0)
    -- and the others are somewhere between -1.0 and 1.0 casting to int is exactly our wanted normal!
    collision.normal.x = math.ceil(collision.normal.x)
    collision.normal.y = math.ceil(collision.normal.y)
    collision.normal.z = math.ceil(collision.normal.z)

    collision.normal   = collision.normal:normalize()

    if (insideBox) then
        -- Reset ray.direction
        ray.direction = ray.direction * -1.0
        -- Fix result
        collision.distance = collision.distance * -1.0
        collision.normal = collision.normal * -1.0
    end

    return collision
end

function editor:draw_3d(lobby, status)
    if self.entity then
        local ray = nil
        local hit_which = nil
        local hit_where = nil

        if quiver.input.mouse.get_press(INPUT_MOUSE.LEFT) then
            local x, y    = quiver.input.mouse.get_point()
            ray           = quiver.draw_3d.get_screen_to_world(lobby.camera_3d, vector_2:old(x, y),
                vector_2:old(quiver.window.get_shape()))

            ray.position  = vector_3:old(ray.position.x, ray.position.y, ray.position.z)
            ray.direction = vector_3:old(ray.direction.x, ray.direction.y, ray.direction.z)
        end

        for i = #self.entity, 1, -1 do
            local entity = self.entity[i]
            local locate = self.list[entity.__help.index]

            if locate.view then
                local view = self.system:get_model(locate.view)
                if self.wire then
                    view:draw_wire(entity.point, 1.0, color:old(255.0, 255.0, 255.0, 255.0))
                else
                    view:draw(entity.point, 1.0, color:old(255.0, 255.0, 255.0, 255.0))
                end
            else
                if ray then
                    local collision = GetRayCollisionBox(ray, locate.box:translate(entity.point))

                    if collision.hit then
                        if hit_which then
                            if hit_where > collision.distance then
                                hit_which = i
                                hit_where = collision.distance
                            end
                        else
                            hit_which = i
                            hit_where = collision.distance
                        end
                    end
                end

                local entity_color = color:red()

                if quiver.input.board.get_down(INPUT_BOARD.L_CONTROL) then
                    if quiver.input.board.get_press(INPUT_BOARD.A) then
                        entity.__help.active = true
                    end
                end

                if quiver.input.board.get_down(INPUT_BOARD.L_ALTERNATE) then
                    if quiver.input.board.get_press(INPUT_BOARD.A) then
                        entity.__help.active = false
                    end
                end

                if entity.__help.active then
                    entity_color = color:green()

                    if quiver.input.board.get_press(INPUT_BOARD.DELETE) then
                        table.remove(self.entity, i)
                    end

                    if quiver.input.board.get_down(INPUT_BOARD.L_CONTROL) then
                        if quiver.input.board.get_press(INPUT_BOARD.D) then
                            local i = table.copy(entity)
                            table.restore_meta(i)
                            table.insert(self.entity, i)

                            entity.__help.active = false
                        end
                    else
                        local move = vector_3:old(0.0, 0.0, 0.0)

                        move.x = (quiver.input.board.get_press(INPUT_BOARD.A) or quiver.input.board.get_press_repeat(INPUT_BOARD.A)) and
                            -self.snap or move.x
                        move.x = (quiver.input.board.get_press(INPUT_BOARD.D) or quiver.input.board.get_press_repeat(INPUT_BOARD.D)) and
                            self.snap or move.x

                        _, move.y = quiver.input.mouse.get_wheel()

                        move.y = move.y * self.snap

                        move.z = (quiver.input.board.get_press(INPUT_BOARD.W) or quiver.input.board.get_press_repeat(INPUT_BOARD.W)) and
                            -self.snap or move.z
                        move.z = (quiver.input.board.get_press(INPUT_BOARD.S) or quiver.input.board.get_press_repeat(INPUT_BOARD.S)) and
                            self.snap or move.z

                        if quiver.input.board.get_up(INPUT_BOARD.L_CONTROL) and quiver.input.mouse.get_down(INPUT_MOUSE.MIDDLE) then
                            local x, y = quiver.input.mouse.get_delta()
                            move.x = x * 0.05
                            move.z = y * 0.05
                        end

                        if quiver.input.mouse.get_release(INPUT_MOUSE.MIDDLE) then
                            entity.point:copy(entity.point:snap(self.snap))
                        end

                        entity.point:copy((entity.point + move))
                    end
                end

                quiver.draw_3d.draw_box_3(locate.box:translate(entity.point), entity_color)
            end
        end

        if ray then
            if hit_which then
                local pick = self.entity[hit_which]

                if not quiver.input.board.get_down(INPUT_BOARD.L_SHIFT) then
                    for _, entity in pairs(self.entity) do
                        entity.__help.active = false
                    end
                end

                pick.__help.active = true
            else
                for _, entity in pairs(self.entity) do
                    entity.__help.active = false
                end
            end
        end

        if quiver.input.mouse.get_press(INPUT_MOUSE.RIGHT) then
            quiver.input.mouse.set_active(false)
        end

        if quiver.input.mouse.get_release(INPUT_MOUSE.RIGHT) then
            quiver.input.mouse.set_active(true)
        end

        if quiver.input.board.get_down(INPUT_BOARD.L_CONTROL) then
            local _, snap = quiver.input.mouse.get_wheel()

            self.snap = math.max(0.25, self.snap + snap * 0.25)
        end

        if quiver.input.mouse.get_down(INPUT_MOUSE.RIGHT) then
            local x, y = quiver.input.mouse.get_delta()
            x = x * 0.025
            y = y * 0.025

            lobby.camera_3d.point:copy(lobby.camera_3d.point + vector_3:old(x, 0.0, y))
            lobby.camera_3d.focus:copy(lobby.camera_3d.focus + vector_3:old(x, 0.0, y))
        end
    end
end

function editor:draw_2d(lobby, status)
    if not self.entity then
        local y = 0.0

        self.name = lobby.window:entry(box_2:old(8.0, 8.0 + (36.0 * y), 320.0, 32.0), "Level Name", self.name); y = y +
            1.0

        if lobby.window:button(box_2:old(8.0, 8.0 + (36.0 * y), 320.0, 32.0), "New Level") then
            if not (self.name == "") then
                self.entity = {}

                -- update the camera.
                lobby.camera_3d.point = vector_3:new(0.0, 8.0, 4.0)
                lobby.camera_3d.focus = vector_3:new(0.0, 0.0, 0.0)
                lobby.camera_3d.zoom = 90.0
            end
        end; y = y + 1.0

        local list = self.system:list("level/")

        lobby.window:text(vector_2:old(8.0, 8.0 + (36.0 * y)), "Load Level", LOGGER_FONT, LOGGER_FONT_SCALE,
            LOGGER_FONT_SPACE, color:white()); y = y + 1.0

        for i, value in ipairs(list) do
            lobby.window:button(box_2:old(8.0, 8.0 + (36.0 * y) + (40.0 * (i - 1.0)), 320.0, 32.0), value)
        end
    else
        local x, y = quiver.window.get_shape()
        quiver.draw_2d.draw_box_2_border(box_2:old(8.0, 8.0, x - 16.0, 48.0))

        lobby.window:button(box_2:old(16.0 + (104.0 * 0.0), 16.0, 96.0, 32.0), "Point")
        lobby.window:button(box_2:old(16.0 + (104.0 * 1.0), 16.0, 96.0, 32.0), "Angle")
        lobby.window:button(box_2:old(16.0 + (104.0 * 2.0), 16.0, 96.0, 32.0), "Scale")
        if lobby.window:button(box_2:old(16.0 + (104.0 * 3.0), 16.0, 96.0, 32.0), "Save") then
            local save = table.copy(self.entity)

            for _, entity in ipairs(save) do
                entity.__type = self.list[entity.__help.index].name
                entity.__help = nil
            end

            quiver.file.set("asset/level/" .. self.name .. ".json", quiver.general.serialize(save))
        end
        if lobby.window:button(box_2:old(16.0 + (104.0 * 4.0), 16.0, 96.0, 32.0), "Load") then
            lobby.editor = editor:new()
        end
        if lobby.window:button(box_2:old(16.0 + (104.0 * 5.0), 16.0, 96.0, 32.0), "Exit") then
            lobby.layout = 0.0
            lobby.editor = editor:new()
        end
        self.wire = lobby.window:toggle(box_2:old(16.0 + (104.0 * 6.0), 16.0, 32.0, 32.0), "Wire", self.wire)

        lobby.window:text(vector_2:old(16.0 + (104.0 * 7.0), 20.0), "Snap: " .. self.snap, LOGGER_FONT, LOGGER_FONT_SCALE,
            LOGGER_FONT_SPACE, color:white())

        quiver.draw_2d.draw_box_2_border(box_2:old(8.0, 64.0, 256.0, y - 160.0))

        for i, value in ipairs(self.list) do
            if lobby.window:button(box_2:old(16.0, 72.0 + (40.0 * (i - 1.0)), 160.0, 32.0), value.info) then
                local point = lobby.camera_3d.point + (lobby.camera_3d.focus - lobby.camera_3d.point):normalize() * 8.0
                point = point:snap(self.snap)

                local entity = {}
                entity.__help = {}
                entity.__help.index = i
                entity.point = vector_3:new(0.0, 0.0, 0.0)
                entity.angle = vector_3:new(0.0, 0.0, 0.0)
                entity.point:copy(point)
                if value.box then
                    entity.__help.active = true
                end

                table.restore_meta(entity)

                table.insert(self.entity, entity)
            end
        end
    end
end

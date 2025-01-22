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

---@enum widget_kind
local WIDGET_KIND = {
    POINT = 0,
    ANGLE = 1,
    SCALE = 2,
}
local ENTITY_LIST = {
    player = {
        box = box_3:new(
            vector_3:new(-0.5, -1.0, -0.5),
            vector_3:new(0.5, 1.0, 0.5)
        )
    },
    zombie = {
        box = box_3:new(
            vector_3:new(-0.5, -1.0, -0.5),
            vector_3:new(0.5, 1.0, 0.5)
        )
    },
    node = {
        box = box_3:new(
            vector_3:new(-0.5, -0.5, -0.5),
            vector_3:new(0.5, 0.5, 0.5)
        )
    },
    door = {
        box = box_3:new(
            vector_3:new(-0.5, -1.0, -0.5),
            vector_3:new(0.5, 1.0, 0.5)
        )
    }
}


local one_tenth = vector_3:new(0.1, 0.1, 0.1)
local color_x = color:new(255.0, 0.0, 0.0, 255.0)
local color_y = color:new(0.0, 255.0, 0.0, 255.0)
local color_z = color:new(0.0, 0.0, 255.0, 255.0)

---@class editor
---@field snap       number
---@field level_wire boolean
---@field level_file string | nil
---@field model_list table
---@field level_list table
---@field scroll     table
---@field widget     widget_kind
editor = {
    __meta = {}
}

---Create a new editor.
---@return editor value # The editor.
function editor:new(status)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type     = "editor"

    -- entity list.
    i.entity     = {}

    -- entity snap amount.
    i.snap       = 0.5

    -- wire-frame view.
    i.level_wire = true

    -- a list of every level-model in the video/level folder and every file in the level folder.
    i.model_list = status.system:list("video/level/")
    i.level_list = status.system:list("level/")

    -- scroll cache for create/re-load level, respectively.
    i.scroll     = { { 0.0, 0.0 }, { 0.0, 0.0 } }

    -- currently active editor widget.
    i.widget     = WIDGET_KIND.POINT

    -- editor camera3D/2D view.
    i.camera_3d  = camera_3d:new(vector_3:new(8.0, 2.5, 0.0), vector_3:new(0.0, 2.0, 0.0), vector_3:new(0.0, 1.0, 0.0),
        90.0, CAMERA_3D_KIND.PERSPECTIVE)
    i.camera_2d  = camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 1.0)

    -- load the main-bar asset data.
    status.system:set_texture("video/editor/point.png")
    status.system:set_texture("video/editor/angle.png")
    status.system:set_texture("video/editor/scale.png")
    status.system:set_texture("video/editor/save.png")
    status.system:set_texture("video/editor/load.png")
    status.system:set_texture("video/editor/exit.png")
    status.system:set_texture("video/editor/reload.png")

    return i
end

function editor:entity_input(index, entity)
    if entity.__help.active then
        -- delete every active entity.
        if quiver.input.board.get_press(INPUT_BOARD.DELETE) then
            table.remove(self.entity, index)
        end

        if quiver.input.board.get_down(INPUT_BOARD.L_CONTROL) then
            -- duplicate every active entity.
            if quiver.input.board.get_press(INPUT_BOARD.D) then
                -- clone the current entity...
                local i = table.copy(entity)

                -- restore meta-table.
                table.restore_meta(i)

                -- insert into the entity table.
                table.insert(self.entity, i)

                -- make sure they're not active, so we don't infinitely clone...
                entity.__help.active = false
            end
        else
            if not quiver.input.board.get_down(INPUT_BOARD.L_SHIFT) then
                local move = editor:widget_movement() * self.snap

                if self.widget == WIDGET_KIND.POINT then
                    if quiver.input.mouse.get_down(INPUT_MOUSE.MIDDLE) then
                        local x, y = quiver.input.mouse.get_delta()
                        move.x = x * 0.05
                        move.z = y * 0.05
                    end

                    if quiver.input.mouse.get_release(INPUT_MOUSE.MIDDLE) then
                        entity.point:copy(entity.point:snap(self.snap))
                    end

                    entity.point:copy(entity.point + move)
                elseif self.widget == WIDGET_KIND.ANGLE then
                    if quiver.input.mouse.get_press(INPUT_MOUSE.MIDDLE) then
                        entity.angle:set(0.0, 0.0, 0.0)
                    end

                    entity.angle:copy(entity.angle + (move * 10.0))
                else
                    if quiver.input.mouse.get_press(INPUT_MOUSE.MIDDLE) then
                        entity.scale:set(1.0, 1.0, 1.0)
                    end

                    entity.scale:copy(entity.scale + move)
                end
            end
        end
    else
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
    end
end

function editor:entity_paint(index, entity, box)
    local entity_color = color:red()

    if entity.__help.active then
        entity_color = color:green()

        for x = 0, 1 do
            for y = 0, 1 do
                for z = 0, 1 do
                    local point =
                        vector_3:old(
                            box.min.x * (1.0 - x) + box.max.x * x,
                            box.min.y * (1.0 - y) + box.max.y * y,
                            box.min.z * (1.0 - z) + box.max.z * z)

                    quiver.draw_3d.draw_cube(point, one_tenth, entity_color)

                    quiver.draw_3d.draw_line(point,
                        point + vector_3:old(-1.0 * (1.0 - x) + 1.0 * x, 0.0, 0.0),
                        entity_color)

                    quiver.draw_3d.draw_line(point,
                        point + vector_3:old(0.0, -1.0 * (1.0 - y) + 1.0 * y, 0.0),
                        entity_color)

                    quiver.draw_3d.draw_line(point,
                        point + vector_3:old(0.0, 0.0, -1.0 * (1.0 - z) + 1.0 * z),
                        entity_color)
                end
            end
        end

        local x, y, z = math.direction_from_euler(entity.angle)
        x = entity.point + x * 2.0
        y = entity.point + y * 2.0
        z = entity.point + z * 2.0

        quiver.draw_3d.draw_cube(x, one_tenth, color_x)
        quiver.draw_3d.draw_cube(y, one_tenth, color_y)
        quiver.draw_3d.draw_cube(z, one_tenth, color_z)

        quiver.draw_3d.draw_line(entity.point, x, color_x)
        quiver.draw_3d.draw_line(entity.point, y, color_y)
        quiver.draw_3d.draw_line(entity.point, z, color_z)
    end

    quiver.draw_3d.draw_box_3(box, entity_color)
end

function editor:draw(lobby, status)
    -- draw 3D view.
    quiver.draw_3d.begin(function() self:draw_3d(lobby, status) end, self.camera_3d)
    -- draw 2D view.
    quiver.draw_2d.begin(function() self:draw_2d(lobby, status) end, self.camera_2d)
end

function editor:draw_3d(lobby, status)
    if self.level_file then
        local hit_ray = nil
        local hit_which = nil
        local hit_where = nil

        if quiver.input.mouse.get_press(INPUT_MOUSE.LEFT) then
            local x, y = quiver.input.mouse.get_point()
            hit_ray    = ray:old(vector_3:zero(), vector_3:zero())
            hit_ray:pack(quiver.draw_3d.get_screen_to_world(self.camera_3d, vector_2:old(x, y),
                vector_2:old(quiver.window.get_shape())))
        end

        for i = #self.entity, 1, -1 do
            local entity = self.entity[i]
            local locate = ENTITY_LIST[entity.__help.locate]
            local locate_box = locate.box:scale(entity.scale):point(entity.point)

            if hit_ray then
                local collision = quiver.collision.ray_box(hit_ray, locate_box)

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

            self:entity_input(i, entity)
            self:entity_paint(i, entity, locate_box)
        end

        if hit_ray then
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

        if quiver.input.board.get_down(INPUT_BOARD.L_SHIFT) then
            local _, snap = quiver.input.mouse.get_wheel()
            local look = (self.camera_3d.focus - self.camera_3d.point):normalize()

            self.camera_3d.point:copy(self.camera_3d.point + look * snap * 4.0)
        end

        if quiver.input.mouse.get_down(INPUT_MOUSE.RIGHT) then
            local x, y = quiver.input.mouse.get_delta()
            x = x * 0.025
            y = y * 0.025

            self.camera_3d.point:copy(self.camera_3d.point + vector_3:old(x, 0.0, y))
            self.camera_3d.focus:copy(self.camera_3d.focus + vector_3:old(x, 0.0, y))
        end

        local level = status.system:get_model(self.level_file)

        if self.level_wire then
            level:draw_wire(vector_3:zero(), 1.0, color:old(255.0, 255.0, 255.0, 255.0))
        else
            level:draw(vector_3:zero(), 1.0, color:old(255.0, 255.0, 255.0, 255.0))
        end
    end
end

function editor:draw_2d(lobby, status)
    -- begin window.
    lobby.window:begin()

    if not self.level_file then
        local x, y = quiver.window.get_shape()
        local half = (x * 0.5) - 16.0
        local point_a = vector_2:old(16.0 + half * 0.0, 16.0)
        local point_b = vector_2:old(24.0 + half * 1.0, 16.0)
        local box_a = box_2:old(point_a.x, point_a.y + 32.0, half - 8.0, y - 64.0)
        local box_b = box_2:old(point_b.x, point_b.y + 32.0, half - 8.0, y - 64.0)

        quiver.draw_2d.draw_box_2_round(box_2:old(8.0, 8.0, x - 16.0, y - 16.0), 0.05, 4.0, color:grey())

        lobby.window:text(point_a, "Create Map", LOGGER_FONT, LOGGER_FONT_SCALE,
            LOGGER_FONT_SPACE, color:white())

        quiver.draw_2d.draw_box_2_round(box_a, 0.25, 4.0, color:grey())

        -- draw every available model to create a new level from.
        self.scroll[1][1], self.scroll[1][2] = lobby:scroll(status, box_a, self.scroll[1][1], self.scroll[1][2],
            function()
                for i, value in ipairs(self.model_list) do
                    if lobby:button(status, box_2:old(box_a.x + 8.0, box_a.y + 8.0 + (40.0 * (i - 1.0)), 320.0, 32.0), value) then
                        status.system:set_model(value)
                        self.level_file = value

                        -- update the camera.
                        self.camera_3d.point = vector_3:new(0.0, 8.0, 4.0)
                        self.camera_3d.focus = vector_3:new(0.0, 0.0, 0.0)
                        self.camera_3d.zoom = 90.0
                    end
                end
            end)

        lobby.window:text(point_b, "Reload Map", LOGGER_FONT, LOGGER_FONT_SCALE,
            LOGGER_FONT_SPACE, color:white())

        quiver.draw_2d.draw_box_2_round(box_b, 0.25, 4.0, color:grey())


        self.scroll[2][1], self.scroll[2][2] = lobby:scroll(status, box_b, self.scroll[2][1], self.scroll[2][2],
            function()
                for i, value in ipairs(self.level_list) do
                    if lobby:button(status, box_2:old(box_b.x + 8.0, box_b.y + 8.0 + (40.0 * (i - 1.0)), 320.0, 32.0), value) then
                        local data = quiver.file.get("asset/" .. value)
                        local data = quiver.general.deserialize(data)

                        for _, entity in ipairs(data.data) do
                            entity.__help = {
                                locate = entity.__type,
                                active = false
                            }
                            entity.__type = nil
                        end

                        status.system:set_model(data.file)
                        self.level_file = data.file

                        self.entity = data.data

                        table.restore_meta(self.entity)

                        -- update the camera.
                        self.camera_3d.point = vector_3:new(0.0, 8.0, 4.0)
                        self.camera_3d.focus = vector_3:new(0.0, 0.0, 0.0)
                        self.camera_3d.zoom = 90.0
                    end
                end
            end)
    else
        local function draw_main_bar(self)
            local x, y = quiver.window.get_shape()

            quiver.draw_2d.draw_box_2_round(box_2:old(8.0, 8.0, x - 16.0, 48.0), 0.25, 4.0, color:grey())

            if lobby:button_toggle(status, box_2:old(16.0 + (36.0 * 0.0), 16.0, 32.0, 32.0), "video/editor/point.png", not (self.widget == WIDGET_KIND.POINT)) then
                self.widget = WIDGET_KIND.POINT
            end
            if lobby:button_toggle(status, box_2:old(16.0 + (36.0 * 1.0), 16.0, 32.0, 32.0), "video/editor/angle.png", not (self.widget == WIDGET_KIND.ANGLE)) then
                self.widget = WIDGET_KIND.ANGLE
            end
            if lobby:button_toggle(status, box_2:old(16.0 + (36.0 * 2.0), 16.0, 32.0, 32.0), "video/editor/scale.png", not (self.widget == WIDGET_KIND.SCALE)) then
                self.widget = WIDGET_KIND.SCALE
            end
            if lobby:button(status, box_2:old(16.0 + (36.0 * 3.0), 16.0, 32.0, 32.0), "video/editor/save.png") then
                local save = {}
                save.file = self.level_file
                save.data = table.copy(self.entity)

                for _, entity in ipairs(save.data) do
                    entity.__type = entity.__help.locate
                    entity.__help = nil
                end

                local file = string.sub(self.level_file, #"video/level/" + 1.0)
                file = string.tokenize(file, "([^.]+)")[1]

                quiver.file.set("asset/level/" .. file .. ".json", quiver.general.serialize(save))
            end
            if lobby:button(status, box_2:old(16.0 + (36.0 * 4.0), 16.0, 32.0, 32.0), "video/editor/load.png") then
                lobby.editor = editor:new(status)
            end
            if lobby:button(status, box_2:old(16.0 + (36.0 * 5.0), 16.0, 32.0, 32.0), "video/editor/exit.png") then
                lobby.layout = 0.0
                lobby.editor = editor:new(status)
            end
            if lobby:button(status, box_2:old(16.0 + (36.0 * 6.0), 16.0, 32.0, 32.0), "video/editor/reload.png") then
                status.system:set_model(self.level_file, true)
            end
            self.level_wire = lobby:toggle(status, box_2:old(16.0 + (36.0 * 7.0), 16.0, 32.0, 32.0), "Wire",
                self.level_wire)

            self.snap = lobby:slider(status, box_2:old(16.0 + (36.0 * 11.0), 16.0, 128.0, 32.0), "Snap",
                self.snap, 0.25, 4.0, 0.25)
        end

        local function draw_side_bar(self)
            local x, y = quiver.window.get_shape()
            local box = box_2:old(8.0, 64.0, x * 0.5, y - 72.0)
            local half = (y * 0.5) - 48.0
            local point_a = vector_2:old(16.0, box.y + 8.0 * 1.0 + half * 0.0)
            local point_b = vector_2:old(16.0, box.y + 8.0 * 2.0 + half * 1.0)
            local box_a = box_2:old(point_a.x, point_a.y, box.width - 16.0, half)
            local box_b = box_2:old(point_b.x, point_b.y, box.width - 16.0, half)

            quiver.draw_2d.draw_box_2_round(box, 0.05, 4.0, color:grey())

            self.scroll[1][1], self.scroll[1][2] = lobby:scroll(status, box_a, self.scroll[1][1], self.scroll[1][2],
                function()
                    local i = 0.0

                    for name, value in pairs(ENTITY_LIST) do
                        if lobby:button(status, box_2:old(box_a.x + 4.0, box_a.y + 4.0 + (32.0 * i), box_a.width - 8.0, 32.0), name) then
                            local point = self.camera_3d.point +
                                (self.camera_3d.focus - self.camera_3d.point):normalize() * 8.0
                            point = point:snap(self.snap)

                            local entity = {}
                            entity.__help = {
                                locate = name,
                                active = true
                            }
                            entity.point = vector_3:new(0.0, 0.0, 0.0)
                            entity.angle = vector_3:new(0.0, 0.0, 0.0)
                            entity.scale = vector_3:new(1.0, 1.0, 1.0)
                            entity.point:copy(point)

                            table.restore_meta(entity)

                            table.insert(self.entity, entity)
                        end

                        i = i + 1.0
                    end
                end)
        end

        local point = vector_2:old(0.0, 0.0)
        local shape = vector_2:old(quiver.window.get_shape())

        for i = #self.entity, 1, -1 do
            local entity = self.entity[i]
            local locate = ENTITY_LIST[entity.__help.locate]

            local x = LOGGER_FONT:measure_text(entity.__help.locate, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE)
            x = x * 0.5

            point:set(quiver.draw_3d.get_world_to_screen(self.camera_3d,
                entity.point + vector_3:old(0.0, locate.box.max.y + 0.5, 0.0), shape))
            point.x = point.x - x

            LOGGER_FONT:draw(entity.__help.locate, point, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
                entity.__help.active and color:green() or color:red())
        end

        draw_main_bar(self)

        if quiver.input.board.get_down(INPUT_BOARD.TAB) then
            draw_side_bar(self)
        end
    end

    -- if the active device is not the mouse...
    if not (lobby.window.device == INPUT_DEVICE.MOUSE) then
        -- make it exclusively be the mouse.
        lobby.window:set_device(INPUT_DEVICE.MOUSE)
    end

    -- close window.
    lobby.window:close(true)
end

function editor:widget_movement()
    local result = vector_3:old(0.0, 0.0, 0.0)
    local key_w = (quiver.input.board.get_press(INPUT_BOARD.W) or quiver.input.board.get_press_repeat(INPUT_BOARD.W))
    local key_a = (quiver.input.board.get_press(INPUT_BOARD.A) or quiver.input.board.get_press_repeat(INPUT_BOARD.A))
    local key_s = (quiver.input.board.get_press(INPUT_BOARD.S) or quiver.input.board.get_press_repeat(INPUT_BOARD.S))
    local key_d = (quiver.input.board.get_press(INPUT_BOARD.D) or quiver.input.board.get_press_repeat(INPUT_BOARD.D))

    result.x = key_a and 1.0 * -1.0 or result.x
    result.x = key_d and 1.0 or result.x

    _, result.y = quiver.input.mouse.get_wheel()

    result.y = result.y

    result.z = key_w and 1.0 * -1.0 or result.z
    result.z = key_s and 1.0 or result.z

    return result
end

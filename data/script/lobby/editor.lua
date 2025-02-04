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
        data = {
            value_1 = 1.0,
            value_2 = 2.0,
            value_3 = 3.0,
            value_4 = false,
        },
        help = {
            box = box_3:new(
                vector_3:new(-0.5, -1.0, -0.5),
                vector_3:new(0.5, 1.0, 0.5)
            )
        }
    },
    zombie = {
        data = {
            value_1 = 1.0,
            value_2 = 2.0,
            value_3 = 3.0,
            value_4 = false,
        },
        help = {
            box = box_3:new(
                vector_3:new(-0.5, -1.0, -0.5),
                vector_3:new(0.5, 1.0, 0.5)
            )
        }
    },
    light = {
        data = {
        },
        help = {
            box = box_3:new(
                vector_3:new(-0.5, -0.5, -0.5),
                vector_3:new(0.5, 0.5, 0.5)
            )
        }
    },
    entry = {
        data = {
            entry_source = 0.0
        },
        help = {
            box = box_3:new(
                vector_3:new(-0.5, -0.5, -0.5),
                vector_3:new(0.5, 0.5, 0.5)
            )
        }
    },
    path = {
        data = {
            source = 0.0,
            target = 0.0,
            entry  = 0.0
        },
        help = {
            box = box_3:new(
                vector_3:new(-0.5, -0.5, -0.5),
                vector_3:new(0.5, 0.5, 0.5)
            ),
            link = {
                target = {
                    where = "source",
                    color = color:new(255.0, 0.0, 0.0, 255.0)
                },
                entry = {
                    where = "entry_source",
                    color = color:new(0.0, 255.0, 0.0, 255.0)
                },
            }
        }
    },
    text = {
        data = {
            index = 0.0
        },
        help = {
            box = box_3:new(
                vector_3:new(-0.5, -0.5, -0.5),
                vector_3:new(0.5, 0.5, 0.5)
            )
        }
    }
}
local ONE_TENTH = vector_3:new(0.1, 0.1, 0.1)
local COLOR_X = color:new(255.0, 0.0, 0.0, 255.0)
local COLOR_Y = color:new(0.0, 255.0, 0.0, 255.0)
local COLOR_Z = color:new(0.0, 0.0, 255.0, 255.0)
local MOUSE_SENSITIVITY = 0.025

---@class editor
---@field entity    table
---@field snap      number
---@field wire      boolean
---@field file      string | nil
---@field scroll    table
---@field widget    widget_kind
---@field camera_3d camera_3d
---@field camera_2d camera_2d
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

    i.__type = "editor"

    -- entity list.
    i.entity = {}

    -- entity snap amount.
    i.snap   = 0.5

    -- wire-frame view.
    i.wire   = false

    -- scroll cache for create/re-load level, respectively.
    i.scroll = { { 0.0, 0.0 }, { 0.0, 0.0 } }

    -- currently active editor widget.
    i.widget = WIDGET_KIND.POINT

    i.scene  = scene:new(status.system:get_shader("light"))

    i.scene.light:set_base_color(color:old(255.0, 255.0, 255.0, 255.0))

    i.scene.camera_3d = camera_3d:new(vector_3:new(4.0, 8.0, 0.0), vector_3:new(0.0, 0.0, 0.0),
        vector_3:new(0.0, 1.0, 0.0),
        90.0, CAMERA_3D_KIND.PERSPECTIVE)

    -- load texture.
    status.system:set_texture("video/editor/point.png")
    status.system:set_texture("video/editor/angle.png")
    status.system:set_texture("video/editor/scale.png")
    status.system:set_texture("video/editor/save.png")
    status.system:set_texture("video/editor/load.png")
    status.system:set_texture("video/editor/exit.png")
    status.system:set_texture("video/editor/reload.png")

    return i
end

function editor:draw(status)
    quiver.input.mouse.set_scale(vector_2:old(1.0, 1.0))

    -- draw 3D view.
    quiver.draw_3d.begin(function()
        self.scene.light:begin(nil, self.scene.camera_3d)

        self.scene.light:set_base_color(color:old(255.0, 255.0, 255.0, 255.0))

        self:draw_3d(status)
    end, self.scene.camera_3d)
    -- draw 2D view.
    quiver.draw_2d.begin(function() self:draw_2d(status) end, self.scene.camera_2d)
end

function editor:draw_3d(status)
    -- if there is a currently acitve file...
    if self.file then
        local mouse = vector_2:old(quiver.input.mouse.get_point())
        local shape = vector_2:old(quiver.window.get_shape())

        if quiver.collision.point_box(mouse, box_2:old(0.0, 64.0, shape.x - (256.0 + 16.0), shape.y)) then
            self:pick_entity()
            self:move_camera()
        end

        -- adjust snap count.
        if quiver.input.board.get_down(INPUT_BOARD.L_CONTROL) then
            local _, wheel = quiver.input.mouse.get_wheel()

            self.wheel = math.max(0.25, self.snap + wheel * 0.25)
        end

        -- for each entity in the entity list...
        for i = #self.entity, 1, -1 do
            -- get the entity.
            local entity = self.entity[i]

            -- run input and 3D draw logic for entity.
            self:entity_work(entity, i)
            self:entity_draw_3d(entity)
        end

        -- get level model.
        local level = status.system:get_model(self.file)

        -- if wire-frame mode is set...
        if self.wire then
            -- draw as wire-frame.
            level:draw_wire(vector_3:zero(), 1.0, color:old(255.0, 255.0, 255.0, 255.0))
        else
            -- draw normally.
            level:draw(vector_3:zero(), 1.0, color:old(255.0, 255.0, 255.0, 255.0))
        end
    end
end

function editor:draw_2d(status)
    -- begin window.
    status.lobby.window:begin()

    -- if there is a current level...
    if self.file then
        -- for every entity in the entity list...
        for _, entity in ipairs(self.entity) do
            -- run draw 2D logic for entity.
            self:draw_entity_2d(status, entity)
        end

        -- draw main and side panel.
        self:layout_main_bar(status)
        self:layout_side_bar(status)
    else
        self:layout_select(status)
    end

    -- if the active device is not the mouse...
    if not (status.lobby.window.device == INPUT_DEVICE.MOUSE) then
        -- make it exclusively be the mouse.
        status.lobby.window:set_device(INPUT_DEVICE.MOUSE)
    end

    -- close window.
    status.lobby.window:close(true)
end

--[[----------------------------------------------------------------]]

---Pick an entity in the world using the mouse.
function editor:pick_entity()
    -- if the l. mouse button was set off...
    if quiver.input.mouse.get_press(INPUT_MOUSE.LEFT) then
        -- get the mouse's point, screen shape.
        local mouse     = vector_2:old(quiver.input.mouse.get_point())
        local shape     = vector_2:old(quiver.window.get_shape())

        local hit_which = nil
        local hit_where = math.huge

        -- get a ray from the camera.
        local hit_ray   = ray:old(vector_3:zero(), vector_3:zero())
        hit_ray:pack(quiver.draw_3d.get_screen_to_world(self.scene.camera_3d, mouse, shape))

        for i, entity in ipairs(self.entity) do
            local locate = ENTITY_LIST[entity.__help.locate]
            local collision = quiver.collision.ray_box(hit_ray,
                locate.help.box
                :scale(entity.scale)
                :point(entity.point)
            )

            -- if ray hit entity...
            if collision.hit then
                -- if the distance to the hit is bigger than the previous hit...
                if hit_where > collision.distance then
                    -- store collision.
                    hit_which = i
                    hit_where = collision.distance
                end
            end
        end

        -- if there has been a collision with the ray...
        if hit_which then
            -- get the entity.
            local entity = self.entity[hit_which]

            -- if the l. shift key is not held down, mark every entity as in-active.
            if not quiver.input.board.get_down(INPUT_BOARD.L_SHIFT) then
                for _, entity in pairs(self.entity) do
                    entity.__help.active = false
                end
            end

            -- mark hit entity as active.
            entity.__help.active = true

            -- mark as last entity pick.
            self.last = hit_which
        else
            -- mark every entity as in-active.
            for _, entity in pairs(self.entity) do
                entity.__help.active = false
            end

            -- remove last entity pick.
            self.last = nil
        end
    end
end

---Move the camera.
function editor:move_camera()
    -- lock mouse.
    if quiver.input.mouse.get_press(INPUT_MOUSE.RIGHT) then
        quiver.input.mouse.set_active(false)
    end

    -- un-lock mouse.
    if quiver.input.mouse.get_release(INPUT_MOUSE.RIGHT) then
        quiver.input.mouse.set_active(true)
    end

    -- move camera on the X and Z axis.
    if quiver.input.mouse.get_down(INPUT_MOUSE.RIGHT) then
        local x, y = quiver.input.mouse.get_delta()
        x = x * MOUSE_SENSITIVITY * -1.0
        y = y * MOUSE_SENSITIVITY

        -- move camera.
        self.scene.camera_3d.point:copy(self.scene.camera_3d.point + vector_3:old(y, 0.0, x))
        self.scene.camera_3d.focus:copy(self.scene.camera_3d.focus + vector_3:old(y, 0.0, x))
    end

    -- move camera on the Y axis.
    if quiver.input.board.get_down(INPUT_BOARD.L_SHIFT) then
        local _, wheel = quiver.input.mouse.get_wheel()
        local look = (self.scene.camera_3d.focus - self.scene.camera_3d.point):normalize()

        self.scene.camera_3d.point:copy(self.scene.camera_3d.point + look * wheel * 4.0)
    end
end

---Layout: select.
---@param status status # The game status.
function editor:layout_select(status)
    local x, y = quiver.window.get_shape()
    local half = (x * 0.5) - 16.0
    local point_a = vector_2:old(16.0 + half * 0.0, 16.0)
    local point_b = vector_2:old(24.0 + half * 1.0, 16.0)
    local box_a = box_2:old(point_a.x, point_a.y + 32.0, half - 8.0, y - 64.0)
    local box_b = box_2:old(point_b.x, point_b.y + 32.0, half - 8.0, y - 64.0)

    quiver.draw_2d.draw_box_2_round(box_2:old(8.0, 8.0, x - 16.0, y - 16.0), 0.05, 4.0, color:grey())

    --[[]]

    status.lobby.window:text(point_a, "Create Map", status.system:get_font("video/font_side.ttf"), 24.0, 1.0,
        color:white())

    quiver.draw_2d.draw_box_2_round(box_a, 0.25, 4.0, color:grey())

    -- draw every available model to create a new level from.
    self.scroll[1][1], self.scroll[1][2] = status.lobby:scroll(status, box_a, self.scroll[1][1], self.scroll[1][2],
        function()
            for i, value in ipairs(status.system:list("video/level/")) do
                if status.lobby:button(status, box_2:old(box_a.x + 8.0, box_a.y + 8.0 + (40.0 * (i - 1.0)), 320.0, 32.0), value) then
                    local model = status.system:set_model(value)

                    -- load model.
                    for x = 1, model.material_count - 1.0 do
                        model:bind_shader(x, self.scene.light.shader)
                    end

                    self.file = value
                end
            end
        end)

    --[[]]

    status.lobby.window:text(point_b, "Reload Map", status.system:get_font("video/font_side.ttf"), 24.0,
        1.0, color:white())

    quiver.draw_2d.draw_box_2_round(box_b, 0.25, 4.0, color:grey())

    self.scroll[2][1], self.scroll[2][2] = status.lobby:scroll(status, box_b, self.scroll[2][1], self.scroll[2][2],
        function()
            for i, value in ipairs(status.system:list("level/")) do
                if status.lobby:button(status, box_2:old(box_b.x + 8.0, box_b.y + 8.0 + (40.0 * (i - 1.0)), 320.0, 32.0), value) then
                    local data = quiver.file.get("data/" .. value)
                    local data = quiver.general.deserialize(data)

                    for _, entity in ipairs(data.data) do
                        entity.__help = {
                            locate = entity.__type,
                            active = false
                        }
                        entity.__type = nil
                    end

                    local model = status.system:set_model(data.file)

                    -- load model.
                    for x = 1, model.material_count - 1.0 do
                        model:bind_shader(x, self.scene.light.shader)
                    end

                    self.file = data.file

                    self.entity = data.data

                    table.restore_meta(self.entity)
                end
            end
        end)
end

---Layout: main bar.
---@param status status # The game status.
function editor:layout_main_bar(status)
    -- get screen shape.
    local shape = vector_2:old(quiver.window.get_shape())

    -- draw background.
    quiver.draw_2d.draw_box_2_round(box_2:old(8.0, 8.0, shape.x - 16.0, 48.0), 0.25, 4.0, color:grey())

    -- widget panel.
    if status.lobby:button_toggle(status, box_2:old(16.0 + (36.0 * 0.0), 16.0, 32.0, 32.0), "Point|video/editor/point.png", not (self.widget == WIDGET_KIND.POINT)) then
        self.widget = WIDGET_KIND.POINT
    end
    if status.lobby:button_toggle(status, box_2:old(16.0 + (36.0 * 1.0), 16.0, 32.0, 32.0), "Angle|video/editor/angle.png", not (self.widget == WIDGET_KIND.ANGLE)) then
        self.widget = WIDGET_KIND.ANGLE
    end
    if status.lobby:button_toggle(status, box_2:old(16.0 + (36.0 * 2.0), 16.0, 32.0, 32.0), "Scale|video/editor/scale.png", not (self.widget == WIDGET_KIND.SCALE)) then
        self.widget = WIDGET_KIND.SCALE
    end

    -- save/load/exit/reload panel.
    if status.lobby:button(status, box_2:old(16.0 + (36.0 * 3.0), 16.0, 32.0, 32.0), "Save|video/editor/save.png") then
        -- create a save table, store level file, level data.
        local save = {}
        save.file = self.file
        save.data = table.copy(self.entity)

        -- for every entity in the save data...
        for _, entity in ipairs(save.data) do
            -- tag entity type, remove editor help table.
            entity.__type = entity.__help.locate
            entity.__help = nil
        end

        -- get model name, without leading path and extension.
        local file = string.sub(self.file, #"video/level/" + 1.0)
        file = string.tokenize(file, "([^.]+)")[1]

        -- serialize save file table, then save to .JSON file.
        quiver.file.set("data/level/" .. file .. ".json", quiver.general.serialize(save))
    end
    if status.lobby:button(status, box_2:old(16.0 + (36.0 * 4.0), 16.0, 32.0, 32.0), "Load|video/editor/load.png") then
        status.lobby.editor = editor:new(status)
    end
    if status.lobby:button(status, box_2:old(16.0 + (36.0 * 5.0), 16.0, 32.0, 32.0), "Exit|video/editor/exit.png") then
        status.lobby.layout = 1.0
        status.lobby.editor = editor:new(status)
    end
    if status.lobby:button(status, box_2:old(16.0 + (36.0 * 6.0), 16.0, 32.0, 32.0), "Reload|video/editor/reload.png") then
        status.system:set_model(self.file, true)
    end

    -- wire/snap panel.
    self.wire = status.lobby:toggle(status, box_2:old(16.0 + (36.0 * 7.0), 16.0, 32.0, 32.0), "Wire",
        self.wire)
    self.snap = status.lobby:slider(status, box_2:old(16.0 + (36.0 * 10.0), 16.0, 128.0, 32.0), "Snap",
        self.snap, 0.25, 4.0, 0.25)
end

---Layout: side bar.
---@param status status # The game status.
function editor:layout_side_bar(status)
    local shape = vector_2:old(quiver.window.get_shape())
    local box = box_2:old(shape.x - (256.0 + 16.0), 64.0, 256.0, shape.y - 72.0)
    local half = self.last and (shape.y * 0.5) - 48.0 or shape.y - 88.0
    local point_a = vector_2:old(box.x + 8.0, box.y + 8.0 * 1.0 + half * 0.0)
    local point_b = vector_2:old(box.x + 8.0, box.y + 8.0 * 2.0 + half * 1.0)
    local box_a = box_2:old(point_a.x, point_a.y, box.width - 16.0, half)
    local box_b = box_2:old(point_b.x, point_b.y, box.width - 16.0, half)

    -- draw background.
    quiver.draw_2d.draw_box_2_round(box, 0.05, 4.0, color:grey())

    self.scroll[1][1], self.scroll[1][2] = status.lobby:scroll(status, box_a, self.scroll[1][1], self.scroll[1][2],
        function()
            local i = 0.0

            -- for each entity in the entity reference list...
            for name, value in pairs(ENTITY_LIST) do
                -- draw button for the creation of a new entity.
                if status.lobby:button(status, box_2:old(box_a.x + 4.0, box_a.y + 4.0 + (36.0 * i), box_a.width - 8.0, 32.0), name) then
                    -- TO-DO this should really cast a ray from the camera view into the level.
                    local point = self.scene.camera_3d.point +
                        (self.scene.camera_3d.focus - self.scene.camera_3d.point):normalize() * 8.0
                    point = point:snap(self.snap)

                    -- create entity table, store a reference to the entity reference table entry, and make active.
                    local entity = table.copy(value.data)
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

    if self.last then
        self.scroll[2][1], self.scroll[2][2] = status.lobby:scroll(status, box_b, self.scroll[2][1], self.scroll[2][2],
            function()
                local i = 0.0

                local entity = self.entity[self.last]

                -- for each entity in the entity reference list...
                for name, value in pairs(entity) do
                    if type(value) == "number" then
                        local box = box_2:old(box_b.x + 4.0, box_b.y + 4.0 + (36.0 * i), box_b.width * 0.5, 32.0)

                        entity[name] = status.lobby:spinner(status, box, name, value)

                        i = i + 1.0
                    elseif type(value) == "boolean" then
                        local box = box_2:old(box_b.x + 4.0, box_b.y + 4.0 + (36.0 * i), 32.0, 32.0)

                        entity[name] = status.lobby:toggle(status, box, name, value)

                        i = i + 1.0
                    end
                end
            end)
    end
end

---Calculate the keyboard and mouse movement.
---@return vector_3 value # The movement.
function editor:widget_movement()
    local result = vector_3:old(0.0, 0.0, 0.0)
    local key_w = (quiver.input.board.get_press(INPUT_BOARD.W) or quiver.input.board.get_press_repeat(INPUT_BOARD.W))
    local key_a = (quiver.input.board.get_press(INPUT_BOARD.A) or quiver.input.board.get_press_repeat(INPUT_BOARD.A))
    local key_s = (quiver.input.board.get_press(INPUT_BOARD.S) or quiver.input.board.get_press_repeat(INPUT_BOARD.S))
    local key_d = (quiver.input.board.get_press(INPUT_BOARD.D) or quiver.input.board.get_press_repeat(INPUT_BOARD.D))

    result.z = key_a and 1.0 or result.z
    result.z = key_d and 1.0 * -1.0 or result.z

    _, result.y = quiver.input.mouse.get_wheel()

    result.x = key_w and 1.0 * -1.0 or result.x
    result.x = key_s and 1.0 or result.x

    return result
end

---Input logic for a given entity.
---@param entity table  # The entity.
---@param index  number # The entity index.
function editor:entity_work(entity, index)
    -- if entity is currently active...
    if entity.__help.active then
        -- delete every active entity.
        if quiver.input.board.get_press(INPUT_BOARD.DELETE) then
            -- if the entity to remove is the same as the "last" entity...
            if self.last == index then
                -- remove last.
                self.last = nil
            end

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

                    -- if middle mouse button has been let go, snap point.
                    if quiver.input.mouse.get_release(INPUT_MOUSE.MIDDLE) then
                        entity.point:copy(entity.point:snap(self.snap))
                    end

                    -- change the entity's point.
                    entity.point:copy(entity.point + move)
                elseif self.widget == WIDGET_KIND.ANGLE then
                    -- if middle mouse button has been set off, reset angle.
                    if quiver.input.mouse.get_press(INPUT_MOUSE.MIDDLE) then
                        entity.angle:set(0.0, 0.0, 0.0)
                    end

                    -- change the entity's angle.
                    entity.angle:copy(entity.angle + (move * 10.0))
                else
                    -- if middle mouse button has been set off, reset scale.
                    if quiver.input.mouse.get_press(INPUT_MOUSE.MIDDLE) then
                        entity.scale:set(1.0, 1.0, 1.0)
                    end

                    -- change the entity's scale.
                    entity.scale:copy(entity.scale + move)
                end
            end
        end
    else
        if quiver.input.board.get_down(INPUT_BOARD.L_CONTROL) then
            -- select every entity.
            if quiver.input.board.get_press(INPUT_BOARD.A) then
                entity.__help.active = true
            end
        end
    end
end

---3D draw logic for a given entity.
---@param entity table  # The entity.
function editor:entity_draw_3d(entity)
    -- set entity color.
    local entity_color = color:red()
    local locate = ENTITY_LIST[entity.__help.locate]
    local locate_box = locate.help.box:scale(entity.scale):point(entity.point)

    -- if entity is currently active...
    if entity.__help.active then
        entity_color = color:green()

        -- draw point help.
        for x = 0, 1 do
            for y = 0, 1 do
                for z = 0, 1 do
                    local point =
                        vector_3:old(
                            locate_box.min.x * (1.0 - x) + locate_box.max.x * x,
                            locate_box.min.y * (1.0 - y) + locate_box.max.y * y,
                            locate_box.min.z * (1.0 - z) + locate_box.max.z * z)

                    quiver.draw_3d.draw_cube(point, ONE_TENTH, entity_color)

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

        if locate.help.link then
            for target, data in pairs(locate.help.link) do
                for _, value in ipairs(self.entity) do
                    if value[data.where] == entity[target] then
                        quiver.draw_3d.draw_line(entity.point, value.point, data.color)
                    end
                end
            end
        end

        -- draw angle help.
        local x, y, z = math.direction_from_euler(entity.angle)
        x = entity.point + x * 2.0
        y = entity.point + y * 2.0
        z = entity.point + z * 2.0

        quiver.draw_3d.draw_cube(x, ONE_TENTH, COLOR_X)
        quiver.draw_3d.draw_cube(y, ONE_TENTH, COLOR_Y)
        quiver.draw_3d.draw_cube(z, ONE_TENTH, COLOR_Z)

        quiver.draw_3d.draw_line(entity.point, x, COLOR_X)
        quiver.draw_3d.draw_line(entity.point, y, COLOR_Y)
        quiver.draw_3d.draw_line(entity.point, z, COLOR_Z)
    end

    if entity.__help.locate == "light" then
        self.scene.light:light_point(entity.point,
            color:red())
    end

    -- draw bound box.
    quiver.draw_3d.draw_box_3(locate_box, entity_color)
end

---2D draw logic for a given entity.
---@param entity table  # The entity.
function editor:draw_entity_2d(status, entity)
    local point  = vector_2:old(0.0, 0.0)
    local shape  = vector_2:old(quiver.window.get_shape())
    local locate = ENTITY_LIST[entity.__help.locate]

    --[[]]

    -- measure the name of the entity.
    local x = status.system:get_font("video/font_side.ttf"):measure_text(entity.__help.locate, 24.0,
        1.0)
    x       = x * 0.5

    -- get the 2D screen position for the 3D world position of the name.
    point:set(quiver.draw_3d.get_world_to_screen(self.scene.camera_3d,
        entity.point + vector_3:old(0.0, locate.help.box.max.y + 0.5, 0.0), shape))

    -- center text.
    point.x = point.x - x

    -- draw text.
    status.system:get_font("video/font_side.ttf"):draw(entity.__help.locate, point, 24.0, 1.0,
        entity.__help.active and color:green() or color:red())
end

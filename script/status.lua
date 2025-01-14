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

local TIME_STEP = 1.0 / 60.0

---@class status
---@field active boolean
---@field dialog dialog
---@field system file_system
---@field entity table
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

    i.__type       = "status"
    i.active       = true
    i.dialog       = dialog:new()
    i.system       = file_system:new({
        "asset"
    })
    i.camera_3d    = camera_3d:new(vector_3:new(4.0, 4.0, 4.0), vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 1.0, 0.0),
        90.0, CAMERA_3D_KIND.PERSPECTIVE)
    i.camera_2d    = camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 1.0)
    i.user         = user:new(i)

    i.time         = 0.0
    i.step         = 0.0
    i.credit       = 250.0
    i.hunter       = {
        hunter:new(i)
    }
    i.weapon       = {
        weapon:new(i),
        weapon:new(i),
    }
    i.ability      = {
        ability:new(i),
        ability:new(i),
    }
    i.item         = {
    }
    i.entity       = {}
    i.entity_index = 0.0
    i.rapier       = quiver.rapier:new()

    -- over-ride default print function with our own.
    print          = function(...)
        i.dialog.logger:print(..., color:new(255.0, 255.0, 255.0, 255.0))
    end

    local tex_a    = i.system:set_texture("video/map/black/texture_08.png")
    local tex_b    = i.system:set_texture("video/map/white/texture_08.png")

    local menu     = i.system:set_model("video/menu.gltf")
    menu:bind(1.0, 0.0, tex_a)
    menu:bind(2.0, 0.0, tex_b)

    local menu = i.system:set_model("video/test.glb")
    menu:bind(0.0, 0.0, tex_a)
    menu:bind(1.0, 0.0, tex_b)

    return i
end

---Initialize a new map.
---@param map string # The map name.
function status:initialize_map(map)
    if not (self.dialog.window.device == INPUT_DEVICE.PAD) then
        self.dialog.window:set_device(INPUT_DEVICE.MOUSE)
        quiver.input.mouse.set_hidden(true)
    end

    self.dialog.layout = 0.0
    self.dialog.active = false
    self.time = 0.0
    self.step = 0.0
    self.entity = {}
    self.entity_index = 0.0
    self.rapier = quiver.rapier:new()

    self.player = player:new(self)
    self.map = map

    local tex_a = self.system:get_texture("video/map/black/texture_08.png")
    local tex_b = self.system:get_texture("video/map/white/texture_08.png")

    local model = self.system:set_model(map)
    model:bind(0.0, 0.0, tex_a)
    model:bind(1.0, 0.0, tex_b)

    for x = 0, model.mesh_count - 1.0 do
        local collider = self.rapier:collider_builder_convex_hull(model:mesh_vertex(x))
        self.rapier:collider_insert(collider)
    end
end

---Attach an entity from the entity game status.
---@param attach entity # The entity to attach.
function status:entity_attach(attach)
    -- add index to entity.
    attach.index = self.entity_index

    -- add entity to table.
    self.entity[tostring(attach.index)] = attach

    -- increase index.
    self.entity_index = self.entity_index + 1.0
end

---Detach an entity from the entity game status.
---@param detach entity # The entity to detach.
function status:entity_detach(detach)
    -- remove entity from table.
    self.entity[tostring(detach.index)] = nil
end

function status:tick()
    if not self.dialog.active then
        local delta = math.min(quiver.general.get_frame_time(), 0.25)

        self.step = self.step + delta

        while self.step >= TIME_STEP do
            for _, entity in pairs(self.entity) do
                if entity.tick then
                    -- save entity point, angle.
                    entity.old_point:copy(entity.point)
                    entity.old_angle:copy(entity.angle)

                    entity:tick(self, TIME_STEP)
                end
            end

            self.rapier:step(function(c_1, c_2)
                table.print(c_1, c_2)
            end
            )
            self.time = self.time + TIME_STEP
            self.step = self.step - TIME_STEP
        end
    end
end

function status:draw_3d()
    local alpha = self.step / TIME_STEP

    if not self.dialog.active then
        local new_point = vector_3:zero()
        local new_angle = vector_3:zero()

        for _, entity in pairs(self.entity) do
            if entity.draw_3d then
                -- save entity point, angle.
                new_point:copy(entity.point)
                new_angle:copy(entity.angle)

                -- interpolate old/new point, angle.
                entity.point:copy(entity.point * alpha + entity.old_point * (1.0 - alpha))
                entity.angle:copy(entity.angle * alpha + entity.old_angle * (1.0 - alpha))

                entity:draw_3d(self)

                -- load entity point, angle.
                entity.point:copy(new_point)
                entity.angle:copy(new_angle)
            end
        end

        local model = self.system:get_model(self.map)
        model:draw(vector_3:zero(), 1.0, color:white())

        self.rapier:debug_render()
    else
        self.dialog:draw_3d(self)
    end
end

function status:draw_2d()
    if not self.dialog.active then
        for _, entity in pairs(self.entity) do
            if entity.draw_2d then
                entity:draw_2d(self)
            end
        end
    end

    self.dialog:draw_2d(self)
end

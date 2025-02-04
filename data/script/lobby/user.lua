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

local USER_FILE = "user.json"

---@class user
---@field video table
---@field audio table
---@field input table
user = {
    __meta = {}
}

---Load the user data. WARNING: user file must exist!
---@param status status # The game status.
---@return user value # The user.
local function user_load(status)
    -- load the data from the user data file, deserialize, and restore the meta-table.
    local i = quiver.general.deserialize(quiver.file.get(USER_FILE))
    table.restore_meta(i)

    -- apply user data.
    i:apply(status)

    return i
end

---Create a new user. The data may vary depending on whether or not an existing user data file does exist.
---@param status status # The game status.
---@return user value # The user.
function user:new(status)
    -- if the user data file does exist...
    if quiver.file.get_file_exist(USER_FILE) then
        -- return user data.
        return user_load(status)
    else
        -- return user data (default).
        return self:default(status)
    end
end

---Load the user data (default).
---@param status status # The game status.
---@return user value # The user.
function user:default(status)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "user"

    i.video = {
        full         = true,
        frame        = 60.0,
        field        = 90.0,
        camera_shake = 1.0,
        camera_walk  = 1.0,
        camera_tilt  = 1.0,
        light        = 0.0,
        gamma        = 1.0,
        glyph        = 0.0,
    }

    i.audio = {
        sound = 1.0,
        music = 1.0,
    }

    i.input = {
        pad_stick           = 0.0,
        pad_dead_zone_x     = 0.1,
        pad_dead_zone_y     = 0.1,
        pad_rumble          = 1.0,
        mouse_sensitivity_x = 0.1,
        mouse_sensitivity_y = 0.1,
        move_x_a            = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.W)
        }),
        move_x_b            = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.S)
        }),
        move_y_a            = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.A)
        }),
        move_y_b            = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.D)
        }),
        lean_a              = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.Q)
        }),
        lean_b              = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.E)
        }),
        sprint              = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.L_SHIFT)
        }),
        crouch              = action:new({
            action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.L_CONTROL)
        }),
        weapon_fire         = action:new({
            action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.LEFT)
        }),
        weapon_swap         = action:new({
            action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.RIGHT)
        })
    }

    i.developer = true

    -- apply user data.
    i:apply(status)

    return i
end

---Save the user data.
function user:save()
    quiver.file.set(USER_FILE, quiver.general.serialize(self))
end

---Apply all user data.
---@param status status # The game status.
function user:apply(status)
    if not quiver.window.get_state(WINDOW_FLAG.RESIZABLE) then
        -- set window as resizable.
        quiver.window.set_state(WINDOW_FLAG.RESIZABLE, true)
    end

    if self.video.full then
        -- set the shape of the window to be the same as the current monitor's shape.
        quiver.window.set_shape(vector_2:old(quiver.window.get_screen_shape(quiver.window.get_screen_focus())))
    end

    -- set full-screen mode.
    quiver.window.set_state(WINDOW_FLAG.FULLSCREEN_MODE, self.video.full)

    -- set frame rate.
    quiver.general.set_frame_rate(self.video.frame)

    -- set exit key.
    quiver.general.set_exit_key(INPUT_BOARD.NULL)
end

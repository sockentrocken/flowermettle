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
---@field video_full       boolean
---@field video_frame      number
---@field video_shake      number
---@field video_view       number
---@field video_menu       number
---@field video_light      number
---@field video_gamma      number
---@field video_cross      number
---@field video_language   number
---@field video_glyph      number
---@field audio_sound      number
---@field audio_music      number
---@field input_pad_look   number
---@field input_pad_assist number
---@field input_pad_rumble number
---@field input_move_x_a   action
---@field input_move_x_b   action
---@field input_move_y_a   action
---@field input_move_y_b   action
---@field input_weapon_a   action
---@field input_weapon_b   action
---@field input_ability_a  action
---@field input_ability_b  action
---@field input_item_a  action
---@field input_item_b  action
user = {
    __meta = {}
}

---Get the correct 2D camera zoom rate.
---@param self # The user.
---@return number zoom # The zoom rate.
local function user_zoom(self)
    if self.video_menu == 0.0 then
        return 1.0
    end

    return self.video_menu * 0.25
end

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

    --[[ video. ]]
    i.video_full     = true
    i.video_frame    = 60.0
    i.video_view     = 1.0
    i.video_menu     = 0.0
    i.video_shake    = 1.0
    i.video_light    = 0.0
    i.video_gamma    = 1.0
    i.video_cross    = 1.0
    i.video_language = 1.0
    i.video_glyph    = 0.0

    --[[ audio. ]]
    i.audio_sound = 1.0
    i.audio_music = 1.0

    --[[ input. ]]
    i.input_pad_look   = 1.0
    i.input_pad_assist = 1.0
    i.input_pad_rumble = 1.0
    i.input_move_x_a   = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.W)
    })
    i.input_move_x_b   = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.S)
    })
    i.input_move_y_a   = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.A)
    })
    i.input_move_y_b   = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.D)
    })
    i.input_weapon_a   = action:new({
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.LEFT),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_TRIGGER_2)
    })
    i.input_weapon_b   = action:new({
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.RIGHT),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_TRIGGER_2)
    })
    i.input_ability_a  = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.Q),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_TRIGGER_1)
    })
    i.input_ability_b  = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.E),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_TRIGGER_1)
    })
    i.input_item_a     = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.Z),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_FACE_LEFT)
    })
    i.input_item_b     = action:new({
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.C),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_FACE_RIGHT)
    })

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

    -- set the shape of the window to be the same as the current monitor's shape.
    quiver.window.set_shape(vector_2:old(quiver.window.get_screen_shape(quiver.window.get_screen_focus())))

    -- set full-screen mode.
    quiver.window.set_state(WINDOW_FLAG.FULLSCREEN_MODE, self.video_full)

    -- set frame rate.
    quiver.general.set_frame_rate(self.video_frame)

    -- set exit key.
    quiver.general.set_exit_key(INPUT_BOARD.NULL)

    status.camera_2d.zoom = user_zoom(self)
    quiver.input.mouse.set_scale(vector_2:old(1.0 / user_zoom(self), 1.0 / user_zoom(self)))
end

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

---@class action_button
---@field device input_device
---@field button number
action_button = {
    __meta = {}
}

---Create a new action button.
---@param device input_device #
function action_button:new(device, button)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "action_button"
    i.device = device
    i.button = button

    return i
end

local function check_device(action_button, active_device, check_device)
    if active_device then
        return action_button.device == check_device and active_device == check_device
    else
        return action_button.device == check_device
    end
end

function action_button:name()
    if self.device == INPUT_DEVICE.BOARD then
        return INPUT_BOARD[self.button]
    end
    if self.device == INPUT_DEVICE.MOUSE then
        return INPUT_MOUSE[self.button]
    end
    if self.device == INPUT_DEVICE.PAD then
        return INPUT_PAD[self.button]
    end

    error("action_button::name(): Unknown device.")
end

function action_button:up(active_device)
    if check_device(self, active_device, INPUT_DEVICE.BOARD) then
        return quiver.input.board.get_up(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.MOUSE) then
        return quiver.input.mouse.get_up(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.PAD) then
        return quiver.input.pad.get_up(0.0, self.button)
    end

    return false
end

function action_button:down(active_device)
    if check_device(self, active_device, INPUT_DEVICE.BOARD) then
        return quiver.input.board.get_down(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.MOUSE) then
        return quiver.input.mouse.get_down(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.PAD) then
        return quiver.input.pad.get_down(0.0, self.button)
    end

    return false
end

function action_button:press(active_device)
    if check_device(self, active_device, INPUT_DEVICE.BOARD) then
        return quiver.input.board.get_press(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.MOUSE) then
        return quiver.input.mouse.get_press(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.PAD) then
        return quiver.input.pad.get_press(0.0, self.button)
    end

    return false
end

function action_button:release(active_device)
    if check_device(self, active_device, INPUT_DEVICE.BOARD) then
        return quiver.input.board.get_release(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.MOUSE) then
        return quiver.input.mouse.get_release(self.button)
    end
    if check_device(self, active_device, INPUT_DEVICE.PAD) then
        return quiver.input.pad.get_release(0.0, self.button)
    end

    return false
end

---@class action
---@field list table
action = {
    __meta = {}
}

---Create a new action.
---@param  button_list table # A table array of every action button to be bound to this action.
---@return action      value # The action.
function action:new(button_list)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "action"
    i.list = button_list

    return i
end

function action:attach(button)
    -- iterate over every button in our button list.
    for i, list_button in ipairs(self.list) do
        if list_button.device == button.device and list_button.button == button.button then
            return nil
        end
    end

    table.insert(self.list, button)
end

function action:up(active_device)
    -- iterate over every button in our button list.
    for i, button in ipairs(self.list) do
        if button:up(active_device) then
            return true, i
        end
    end

    return false, nil
end

function action:down(active_device)
    -- iterate over every button in our button list.
    for i, button in ipairs(self.list) do
        if button:down(active_device) then
            return true, i
        end
    end

    return false, nil
end

function action:press(active_device)
    -- iterate over every button in our button list.
    for i, button in ipairs(self.list) do
        if button:press(active_device) then
            return true, i
        end
    end

    return false, nil
end

function action:release(active_device)
    -- iterate over every button in our button list.
    for i, button in ipairs(self.list) do
        if button:release(active_device) then
            return true, i
        end
    end

    return false, nil
end

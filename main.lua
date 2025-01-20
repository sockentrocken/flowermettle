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

require "script/base"
require "script/status"
require "script/lobby/lobby"
require "script/inner/inner"
require "script/outer/outer"

--[[----------------------------------------------------------------]]

function quiver.main()
    -- create the game state.
    local status = status:new()

    -- while window should remain open and status is active...
    while not quiver.window.get_close() and status.active do
        -- re-load quiver.
        if quiver.input.board.get_press(INPUT_BOARD.F1) then
            break
        end

        -- draw state.
        quiver.draw.begin(function() status:draw() end)
    end

    -- save user data.
    status.lobby.user:save()

    return quiver.input.board.get_press(INPUT_BOARD.F1)
end

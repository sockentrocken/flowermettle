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
require "script/user"
require "script/dialog"
require "script/editor"
require "script/entity"
require "script/player"
require "script/hunter"
require "script/weapon"
require "script/ability"
require "script/item"

--[[----------------------------------------------------------------]]

local global_status = status:new()

function quiver.main()
    while not quiver.window.get_close() and global_status.active do
        if quiver.input.board.get_press(INPUT_BOARD.F1) then
            break
        end

        table_pool:clear()

        global_status:tick()

        table_pool:clear()

        quiver.draw.begin(draw)
    end

    global_status.user:save()

    return quiver.input.board.get_press(INPUT_BOARD.F1)
end

--[[----------------------------------------------------------------]]

function draw()
    quiver.draw.clear(color:black())
    quiver.draw_3d.begin(draw_3d, global_status.camera_3d)
    quiver.draw_2d.begin(draw_2d, global_status.camera_2d)
end

--[[----------------------------------------------------------------]]

function draw_3d()
    global_status:draw_3d()
end

--[[----------------------------------------------------------------]]

function draw_2d()
    global_status:draw_2d()
end

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

bit             = require("bit")

---@enum rigid_body_kind
RIGID_BODY_KIND = {
    DYNAMIC                  = "Dynamic",
    FIXED                    = "Fixed",
    KINEMATIC_POSITION_BASED = "KinematicPositionBased",
    KINEMATIC_VELOCITY_BASED = "KinematicVelocityBased",
}

---@enum input_device
INPUT_DEVICE    = {
    BOARD = 0,
    MOUSE = 1,
    PAD   = 2,
}

---@enum input_board
INPUT_BOARD     = {
    NULL          = 0,
    APOSTROPHE    = 39,
    COMMA         = 44,
    MINUS         = 45,
    PERIOD        = 46,
    SLASH         = 47,
    ZERO          = 48,
    ONE           = 49,
    TWO           = 50,
    THREE         = 51,
    FOUR          = 52,
    FIVE          = 53,
    SIX           = 54,
    SEVEN         = 55,
    EIGHT         = 56,
    NINE          = 57,
    SEMICOLON     = 59,
    EQUAL         = 61,
    A             = 65,
    B             = 66,
    C             = 67,
    D             = 68,
    E             = 69,
    F             = 70,
    G             = 71,
    H             = 72,
    I             = 73,
    J             = 74,
    K             = 75,
    L             = 76,
    M             = 77,
    N             = 78,
    O             = 79,
    P             = 80,
    Q             = 81,
    R             = 82,
    S             = 83,
    T             = 84,
    U             = 85,
    V             = 86,
    W             = 87,
    X             = 88,
    Y             = 89,
    Z             = 90,
    LEFT_BRACKET  = 91,
    BACKSLASH     = 92,
    RIGHT_BRACKET = 93,
    GRAVE         = 96,
    SPACE         = 32,
    ESCAPE        = 256,
    RETURN        = 257,
    TAB           = 258,
    BACKSPACE     = 259,
    INSERT        = 260,
    DELETE        = 261,
    RIGHT         = 262,
    LEFT          = 263,
    DOWN          = 264,
    UP            = 265,
    PAGE_UP       = 266,
    PAGE_DOWN     = 267,
    HOME          = 268,
    END           = 269,
    CAPS_LOCK     = 280,
    SCROLL_LOCK   = 281,
    NUMBER_LOCK   = 282,
    PRINT_SCREEN  = 283,
    PAUSE         = 284,
    F1            = 290,
    F2            = 291,
    F3            = 292,
    F4            = 293,
    F5            = 294,
    F6            = 295,
    F7            = 296,
    F8            = 297,
    F9            = 298,
    F10           = 299,
    F11           = 300,
    F12           = 301,
    L_SHIFT       = 340,
    L_CONTROL     = 341,
    L_ALTERNATE   = 342,
    L_SUPER       = 343,
    R_SHIFT       = 344,
    R_CONTROL     = 345,
    R_ALTERNATE   = 346,
    R_SUPER       = 347,
    KB_MENU       = 348,
    KP_0          = 320,
    KP_1          = 321,
    KP_2          = 322,
    KP_3          = 323,
    KP_4          = 324,
    KP_5          = 325,
    KP_6          = 326,
    KP_7          = 327,
    KP_8          = 328,
    KP_9          = 329,
    KP_DECIMAL    = 330,
    KP_DIVIDE     = 331,
    KP_MULTIPLY   = 332,
    KP_SUBTRACT   = 333,
    KP_ADD        = 334,
    KP_ENTER      = 335,
    KP_EQUAL      = 336,
    BACK          = 4,
    VOLUME_UP     = 24,
    VOLUME_DOWN   = 25,
    [0]           = "Unknown",
    [39]          = "'",
    [44]          = ",",
    [45]          = "-",
    [46]          = ".",
    [47]          = "/",
    [48]          = "0",
    [49]          = "1",
    [50]          = "2",
    [51]          = "3",
    [52]          = "4",
    [53]          = "5",
    [54]          = "6",
    [55]          = "7",
    [56]          = "8",
    [57]          = "9",
    [59]          = ";",
    [61]          = "=",
    [65]          = "A",
    [66]          = "B",
    [67]          = "C",
    [68]          = "D",
    [69]          = "E",
    [70]          = "F",
    [71]          = "G",
    [72]          = "H",
    [73]          = "I",
    [74]          = "J",
    [75]          = "K",
    [76]          = "L",
    [77]          = "M",
    [78]          = "N",
    [79]          = "O",
    [80]          = "P",
    [81]          = "Q",
    [82]          = "R",
    [83]          = "S",
    [84]          = "T",
    [85]          = "U",
    [86]          = "V",
    [87]          = "W",
    [88]          = "X",
    [89]          = "Y",
    [90]          = "Z",
    [91]          = "{",
    [92]          = "\\",
    [93]          = "}",
    [96]          = "`",
    [32]          = "Space",
    [256]         = "Escape",
    [257]         = "Return",
    [258]         = "Tab",
    [259]         = "Backspace",
    [260]         = "Insert",
    [261]         = "Delete",
    [262]         = "Right",
    [263]         = "Left",
    [264]         = "Down",
    [265]         = "Up",
    [266]         = "Page Up",
    [267]         = "Page Down",
    [268]         = "Home",
    [269]         = "End",
    [280]         = "Caps Lock",
    [281]         = "Scroll Lock",
    [282]         = "Number Lock",
    [283]         = "Print Screen",
    [284]         = "Pause",
    [290]         = "F1",
    [291]         = "F2",
    [292]         = "F3",
    [293]         = "F4",
    [294]         = "F5",
    [295]         = "F6",
    [296]         = "F7",
    [297]         = "F8",
    [298]         = "F9",
    [299]         = "F10",
    [300]         = "F11",
    [301]         = "F12",
    [340]         = "L. Shift",
    [341]         = "L. Control",
    [342]         = "L. Alternate",
    [343]         = "L. Super",
    [344]         = "R. Shift",
    [345]         = "R. Control",
    [346]         = "R. Alternate",
    [347]         = "R. Super",
    [348]         = "Menu",
    [320]         = "Pad 0",
    [321]         = "Pad 1",
    [322]         = "Pad 2",
    [323]         = "Pad 3",
    [324]         = "Pad 4",
    [325]         = "Pad 5",
    [326]         = "Pad 6",
    [327]         = "Pad 7",
    [328]         = "Pad 8",
    [329]         = "Pad 9",
    [330]         = "Pad .",
    [331]         = "Pad /",
    [332]         = "Pad *",
    [333]         = "Pad -",
    [334]         = "Pad +",
    [335]         = "Pad Return",
    [336]         = "Pad =",
    [4]           = "Back",
    [24]          = "Volume Up",
    [25]          = "Volume Down",
}

---@enum input_mouse
INPUT_MOUSE     = {
    LEFT    = 0,
    RIGHT   = 1,
    MIDDLE  = 2,
    SIDE    = 3,
    EXTRA   = 4,
    FORWARD = 5,
    BACK    = 6,
    [0]     = "Mouse 0",
    [1]     = "Mouse 1",
    [2]     = "Mouse 2",
    [3]     = "Mouse 3",
    [4]     = "Mouse 4",
    [5]     = "Mouse 5",
    [6]     = "Mouse &",
}

---@enum cursor_mouse
CURSOR_MOUSE    = {
    DEFAULT       = 0,
    ARROW         = 1,
    IBEAM         = 2,
    CROSSHAIR     = 3,
    POINTING_HAND = 4,
    RESIZE_EW     = 5,
    RESIZE_NS     = 6,
    RESIZE_NWSE   = 7,
    RESIZE_NESW   = 8,
    RESIZE_ALL    = 9,
    NOT_ALLOWED   = 10
}

---@enum input_pad
INPUT_PAD       = {
    NULL             = 0,
    LEFT_FACE_UP     = 1,
    LEFT_FACE_RIGHT  = 2,
    LEFT_FACE_DOWN   = 3,
    LEFT_FACE_LEFT   = 4,
    RIGHT_FACE_UP    = 5,
    RIGHT_FACE_RIGHT = 6,
    RIGHT_FACE_DOWN  = 7,
    RIGHT_FACE_LEFT  = 8,
    LEFT_TRIGGER_1   = 9,
    LEFT_TRIGGER_2   = 10,
    RIGHT_TRIGGER_1  = 11,
    RIGHT_TRIGGER_2  = 12,
    MIDDLE_LEFT      = 13,
    MIDDLE           = 14,
    MIDDLE_RIGHT     = 15,
    LEFT_THUMB       = 16,
    RIGHT_THUMB      = 17,
    [0]              = "Unknown",
    [1]              = "L. Up",
    [2]              = "L. Right",
    [3]              = "L. Down",
    [4]              = "L. Left",
    [5]              = "R. Up",
    [6]              = "R. Right",
    [7]              = "R. Down",
    [8]              = "R. Left",
    [9]              = "L. Trigger 1",
    [10]             = "L. Trigger 2",
    [11]             = "R. Trigger 1",
    [12]             = "R. Trigger 2",
    [13]             = "Middle L.",
    [14]             = "Middle",
    [15]             = "Middle R.",
    [16]             = "L. Thumb",
    [17]             = "R. Thumb",
}

---@enum shader_location
SHADER_LOCATION = {
    VERTEX_POSITION    = 0,  -- Shader location: vertex attribute: position
    VERTEX_TEXCOORD01  = 1,  -- Shader location: vertex attribute: texcoord01
    VERTEX_TEXCOORD02  = 2,  -- Shader location: vertex attribute: texcoord02
    VERTEX_NORMAL      = 3,  -- Shader location: vertex attribute: normal
    VERTEX_TANGENT     = 4,  -- Shader location: vertex attribute: tangent
    VERTEX_COLOR       = 5,  -- Shader location: vertex attribute: color
    MATRIX_MVP         = 6,  -- Shader location: matrix uniform: model-view-projection
    MATRIX_VIEW        = 7,  -- Shader location: matrix uniform: view (camera transform)
    MATRIX_PROJECTION  = 8,  -- Shader location: matrix uniform: projection
    MATRIX_MODEL       = 9,  -- Shader location: matrix uniform: model (transform)
    MATRIX_NORMAL      = 10, -- Shader location: matrix uniform: normal
    VECTOR_VIEW        = 11, -- Shader location: vector uniform: view
    COLOR_DIFFUSE      = 12, -- Shader location: vector uniform: diffuse color
    COLOR_SPECULAR     = 13, -- Shader location: vector uniform: specular color
    COLOR_AMBIENT      = 14, -- Shader location: vector uniform: ambient color
    MAP_ALBEDO         = 15, -- Shader location: sampler2d texture: albedo (same as: SHADER_LOC_MAP_DIFFUSE)
    MAP_METALNESS      = 16, -- Shader location: sampler2d texture: metalness (same as: SHADER_LOC_MAP_SPECULAR)
    MAP_NORMAL         = 17, -- Shader location: sampler2d texture: normal
    MAP_ROUGHNESS      = 18, -- Shader location: sampler2d texture: roughness
    MAP_OCCLUSION      = 19, -- Shader location: sampler2d texture: occlusion
    MAP_EMISSION       = 20, -- Shader location: sampler2d texture: emission
    MAP_HEIGHT         = 21, -- Shader location: sampler2d texture: height
    MAP_CUBEMAP        = 22, -- Shader location: samplerCube texture: cubemap
    MAP_IRRADIANCE     = 23, -- Shader location: samplerCube texture: irradiance
    MAP_PREFILTER      = 24, -- Shader location: samplerCube texture: prefilter
    MAP_BRDF           = 25, -- Shader location: sampler2d texture: brdf
    VERTEX_BONEIDS     = 26, -- Shader location: vertex attribute: boneIds
    VERTEX_BONEWEIGHTS = 27, -- Shader location: vertex attribute: boneWeights
    BONE_MATRICES      = 28, -- Shader location: array of matrices uniform: boneMatrices
    VERTEX_INSTANCE_TX = 29  -- Shader location: vertex attribute: instanceTransform
}

---@enum window_flag
WINDOW_FLAG     = {
    VSYNC_HINT               = 0x00000040, -- Set to try enabling V-Sync on GPU
    FULLSCREEN_MODE          = 0x00000002, -- Set to run program in fullscreen
    RESIZABLE                = 0x00000004, -- Set to allow resizable window
    UNDECORATED              = 0x00000008, -- Set to disable window decoration (window and buttons)
    HIDDEN                   = 0x00000080, -- Set to hide window
    MINIMIZED                = 0x00000200, -- Set to minimize window (iconify)
    MAXIMIZED                = 0x00000400, -- Set to maximize window (expanded to monitor)
    UNFOCUSED                = 0x00000800, -- Set to window non focused
    TOPMOST                  = 0x00001000, -- Set to window always on top
    ALWAYS_RUN               = 0x00000100, -- Set to allow windows running while minimized
    TRANSPARENT              = 0x00000010, -- Set to allow transparent windowbuffer
    HIGHDPI                  = 0x00002000, -- Set to support HighDPI
    MOUSE_PASSTHROUGH        = 0x00004000, -- Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    BORDERLESS_WINDOWED_MODE = 0x00008000, -- Set to run program in borderless windowed mode
    MSAA_4X_HINT             = 0x00000020, -- Set to try enabling MSAA 4X
    INTERLACED_HINT          = 0x00010000  -- Set to try enabling interlaced video format (for V3D)
}

---@enum texture_filter
TEXTURE_FILTER  = {
    POINT           = 0, -- No filter, just pixel approximation
    BILINEAR        = 1, -- Linear filtering
    TRILINEAR       = 2, -- Trilinear filtering (linear with mipmaps)
    ANISOTROPIC_4X  = 3, -- Anisotropic filtering 4x
    ANISOTROPIC_8X  = 4, -- Anisotropic filtering 8x
    ANISOTROPIC_16X = 5, -- Anisotropic filtering 16x
}

---@enum texture_wrap
TEXTURE_WRAP    = {
    REPEAT        = 0, -- Repeats texture in tiled mode
    CLAMP         = 1, -- Clamps texture to edge pixel in tiled mode
    MIRROR_REPEAT = 2, -- Mirrors and repeats the texture in tiled mode
    MIRROR_CLAMP  = 3  -- Mirrors and clamps to border the texture in tiled mode
}

-- ================================================================
-- Standard Lua type extension library.
-- ================================================================

---Check if a string does start with another string.
---@param text string # Main text.
---@param find string # Text to check against with main text.
function string.start_with(text, find)
    return string.sub(text, 1, string.len(find)) == find
end

---Tokenize a string.
---@param text string # Text to tokenize.
---@param find string # Pattern to tokenize with.
function string.tokenize(text, find)
    local i = {}

    for token in text:gmatch(find) do
        table.insert(i, token)
    end

    return i
end

--[[----------------------------------------------------------------]]

---Deep copy a table.
---@param value table # Table to copy.
function table.copy(value, work)
    if not work then
        work = {}
    end

    for k, v in pairs(value) do
        if type(v) == "table" then
            work[k] = table.copy(v)
        else
            work[k] = v
        end
    end

    return work
end

---Print every key/value pair in a table.
---@param value table # Table to print.
function table.print(value)
    for k, v in pairs(value) do
        print(tostring(k) .. ":" .. tostring(v))

        if type(v) == "table" then
            table.print(v)
        end
    end
end

---Check if an object is within a table.
---@param value  table # Table to check the value in.
---@param object any   # Value to check.
---@return boolean check # True if value is in table, false otherwise.
function table.in_set(value, object)
    for k, v in ipairs(value) do
        if v == object then
            return true
        end
    end

    return false
end

---Remove an object from an array table by value.
---@param value  table # Table to remove the value from.
---@param object any   # Value to remove.
function table.remove_object(value, object)
    for k, v in ipairs(value) do
        if v == object then
            print("remove_object = " .. k)
            table.remove(value, k)
            return
        end
    end
end

---Recursively restore every table within a table's meta table.
---@param value table # Table to restore.
function table.restore_meta(value)
    -- for each key/value pair in the table...
    for k, v in pairs(value) do
        -- if the current value is a table...
        if type(v) == "table" then
            -- if the current table has a .__type field...
            if v.__type then
                -- locate the "class" table.
                local meta = _G[v.__type]

                -- if the class table does exist...
                if meta then
                    -- restore the current table's meta-table to be that of the class table.
                    setmetatable(v, meta.__meta)
                    getmetatable(v).__index = meta
                else
                    error(string.format(
                        "table.restore_meta(): Found \"__type\" for table, but could not find \"%s\" class table.",
                        v.__type))
                end
            end

            -- recursively iterate table.
            table.restore_meta(v)
        end
    end

    -- check the given value as well.
    if type(value) == "table" then
        -- if the current table has a .__type field...
        if value.__type then
            -- locate the "class" table.
            local meta = _G[value.__type]

            -- if the class table does exist...
            if meta then
                print("Restoring value: " .. value.__type)

                -- restore the current table's meta-table to be that of the class table.
                if meta.__meta then
                    setmetatable(value, meta.__meta)
                    getmetatable(value).__index = meta
                end
            else
                error(string.format(
                    "table.restore_meta(): Found \"__type\" for table, but could not find \"%s\" class table.",
                    value.__type))
            end
        end
    end
end

--[[----------------------------------------------------------------]]

---Check the sanity of a number, which will check for NaN and Infinite.
---@param value number # Number to check.
---@return boolean sanity # True if number is not sane, false otherwise.
function math.sanity(value)
    return not (value == value) or value == math.huge
end

---Check the sign of a number.
---@param value number # Number to check.
---@return number sign # 1.0 if number is positive OR equal to 0.0, -1.0 otherwise.
function math.sign(value)
    return value >= 0 and 1.0 or -1.0
end

---Get the percentage of a value in a range.
---@param min number # Minimum value.
---@param max number # Maximum value.
---@param value number # Input value.
---@return number percentage # Percentage.
function math.percentage_from_value(min, max, value)
    return (value - min) / (max - min)
end

---Get the value of a percentage in a range.
---@param min number # Minimum value.
---@param max number # Maximum value.
---@param value number # Input percentage.
---@return number value # Value.
function math.value_from_percentage(min, max, value)
    return value * (max - min) + min
end

---Snap a value to a given step.
---@param step number # Step.
---@param value number # Input value.
---@return number value # Value.
function math.snap(snap, value)
    return math.floor(value / snap) * snap
end

---Get a random variation of a given value, which can either be positive or negative.
---@param value number # Number to randomize.
---@return number value # A value between [-number, number].
function math.random_sign(value)
    local random = math.random()
    if random > 0.5 then
        return value * math.percentage_from_value(0.5, 1.0, random)
    else
        return value * math.percentage_from_value(0.0, 0.5, random) * -1.0
    end
end

---Linear interpolation.
---@param a    number # Point "A".
---@param b    number # Point "B".
---@param time number # Time into the interpolation.
---@return number interpolation # The interpolation.
function math.interpolate(a, b, time)
    return (1.0 - time) * a + time * b
end

---Clamp a value in a range.
---@param min   number # Minimum value.
---@param max   number # Maximum value.
---@param value number # Value to clamp.
---@return number value # The value, within the min/max range.
function math.clamp(min, max, value)
    if value < min then return min end
    if value > max then return max end
    return value
end

---Roll-over a value: if value is lower than the minimum, roll-over to the maximum, and viceversa.
---@param min   number # Minimum value.
---@param max   number # Maximum value.
---@param value number # Value to roll-over.
---@return number value # The value, within the min/max roll-over range.
function math.roll_over(min, max, value)
    if value < min then return max end
    if value > max then return min end
    return value
end

---Return the "X", "Y", "Z" vector from an Euler angle.
---@param angle vector_3
---@return vector_3 d_x # "X" direction.
---@return vector_3 d_y # "Y" direction.
---@return vector_3 d_z # "Z" direction.
function math.direction_from_euler(angle)
    local d_x = vector_3:zero()
    local d_y = vector_3:zero()
    local d_z = vector_3:zero()

    -- Convert to radian.
    local angle = vector_2:old(angle.x * (math.pi / 180.0), angle.y * (math.pi / 180.0))

    -- "X" vector.
    d_x.x = math.cos(angle.y) * math.sin(angle.x)
    d_x.y = math.sin(angle.y) * -1.0
    d_x.z = math.cos(angle.y) * math.cos(angle.x)

    -- "Y" vector.
    d_y.x = math.sin(angle.y) * math.sin(angle.x)
    d_y.y = math.cos(angle.y)
    d_y.z = math.sin(angle.y) * math.cos(angle.x)

    -- "Z" vector.
    d_z.x = math.cos(angle.x)
    d_z.y = 0.0
    d_z.z = math.sin(angle.x) * -1.0

    return d_x, d_y, d_z
end

-- ================================================================
-- Math animation library.
-- ================================================================

ease = {}

function ease.out_sine(value)
    return math.sin((value * math.pi) * 0.5)
end

function ease.out_quad(value)
    return 1.0 - (1.0 - value) * (1.0 - value)
end

-- ================================================================
-- Table-pool library.
-- ================================================================

local POOL_VECTOR_2_AMOUNT  = 1024
local POOL_VECTOR_3_AMOUNT  = 1024
local POOL_VECTOR_4_AMOUNT  = 1024
local POOL_CAMERA_2D_AMOUNT = 4
local POOL_CAMERA_3D_AMOUNT = 4
local POOL_COLOR_AMOUNT     = 1024
local POOL_BOX_2_AMOUNT     = 1024
local POOL_BOX_3_AMOUNT     = 1024

---A table pool, for initializing a memory arena of a certain kind for borrowing later.
---@class table_pool
---@field index number
---@field count number
---@field kind  table
table_pool                  = {
    __meta = {}
}

---Create a new table pool.
---@param kind table  # The kind of table this table pool will initialize a memory arena for. MUST have a "default" function.
---@param size number # The size of the table.
function table_pool:new(kind, size, name)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    -- initialize the table pool from 1 to {size} with the default instance of the {kind}.
    for x = 1, size + 1 do
        i[x] = kind:default()
    end

    i.__type = "table_pool"
    i.index = 1
    i.count = size
    i.kind = kind
    i.name = name

    return i
end

---Clear the table pool index.
function table_pool:begin()
    self.index = 1
end

---Borrow a table from the table pool. WILL allocate a new table if every table in the pool is already in use.
function table_pool:get()
    -- increase the index by 1.
    self.index = self.index + 1

    -- index overflow!
    if self.index > self.count then
        error("index overflow: " .. self.name)
        -- create a new table.
        self[self.index] = self.kind:default()
        -- update our known table pool size.
        self.count = self.index
    end

    -- borrow table.
    return self[self.index - 1]
end

-- ================================================================
-- Quiver API primitive library.
-- ================================================================

---@class vector_2
---@field x number
---@field y number
vector_2 = {
    __meta = {
        __add = function(a, b) return vector_2:old(a.x + b.x, a.y + b.y) end,
        __sub = function(a, b) return vector_2:old(a.x - b.x, a.y - b.y) end,
        __mul = function(a, b)
            if type(a) == "number" then
                return vector_2:old(a * b.x, a * b.y)
            elseif type(b) == "number" then
                return vector_2:old(a.x * b, a.y * b)
            else
                return vector_2:old(a.x * b.x, a.y * b.y)
            end
        end,
        __div = function(a, b) return vector_2:old(a.x / b.x, a.y / b.y) end,
        __tostring = function(a)
            return "{ x:" .. tostring(a.x) .. " y:" .. tostring(a.y) .. " }" .. tostring(a.z) .. " }"
        end
    }
}

---Create a new vector (2 dimensional).
---@param x number # "X" component.
---@param y number # "Y" component.
---@return vector_2 value # The vector.
function vector_2:new(x, y)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "vector_2"
    i.x = x
    i.y = y

    return i
end

function vector_2:default()
    return vector_2:new(0.0, 0.0)
end

---Borrow an old vector from the vector pool. (2 dimensional).
---@param x number # "X" component.
---@param y number # "Y" component.
---@return vector_2 value # The vector.
function vector_2:old(x, y)
    local i = vector_2_pool:get()
    i.x = x
    i.y = y
    return i
end

---Set every component for the current vector.
---@param x number # "X" component.
---@param y number # "Y" component.
function vector_2:set(x, y)
    self.x = x
    self.y = y
end

---Create a new, GC-vector from an old table-pool vector.
---@return vector_2 value # The new vector.
function vector_2:old_to_new()
    return vector_2:new(self.x, self.y)
end

---Borrow an old, table-pool vector from a new GC-vector.
---@return vector_2 value # The old vector.
function vector_2:new_to_old()
    return vector_2:old(self.x, self.y)
end

---Copy the data of a given vector into the current vector.
---@param value vector_2 # The vector to copy from.
function vector_2:copy(value)
    self.x = value.x
    self.y = value.y
end

---Get the "X" vector.
---@return vector_2 value # The vector.
function vector_2:x()
    return vector_2:old(1.0, 0.0)
end

---Get the "Y" vector.
---@return vector_2 value # The vector.
function vector_2:y()
    return vector_2:old(0.0, 1.0)
end

---Get a vector, with every component set to "1".
---@return vector_2 value # The vector.
function vector_2:one()
    return vector_2:old(1.0, 1.0)
end

---Get a vector, with every component set to "0".
---@return vector_2 value # The vector.
function vector_2:zero()
    return vector_2:old(0.0, 0.0)
end

---Get the magnitude of the current vector.
---@return number value # The magnitude.
function vector_2:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y)
end

---Get the unit vector of the current vector.
---@return vector_2 value # The unit vector.
function vector_2:normalize()
    local length = math.sqrt(self.x * self.x + self.y * self.y)

    if not (length == 0.0) then
        local length = 1.0 / length
        return vector_2:old(self.x * length, self.y * length)
    else
        return self
    end
end

---Get the angle between the current vector, and a given one.
---@param value vector_2 # The vector to calculate the angle to.
---@return number value # The magnitude.
function vector_2:angle(value)
    return -math.atan2(value.y - self.y, value.x - self.x)
end

vector_2_pool = table_pool:new(vector_2, POOL_VECTOR_2_AMOUNT, "vector_2")

--[[----------------------------------------------------------------]]

---@class vector_3
---@field x number
---@field y number
---@field z number
vector_3 = {
    __meta = {
        __add = function(a, b) return vector_3:old(a.x + b.x, a.y + b.y, a.z + b.z) end,
        __sub = function(a, b) return vector_3:old(a.x - b.x, a.y - b.y, a.z - b.z) end,
        __mul = function(a, b)
            if type(a) == "number" then
                return vector_3:old(a * b.x, a * b.y, a * b.z)
            elseif type(b) == "number" then
                return vector_3:old(a.x * b, a.y * b, a.z * b)
            else
                return vector_3:old(a.x * b.x, a.y * b.y, a.z * b.z)
            end
        end,
        __div = function(a, b) return vector_3:old(a.x / b.x, a.y / b.y, a.z / b.z) end,
        __tostring = function(a)
            return string.format("{ x : %.2f, y: %.2f, z: %.2f }", a.x, a.y, a.z)
        end
    }
}

---Create a new vector (3 dimensional).
---@param x number # "X" component.
---@param y number # "Y" component.
---@param z number # "Z" component.
---@return vector_3 value # The vector.
function vector_3:new(x, y, z)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "vector_3"
    i.x = x
    i.y = y
    i.z = z

    return i
end

function vector_3:default()
    return vector_3:new(0.0, 0.0, 0.0)
end

---Borrow an old vector from the vector pool. (3 dimensional).
---@param x number # "X" component.
---@param y number # "Y" component.
---@param z number # "Z" component.
---@return vector_3 value # The vector.
function vector_3:old(x, y, z)
    local i = vector_3_pool:get()
    i.x = x
    i.y = y
    i.z = z
    return i
end

---Set every component for the current vector.
---@param x number # "X" component.
---@param y number # "Y" component.
---@param z number # "Z" component.
function vector_3:set(x, y, z)
    self.x = x
    self.y = y
    self.z = z
end

---Create a new, GC-vector from an old table-pool vector.
---@return vector_3 value # The new vector.
function vector_3:old_to_new()
    return vector_3:new(self.x, self.y, self.z)
end

---Borrow an old, table-pool vector from a new GC-vector.
---@return vector_3 value # The old vector.
function vector_3:new_to_old()
    return vector_3:old(self.x, self.y, self.z)
end

---Copy the data of a given vector into the current vector.
---@param value vector_3 # The vector to copy from.
function vector_3:copy(value)
    self.x = value.x
    self.y = value.y
    self.z = value.z
end

---Get the "X" vector.
---@return vector_3 value # The vector.
function vector_3:x()
    return vector_3:old(1.0, 0.0, 0.0)
end

---Get the "Y" vector.
---@return vector_3 value # The vector.
function vector_3:y()
    return vector_3:old(0.0, 1.0, 0.0)
end

---Get the "Z" vector.
---@return vector_3 value # The vector.
function vector_3:z()
    return vector_3:old(0.0, 0.0, 1.0)
end

---Get a vector, with every component set to "1".
---@return vector_3 value # The vector.
function vector_3:one()
    return vector_3:old(1.0, 1.0, 1.0)
end

---Get a vector, with every component set to "0".
---@return vector_3 value # The vector.
function vector_3:zero()
    return vector_3:old(0.0, 0.0, 0.0)
end

---Get the dot product between the current vector, and another one.
---@param value vector_3 # Vector to perform the dot product with.
---@return number value # The dot product.
function vector_3:dot(value)
    return (self.x * value.x + self.y * value.y + self.z * value.z)
end

---Get the cross product between the current vector, and another one.
---@param value vector_3 # Vector to perform the cross product with.
---@return vector_3 value # The cross product.
function vector_3:cross(value)
    return vector_3:old(self.y * value.z - self.z * value.y, self.z * value.x - self.x * value.z,
        self.x * value.y - self.y * value.x)
end

---Get the magnitude of the current vector.
---@return number value # The magnitude.
function vector_3:magnitude()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

---Get the unit vector of the current vector.
---@return vector_3 value # The unit vector.
function vector_3:normalize()
    local length = math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)

    if not (length == 0.0) then
        local length = 1.0 / length
        return vector_3:old(self.x * length, self.y * length, self.z * length)
    else
        return self
    end
end

---Rotate the current vector by an axis and an angle.
---@param axis  vector_3 # The axis.
---@param angle number # The angle.
---@return vector_3 value # The vector.
function vector_3:rotate_axis_angle(axis, angle)
    local axis = axis:normalize()

    angle      = angle / 2.0
    local a    = math.sin(angle)
    local b    = axis.x * a
    local c    = axis.y * a
    local d    = axis.z * a
    a          = math.cos(angle)
    local w    = vector_3:old(b, c, d)

    local wv   = w:cross(self)

    local wwv  = w:cross(wv)

    wv         = wv * a * 2.0

    wwv        = wwv * 2.0

    return vector_3:old(self.x + wv.x + wwv.x, self.y + wv.y + wwv.y, self.z + wv.z + wwv.z)
end

vector_3_pool = table_pool:new(vector_3, POOL_VECTOR_3_AMOUNT, "vector_3")

--[[----------------------------------------------------------------]]

---@class vector_4
---@field x number
---@field y number
---@field z number
---@field w number
vector_4 = {
    __meta = {
        __add = function(a, b) return vector_4:old(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w) end,
        __sub = function(a, b) return vector_4:old(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w) end,
        __mul = function(a, b)
            if type(a) == "number" then
                return vector_4:old(a * b.x, a * b.y, a * b.z, a * b.w)
            elseif type(b) == "number" then
                return vector_4:old(a.x * b, a.y * b, a.z * b, a.w * b)
            else
                return vector_4:old(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
            end
        end,
        __div = function(a, b) return vector_4:old(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w) end,
        __tostring = function(a)
            return "{ x:" ..
                tostring(a.x) .. " y:" .. tostring(a.y) .. " z:" .. tostring(a.z) .. " w:" .. tostring(a.w) .. " }"
        end
    }
}

---Create a new vector (4 dimensional).
---@param x number # "X" component.
---@param y number # "Y" component.
---@param z number # "Z" component.
---@param w number # "W" component.
---@return vector_4 value # The vector.
function vector_4:new(x, y, z, w)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "vector_4"
    i.x = x
    i.y = y
    i.z = z
    i.w = w

    return i
end

function vector_4:default()
    return vector_4:new(0.0, 0.0, 0.0, 0.0)
end

---Borrow an old vector from the vector pool. (3 dimensional).
---@param x number # "X" component.
---@param y number # "Y" component.
---@param z number # "Z" component.
---@return vector_4 value # The vector.
function vector_4:old(x, y, z, w)
    local i = vector_4_pool:get()
    i.x = x
    i.y = y
    i.z = z
    i.w = w
    return i
end

---Set every component for the current vector.
---@param x number # "X" component.
---@param y number # "Y" component.
---@param z number # "Z" component.
---@param w number # "W" component.
function vector_4:set(x, y, z, w)
    self.x = x
    self.y = y
    self.z = z
    self.w = w
end

---Create a new, GC-vector from an old table-pool vector.
---@return vector_4 value # The new vector.
function vector_4:old_to_new()
    return vector_4:new(self.x, self.y, self.z, self.w)
end

---Borrow an old, table-pool vector from a new GC-vector.
---@return vector_4 value # The old vector.
function vector_4:new_to_old()
    return vector_4:old(self.x, self.y, self.z, self.w)
end

---Copy the data of a given vector into the current vector.
---@param value vector_4 # The vector to copy from.
function vector_4:copy(value)
    self.x = value.x
    self.y = value.y
    self.z = value.z
    self.w = value.w
end

---Get the "X" vector.
---@return vector_4 value # The vector.
function vector_4:x()
    return vector_4:old(1.0, 0.0, 0.0, 0.0)
end

---Get the "Y" vector.
---@return vector_4 value # The vector.
function vector_4:y()
    return vector_4:old(0.0, 1.0, 0.0, 0.0)
end

---Get the "Z" vector.
---@return vector_4 value # The vector.
function vector_4:z()
    return vector_4:old(0.0, 0.0, 1.0, 0.0)
end

---Get the "W" vector.
---@return vector_4 value # The vector.
function vector_4:w()
    return vector_4:old(0.0, 0.0, 0.0, 1.0)
end

---Get a vector, with every component set to "1".
---@return vector_4 value # The vector.
function vector_4:one()
    return vector_4:old(1.0, 1.0, 1.0, 1.0)
end

---Get a vector, with every component set to "0".
---@return vector_4 value # The vector.
function vector_4:zero()
    return vector_4:old(0.0, 0.0, 0.0, 0.0)
end

---Get the unit vector of the current vector.
---@return vector_4 value # The unit vector.
function vector_4:normalize()
    local length = math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)

    if not (length == 0.0) then
        local length = 1.0 / length
        return vector_4:old(self.x * length, self.y * length, self.z * length, self.w * length)
    else
        return self
    end
end

vector_4_pool = table_pool:new(vector_4, POOL_VECTOR_4_AMOUNT)

--[[----------------------------------------------------------------]]

---@class box_2
---@field x      number
---@field y      number
---@field width  number
---@field height number
box_2 = {
    __meta = {}
}

function box_2:new(x, y, width, height)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "box_2"
    i.x = x
    i.y = y
    i.width = width
    i.height = height

    return i
end

function box_2:default()
    return box_2:new(0.0, 0.0, 0.0, 0.0)
end

function box_2:old(x, y, width, height)
    local i = box_2_pool:get()
    i.x = x
    i.y = y
    i.width = width
    i.height = height
    return i
end

---Set every component for the current box.
---@param x      number # "X" component.
---@param y      number # "Y" component.
---@param width  number # Width component.
---@param height number # Height component.
function box_2:set(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

box_2_pool = table_pool:new(box_2, POOL_BOX_2_AMOUNT)

--[[----------------------------------------------------------------]]

---@class box_3
---@field min vector_3
---@field max vector_3
box_3 = {
    __meta = {}
}

function box_3:new(min, max)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "box_3"
    i.min = min
    i.max = max

    return i
end

function box_3:default()
    return box_3:new(vector_3:default(), vector_3:default())
end

function box_3:old(min, max)
    local i = box_3_pool:get()
    i.min = min
    i.max = max
    return i
end

box_3_pool = table_pool:new(box_3, POOL_BOX_3_AMOUNT)

--[[----------------------------------------------------------------]]

---@class ray
---@field position  vector_3
---@field direction vector_3
ray = {
    __meta = {}
}

function ray:new(position, direction)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type    = "ray"
    i.position  = position
    i.direction = direction

    return i
end

--[[----------------------------------------------------------------]]

---@class color
---@field r number
---@field g number
---@field b number
---@field a number
color = {
    __meta = {
        __mul = function(a, b)
            if type(a) == "number" then
                return color:old(
                    math.floor(a * b.r),
                    math.floor(a * b.g),
                    math.floor(a * b.b),
                    b.a
                )
            elseif type(b) == "number" then
                return color:old(
                    math.floor(a.r * b),
                    math.floor(a.g * b),
                    math.floor(a.b * b),
                    a.a
                )
            else
                return color:old(
                    math.floor(a.r * b.r),
                    math.floor(a.g * b.g),
                    math.floor(a.b * b.b),
                    a.a * b.a
                )
            end
        end
    }
}

function color:new(r, g, b, a)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "color"
    i.r = r
    i.g = g
    i.b = b
    i.a = a

    return i
end

function color:default()
    return color:new(0.0, 0.0, 0.0, 0.0)
end

---Borrow an old color from the color pool.
---@param r number # "R" component.
---@param g number # "G" component.
---@param b number # "B" component.
---@param a number # "A" component.
---@return color value # The color.
function color:old(r, g, b, a)
    local i = color_pool:get()
    i.r = r
    i.g = g
    i.b = b
    i.a = a
    return i
end

---Set every component for the current color.
---@param r number # "R" component.
---@param g number # "G" component.
---@param b number # "B" component.
---@param a number # "A" component.
function color:set(r, g, b, a)
    self.r = r
    self.g = g
    self.b = b
    self.a = a
end

---Create a new, GC-vector from an old table-pool vector.
---@return color value # The new vector.
function color:old_to_new()
    return color:new(self.r, self.g, self.b, self.a)
end

---Borrow an old, table-pool vector from a new GC-vector.
---@return color value # The old vector.
function color:new_to_old()
    return color:old(self.r, self.g, self.b, self.a)
end

---Copy the data of a given vector into the current vector.
---@param value color # The vector to copy from.
function color:copy(value)
    self.r = value.r
    self.g = value.g
    self.b = value.b
    self.a = value.a
end

function color:white()
    return color:old(255.0, 255.0, 255.0, 255.0)
end

function color:black()
    return color:old(0.0, 0.0, 0.0, 255.0)
end

function color:red()
    return color:old(255.0, 0.0, 0.0, 255.0)
end

function color:green()
    return color:old(0.0, 255.0, 0.0, 255.0)
end

function color:blue()
    return color:old(0.0, 0.0, 255.0, 255.0)
end

color_pool = table_pool:new(color, POOL_COLOR_AMOUNT)

---@class camera_2d
---@field shift vector_2
---@field focus vector_2
---@field angle number
---@field zoom  number
camera_2d = {
    __meta = {}
}

function camera_2d:new(shift, focus, angle, zoom)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "camera_2d"
    i.shift = shift
    i.focus = focus
    i.angle = angle
    i.zoom = zoom

    return i
end

function camera_2d:default()
    return camera_2d:new(vector_2:new(0.0, 0.0), vector_2:new(0.0, 0.0), 0.0, 0.0)
end

function camera_2d:old(shift, focus, angle, zoom)
    local i = camera_2d_pool:get()
    i.shift = shift
    i.focus = focus
    i.angle = angle
    i.zoom = zoom
    return i
end

camera_2d_pool = table_pool:new(camera_2d, POOL_CAMERA_2D_AMOUNT)

--[[----------------------------------------------------------------]]

---@enum camera_3d_kind
CAMERA_3D_KIND = {
    PERSPECTIVE = 0,
    ORTHOGRAPHIC = 1,
}

---@class camera_3d
---@field point vector_3
---@field focus vector_3
---@field angle vector_3
---@field zoom  number
---@field kind  camera_3d_kind
camera_3d = {
    __meta = {}
}

function camera_3d:new(point, focus, angle, zoom, kind)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "camera_3d"
    i.point = point
    i.focus = focus
    i.angle = angle
    i.zoom = zoom
    i.kind = kind

    return i
end

function camera_3d:default()
    return camera_3d:new(vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 0.0, 0.0), vector_3:new(0.0, 0.0, 0.0), 0.0,
        CAMERA_3D_KIND.PERSPECTIVE)
end

function camera_3d:old(point, focus, angle, zoom, kind)
    local i = camera_3d_pool:get()
    i.point = point
    i.focus = focus
    i.angle = angle
    i.zoom = zoom
    i.kind = kind
    return i
end

function camera_3d:pack(p_x, p_y, p_z, f_x, f_y, f_z, a_x, a_y, a_z, zoom, kind)
    self.point:set(p_x, p_y, p_z)
    self.focus:set(f_x, f_y, f_z)
    self.angle:set(a_x, a_y, a_z)
    self.zoom = zoom
    self.kind = kind
end

camera_3d_pool = table_pool:new(camera_3d, POOL_CAMERA_3D_AMOUNT)

-- ================================================================
-- Quiver API extension library.
-- ================================================================

---Get the last mouse button press.
---@return input_mouse|nil value # The last mouse button press.
function quiver.input.mouse.get_queue()
    for i, value in pairs(INPUT_MOUSE) do
        if type(value) == "number" then
            if quiver.input.mouse.get_press(value) then
                return value
            end
        end
    end

    return
end

local BORDER_THICK        = 2.0
local BORDER_COLOR_A_MAIN = color:new(76.0, 88.0, 68.0, 255.0)
local BORDER_COLOR_A_SIDE = color:new(62.0, 70.0, 55.0, 255.0)
local BORDER_COLOR_B      = color:new(124.0, 133.0, 116.0, 255.0)
local BORDER_COLOR_C      = color:new(37.0, 48.0, 31.0, 255.0)
local BORDER_COLOR_D      = color:new(196.0, 181.0, 80.0, 255.0)

---Draw a box, with a border.
---@param box     box_2   # The box to draw.
---@param invert? boolean # OPTIONAL: Invert the upper/lower color of the border.
---@param color?  color   # OPTIONAL: The color of the box to draw.
function quiver.draw_2d.draw_box_2_border(box, invert, color)
    -- calculate the full thickness, and also the half thickness.
    local thick_full = BORDER_THICK
    local thick_half = thick_full * 0.5

    -- calculate the color.
    local color_a = invert and BORDER_COLOR_A_SIDE or BORDER_COLOR_A_MAIN
    local color_b = invert and BORDER_COLOR_C or BORDER_COLOR_B
    local color_c = invert and BORDER_COLOR_B or BORDER_COLOR_C

    -- if color is not nil...
    if color then
        -- use given color instead.
        color_a = invert and color * 0.25 or color
        color_b = invert and color * 0.50 or color * 0.75
        color_c = invert and color * 0.75 or color * 0.50
    end

    -- draw main color.
    quiver.draw_2d.draw_box_2(box, vector_2:zero(), 0.0, color_a)

    -- draw upper color.
    quiver.draw_2d.draw_line(
        vector_2:old(box.x + thick_half, box.y),
        vector_2:old(box.x + thick_half, box.y + box.height),
        thick_full, color_b)
    quiver.draw_2d.draw_line(
        vector_2:old(box.x, box.y + thick_half),
        vector_2:old(box.x + box.width, box.y + thick_half),
        thick_full, color_b)

    -- draw lower color.
    quiver.draw_2d.draw_line(
        vector_2:old(box.x, box.y + box.height - thick_half),
        vector_2:old(box.x + box.width, box.y + box.height - thick_half),
        thick_full, color_c)
    quiver.draw_2d.draw_line(
        vector_2:old(box.x + box.width - thick_half, box.y),
        vector_2:old(box.x + box.width - thick_half, box.y + box.height),
        thick_full, color_c)
end

local DOT_COLOR = color:new(255.0, 255.0, 255.0, 255.0)
local DOT_SPACE = 8.0

---Draw a box, with a dot outline.
---@param box box_2 # The box to draw.
function quiver.draw_2d.draw_box_2_dot(box)
    -- calculate the dot count for the X and Y axis.
    local dot_count = vector_2:old(math.floor((box.width - DOT_SPACE) / DOT_SPACE),
        math.floor((box.height - DOT_SPACE) / DOT_SPACE))

    -- initialize every vector.
    local point_a = vector_2:old(0.0, 0.0)
    local point_b = vector_2:old(0.0, 0.0)

    -- draw X dot.
    for i = 0, dot_count.x do
        -- draw upper dot.
        point_a:set(box.x + (i * DOT_SPACE), box.y)
        point_b:set(box.x + (i * DOT_SPACE) + DOT_SPACE / 2.0, box.y)
        quiver.draw_2d.draw_line(point_a, point_b, 2.0, DOT_COLOR)

        -- draw lower dot.
        point_a:set(box.x + (i * DOT_SPACE), box.y + box.height)
        point_b:set(box.x + (i * DOT_SPACE) + DOT_SPACE / 2.0, box.y + box.height)
        quiver.draw_2d.draw_line(point_a, point_b, 2.0, DOT_COLOR)
    end

    -- draw Y dot.
    for i = 0, dot_count.y do
        -- draw L. dot.
        point_a:set(box.x, box.y + (i * DOT_SPACE))
        point_b:set(box.x, box.y + (i * DOT_SPACE) + DOT_SPACE / 2.0)
        quiver.draw_2d.draw_line(point_a, point_b, 2.0, DOT_COLOR)

        -- draw R. dot.
        point_a:set(box.x + box.width, box.y + (i * DOT_SPACE))
        point_b:set(box.x + box.width, box.y + (i * DOT_SPACE) + DOT_SPACE / 2.0)
        quiver.draw_2d.draw_line(point_a, point_b, 2.0, DOT_COLOR)
    end
end

-- ================================================================
-- Virtual file-system library.
-- ================================================================

---@class file_system
---@field search      table
---@field locate      table
---@field memory_list table
---@field memory_data table
file_system = {
    __meta = {}
}

---Create a new virtual file-system. For serialization, you may want to only serialize "search", "locate", and "memory_list", which only contain serializable data.
---```lua
---local i = file_system:new({
---    "game_folder_1", -- image.png, sound.wav, model.obj
---    "game_folder_2", -- image.png
---    "game_folder_3"  -- sound.wav
---})
---
----- Scan "g_f_1", "g_f_2", "g_f_3" to update the asset look-up table.
---i:scan()
---
---i:find("image.png") -- "game_folder_2/image.png"
---i:find("sound.wav") -- "game_folder_3/sound.wav"
---i:find("model.obj") -- "game_folder_1/model.obj"
---```
---@return file_system value # The virtual file-system.
function file_system:new(search)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "file_system"
    i.locate = {}
    i.memory_list = {
        texture = {},
        model = {},
        sound = {},
        music = {},
        shader = {},
        font = {}
    }
    i.memory_data = {
        texture = {},
        model = {},
        sound = {},
        music = {},
        shader = {},
        font = {}
    }

    i:scan(search)

    return i
end

---Scan every directory in the asset's search table, to update the asset look-up table.
function file_system:scan(search)
    -- get the info path (i.e. path: "main_folder").
    local _, path = quiver.general.get_info()

    -- for each search path in the search table...
    for _, search_path in ipairs(search) do
        -- scan the path recursively.
        local list = quiver.file.scan_path(search_path, nil, true)
        -- make the full path (main_folder/game_folder_1).
        local wipe = path .. "/" .. search_path

        for _, search_file in ipairs(list) do
            -- strip "main_folder/game_folder_1/video/image.png" to "video/image.png".
            local entry = string.sub(search_file, #wipe + 2, -1)
            local value = string.sub(search_file, #path + 2, -1)

            -- set entry. (i.e. "video/image.png" = "main_folder/game_folder_1/video/image.png").
            self.locate[entry] = value
        end
    end
end

function file_system:list(search)
    local result = {}

    for path, _ in pairs(self.locate) do
        if string.start_with(path, search) then
            table.insert(result, path)
        end
    end

    return result
end

---Find an asset by name, to get the full path of the asset.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return string full_path # The "full" path to the asset.
function file_system:find(faux_path)
    return self.locate[faux_path]
end

---Re-load every asset in memory.
function file_system:load()
    for path, _ in pairs(self.memory_data.texture) do
        self:set_texture(path)
    end
end

local function file_system_set_asset(self, memory_data, memory_list, call_new, force, faux_path, ...)
    -- if asset was already in memory...
    if memory_data[faux_path] then
        if force then
            -- remove from the book-keeping memory table.
            table.remove_object(memory_list, faux_path)

            -- remove from the data-keeping memory table.
            memory_data[faux_path] = nil

            collectgarbage("collect")
        else
            return memory_data[faux_path]
        end
    end

    -- locate the asset.
    local asset = self.locate[faux_path]

    -- create the asset.
    asset = call_new(asset, ...)

    -- insert into the book-keeping memory table.
    table.insert(memory_list, faux_path)

    -- insert into the data-keeping memory table.
    memory_data[faux_path] = asset

    return asset
end

---Set a texture asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return texture asset # The asset.
function file_system:set_texture(faux_path)
    return file_system_set_asset(self, self.memory_data.texture, self.memory_list.texture, quiver.texture.new, false,
        faux_path)
end

---Get a texture asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return texture asset # The asset.
function file_system:get_texture(faux_path)
    return self.memory_data.texture[faux_path]
end

---Get a model asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return model asset # The asset.
function file_system:get_model(faux_path)
    return self.memory_data.model[faux_path]
end

---Set a model asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return model asset # The asset.
function file_system:set_model(faux_path)
    return file_system_set_asset(self, self.memory_data.model, self.memory_list.model, quiver.model.new, false, faux_path)
end

---Get a sound asset from the file-system sound resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return sound asset # The asset.
function file_system:get_sound(faux_path)
    return self.memory_data.sound[faux_path]
end

---Set a sound asset into the file-system sound resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return sound asset # The asset.
function file_system:set_sound(faux_path)
    return file_system_set_asset(self, self.memory_data.sound, self.memory_list.sound, quiver.sound.new, false, faux_path)
end

---Get a model asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return shader asset # The asset.
function file_system:get_shader(faux_path)
    return self.memory_data.shader[faux_path]
end

---Set a shader asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return shader asset # The asset.
function file_system:set_shader(faux_path, ...)
    return file_system_set_asset(self, self.memory_data.shader, self.memory_list.shader, quiver.shader.new, false,
        faux_path,
        ...)
end

---Get a model asset from the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return font asset # The asset.
function file_system:get_font(faux_path)
    return self.memory_data.font[faux_path]
end

---Set a font asset into the file-system model resource table.
---@param  faux_path string # The "faux" path to the asset, not taking into consideration the search path in which it was found.
---@return font asset # The asset.
function file_system:set_font(faux_path, ...)
    return file_system_set_asset(self, self.memory_data.font, self.memory_list.font, quiver.font.new, false, faux_path,
        ...)
end

-- ================================================================
-- Action/action-button library.
-- ================================================================

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

-- ================================================================
-- Logger library.
-- ================================================================

local LOGGER_LINE_COLOR_HISTORY = color:new(127.0, 127.0, 127.0, 255.0)
local LOGGER_LINE_COLOR_MESSAGE = color:new(255.0, 255.0, 255.0, 255.0)
local LOGGER_LINE_COLOR_FAILURE = color:new(255.0, 0.0, 0.0, 255.0)
local LOGGER_LINE_COUNT         = 4.0
local LOGGER_LINE_DELAY         = 4.0
local LOGGER_LINE_LABEL_TIME    = false

---@class logger_line
logger_line                     = {
    __meta = {}
}

function logger_line:new(label, color)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "logger_line"
    i.label = label
    i.color = color
    i.time = quiver.general.get_time()

    return i
end

--[[----------------------------------------------------------------]]

---@class logger_command
logger_command = {
    __meta = {}
}

function logger_command:new(info, call)
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "logger_command"
    i.info = info
    i.call = call

    return i
end

--[[----------------------------------------------------------------]]

LOGGER_FONT_SCALE    = 24.0
LOGGER_FONT_SPACE    = 1.0
LOGGER_FONT          = quiver.font.new("asset/video/font.ttf", LOGGER_FONT_SCALE)
LOGGER_SHAPE         = vector_2:new(1.0, 0.5)
LOGGER_LINE_CAP      = 64.0
LOGGER_TOGGLE        = INPUT_BOARD.F2
LOGGER_DELETE        = INPUT_BOARD.BACKSPACE
LOGGER_SUGGEST       = INPUT_BOARD.TAB
LOGGER_HISTORY_ABOVE = INPUT_BOARD.UP
LOGGER_HISTORY_BELOW = INPUT_BOARD.DOWN
LOGGER_PRINT         = INPUT_BOARD.ENTER

---@class logger
---@field worker  string
---@field buffer  table
---@field suggest table
---@field history table
---@field command table
---@field active  boolean
logger               = {
    __meta = {}
}

---Clear and build the suggest buffer.
local function logger_suggest_build(self)
    -- clear the buffer.
    self.suggest = {}

    if not (self.worker == "") then
        -- for each command in the command list...
        for name, _ in pairs(self.command) do
            -- if the command name does start with the worker buffer string...
            if string.start_with(name, self.worker) then
                -- add to suggest buffer.
                table.insert(self.suggest, name)
            end
        end
    end
end

---Input handling: handle deletion.
local function logger_handle_delete(self)
    -- pop the last character of the working buffer.
    self.worker = string.sub(self.worker, 0, #self.worker - 1)

    -- re-build the suggestion buffer.
    logger_suggest_build(self)
end

---Input handling: handle suggest navigation.
local function logger_handle_suggest(self)
    -- get the length of the suggest buffer.
    local count = #self.suggest

    -- if the suggest buffer is bigger than 0.0...
    if count > 0.0 then
        local empty = true

        -- for each line in the suggest buffer...
        for i, name in pairs(self.suggest) do
            -- the current working buffer is the same as this command's name.
            if self.worker == name then
                -- we can index one command above...
                if i + 1 <= count then
                    -- set the working buffer text to the command above, don't do anything else.
                    self.worker = self.suggest[i + 1]
                    empty = false
                end

                break
            end
        end

        -- no text equal to the worker working buffer found or we are indexing into nil.
        if empty then
            -- set worker string.
            self.worker = self.suggest[1]
        end
    end
end

---Input handling: handle history navigation.
local function logger_handle_history(self, direction)
    -- get the length of the history buffer.
    local count = #self.history

    -- if the history buffer is bigger than 0.0...
    if count > 0.0 then
        local empty = true
        local index = 1.0

        -- for each line in the history buffer...
        for i, name in pairs(self.history) do
            if self.worker == name then
                -- get the direction of the history scroll.
                local which = direction and -1.0 or 1.0

                -- if {i} + {which} is within the correct index range...
                if i + which >= 1.0 and i + which <= count then
                    -- set index, don't do anything else.
                    index = i + which
                    empty = false
                end

                break
            end
        end

        -- no text equal to the working buffer found or we are indexing into nil.
        if empty then
            if direction then
                -- going up, roll over to {count}.
                index = count
            else
                -- going down, roll over to {1.0}.
                index = 1.0
            end
        end

        -- set working buffer.
        self.worker = self.history[index]
    end
end

---Input handling: handle printing a line to the logger from the working buffer.
local function logger_handle_print(self)
    -- if the working buffer isn't empty...
    if not (self.buffer == "") then
        -- tokenize the string. use the first match as the command name, everything else as an argument.
        local token = self.worker:tokenize("%S+")

        -- find the command by name.
        local command = self.command[token[1]]

        -- print the working buffer.
        self:print(self.worker, LOGGER_LINE_COLOR_HISTORY)

        -- if there is a valid command...
        if command then
            -- call it, pass the tokenization table.
            command.call(self, token)
        else
            -- print error message.
            self:print("Unknown command.", LOGGER_LINE_COLOR_FAILURE)
        end

        -- insert as part of the history table, clear working buffer, clear suggestion list.
        table.insert(self.history, self.worker)
        self.worker  = ""
        self.suggest = {}
    end
end

---Input handling: handle the press of a key.
local function logger_handle_press(self)
    -- get latest unicode key.
    local uni = quiver.input.board.get_uni_code_queue()

    -- while the queue isn't empty...
    while not (uni == 0) do
        -- attach a character to the end of the working buffer string, re-build suggest buffer.
        self.worker = self.worker .. string.char(uni)
        logger_suggest_build(self)

        uni = quiver.input.board.get_uni_code_queue()
    end
end

---Draw the main logger layout. Only drawn when logger is set.
---@param self   logger # The logger.
---@param window window # The window for rendering every possible command suggestion.
local function logger_draw_main(self, window)
    local count = #self.buffer

    -- get mouse wheel movement, scroll logger buffer.
    local _, y = quiver.input.mouse.get_wheel()
    self.scroll = math.max(0.0, self.scroll + y)

    -- get window shape, calculate each box's shape.
    local x, y = quiver.window.get_render_shape()
    x = x * LOGGER_SHAPE.x
    y = y * LOGGER_SHAPE.y
    local box_main = box_2:old(0.0, 0.0, x, y)
    local box_side = box_2:old(8.0, 8.0, x - 16.0, y - 28.0 - LOGGER_FONT_SCALE)
    local box_type = box_2:old(8.0, y - 12.0 - LOGGER_FONT_SCALE, x - 16.0, LOGGER_FONT_SCALE + 4.0)

    -- input handling block.
    if quiver.input.board.get_press(LOGGER_DELETE) or quiver.input.board.get_press_repeat(LOGGER_DELETE) then
        logger_handle_delete(self)
    elseif quiver.input.board.get_press(LOGGER_SUGGEST) or quiver.input.board.get_press_repeat(LOGGER_SUGGEST) then
        logger_handle_suggest(self)
    elseif quiver.input.board.get_press(LOGGER_HISTORY_ABOVE) or quiver.input.board.get_press_repeat(LOGGER_HISTORY_ABOVE) then
        logger_handle_history(self, true)
    elseif quiver.input.board.get_press(LOGGER_HISTORY_BELOW) or quiver.input.board.get_press_repeat(LOGGER_HISTORY_BELOW) then
        logger_handle_history(self, false)
    elseif quiver.input.board.get_press(LOGGER_PRINT) then
        logger_handle_print(self)
    else
        logger_handle_press(self)
    end

    -- draw box.
    quiver.draw_2d.draw_box_2_border(box_main, false)
    quiver.draw_2d.draw_box_2_border(box_side, true)
    quiver.draw_2d.draw_box_2_border(box_type, true)

    -- initialize vector, box.
    local text_point = vector_2:old(0.0, 0.0)
    local text_shape = box_2:old(0.0, 0.0, 0.0, 0.0)

    -- draw every line in the logger buffer inside of a GL scissor test.
    quiver.draw.begin_scissor(function()
        for i, line in pairs(self.buffer) do
            i = (count - i) - self.scroll

            text_point:set(12.0,
                (box_side.y + box_side.height - LOGGER_FONT_SCALE - 4.0) - (i * LOGGER_FONT_SCALE))
            text_shape:set(text_point.x, text_point.y, 16.0, LOGGER_FONT_SCALE)

            -- console line is within view, draw.
            if collision.box_box(text_shape, box_side) then
                LOGGER_FONT:draw(line.label, text_point, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, line.color)
            end
        end
    end, box_side)

    -- draw working buffer.
    LOGGER_FONT:draw(self.worker, vector_2:old(12.0, box_type.y), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, color:white())

    -- if the working buffer isn't empty...
    if not (self.worker == "") then
        -- for each suggestion in the suggest buffer...
        for i, name in pairs(self.suggest) do
            -- start from zero.
            i = i - 1

            -- measure text.
            local size_x, size_y = LOGGER_FONT:measure_text(name, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE)
            size_x = size_x + WINDOW_SHIFT_A.x * 2.0
            size_y = size_y + WINDOW_SHIFT_A.y * 2.0

            -- draw button, if button is set off, replace working buffer with the suggestion instead.
            if window:button(box_2:old(box_type.x, box_type.y + box_type.height + (i * size_y), size_x, size_y), name, GIZMO_FLAG.IGNORE_BOARD) then
                self.worker = name
                self.suggest = {}
            end
        end
    end
end

---Draw a small portion of the most recently sent content in the logger buffer. Only drawn when logger is not set.
local function logger_draw_side(self)
    -- get the length of the buffer worker.
    local count = #self.buffer
    local text_point_a = vector_2:old(0.0, 0.0)
    local text_point_b = vector_2:old(0.0, 0.0)

    -- draw the latest logger buffer, iterating through the buffer in reverse.
    for i = 1, LOGGER_LINE_COUNT do
        local line = self.buffer[count + 1 - i]

        -- line isn't nil...
        if line then
            -- line is within the time threshold...
            if quiver.general.get_time() < line.time + LOGGER_LINE_DELAY then
                -- start from 0.
                i = i - 1

                text_point_a:set(13.0, 13.0 + (i * LOGGER_FONT_SCALE))
                text_point_b:set(12.0, 12.0 + (i * LOGGER_FONT_SCALE))
                local label = line.label

                -- line with time-stamp is set, add time-stamp to beginning.
                if LOGGER_LINE_LABEL_TIME then
                    label = string.format("(%.2f) %s", line.time, line.label)
                end

                -- draw back-drop.
                LOGGER_FONT:draw(label, text_point_a, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, line.color * 0.5)
                -- draw line.
                LOGGER_FONT:draw(label, text_point_b, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, line.color)
            end
        end
    end
end

---Create a new logger.
---@return logger value # The logger.
function logger:new()
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type  = "logger"
    i.worker  = ""
    i.buffer  = {}
    i.suggest = {}
    i.history = {}
    i.command = {}
    i.active  = false
    i.scroll  = 0.0

    --[[]]

    i.command["echo"] = logger_command:new("Echo text.", function(self, token)
        if #token > 1.0 then
            local work = ""

            for x = 2, #token do
                work = work .. (x == 2 and "" or " ") .. token[x]
            end

            print(work)
        end
    end
    )

    i.command["find"] = logger_command:new("Find every logger command.", function(self, token)
        local find = token[2]

        if find then
            for name, command in pairs(self.command) do
                if string.start_with(name, find) then
                    self:print(name .. ": " .. command.info)
                end
            end
        else
            for name, command in pairs(self.command) do
                self:print(name .. ": " .. command.info)
            end
        end
    end
    )

    i.command["wipe"] = logger_command:new("Wipe every logger line.", function(self)
        self.buffer = {}
    end
    )

    return i
end

---Draw the logger.
---@param window window # The window for rendering every possible command suggestion.
function logger:draw(window)
    -- toggle key was hit, toggle active state.
    if quiver.input.board.get_press(LOGGER_TOGGLE) then
        self.active = not self.active
    end

    -- if the logger is active...
    if self.active then
        -- logger active state is set, draw main layout.
        logger_draw_main(self, window)
    else
        -- logger active state is not set, draw side layout.
        logger_draw_side(self)
    end
end

---Print a new line to the logger.
---@param line_label  string # Line label.
---@param line_color? color  # OPTIONAL: Line color.
function logger:print(line_label, line_color)
    -- if line color is nil, use default color.
    line_color = line_color and line_color or LOGGER_LINE_COLOR_MESSAGE

    -- insert a new logger line.
    table.insert(self.buffer, logger_line:new(tostring(line_label), line_color))

    -- if logger line count is over the cap...
    if #self.buffer > LOGGER_LINE_CAP then
        -- pop one logger line.
        table.remove(self.buffer, 1)
    end
end

-- ================================================================
-- Window library.
-- ================================================================

local WINDOW_ACTION_ABOVE     = action:new(
    {
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.W),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_FACE_UP),
    }
)
local WINDOW_ACTION_BELOW     = action:new(
    {
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.S),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_FACE_DOWN),
    }
)
local WINDOW_ACTION_FOCUS     = action:new(
    {
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.SPACE),
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.LEFT),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_FACE_DOWN),
    }
)
local WINDOW_ACTION_ALTERNATE = action:new(
    {
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.SPACE),
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.TAB),
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.LEFT),
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.RIGHT),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_FACE_DOWN),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.RIGHT_FACE_UP),
    }
)
local WINDOW_ACTION_LATERAL   = action:new(
    {
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.A),
        action_button:new(INPUT_DEVICE.BOARD, INPUT_BOARD.D),
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.LEFT),
        action_button:new(INPUT_DEVICE.MOUSE, INPUT_MOUSE.RIGHT),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_FACE_LEFT),
        action_button:new(INPUT_DEVICE.PAD, INPUT_PAD.LEFT_FACE_RIGHT),
    }
)
local WINDOW_SHIFT_A          = vector_2:new(6.0, 4.0)
local WINDOW_SHIFT_B          = vector_2:new(8.0, 6.0)
local WINDOW_DOT              = vector_2:new(4.0, 4.0)

---@enum gizmo_flag
GIZMO_FLAG                    = {
    IGNORE_BOARD   = 0x00000001,
    IGNORE_MOUSE   = 0x00000010,
    CLICK_ON_PRESS = 0x00000100,
}

---@class window
---@field index  number
---@field count  number
---@field focus  number | nil
---@field device input_device
window                        = {
    __meta = {}
}

---Draw a glyph.
---@param self        window # The window.
---@param board_label string # Board label.
---@param mouse_label string # Mouse label.
---@param pad_label   string # Pad label.
local function window_glyph(self, board_label, mouse_label, pad_label)
    local x, y = quiver.window.get_render_shape()
    local point = vector_2:old(8.0, y - 40.0)
    local label = board_label

    -- draw border.
    quiver.draw_2d.draw_box_2_border(box_2:old(point.x, point.y, x - 16.0, 32.0), false)

    -- if active device is the mouse...
    if self.device == INPUT_DEVICE.MOUSE then
        -- use mouse label.
        label = mouse_label
        -- if active device is the pad...
    elseif self.device == INPUT_DEVICE.PAD then
        -- use pad label.
        label = pad_label
    end

    -- draw label.
    LOGGER_FONT:draw(label, point + WINDOW_SHIFT_A, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, color:white())
end

---Draw a border.
---@param shape  box_2    # The shape of the border.
---@param hover  boolean  # Mouse focus. Whether or not the mouse cursor is over this gizmo.
---@param index  boolean  # Board focus. Whether or not the board cursor is over this gizmo.
---@param focus  boolean  # Gizmo focus. Whether or not the window focus is on this gizmo.
---@param label? string   # OPTIONAL: Text to draw.
---@param move?  vector_2 # OPTIONAL: Text off-set.
local function window_border(self, shape, hover, index, focus, label, move)
    local shift = focus and vector_2:old(shape.x + WINDOW_SHIFT_B.x, shape.y + WINDOW_SHIFT_B.y) or
        vector_2:old(shape.x + WINDOW_SHIFT_A.x, shape.y + WINDOW_SHIFT_A.y)

    -- if move isn't nil...
    if move then
        -- apply text off-set.
        shift = shift + move
    end

    -- draw border.
    quiver.draw_2d.draw_box_2_border(shape, focus)

    -- if we are not the focus gizmo...
    if not self.focus then
        -- if we have board/pad hover OR mouse hover...
        if index or hover then
            quiver.draw_2d.draw_box_2_dot(shape:old(shape.x + WINDOW_DOT.x, shape.y + WINDOW_DOT.y,
                shape.width - WINDOW_DOT.x * 2.0,
                shape.height - WINDOW_DOT.y * 2.0))
        end
    else
        -- if we have board/pad hover OR we are the focus gizmo...
        if index or focus then
            quiver.draw_2d.draw_box_2_dot(shape:old(shape.x + WINDOW_DOT.x, shape.y + WINDOW_DOT.y,
                shape.width - WINDOW_DOT.x * 2.0,
                shape.height - WINDOW_DOT.y * 2.0))
        end
    end

    -- if label isn't nil...
    if label then
        -- draw text, draw with back-drop.
        LOGGER_FONT:draw(label, shift + vector_2:old(1.0, 1.0), LOGGER_FONT_SCALE, LOGGER_FONT_SPACE,
            color:old(127.0, 127.0, 127.0, 255.0))
        LOGGER_FONT:draw(label, shift, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE, color:old(255.0, 255.0, 255.0, 255.0))
    end
end

---Get the state of a gizmo.
---@param self   window     # The window.
---@param shape  box_2      # The shape of the gizmo.
---@param flag?  gizmo_flag # OPTIONAL: The flag of the gizmo.
---@param input? action     # OPTIONAL: The input of the gizmo. Will override the default focus action for the gizmo.
local function window_state(self, shape, flag, input)
    -- get the mouse position.
    local mouse_x, mouse_y = quiver.input.mouse.get_point()
    local mouse = vector_2:old(mouse_x, mouse_y)

    local check = true

    -- if there is a view-port shape set...
    if self.shape then
        -- check if the gizmo is within it.
        check = collision.box_box(shape, self.shape) and collision.point_box(mouse, self.shape)
    end

    -- mouse interaction check.
    local hover = self.device == INPUT_DEVICE.MOUSE and collision.point_box(mouse, shape) and check
    -- board interaction check.
    local index = self.device ~= INPUT_DEVICE.MOUSE and self.index == self.count
    -- whether or not this gizmo has been set off.
    local click = false
    local which = nil

    -- if flag isn't nil...
    if flag then
        -- gizmo flag set to ignore board/pad input.
        if bit.band(flag, GIZMO_FLAG.IGNORE_BOARD) ~= 0 then
            -- if board/pad is interacting with us...
            if index then
                -- set to false, and scroll away from us, using the last input direction.
                index = false
                self.index = self.index + self.which
            end
        end

        -- gizmo flag set to ignore mouse input.
        if bit.band(flag, GIZMO_FLAG.IGNORE_MOUSE) ~= 0 then
            -- if mouse is interacting with us...
            if hover then
                -- set to false.
                hover = false
            end
        end
    end

    -- if we have any form of interaction with the gizmo...
    if hover or index then
        -- check if the focus button has been set off.
        local hover_click = WINDOW_ACTION_FOCUS:press(self.device)

        -- if input over-ride isn't nil...
        if input then
            -- over-ride the default focus button with the given one.
            hover_click, which = input:press(self.device)
        end

        if hover_click then
            if flag and bit.band(flag, GIZMO_FLAG.CLICK_ON_PRESS) ~= 0 then
                click = true
            else
                -- focus button was set off, set us as the focus gizmo.
                self.focus = self.count
            end
        end
    end

    -- check if we are the focus gizmo.
    local focus = self.focus == self.count

    -- if we are the focus gizmo...
    if focus then
        -- check if the focus button has been set up.
        local focus_click = WINDOW_ACTION_FOCUS:release(self.device)

        -- if input over-ride isn't nil...
        if input then
            -- over-ride the default focus button with the given one.
            focus_click, which = input:release(self.device)
        end

        -- focus button was set up, set off click event, release focus gizmo.
        if focus_click then
            click = true
            self.focus = nil
        end
    end

    -- increase gizmo count.
    self.count = self.count + 1
    self.last = shape.y + shape.height

    if index then
        self.gizmo = shape
    end

    return hover, index, focus, click, which
end

---Create a new window.
---@return window value # The window.
function window:new()
    local i = {}
    setmetatable(i, self.__meta)
    getmetatable(i).__index = self

    --[[]]

    i.__type = "window"
    i.index = 0.0
    i.count = 0.0
    i.point = 0.0
    i.shape = nil
    i.focus = nil
    i.glyph = nil
    i.which = 0.0
    i.shift = false
    i.pick = nil
    i.device = INPUT_DEVICE.MOUSE
    i.gizmo = nil

    return i
end

---Begin the window.
function window:begin()
    self.count = 0.0
end

---Close the window.
---@param lock boolean # If true, will lock user input.
function window:close(lock)
    local above = WINDOW_ACTION_ABOVE:press(self.device)
    local below = WINDOW_ACTION_BELOW:press(self.device)

    -- roll over the value in case it is not hovering over any valid gizmo.
    self.index = math.roll_over(0.0, self.count - 1.0, self.index)

    -- if temporarily locking navigation input or currently focusing a gizmo...
    if self.shift or self.focus or lock then
        -- remove navigation lock.
        self.shift = false

        -- disregard any input.
        return
    end

    -- scroll above.
    if above then
        self.index = self.index - 1.0
        self.which = -1.0
    end

    -- scroll below.
    if below then
        self.index = self.index + 1.0
        self.which = 1.0
    end

    -- get the latest board press.
    local board_check = quiver.input.board.get_key_code_queue() > 0.0
    local mouse_check = quiver.input.mouse.get_press(INPUT_MOUSE.LEFT)
    local pad_check = quiver.input.pad.get_queue() > 0.0

    -- a board or pad button was set off...
    if board_check or pad_check then
        -- set the active device as either board, or pad.
        self:set_device(board_check and INPUT_DEVICE.BOARD or INPUT_DEVICE.PAD)
    end

    -- a mouse button was set off...
    if mouse_check then
        self:set_device(INPUT_DEVICE.MOUSE)
    end
end

function window:set_device(device)
    if device == INPUT_DEVICE.BOARD or device == INPUT_DEVICE.PAD then
        if not quiver.input.mouse.get_hidden() then
            -- if mouse wasn't hidden, disable.
            quiver.input.mouse.set_active(false)
        end
    else
        if quiver.input.mouse.get_hidden() then
            -- if mouse was hidden, enable.
            quiver.input.mouse.set_active(true)
        end

        -- reset index.
        self.index = 0.0
    end

    -- set the active device.
    self.device = device
end

local function window_check_draw(self, shape)
    if self.shape then
        return collision.box_box(self.shape, shape)
    end

    return true
end

---Draw a text gizmo.
---@param point  box_2  # The point of the gizmo.
---@param label  string # The label of the gizmo.
---@param font   string # The font of the gizmo.
---@param scale  number # The text scale of the gizmo.
---@param space  number # The text space of the gizmo.
---@param color  number # The text color of the gizmo.
---@return boolean click # True on click, false otherwise.
function window:text(point, label, font, scale, space, color, call_back, call_data)
    -- scroll.
    point.y = point.y + self.point

    if window_check_draw(self, box_2:old(point.x, point.y, 1.0, scale)) then
        font:draw(label, point, scale, space, color)
    end
end

---Draw a button gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return boolean click # True on click, false otherwise.
function window:button(shape, label, flag, call_back, call_data)
    -- scroll.
    shape.y = shape.y + self.point

    -- get the state of this gizmo.
    local hover, index, focus, click = window_state(self, shape, flag)

    if window_check_draw(self, shape) then
        if call_back then
            call_back(call_data, self, shape, hover, index, focus, click, label)
        else
            -- draw a border.
            window_border(self, shape, hover, index, focus, label)
        end
    end

    -- return true on click.
    return click
end

---Draw a toggle gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param value number     # The value of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return number  value # The value.
---@return boolean click # True on click, false otherwise.
function window:toggle(shape, label, value, flag, call_back, call_data)
    -- scroll.
    shape.y = shape.y + self.point

    -- get the state of this gizmo.
    local hover, index, focus, click = window_state(self, shape, flag)

    -- toggle value on click.
    if click then
        value = not value
    end

    if window_check_draw(self, shape) then
        if call_back then
            call_back(call_data, self, shape, hover, index, focus, label, value)
        else
            -- draw a border, with a text off-set.
            window_border(self, shape, hover, index, focus, label, vector_2:old(shape.width, 0.0))

            -- if value is set on, draw a small box to indicate so.
            if value then
                quiver.draw_2d.draw_box_2_border(
                    box_2:old(shape.x + 6.0, shape.y + 6.0, shape.width - 12.0, shape.height - 12.0), false,
                    BORDER_COLOR_D)
            end
        end
    end

    -- return value, and click.
    return value, click
end

---Draw a slider gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param value number     # The value of the gizmo.
---@param min   number     # The minimum value of the gizmo.
---@param max   number     # The minimum value of the gizmo.
---@param step  number     # The step size of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return number  value # The value.
---@return boolean click # True on click, false otherwise.
function window:slider(shape, label, value, min, max, step, flag, call_back, call_data)
    -- scroll.
    shape.y = shape.y + self.point

    -- click on press flag is incompatible with this gizmo, remove if present.
    if flag then
        flag = bit.band(flag, bit.bnot(GIZMO_FLAG.CLICK_ON_PRESS))
    end

    -- get the state of this gizmo.
    local hover, index, focus, click, which = window_state(self, shape, flag, WINDOW_ACTION_LATERAL)

    -- special preference for the mouse.
    if self.device == INPUT_DEVICE.MOUSE then
        -- if gizmo is in focus...
        if focus then
            -- get mouse position (X).
            local mouse_x = quiver.input.mouse.get_point()

            -- calculate value.
            local result = math.percentage_from_value(shape.x + 6.0, shape.x + 6.0 + shape.width - 12.0, mouse_x)
            result = math.clamp(0.0, 1.0, result)
            result = math.value_from_percentage(min, max, result)
            result = math.snap(step, result)
            value = result
        end
    else
        -- if there has been input at all...
        if which then
            -- get the actual button.
            which = WINDOW_ACTION_LATERAL.list[which]

            if which.button == INPUT_BOARD.A or which == INPUT_PAD.LEFT_FACE_LEFT then
                -- decrease value.
                value = value - step
            else
                -- increase value.
                value = value + step
            end

            -- clamp.
            value = math.clamp(min, max, value)
        end
    end

    if window_check_draw(self, shape) then
        -- get the percentage of the value within the minimum/maximum range.
        local percentage = math.percentage_from_value(min, max, value)

        if call_back then
            call_back(call_data, self, shape, hover, index, focus, label, value, percentage)
        else
            -- draw a border, with a text off-set.
            window_border(self, shape, hover, index, focus, label, vector_2:old(shape.width, 0.0),
                function() window_glyph(self, "board", "mouse", "pad") end)

            -- if percentage is above 0.0...
            if percentage > 0.0 then
                quiver.draw_2d.draw_box_2_border(
                    box_2:old(shape.x + 6.0, shape.y + 6.0, (shape.width - 12.0) * percentage, shape.height - 12.0),
                    false,
                    BORDER_COLOR_D)
            end

            -- measure text.
            local measure = LOGGER_FONT:measure_text(value, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE)

            -- draw value.
            LOGGER_FONT:draw(value, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 4.0),
                LOGGER_FONT_SCALE,
                LOGGER_FONT_SPACE,
                color:white())
        end
    end

    -- return value, and click.
    return value, click
end

---Draw a switch gizmo.
---@param shape box_2      # The shape of the gizmo.
---@param label string     # The label of the gizmo.
---@param value number     # The value of the gizmo.
---@param pool  table      # The value pool of the gizmo.
---@param flag? gizmo_flag # OPTIONAL: The flag of the gizmo.
---@return number  value # The value.
---@return boolean click # True on click, false otherwise.
function window:switch(shape, label, value, pool, flag, call_back, call_data)
    -- scroll.
    shape.y = shape.y + self.point

    -- get the state of this gizmo.
    local hover, index, focus, click, which = window_state(self, shape, flag, WINDOW_ACTION_LATERAL)

    local value_a = nil
    local value_b = nil
    local value_label = "N/A"

    value_label = pool[value]

    -- if there's an entry below us...
    if pool[value - 1] then
        value_a = value - 1
    end

    -- if there's an entry below us...
    if pool[value + 1] then
        value_b = value + 1
    end

    -- if there has been input at all...
    if which then
        -- get the actual button.
        which = WINDOW_ACTION_LATERAL.list[which]

        if which.button == INPUT_BOARD.A or which.button == INPUT_MOUSE.LEFT or which.button == INPUT_PAD.LEFT_FACE_LEFT then
            -- if below value is valid...
            if value_a then
                -- decrease value.
                value = value_a
            end
        else
            -- if above value is valid...
            if value_b then
                -- increase value.
                value = value_b
            end
        end
    end

    if window_check_draw(self, shape) then
        if call_back then
            call_back(call_data, self, shape, hover, index, focus, label, value_label)
        else
            -- draw a border, with a text off-set.
            window_border(self, shape, hover, index, focus, label, vector_2:old(shape.width, 0.0))

            -- measure text.
            local measure = LOGGER_FONT:measure_text(value_label, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE)

            -- draw value.
            LOGGER_FONT:draw(value_label, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 4.0),
                LOGGER_FONT_SCALE,
                LOGGER_FONT_SPACE,
                color:white())
        end
    end

    -- return value, and click.
    return value, click
end

---Draw an action gizmo.
---@param shape   box_2      # The shape of the gizmo.
---@param label   string     # The label of the gizmo.
---@param value   action     # The value of the gizmo.
---@param clamp?  number     # OPTIONAL: The maximum button count for the action. If nil, do not clamp.
---@param flag?   gizmo_flag # The flag of the gizmo.
---@return boolean click # True on click, false otherwise.
function window:action(shape, label, value, clamp, flag, call_back, call_data)
    -- scroll.
    shape.y = shape.y + self.point

    local pick = false

    -- if pick gizmo is not nil...
    if self.pick then
        -- check if we are the pick gizmo.
        pick = self.pick == self.count
    end

    -- if we are the pick gizmo...
    if pick then
        -- get every button press in the queue.
        local board_queue = quiver.input.board.get_key_code_queue()
        local mouse_queue = quiver.input.mouse.get_queue()

        -- if a button was set off...
        if board_queue > 0.0 or mouse_queue then
            if clamp then
                if #value.list >= clamp then
                    -- remove every button for this action.
                    value.list = {}
                end
            end

            -- if button came from the board, attach board action.
            if board_queue > 0.0 then
                value:attach(action_button:new(INPUT_DEVICE.BOARD, board_queue))
            end

            -- if button came from the mouse, attach mouse action.
            if mouse_queue then
                value:attach(action_button:new(INPUT_DEVICE.MOUSE, mouse_queue))
            end

            -- remove us from the focus gizmo, lock navigation, and remove us from the pick gizmo.
            self.focus = nil
            self.shift = true
            self.pick = nil
        end
    end

    local action = pick and action:new({}) or WINDOW_ACTION_ALTERNATE

    -- get the state of this gizmo.
    local hover, index, focus, click, which = window_state(self, shape, flag, action)

    -- if there has been input at all...
    if which then
        -- get the actual button.
        which = WINDOW_ACTION_ALTERNATE.list[which]

        if which.button == INPUT_BOARD.SPACE or which.button == INPUT_MOUSE.LEFT or which.button == INPUT_PAD.LEFT_FACE_DOWN then
            -- make us the focus/pick gizmo
            self.focus = self.count - 1.0
            self.pick = self.count - 1.0
        else
            -- remove every button for this action.
            value.list = {}
        end
    end

    if window_check_draw(self, shape) then
        if call_back then
            call_back(call_data, self, shape, hover, index, focus, label, value)
        else
            -- draw a border.
            window_border(self, shape, hover, index, focus, label, vector_2:old(shape.width, 0.0))

            local label = #value.list > 0.0 and "" or "N/A"

            -- for every button in the action's list...
            for i, button in ipairs(value.list) do
                -- concatenate the button's name.
                label = label .. (i > 1.0 and "/" or "")
                    .. button:name()
            end

            -- measure text.
            local measure = LOGGER_FONT:measure_text(label, LOGGER_FONT_SCALE, LOGGER_FONT_SPACE)

            -- draw value.
            LOGGER_FONT:draw(label, vector_2:old(shape.x + (shape.width * 0.5) - (measure * 0.5), shape.y + 4.0),
                LOGGER_FONT_SCALE,
                LOGGER_FONT_SPACE,
                color:white())
        end
    end

    return click
end

---Draw an action gizmo.
---@param shape   box_2      # The shape of the gizmo.
---@param label   string     # The label of the gizmo.
---@param value   action     # The value of the gizmo.
---@param clamp?  number     # OPTIONAL: The maximum button count for the action. If nil, do not clamp.
---@param flag?   gizmo_flag # The flag of the gizmo.
---@return boolean click # True on click, false otherwise.
function window:entry(shape, label, value, flag)
    -- scroll.
    shape.y = shape.y + self.point

    local pick = false

    -- if pick gizmo is not nil...
    if self.pick then
        -- check if we are the pick gizmo.
        pick = self.pick == self.count
    end

    -- if we are the pick gizmo...
    if pick then
        -- get every button press in the queue.
        local board_queue = quiver.input.board.get_uni_code_queue()

        -- if a button was set off...
        if board_queue > 0.0 then
            value = value .. string.char(board_queue)
        end

        if quiver.input.board.get_press(INPUT_BOARD.RETURN) then
            -- remove us from the focus gizmo, lock navigation, and remove us from the pick gizmo.
            self.focus = nil
            self.shift = true
            self.pick = nil
        elseif quiver.input.board.get_press(INPUT_BOARD.BACKSPACE) then
            -- pop the last character of the working buffer.
            value = string.sub(value, 0, #value - 1)
        end
    end

    local action = pick and action:new({}) or WINDOW_ACTION_FOCUS

    -- get the state of this gizmo.
    local hover, index, focus, click, which = window_state(self, shape, flag, action)

    -- if there has been input at all...
    if which then
        self.focus = self.count - 1.0
        self.pick = self.count - 1.0
    end

    -- draw a border.
    window_border(self, shape, hover, index, focus, label, vector_2:old(shape.width, 0.0))

    -- draw value.
    LOGGER_FONT:draw(value, vector_2:old(shape.x + 4.0, shape.y + 4.0),
        LOGGER_FONT_SCALE,
        LOGGER_FONT_SPACE,
        color:white())

    return value
end

---Draw a scroll gizmo.
---@param shape box_2    # The shape of the gizmo.
---@param value number   # The value of the gizmo.
---@param last  number   # The value of the gizmo.
---@param call  function # The draw function.
function window:scroll(shape, value, last, call, call_back, call_data)
    if call_back then
        call_back(call_data, self, shape, value, last)
    end

    local view_size = math.min(0.0, shape.height - last)
    self.point = view_size * value
    self.shape = shape
    self.last = 0.0

    local begin = self.count

    quiver.draw.begin_scissor(call, shape)

    local close = self.count

    last = (self.last - shape.y) - self.point

    self.point = 0.0
    self.shape = nil
    self.last = 0.0

    if self.gizmo then
        if self.index >= begin and self.index <= close then
            if self.gizmo.y < shape.y then
                local subtract = shape.y - self.gizmo.y

                value = math.clamp(0.0, 1.0, value + (subtract / view_size))
            end

            if self.gizmo.y + self.gizmo.height > shape.y + shape.height then
                local subtract = (self.gizmo.y + self.gizmo.height) - (shape.y + shape.height)

                value = math.clamp(0.0, 1.0, value - (subtract / view_size))
            end
        else
            if self.index < begin then value = 0.0 end
            if self.index > close then value = 1.0 end
        end
    end

    self.gizmo = nil

    local mouse = vector_2:old(quiver.input.mouse.get_point())
    local delta = vector_2:old(quiver.input.mouse.get_wheel())

    if collision.point_box(mouse, shape) then
        value = math.clamp(0.0, 1.0, value - delta.y * 0.05)
    end

    return value, last
end

-- ================================================================
-- A* path-finder library.
-- ================================================================

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

-- ================================================================
-- Collision library.
-- ================================================================

collision = {}

---Check if a point and a box are colliding.
---@param  point   vector_2  # Point to check.
---@param  box     box_2     # Box to check.
---@return boolean collision # True if colliding, false otherwise.
function collision.point_box(point, box)
    return (point.x >= box.x) and (point.x < (box.x + box.width)) and (point.y >= box.y) and
        (point.y < (box.y + box.height))
end

---Check if a box and a box are colliding.
---@param  box_a box_2 # Box A to check.
---@param  box_b box_2 # Box B to check.
---@return boolean collision # True if colliding, false otherwise.
function collision.box_box(box_a, box_b)
    return (box_a.x < (box_b.x + box_b.width) and (box_a.x + box_a.width) > box_b.x) and
        (box_a.y < (box_b.y + box_b.height) and (box_a.y + box_a.height) > box_b.y)
end

-- ================================================================
-- Miscellaneous.
-- ================================================================

---Reset every table pool index to 1. This should usually be done before beginning to draw, or when running a simulation tick.
function table_pool:clear()
    vector_2_pool:begin()
    vector_3_pool:begin()
    vector_4_pool:begin()
    color_pool:begin()
    box_2_pool:begin()
    box_3_pool:begin()
    camera_2d_pool:begin()
    camera_3d_pool:begin()
end

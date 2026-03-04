local w, r = io.write, io.read
local t, c = setmetatable({ 0 }, {
    __index = function(t, k)
        return 0
    end,

    __newindex = function(t, k, v)
        rawset(t, k, v % 256)
    end
}), 1

local loops = {}

local instructions

instructions = setmetatable({
    ["+"] = function()
        t[c] = t[c] + 1
    end,

    ["-"] = function()
        t[c] = t[c] - 1
    end,

    ["<"] = function()
        c = (c - 1) % 30000
    end,

    [">"] = function()
        c = c + 1
    end,

    ["."] = function()
        w(string.char(t[c]))
    end,

    [","] = function()
        t[c] = string.byte(r(1) or 0) or 0;
    end,

    ["["] = function(i)
        if t[c] == 0 then
            return loops[i]
        end
    end,

    ["]"] = function(i)
        if t[c] ~= 0 then
            return loops[i]
        end
    end,
}, {
    __index = function()
        return function() end -- teehee cheap solutions
    end
})

-- Overview
w("BRAINF*** INTERPRETER\n(Press enter to continue)\n")
r();
w("    There are eight commands:\n")
r();
w("+ : Increments the value at the current cell by one.\n")
r();
w("- : Decrements the value at the current cell by one.\n")
r();
w("> : Moves the data pointer to the next cell (cell on the right).\n")
r();
w("< : Moves the data pointer to the previous cell (cell on the left).\n")
r();
w(". : Prints the ASCII value at the current cell (i.e. 65 = 'A').\n")
r();
w(", : Reads a single input character into the current cell.\n")
r();
w("[ : If the value at the current cell is zero, skips to the corresponding ] .\n")
r();
w("    Otherwise, move to the next instruction.\n")
r();
w("] : If the value at the current cell is zero, move to the next instruction.\n")
r();
w("    Otherwise, move backwards in the instructions to the corresponding [ .\n")
r();
w("    Remember, the keyboard interrupt is CTRL + C\n\n")
r();
-- (Courtesy of learnxinyminutes.com, bc I'm lazy)

local function run()
    -- Initial prompt
    w("\nEnter your code below:\n")

    local s = r()
    local loop_stack = {}

    loops = {}
    c = 1
    t = setmetatable({}, getmetatable(t))

    if not s then
        return
    end

    for i = 1, #s do
        local char = s:sub(i, i)

        if char == "[" then
            table.insert(loop_stack, i)
        elseif char == "]" then
            local n = table.remove(loop_stack) -- handy

            if n == nil then
                error("Lonely ']' :(")
            end

            loops[n] = i
            loops[i] = n
        end
    end

    if #loop_stack > 0 then
        error("Lonely '[' :(")
    end

    local i = 1
    while i <= #s do
        local char = s:sub(i, i)
        -- THESE BRACKETS
        local jump = instructions[char](i)

        if jump then
            i = jump + 1
        else
            i = i + 1
        end
    end

    -- New prompt
    w("\n========================\n")
end

while true do
    run()
end

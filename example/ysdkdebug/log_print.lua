local utf8 = require("example.ysdkdebug.utf8")
local rxi_json = require("yagames.helpers.json")

local M = {}

M.log = ""
M.log_dirty = true

local function into_chunks(text, size)
    local s = {}
    for i = 1, utf8.len(text), size do
        s[#s + 1] = utf8.sub(text, i, i + size - 1)
    end
    return s
end

function M.print(...)
    local arg = {...}
    local t = ""
    for _, v in pairs(arg) do
        t = t .. tostring(v) .. " "
    end
    print(t)
    if html5 and not sys.get_engine_info().is_debug then
        html5.run("console.log(" .. rxi_json.encode(t) .. ")")
    end

    local chunks = into_chunks(t, 79)
    local s = table.concat(chunks, "\n           ")

    M.log = "[" .. os.date("%H:%M:%S") .. "] " .. s .. "\n" .. M.log
    M.log_dirty = true
end

function M.clear_log()
    M.log = ""
    M.log_dirty = true
end

return M

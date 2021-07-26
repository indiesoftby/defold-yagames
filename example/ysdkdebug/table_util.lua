local M = {}

function M.val_to_str(v)
    if "string" == type(v) then
        v = string.gsub(v, "\n", "\\n")
        if string.match(string.gsub(v, "[^'\"]", ""), '^"+$') then
            return "'" .. v .. "'"
        end
        return '"' .. string.gsub(v, '"', '\\"') .. '"'
    else
        return "table" == type(v) and M.tostring(v) or tostring(v)
    end
end

function M.key_to_str(k)
    if "string" == type(k) and string.match(k, "^[_%a][_%a%d]*$") then
        return k
    else
        return "[" .. M.val_to_str(k) .. "]"
    end
end

function M.tostring(tbl)
    if "table" ~= type(tbl) then return tostring(tbl) end
    local result, done = {}, {}
    for k, v in ipairs(tbl) do
        table.insert(result, M.val_to_str(v))
        done[k] = true
    end
    for k, v in pairs(tbl) do
        if not done[k] then
            table.insert(result, M.key_to_str(k) .. "=" .. M.val_to_str(v))
        end
    end
    return "{" .. table.concat(result, ",") .. "}"
end

return M

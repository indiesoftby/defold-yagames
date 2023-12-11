local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.flags_get_handler(self)
    local options = { defaultFlags = { test1 = "A" } } -- also, it can be `nil`
    yagames.flags_get(options, function(self, err, result)
        print("yagames.flags_get(" .. table_util.tostring(options) .. "):", err or table_util.tostring(result))
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_config_flags_get", M.flags_get_handler)
end

return M

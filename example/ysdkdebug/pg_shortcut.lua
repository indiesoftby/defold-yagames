local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.can_show_prompt_handler(self)
    yagames.shortcut_can_show_prompt(function(self, err, result)
        print("yagames.shortcut_can_show_prompt():", err or table_util.tostring(result))
    end)
end

function M.show_prompt_handler(self)
    yagames.shortcut_show_prompt(function(self, err, result)
        print("yagames.shortcut_show_prompt():", err or table_util.tostring(result))
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_shortcut_can_show_prompt", M.can_show_prompt_handler)
    druid_style.make_button(self, "button_shortcut_show_prompt", M.show_prompt_handler)
end

return M

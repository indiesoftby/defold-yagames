local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.handler(self)
    yagames.auth_open_auth_dialog(function(self, err)
        print("yagames.auth_open_auth_dialog:", err or "OK!")
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_auth_open", M.handler)
end

return M

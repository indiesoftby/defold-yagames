local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.status_handler(self)
    print("yagames.screen_fullscreen_status:", table_util.tostring(yagames.screen_fullscreen_status()))
end

function M.request_handler(self)
    yagames.screen_fullscreen_request(function(self, err)
        print("yagames.screen_fullscreen_request:", err or "OK")
    end)
end

function M.exit_handler(self)
    yagames.screen_fullscreen_exit(function(self, err)
        print("yagames.screen_fullscreen_exit:", err or "OK")
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_screen_fullscreen_status", M.status_handler)
    druid_style.make_button(self, "button_screen_fullscreen_request", M.request_handler)
    druid_style.make_button(self, "button_screen_fullscreen_exit", M.exit_handler)
end

return M

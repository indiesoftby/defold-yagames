local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local rxi_json = require("yagames.helpers.json")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.init_handler(self, err)
    print("yagames.leaderboards_init:", err or "OK")

    if not err then
        -- self.button_banner_create:set_enabled(true)
    end
end

function M.init(self)
    self.button_leaderboards_init = druid_style.button_with_text(self, "button_leaderboards_init/body",
        "button_leaderboards_init/text", M.init_handler)
end

return M

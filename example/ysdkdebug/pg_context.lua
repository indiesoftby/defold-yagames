local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

local rtb_id = "R-A-123456-1"

function M.init_handler(self)
    self.button_context_create:set_enabled(true)
    self.button_context_refresh:set_enabled(true)
    self.button_context_destroy:set_enabled(true)
end

function M.create_handler(self)
    yagames.context_create_banner(rtb_id, {
        css_styles = "width: 300px; height: 250px; position: absolute;"
    }, function (self, err)
        print("Banner created", err)
    end)
end

function M.refresh_handler(self)
    yagames.context_refresh_banner(rtb_id, function (self, err)
        print("Banner refreshed", err)
    end)
end

function M.destroy_handler(self)
    yagames.context_destroy_banner(rtb_id)
end

function M.init(self)
    self.button_context_create = druid_style.button_with_text(self, "button_context_create/body",
        "button_context_create/text", M.create_handler, true)
    self.button_context_refresh = druid_style.button_with_text(self, "button_context_refresh/body",
        "button_context_refresh/text", M.refresh_handler, true)
    self.button_context_destroy = druid_style.button_with_text(self, "button_context_destroy/body",
        "button_context_destroy/text", M.destroy_handler, true)
        
    yagames.context_init(M.init_handler)
end

return M

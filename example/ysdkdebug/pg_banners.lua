local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

local rtb_id = "R-A-663806-4"
local display_status = "block"

function M.init_handler(self, err)
    print("yagames.banner_init:", err or "OK")

    if not err then
        self.button_banner_create:set_enabled(true)
        self.button_banner_refresh:set_enabled(true)
        self.button_banner_destroy:set_enabled(true)
        self.button_banner_toggle:set_enabled(true)
    end
end

function M.create_handler(self)
    yagames.banner_create(rtb_id, {
        css_styles = "position: absolute; width: 336px; height: 280px; position: absolute; top: 100vh; margin-top: -350px; background: #d2d2d2; left: 50vw; margin-left: -168px;"
    }, function(self, err, data)
        print("yagames.banner_create:", err or table_util.tostring(data))
    end)
end

function M.refresh_handler(self)
    yagames.banner_refresh(rtb_id, function(self, err, data)
        print("yagames.banner_refresh:", err or table_util.tostring(data))
    end)
end

function M.destroy_handler(self)
    yagames.banner_destroy(rtb_id)
    print("yagames.banner_destroy")
end

function M.toggle_handler(self)
    if display_status == "block" then
        display_status = "none"
    else
        display_status = "block"
    end

    yagames.banner_set(rtb_id, "display", display_status)
    print("yagames.banner_set:", "display", display_status)
end

function M.init(self)
    druid_style.make_button(self, "button_banner_create", M.create_handler, true)
    druid_style.make_button(self, "button_banner_refresh", M.refresh_handler, true)
    druid_style.make_button(self, "button_banner_destroy", M.destroy_handler, true)
    druid_style.make_button(self, "button_banner_toggle", M.toggle_handler, true)

    yagames.banner_init(M.init_handler)
end

return M

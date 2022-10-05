local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.show_fullscreen_adv(self)
    yagames.adv_show_fullscreen_adv({
        open = function(self)
            print("yagames.adv_show_fullscreen_adv: 'open' event.")
        end,
        close = function(self, was_shown)
            print("yagames.adv_show_fullscreen_adv: 'close' event. Was shown:", was_shown)
        end,
        offline = function(self)
            print("yagames.adv_show_fullscreen_adv: 'offline' event.")
        end,
        error = function(self, err)
            print("yagames.adv_show_fullscreen_adv error:", err)
        end
    })
end

function M.show_rewarded_video(self)
    yagames.adv_show_rewarded_video({
        open = function(self)
            print("yagames.adv_show_rewarded_video: 'open' event.")
        end,
        rewarded = function(self)
            print("yagames.adv_show_rewarded_video: 'rewarded' event.")
        end,
        close = function(self)
            print("yagames.adv_show_rewarded_video: 'close' event.")
        end,
        error = function(self, err)
            print("yagames.adv_show_rewarded_video error", err)
        end
    })
end

function M.adv_get_banner_adv_status(self)
    yagames.adv_get_banner_adv_status(function(self, err, result)
        print("yagames.adv_get_banner_adv_status:", err or table_util.tostring(result))
    end)
end

function M.adv_show_banner_adv(self)
    yagames.adv_show_banner_adv(function(self, err, result)
        print("yagames.adv_show_banner_adv:", err or table_util.tostring(result))
    end)
end

function M.adv_hide_banner_adv(self)
    yagames.adv_hide_banner_adv(function(self, err, result)
        print("yagames.adv_hide_banner_adv:", err or table_util.tostring(result))
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_show_fullscreen_adv", M.show_fullscreen_adv)
    druid_style.make_button(self, "button_show_rewarded_video", M.show_rewarded_video)
    druid_style.make_button(self, "button_adv_get_banner_adv_status", M.adv_get_banner_adv_status)
    druid_style.make_button(self, "button_adv_show_banner_adv", M.adv_show_banner_adv)
    druid_style.make_button(self, "button_adv_hide_banner_adv", M.adv_hide_banner_adv)
end

return M

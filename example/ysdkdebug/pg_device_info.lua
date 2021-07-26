local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.init(self)
    local is_desktop = gui.get_node("text_is_desktop")
    local is_mobile = gui.get_node("text_is_mobile")
    local is_tablet = gui.get_node("text_is_tablet")

    local alpha1 = vmath.vector4(0, 0, 0, 1)
    local alpha2 = vmath.vector4(0, 0, 0, 0.25)

    gui.set_color(is_desktop, yagames.device_info_is_desktop() and alpha1 or alpha2)
    gui.set_color(is_mobile, yagames.device_info_is_mobile() and alpha1 or alpha2)
    gui.set_color(is_tablet, yagames.device_info_is_tablet() and alpha1 or alpha2)

    print("yagames.device_info_type():", yagames.device_info_type())
end

return M

local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.init(self)
    print("Initialized!")
end

function M.add_rtb_block(self)

end

function M.render_rtb_block(self)

end

function M.init(self)
    self.button_add_rtb_block = druid_style.button_with_text(self, "button_add_rtb_block/body",
                                                             "button_add_rtb_block/text", M.add_rtb_block)
    self.button_render_rtb_block = druid_style.button_with_text(self, "button_render_rtb_block/body",
                                                                "button_render_rtb_block/text", M.render_rtb_block)

                                                                yagames.context_init(M.init)
end

return M

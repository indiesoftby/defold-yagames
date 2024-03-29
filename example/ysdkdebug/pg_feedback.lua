local druid = require("druid.druid")
local druid_style = require("example.ysdkdebug.druid_style")
local table_util = require("example.ysdkdebug.table_util")

local yagames = require("yagames.yagames")

local log_print = require("example.ysdkdebug.log_print")
local print = log_print.print

local M = {}

function M.can_review_handler(self)
    yagames.feedback_can_review(function(self, err, result)
        print("yagames.feedback_can_review:", err or table_util.tostring(result))
    end)
end

function M.request_review_handler(self)
    yagames.feedback_request_review(function(self, err, result)
        print("yagames.feedback_request_review:", err or table_util.tostring(result))
    end)
end

function M.init(self)
    druid_style.make_button(self, "button_feedback_can_review", M.can_review_handler)
    druid_style.make_button(self, "button_feedback_request_review", M.request_review_handler)
end

return M
